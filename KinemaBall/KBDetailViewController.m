//
//  KBDetailViewController.m
//  KinemaBall
//
//  Created by Konrad Roj on 23.11.2015.
//  Copyright © 2015 Konrad Roj. All rights reserved.
//

#import "KBDetailViewController.h"
#import "BallPosition.h"
#import "KBDetailPresenter.h"
#import "KBOpenCVViewController.h"

typedef enum : NSUInteger {
    ChartTypeXTime,
    ChartTypeYTime,
    ChartTypeVTime,
    ChartTypeATime,
    ChartTypeEKTime,
    ChartTypeEPTime
} ChartType;

@interface KBDetailViewController () <CPTBarPlotDataSource, CPTScatterPlotDataSource>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *videoView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UIView *controlView;
@property (weak, nonatomic) IBOutlet CPTGraphHostingView *graphView;
@property (weak, nonatomic) IBOutlet UIButton *chartButton;
@property (strong, nonatomic) CPTXYGraph *graph;

@property (assign, nonatomic) BOOL currentVideo;
@property (assign, nonatomic) BOOL animating;
@property (assign, nonatomic) CGFloat speed;
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) NSUInteger counter;
@property (assign, nonatomic) NSUInteger currentIndex;

@property (strong, nonatomic) NSArray *dataForPlot;
@property (strong, nonatomic) NSArray *indexList;

@property (strong, nonatomic) NSDate *pauseStart;
@property (strong, nonatomic) NSDate *previousFireDate;

@property (assign, nonatomic) ChartType chartType;
@property (strong, nonatomic) KBDetailPresenter *presenter;
@end

@implementation KBDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Detail", nil);
    
    [self.indicator startAnimating];
    
    self.videoView.contentMode = UIViewContentModeScaleAspectFit;
    self.videoView.backgroundColor = [UIColor blackColor];
    self.videoView.layer.borderWidth = 3.0f;
    self.videoView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.videoViewHeightConstraint.constant = 150.0f;
    [self.view layoutIfNeeded];
    
    self.chartButton.hidden = YES;
    [self.chartButton setTitle:NSLocalizedString(@"Velocity - Time", nil) forState:UIControlStateNormal];
    self.chartType = ChartTypeVTime;
    
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count == 4) {
        [self.navigationController setViewControllers:@[viewControllers.firstObject, viewControllers.lastObject]];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forcePauseAnimatingVideo) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [self setup];
}

- (void)setup {
    NSOperationQueue *myQueue = [[NSOperationQueue alloc] init];
    [myQueue addOperationWithBlock:^{
        self.presenter = [[KBDetailPresenter alloc] initWithDate:self.date];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self setupGestures];
            
            self.speed = 1.0f;
            [self animateImages:self.presenter.images withSpeed:self.speed];
            self.currentVideo = 0;
            self.animating = 1;
            [self.indicator stopAnimating];
            
            NSArray *tuple = [self.presenter generateVelocityWithMaxValue:YES];
            self.dataForPlot = [tuple firstObject];
            self.indexList = [tuple lastObject];
            
            [self constructScatterPlot];
            self.chartButton.hidden = NO;
        }];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.timer = nil;
}

#pragma mark ------------------------------------
#pragma mark Gesture Control Methods
#pragma mark ------------------------------------

- (void)swipeLeft:(UISwipeGestureRecognizer *)sender {
    if (self.speed > 0.1f) {
        self.speed -= 0.1f;
        [self updateAnimationSpeed];
    }
}

- (void)swipeRight:(UISwipeGestureRecognizer *)sender {
    if (self.speed < 1.0f) {
        self.speed += 0.1f;
        [self updateAnimationSpeed];
    }
}

- (void)stopAnimatingVideo:(UITapGestureRecognizer *)sender {
    if (self.animating) {
        [self pauseLayer:self.videoView.layer];
        self.animating = NO;
    } else {
        [self resumeLayer:self.videoView.layer];
        self.animating = YES;
    }
}

