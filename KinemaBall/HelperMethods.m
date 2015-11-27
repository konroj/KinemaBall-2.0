//
//  HelperMethods.m
//  PixoDżule
//
//  Created by Konrad Roj on 02.08.2015.
//  Copyright (c) 2015 Konrad Roj. All rights reserved.
//

#import "HelperMethods.h"

@implementation HelperMethods

void waitFor(NSTimeInterval duration, WaitCompletionBlock completion) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC),
                   dispatch_get_main_queue(), ^
                   { completion(); });
}

@end
