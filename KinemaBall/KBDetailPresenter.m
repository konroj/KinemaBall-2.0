//
//  KBDetailPresenter.m
//  KinemaBall
//
//  Created by Konrad Roj on 24.11.2015.
//  Copyright © 2015 Konrad Roj. All rights reserved.
//

#import "KBDetailPresenter.h"
#import "BallPosition.h"

@interface KBDetailPresenter()
@property (strong, nonatomic) NSString *date;

@end

@implementation KBDetailPresenter

- (instancetype)initWithDate:(NSString *)date {
    self = [super init];
    if (!self) return nil;
    
    self.images = [NSMutableArray new];
    self.grayImages = [NSMutableArray new];
    self.positions = [NSMutableArray new];
    self.date = date;
    
    [self loadData];
    
    return self;
}

- (void)loadData {
    if (self.date) {
        self.measurement = [Measurement MR_findFirstByAttribute:@"time" withValue:self.date];
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", self.measurement.framesPath]];
    NSString *fullGreyPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"grayframes%@", self.measurement.framesPath]];
    NSString *positionsPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", self.measurement.positionsPath]];
    
    NSArray *normalImages = [[NSArray alloc] initWithArray:[NSKeyedUnarchiver unarchiveObjectWithFile:fullPath]];
    NSArray *grayImages = [[NSArray alloc] initWithArray:[NSKeyedUnarchiver unarchiveObjectWithFile:fullGreyPath]];
    
    self.positions = [[NSMutableArray alloc] initWithArray:[NSKeyedUnarchiver unarchiveObjectWithFile:positionsPath]];
    
    for (NSString *data in normalImages) {
        [self.images addObject:[self decodeBase64ToImage:data]];
    }
    
    for (NSString *data in grayImages) {
        [self.grayImages addObject:[self decodeBase64ToImage:data]];
    }
}

- (UIImage *)decodeBase64ToImage:(NSString *)strEncodeData {
    NSData *data = [[NSData alloc] initWithBase64EncodedString:strEncodeData options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:data];
}

#pragma mark ------------------------------------
#pragma mark Value Methods
#pragma mark ------------------------------------

- (NSArray *)generateVelocityWithMaxValue:(BOOL)maxValue {
    NSMutableArray *mutableArray = [NSMutableArray new];
    NSMutableArray *indexesArray = [NSMutableArray new];
    
    CGFloat totalTime = self.positions.count / [self.measurement.fps floatValue];
    CGFloat frameTime = totalTime / self.positions.count;
    
    CGFloat currentTime = 0;
    for (int i = 1 ; i < self.positions.count ; i++) {
        BallPosition *currentPosition = self.positions[i];
        BallPosition *lastPosition = self.positions[0];
        
        if (currentPosition.radius > 0 && lastPosition.radius > 0) {
            CGFloat street = sqrt(((currentPosition.x - lastPosition.x)*(currentPosition.x - lastPosition.x)) + ((currentPosition.y - lastPosition.y)*(currentPosition.y - lastPosition.y)));
            
            CGFloat mPerPixel = (self.measurement.size.floatValue / currentPosition.radius);
            
            NSNumber *yAxisValue = [NSNumber numberWithFloat:mPerPixel * fabs(street)];
            NSNumber *xAxisValue = @(currentTime);
            
            if ([yAxisValue isGreaterThan:@(0)] && ![yAxisValue isEqual:@(INFINITY)]) {
                if (yAxisValue.floatValue > self.maximumValue && maxValue) {
                    self.maximumValue = yAxisValue.floatValue;
                }
                
                [mutableArray addObject:@[xAxisValue, yAxisValue]];
                [indexesArray addObject:@(1)];
            } else {
                [indexesArray addObject:@(0)];
            }
        } else {
            [indexesArray addObject:@(0)];
        }
        
        currentTime = currentTime + frameTime;
    }
    
    return @[[NSArray arrayWithArray:mutableArray], [NSArray arrayWithArray:indexesArray]];
}