- (void)forcePauseAnimatingVideo {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.animating = YES;
        [self pauseLayer:self.videoView.layer];
    });
}

- (void)pauseLayer:(CALayer *)layer {
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
    self.animating = NO;
    
    [self pauseTimer];
}

- (void)resumeLayer:(CALayer *)layer {
    CFTimeInterval pausedTime = [layer timeOffset];
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    layer.beginTime = timeSincePause;
    self.animating = YES;
    
    [self resumeTimer];
}

- (void)changeVideo:(UITapGestureRecognizer *)sender {
    if (self.currentVideo) {
        [self.videoView stopAnimating];
        [self animateImages:self.presenter.images withSpeed:self.speed];
        self.currentVideo = 0;
    } else {
        [self.videoView stopAnimating];
        [self animateImages:self.presenter.grayImages withSpeed:self.speed];
        self.currentVideo = 1;
    }
}

- (void)animateImages:(NSArray *)images withSpeed:(CGFloat)speed {
    NSInteger animationImageCount = self.presenter.images.count;
    self.videoView.animationImages = images;
    self.videoView.animationDuration = ( animationImageCount / [self.presenter.measurement.fps integerValue] ) / speed;
    self.videoView.animationRepeatCount = 0;
    
    [self resetTimer];
    [self.videoView startAnimating];
}

- (void)updateAnimationSpeed {
    [self.videoView stopAnimating];
    self.videoView.animationDuration = ( self.presenter.images.count / [self.presenter.measurement.fps integerValue] ) / self.speed;
    
    [self resetTimer];
    [self.videoView startAnimating];
}

- (void)resetTimer {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.counter = 0;
        self.currentIndex = 0;
        
        [self.timer invalidate];
        self.timer = nil;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:self.videoView.animationDuration/self.presenter.images.count target:self selector:@selector(increaseTimeCounter) userInfo:nil repeats:YES];
    });
}

- (void)increaseTimeCounter {
    self.counter++;
    if (self.counter > self.presenter.images.count) {
        self.counter = 0;
        self.currentIndex = 0;
    }
    
    if (self.counter < self.indexList.count && [self.indexList[self.counter] isEqual:@1] && self.animating)  {
        self.currentIndex++;
    }
    
    [self updateScatterPlotWithIndex:self.counter];
}

#pragma mark ------------------------------------
#pragma mark Gesture Methods
#pragma mark ------------------------------------

