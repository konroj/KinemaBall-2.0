//
//  HelperMethods.h
//  PixoDżule
//
//  Created by Konrad Roj on 02.08.2015.
//  Copyright (c) 2015 Konrad Roj. All rights reserved.
//

#import <Foundation/Foundation.h>

struct HSV {
    CGFloat h;
    CGFloat s;
    CGFloat v;
};

struct RGB {
    CGFloat r;
    CGFloat g;
    CGFloat b;
};

typedef void (^WaitCompletionBlock)();

@interface HelperMethods : NSObject

void waitFor(NSTimeInterval duration, WaitCompletionBlock completion);

@end