- (NSArray *)generateXT {
    NSMutableArray *mutableArray = [NSMutableArray new];
    NSMutableArray *indexesArray = [NSMutableArray new];
    
    CGFloat totalTime = self.positions.count / [self.measurement.fps floatValue];
    CGFloat frameTime = totalTime / self.positions.count;
    
    CGFloat currentTime = 0;
    for (int i = 1 ; i < self.positions.count ; i++) {
        BallPosition *currentPosition = self.positions[i];
        BallPosition *lastPosition = self.positions[0];
        
        if (currentPosition.radius > 0 && lastPosition.radius > 0) {
            CGFloat mPerPixel = (self.measurement.size.floatValue / currentPosition.radius);
            
            NSNumber *yAxisValue = @(mPerPixel * fabs((lastPosition.x - currentPosition.x) * 1.0f));
            NSNumber *xAxisValue = @(currentTime);
            
            if ([yAxisValue isGreaterThan:@(0)] && ![yAxisValue isEqual:@(INFINITY)]) {
                if (yAxisValue.floatValue > self.maximumValue) {
                    self.maximumValue = yAxisValue.floatValue;
                }
                
                [mutableArray addObject:@[xAxisValue, yAxisValue]];
                [indexesArray addObject:@(1)];
            } else {
                [indexesArray addObject:@(0)];
            }
        } else {
            [indexesArray addObject:@(0)];
        }
        
        currentTime = currentTime + frameTime;
    }
    
    return @[[NSArray arrayWithArray:mutableArray], [NSArray arrayWithArray:indexesArray]];
}

- (NSArray *)generateYT {
    NSMutableArray *mutableArray = [NSMutableArray new];
    NSMutableArray *indexesArray = [NSMutableArray new];
    
    CGFloat totalTime = self.positions.count / [self.measurement.fps floatValue];
    CGFloat frameTime = totalTime / self.positions.count;
    
    CGFloat currentTime = 0;
    for (int i = 1 ; i < self.positions.count ; i++) {
        BallPosition *currentPosition = self.positions[i];
        BallPosition *lastPosition = self.positions[0];
        
        if (currentPosition.radius > 0 && lastPosition.radius > 0) {
            CGFloat mPerPixel = (self.measurement.size.floatValue / currentPosition.radius);
            
            NSNumber *yAxisValue = @(mPerPixel * fabs((lastPosition.y - currentPosition.y) * 1.0f));
            NSNumber *xAxisValue = @(currentTime);
            
            if ([yAxisValue isGreaterThan:@(0)] && ![yAxisValue isEqual:@(INFINITY)]) {
                if (yAxisValue.floatValue > self.maximumValue) {
                    self.maximumValue = yAxisValue.floatValue;
                }
                
                [mutableArray addObject:@[xAxisValue, yAxisValue]];
                [indexesArray addObject:@(1)];
            } else {
                [indexesArray addObject:@(0)];
            }
        } else {
            [indexesArray addObject:@(0)];
        }
        
        currentTime = currentTime + frameTime;
    }
    
    return @[[NSArray arrayWithArray:mutableArray], [NSArray arrayWithArray:indexesArray]];
}

- (NSArray *)generateAcceleration {
    NSMutableArray *mutableArray = [NSMutableArray new];
    
    CGFloat totalTime = self.positions.count / [self.measurement.fps floatValue];
    
    NSArray *tuple = [self generateVelocityWithMaxValue:NO];
    NSArray *values = [tuple firstObject];
    NSMutableArray *indexesArray = [NSMutableArray arrayWithArray:tuple[1]];
    
    for (int i = 1 ; i < values.count - 1; i++) {
        NSArray *currentVelocity = values[i];
        NSArray *finalVelocity = values[values.count - 1];
        
        CGFloat velocityPerFrame = fabs([[finalVelocity lastObject] doubleValue]-[[currentVelocity lastObject] doubleValue]);
        NSNumber *acceleration = @(velocityPerFrame / (totalTime - [[currentVelocity firstObject] doubleValue]));
        
        if (![acceleration isEqual:@(INFINITY)]) {
            if (acceleration.floatValue > self.maximumValue) {
                self.maximumValue = acceleration.floatValue;
            }
            
            [mutableArray addObject:@[[currentVelocity firstObject], acceleration]];
        }
    }
    
    return @[[NSArray arrayWithArray:mutableArray], [NSArray arrayWithArray:indexesArray]];
}

/// MV^2/2
- (NSArray *)generateKineticEnergy {
    NSMutableArray *mutableArray = [NSMutableArray new];
    
    NSArray *tuple = [self generateVelocityWithMaxValue:NO];
    NSArray *velocityList = [tuple firstObject];
    NSMutableArray *indexesArray = [NSMutableArray arrayWithArray:tuple[1]];
    
    for (NSArray *values in velocityList) {
        NSNumber *velocity = [values lastObject];
        NSNumber *time = [values firstObject];
        
        NSNumber *energy = @(((self.measurement.mass.doubleValue / 1000.0f) * (velocity.doubleValue * velocity.doubleValue) / 2.0f));
        
        if (![energy isEqual:@(INFINITY)]) {
            if (energy.floatValue > self.maximumValue) {
                self.maximumValue = energy.floatValue;
            }
            
            [mutableArray addObject:@[time, energy]];
        }
    }
    
    return @[[NSArray arrayWithArray:mutableArray], [NSArray arrayWithArray:indexesArray]];
}

