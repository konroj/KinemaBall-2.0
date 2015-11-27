//
//  BallPosition.h
//  PixoDżule
//
//  Created by Konrad Roj on 09.11.2014.
//  Copyright (c) 2014 Konrad Roj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BallPosition : NSObject

@property (nonatomic) NSInteger x;
@property (nonatomic) NSInteger y;
@property (nonatomic) NSInteger radius;
@property (nonatomic) NSInteger frame;

- (id)initWithX:(NSInteger)x y:(NSInteger)y radius:(NSInteger)radius andFrame:(NSInteger)frame;

@end
