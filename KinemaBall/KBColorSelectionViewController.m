//
//  KBColorSelectionViewController.m
//  KinemaBall
//
//  Created by Konrad Roj on 23.11.2015.
//  Copyright © 2015 Konrad Roj. All rights reserved.
//

#import "KBColorSelectionViewController.h"
#import "KBOpenCVViewController.h"
#import "DTColorPickerImageView.h"

@interface KBColorSelectionViewController () <DTColorPickerImageViewDelegate>
@property (strong, nonatomic) UIColor *color;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet DTColorPickerImageView *colorPicker;

@end

@implementation KBColorSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Choose color", nil);
    self.color = nil;
    self.colorPicker.delegate = self;
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (IBAction)chooseColor:(id)sender {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Are you sure?"
                                          message:@"Choosen color will be used to detect movement of your ball."
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Cancel action");
                                   }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {
                                   [self performSegueWithIdentifier:@"toCV" sender:nil];
                               }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toCV"]) {
        KBOpenCVViewController *vc = [segue destinationViewController];
        vc.choosenColor = self.color;
    }
}

- (void)imageView:(DTColorPickerImageView *)imageView didPickColorWithColor:(UIColor *)color {
    CGFloat red, green, blue;
    [color getRed:&red green:&green blue:&blue alpha:NULL];
    
    [self.nextButton setImage:[[UIImage imageNamed:@"like"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    
    if (red < 0.15 && green < 0.15 && blue < 0.15) {
        [self.nextButton setTintColor:[UIColor whiteColor]];
        self.color = [UIColor whiteColor];
    } else {
        [self.nextButton setTintColor:color];
    }
    
    self.color = color;
}

@end
