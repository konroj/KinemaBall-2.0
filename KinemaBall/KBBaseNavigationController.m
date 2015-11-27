//
//  KBBaseNavigationController.m
//  KinemaBall
//
//  Created by Konrad Roj on 23.11.2015.
//  Copyright © 2015 Konrad Roj. All rights reserved.
//

#import "KBBaseNavigationController.h"

@implementation KBBaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
     setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont fontWithName:@"AvenirNext-Medium" size:13.0f]}
     forState:UIControlStateNormal];
}

@end