- (void)setupGestures {
    [self.videoView setUserInteractionEnabled:YES];
    UITapGestureRecognizer *doubleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeVideo:)];
    [doubleTap setNumberOfTapsRequired:2];
    [self.videoView addGestureRecognizer:doubleTap];
    
    UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(stopAnimatingVideo:)];
    [singleTap setNumberOfTapsRequired:1];
    [self.videoView addGestureRecognizer:singleTap];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.videoView addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.videoView addGestureRecognizer:swipeRight];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.controlView addGestureRecognizer:panGesture];
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    CGPoint currentlocation = [recognizer locationInView:self.view];
    
    if (currentlocation.y > 40 && currentlocation.y < self.view.frame.size.height - 40) {
        CGPoint translation = [recognizer translationInView:self.controlView];
        recognizer.view.center = CGPointMake(self.view.center.x, recognizer.view.center.y + translation.y);
        
        if (recognizer.state == UIGestureRecognizerStateChanged) {
            self.videoViewHeightConstraint.constant = currentlocation.y;
            [self.view layoutIfNeeded];
        }
        
        [recognizer setTranslation:CGPointMake(0, 0) inView:self.controlView];
    }
    
    [self.videoView layoutIfNeeded];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {

    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (!UIInterfaceOrientationIsLandscape(orientation)) {
        self.videoViewHeightConstraint.constant = 150.0f;
        [self.view layoutIfNeeded];
    }
    
    self.animating ? nil : [self resumeLayer:self.videoView.layer];
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

#pragma mark ------------------------------------
#pragma mark Core Plot Methods
#pragma mark ------------------------------------

- (void)constructScatterPlot {
    // Create graph from theme
    CPTXYGraph *newGraph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    CPTTheme *theme = [CPTTheme themeNamed:kCPTPlainWhiteTheme];
    [newGraph applyTheme:theme];
    
    self.graphView.hostedGraph = newGraph;
    self.graph = newGraph;
    
    newGraph.paddingLeft = 2.0;
    newGraph.paddingTop = 2.0;
    newGraph.paddingRight = 2.0;
    newGraph.paddingBottom = 2.0;
    
    NSNumber *xRange = @(self.presenter.positions.count / [self.presenter.measurement.fps floatValue]);
    NSNumber *yRange = @(self.presenter.maximumValue);
    // Setup plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)newGraph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    plotSpace.globalXRange = [CPTPlotRange plotRangeWithLocation:@(-0.15 * xRange.floatValue) length:@(xRange.floatValue + (0.20 * xRange.floatValue))];
    plotSpace.globalYRange = [CPTPlotRange plotRangeWithLocation:@(-0.15 * yRange.floatValue) length:@(yRange.floatValue + (0.20 * yRange.floatValue))];
    
    plotSpace.xRange = plotSpace.globalXRange;
    plotSpace.yRange = plotSpace.globalYRange;
    
    // Axes
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)newGraph.axisSet;
    CPTXYAxis *x = axisSet.xAxis;
    x.majorIntervalLength = @0.2;
    x.orthogonalPosition = @0.0;
    x.minorTicksPerInterval = 1;
    
    CPTPlotRangeArray exclusionRanges = @[[CPTPlotRange plotRangeWithLocation:@(-100) length:@99.99999]];
    
    x.labelExclusionRanges = exclusionRanges;
    
    CPTXYAxis *y = axisSet.yAxis;
    y.majorIntervalLength = @(self.presenter.maximumValue / 10);
    y.orthogonalPosition = @0.0;
    y.minorTicksPerInterval = 1;
    y.labelExclusionRanges = exclusionRanges;
    
    if (self.presenter.maximumValue < 1) {
        NSNumberFormatter *formatter = [NSNumberFormatter new];
        [formatter setMaximumFractionDigits:3];
        
        y.labelFormatter = formatter;
    }
    
    CPTMutableLineStyle *lineStyle;
    
    // Create a blue plot area
    CPTScatterPlot *plot = [CPTScatterPlot new];
    plot.identifier = @"Blue Plot";
    
    lineStyle = [plot.dataLineStyle mutableCopy];
    lineStyle.miterLimit = 3.0;
    lineStyle.lineWidth = 3.0;
    lineStyle.lineColor= [CPTColor blueColor];
    
    plot.dataSource = self;
    plot.cachePrecision = CPTPlotCachePrecisionDouble;
    plot.interpolation = CPTScatterPlotInterpolationCurved;
    [newGraph insertPlot:plot atIndex:0];
}

#pragma mark ------------------------------------
#pragma mark Plot Data Source Methods
#pragma mark ------------------------------------

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return self.dataForPlot.count;
}

- (id)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    NSArray *position = self.dataForPlot[index];
    id num = @(NAN);
    
    if (fieldEnum == CPTScatterPlotFieldX) {
        num = position.firstObject;
    } else if (fieldEnum == CPTScatterPlotFieldY) {
        num = position.lastObject;
    }
    
    return num;
}

- (CPTPlotSymbol *)symbolForScatterPlot:(CPTScatterPlot *)plot recordIndex:(NSUInteger)idx {
    CPTMutableLineStyle *symbolLineStyle = [CPTMutableLineStyle lineStyle];
    symbolLineStyle.lineColor = [CPTColor whiteColor];
    CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    if (idx != self.currentIndex) {
        plotSymbol.fill = [CPTFill fillWithColor:[CPTColor blueColor]];
        plotSymbol.lineStyle = symbolLineStyle;
        plotSymbol.size = CGSizeMake(10.0, 10.0);
    } else {
        plotSymbol.fill = [CPTFill fillWithColor:[CPTColor redColor]];
        plotSymbol.lineStyle = symbolLineStyle;
        plotSymbol.size = CGSizeMake(15.0, 15.0);
    }
    return plotSymbol;
}

