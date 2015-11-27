//
//  KBDetailPresenter.h
//  KinemaBall
//
//  Created by Konrad Roj on 24.11.2015.
//  Copyright © 2015 Konrad Roj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KBDetailPresenter : NSObject
@property (strong, nonatomic) NSMutableArray *images;
@property (strong, nonatomic) NSMutableArray *grayImages;
@property (strong, nonatomic) NSMutableArray *positions;
@property (strong, nonatomic) Measurement *measurement;
@property (assign, nonatomic) CGFloat maximumValue;

- (instancetype)initWithDate:(NSString *)date;

- (NSArray *)generateVelocityWithMaxValue:(BOOL)maxValue;
- (NSArray *)generateXT;
- (NSArray *)generateYT;
- (NSArray *)generateAcceleration;
- (NSArray *)generateKineticEnergy;
- (NSArray *)generatePotentialEnergy;

- (NSArray *)regressionOfArray:(NSArray *)array;

@end
