//
//  BallPosition.m
//  PixoDżule
//
//  Created by Konrad Roj on 09.11.2014.
//  Copyright (c) 2014 Konrad Roj. All rights reserved.
//

#import "BallPosition.h"

@implementation BallPosition

- (id)initWithX:(NSInteger)x y:(NSInteger)y radius:(NSInteger)radius andFrame:(NSInteger)frame {
    self = [super init];
    
    if (self != nil){
        self.x = x;
        self.y = y;
        self.radius = radius;
        self.frame = frame;
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInteger:self.x forKey:@"x"];
    [coder encodeInteger:self.y forKey:@"y"];
    [coder encodeInteger:self.radius forKey:@"radius"];
    [coder encodeInteger:self.frame forKey:@"frame"];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.x = [coder decodeIntegerForKey:@"x"];
        self.y = [coder decodeIntegerForKey:@"y"];
        self.radius = [coder decodeIntegerForKey:@"radius"];
        self.frame = [coder decodeIntegerForKey:@"frame"];
    }
    return self;
}

@end