#pragma mark ------------------------------------
#pragma mark Button Control Methods
#pragma mark ------------------------------------

- (IBAction)playAction:(id)sender {
    if (self.animating == NO) {
        [self stopAnimatingVideo:nil];
    }
}

- (IBAction)pauseAction:(id)sender {
    if (self.animating == YES) {
        [self stopAnimatingVideo:nil];
    }
}

- (IBAction)stopAction:(id)sender {
    if (self.animating == YES) {
        [self stopAnimatingVideo:nil];
    }
    
    self.videoViewHeightConstraint.constant = 0.0f;
    [UIView animateWithDuration:0.1f animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)changeAction:(id)sender {
    [self changeVideo:nil];
}

- (IBAction)chartButtonAction:(id)sender {
    self.chartType = (++self.chartType) % 6;
    self.presenter.maximumValue = 0.0f;
    
    switch (self.chartType) {
        case ChartTypeATime: {
            [self.chartButton setTitle:NSLocalizedString(@"Acceleration - Time", nil) forState:UIControlStateNormal];
            
            NSArray *tuple = [self.presenter generateAcceleration];
            self.dataForPlot = [tuple firstObject];
            self.indexList = [tuple lastObject];
            
            break;
        }
        case ChartTypeVTime: {
            [self.chartButton setTitle:NSLocalizedString(@"Velocity - Time", nil) forState:UIControlStateNormal];
            
            NSArray *tuple = [self.presenter generateVelocityWithMaxValue:YES];
            self.dataForPlot = [tuple firstObject];
            self.indexList = [tuple lastObject];
            
            break;
        }
        case ChartTypeXTime: {
            [self.chartButton setTitle:NSLocalizedString(@"X - Time", nil) forState:UIControlStateNormal];
            
            NSArray *tuple = [self.presenter generateXT];
            self.dataForPlot = [tuple firstObject];
            self.indexList = [tuple lastObject];
            
            break;
        }
        case ChartTypeYTime: {
            [self.chartButton setTitle:NSLocalizedString(@"Y - Time", nil) forState:UIControlStateNormal];
            
            NSArray *tuple = [self.presenter generateYT];
            self.dataForPlot = [tuple firstObject];
            self.indexList = [tuple lastObject];
            
            break;
        }
        case ChartTypeEKTime: {
            [self.chartButton setTitle:NSLocalizedString(@"Kinetic Energy - Time", nil) forState:UIControlStateNormal];
            
            NSArray *tuple = [self.presenter generateKineticEnergy];
            self.dataForPlot = [tuple firstObject];
            self.indexList = [tuple lastObject];
            
            break;
        }
        case ChartTypeEPTime: {
            [self.chartButton setTitle:NSLocalizedString(@"Potential Energy - Time", nil) forState:UIControlStateNormal];
            
            NSArray *tuple = [self.presenter generatePotentialEnergy];
            self.dataForPlot = [tuple firstObject];
            self.indexList = [tuple lastObject];
            
            break;
        }
            
        default:
            break;
    }
    
    [self constructScatterPlot];
}

- (void)updateScatterPlotWithIndex:(NSUInteger)index {
    [self.graph reloadData];
}

- (void)pauseTimer {
    self.pauseStart = [NSDate dateWithTimeIntervalSinceNow:0];
    self.previousFireDate = [self.timer fireDate];
    
    [self.timer setFireDate:[NSDate distantFuture]];
}

- (void)resumeTimer {
    float pauseTime = -1 * [self.pauseStart timeIntervalSinceNow];
    [self.timer setFireDate:[self.previousFireDate initWithTimeInterval:pauseTime sinceDate:self.previousFireDate]];
}

@end
