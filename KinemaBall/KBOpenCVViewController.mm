//
//  KBOpenCVViewController.m
//  KinemaBall
//
//  Created by Konrad Roj on 23.11.2015.
//  Copyright © 2015 Konrad Roj. All rights reserved.
//

#import "KBOpenCVViewController.h"
#import "BallPosition.h"
#import "KBDetailViewController.h"
#import "KBOpenCVPresenter.h"


@interface KBOpenCVViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIImagePickerControllerDelegate, OpenCVPresenterDelegate>
@property (weak, nonatomic) IBOutlet MBCircularProgressBarView *processing;
@property (weak, nonatomic) IBOutlet UILabel *mainTitle;
@property (weak, nonatomic) IBOutlet UIImageView *cameraView;
@property (weak, nonatomic) IBOutlet UIImageView *cameraGrayView;
@property (weak, nonatomic) IBOutlet UIView *buttonsView;
@property (nonatomic, strong) NSURL *movieURL;

@property (assign, nonatomic) CGFloat max;
@property (strong, nonatomic) UIPopoverController *popOver;

@property (strong, nonatomic) KBOpenCVPresenter *presenter;
@end

@implementation KBOpenCVViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"New", nil);
    self.presenter = [KBOpenCVPresenter new];
    self.presenter.delegate = self;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    self.view.window.rootViewController = self;
    
    [self setupProperties];
}

- (void)setupProperties {
    self.buttonsView.hidden = NO;
    self.processing.hidden = YES;
    self.processing.alpha = 0.0f;
    self.cameraGrayView.alpha = 0.0f;
    self.cameraView.alpha = 0.0f;
    self.mainTitle.alpha = 1.0f;
}

- (IBAction)recordVideo:(id)sender {
    UIImagePickerController *videoScreen = [[UIImagePickerController alloc] init];
    videoScreen.sourceType = UIImagePickerControllerSourceTypeCamera;
    videoScreen.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
    videoScreen.allowsEditing = YES;
    videoScreen.delegate = self;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self presentViewController:videoScreen animated:YES completion:nil];
    }];
}

- (IBAction)playVideo:(id)sender {
    UIImagePickerController *mediaLibrary = [[UIImagePickerController alloc] init];
    mediaLibrary.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    mediaLibrary.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
    mediaLibrary.allowsEditing = YES;
    mediaLibrary.delegate = self;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self presentViewController:mediaLibrary animated:YES completion:nil];
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    self.movieURL = [info objectForKey:UIImagePickerControllerReferenceURL];
    [self dismissViewControllerAnimated:NO completion:nil];
    if (CFStringCompare ((__bridge_retained CFStringRef)mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        self.movieURL = [info objectForKey:UIImagePickerControllerMediaURL];
        NSLog(@"%@\n", self.movieURL);
        
        self.buttonsView.hidden = YES;
        self.processing.hidden = NO;
        [UIView animateWithDuration:1.6f animations:^{
            self.mainTitle.alpha = 0.0f;
            self.processing.alpha = 1.0f;
        } completion:^(BOOL finished) {
            [self calculateSpeed];
        }];
    }
}

- (void)calculateSpeed {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:self.movieURL options:nil];
    AVAssetTrack *track = asset.tracks.lastObject;
    self.presenter.FPS = track.nominalFrameRate;
    
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.requestedTimeToleranceAfter =  kCMTimeZero;
    generator.requestedTimeToleranceBefore =  kCMTimeZero;
    generator.appliesPreferredTrackTransform = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSUInteger max = CMTimeGetSeconds(asset.duration) * self.presenter.FPS;
        for (Float64 i = 0; i < max ; i++) {
            @autoreleasepool {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.processing setValue:(i/max)*100 animateWithDuration:0.5];
                });
                
                CMTime time = CMTimeMake(i, self.presenter.FPS);
                NSError *err;
                CMTime actualTime;
                CGImageRef image = [generator copyCGImageAtTime:time actualTime:&actualTime error:&err];
                [self.presenter processImage:[[UIImage alloc] initWithCGImage:image] frame:i choosenColor:self.choosenColor];
                CGImageRelease(image);
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self animateDetectionWithFPS:self.presenter.FPS];
        });
    });
}

- (void)animateDetectionWithFPS:(NSUInteger)FPS {
    NSInteger animationImageCount = self.presenter.images.count;
    self.cameraView.contentMode = UIViewContentModeScaleAspectFit;
    self.cameraView.alpha = 0.0f;
    self.cameraView.backgroundColor = [UIColor blackColor];
    self.cameraView.layer.borderWidth = 3.0f;
    self.cameraView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.cameraView.animationImages = self.presenter.images;
    self.cameraView.animationDuration = animationImageCount / FPS;
    self.cameraView.animationRepeatCount = 0;
    [self.cameraView startAnimating];
    
    self.cameraGrayView.contentMode = UIViewContentModeScaleAspectFit;
    self.cameraGrayView.alpha = 0.0f;
    self.cameraGrayView.backgroundColor = [UIColor blackColor];
    self.cameraGrayView.layer.borderWidth = 3.0f;
    self.cameraGrayView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.cameraGrayView.animationImages = self.presenter.grayImages;
    self.cameraGrayView.animationDuration = animationImageCount / FPS;
    self.cameraGrayView.animationRepeatCount = 0;
    [self.cameraGrayView startAnimating];
    
    [UIView animateWithDuration:0.4f animations:^{
        self.processing.alpha = 0.0f;
        self.cameraView.alpha = 1.0f;
        self.cameraGrayView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        [self performSelector:@selector(saveAlert) withObject:nil afterDelay:1.0f];
    }];
}

- (void)saveAlert {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Completed"
                                          message:@"Do you want to continue or repeat measurement?"
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Repeat", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       self.buttonsView.alpha = 0.0f;
                                       self.buttonsView.hidden = NO;
                                       [UIView animateWithDuration:0.4f animations:^{
                                           self.buttonsView.alpha = 1.0f;
                                           self.mainTitle.alpha = 1.0f;
                                           self.cameraView.alpha = 0.0f;
                                           self.cameraGrayView.alpha = 0.0f;
                                       } completion:nil];
                                       [self.cameraView stopAnimating];
                                       [self.cameraGrayView stopAnimating];
                                       [self setupProperties];
                                   }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"Continue", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {
                                   [self.presenter save];
                               }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)didSaved:(BOOL)success sender:(id)sender {
    if (success) {
        [self performSegueWithIdentifier:@"toDetailsFromMeasurement" sender:sender];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"toDetailsFromMeasurement"]) {
        KBDetailViewController *vc = [segue destinationViewController];
        vc.date = (NSString *)sender;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.presenter.images.count) {
        [self.cameraGrayView stopAnimating];
        [self.cameraView stopAnimating];
        [self setupProperties];
        [self.presenter clearPresenter];
    }
}

@end