/// M*G*H
- (NSArray *)generatePotentialEnergy {
    NSMutableArray *mutableArray = [NSMutableArray new];
    NSMutableArray *indexesArray = [NSMutableArray new];
    
    CGFloat maxY = -1.0f;
    
    for (BallPosition *position in self.positions) {
        if ((position.y > maxY || maxY == -1.0f) && position.y > 0) {
            maxY = position.y;
        }
    }
    
    CGFloat totalTime = self.positions.count / [self.measurement.fps floatValue];
    CGFloat frameTime = totalTime / self.positions.count;
    
    CGFloat currentTime = 0;
    for (int i = 0 ; i < self.positions.count ; i++) {
        BallPosition *currentPosition = self.positions[i];
        
        if (currentPosition.radius > 0) {
            CGFloat mPerPixel = (self.measurement.size.floatValue / currentPosition.radius);
            
            CGFloat yPlace = (mPerPixel*(maxY - currentPosition.y));
            
            NSNumber *yAxisValue = @((self.measurement.mass.doubleValue / 1000.0f) * 9.81 * yPlace);
            NSNumber *xAxisValue = @(currentTime);
            
            if ([yAxisValue isGreaterThan:@(0)] && ![yAxisValue isEqual:@(INFINITY)]) {
                if (yAxisValue.floatValue > self.maximumValue) {
                    self.maximumValue = yAxisValue.floatValue;
                }
                
                [mutableArray addObject:@[xAxisValue, yAxisValue]];
                [indexesArray addObject:@(1)];
            } else {
                [indexesArray addObject:@(0)];
            }
        } else {
            [indexesArray addObject:@(0)];
        }
        
        currentTime = currentTime + frameTime;
    }
    
    return @[[NSArray arrayWithArray:mutableArray], [NSArray arrayWithArray:indexesArray]];
}

- (NSArray *)regressionOfArray:(NSArray *)array {
    CGFloat a = 0;
    CGFloat b = 0;
    CGFloat c = 0;

    CGFloat x = 0;
    CGFloat x2 = 0;
    CGFloat y = 0;
    CGFloat xy = 0;
    
    CGFloat pSXX = 0;
    CGFloat pSXY = 0;
    CGFloat pSXX2 = 0;
    CGFloat pSX2Y = 0;
    CGFloat pSX2X2 = 0;

    for (NSArray *value in array) {
        CGFloat xValue = [[value firstObject] doubleValue];
        CGFloat yValue = [[value lastObject] doubleValue];
        
        y += yValue;
        x += yValue;
        x2 += xValue*xValue;
        xy += xValue*yValue;
        
        double currX2 = xValue*xValue;
        double currX3 = xValue*xValue*xValue;
        double currX4 = xValue*xValue*xValue*xValue;
        double currXY = xValue*yValue;
        double currX2Y = xValue*xValue*yValue;
        
        pSXX += currX2 - (xValue*xValue/array.count);
        pSXY += currXY - (xValue*yValue/array.count);
        pSXX2 += currX3 - (xValue*currX2/array.count);
        pSX2Y += currX2Y - (currX2*yValue/array.count);
        pSX2X2 += currX4 - (currX2*currX2/array.count);
        
    }
    
    a = ((pSX2Y*pSXX)-(pSXY*pSXX2))/((pSXX*pSX2X2)-(pSXX2*pSXX2));
    b = ((pSXY*pSX2X2)-(pSX2Y*pSXX2))/((pSXX*pSX2X2)-(pSXX2*pSXX2));
    c = (y/array.count)-(b*x/array.count)-(a*x2/array.count);
    
    NSMutableArray *mutableValuesArray = [NSMutableArray new];
    for (int i = 0; i < array.count ; i++) {
        CGFloat timeValue = [[array[i] firstObject] doubleValue];
        [mutableValuesArray addObject:@[@(timeValue), @((a*timeValue*timeValue) + (b*timeValue) + c)]];
    }
    
    return [NSArray arrayWithArray:mutableValuesArray];
}

@end
