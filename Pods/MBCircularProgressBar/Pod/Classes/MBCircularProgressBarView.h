//
//  MBCircularProgressBarView.h
//  MBCircularProgressBar
//
//  Created by Mati Bot on 7/2/15.
//  Copyright (c) 2015 Mati Bot All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface MBCircularProgressBarView : UIView

/* Should show value string */
@property (nonatomic,assign) IBInspectable BOOL      showValueString;

/* The value of the progress bar  */
@property (nonatomic,assign) IBInspectable CGFloat   value;

/* The maximum possible value, used to calculate the progress (value/maxValue)	[0,∞) */
@property (nonatomic,assign) IBInspectable CGFloat   maxValue;

/* Number of decimal places of the value [0,∞) */
@property (nonatomic,assign) IBInspectable NSInteger decimalPlaces;

/* The name of the font of the value string*/
@property (nonatomic,copy)   IBInspectable NSString  *valueFontName;

/* The font size of the value text	[0,∞) */
@property (nonatomic,assign) IBInspectable CGFloat   valueFontSize;

/* The value to be displayed in the center */
@property (nonatomic,assign) IBInspectable CGFloat   valueDecimalFontSize;

/* Should show unit screen */
@property (nonatomic,assign) IBInspectable BOOL      showUnitString;

/* The name of the font of the unit string */
@property (nonatomic,copy)   IBInspectable NSString  *unitFontName;

/* The font size of the unit text	[0,∞) */
@property (nonatomic,assign) IBInspectable CGFloat   unitFontSize;

/* The string that represents the units, usually % */
@property (nonatomic,copy)   IBInspectable NSString  *unitString;

/* The color of the value and unit text */
@property (nonatomic,strong) IBInspectable UIColor   *fontColor;

/* Progress bar rotation (Clockewise)	[0,100] */
@property (nonatomic,assign) IBInspectable CGFloat   progressRotationAngle;

/* Set a partial angle for the progress bar	[0,100] */
@property (nonatomic,assign) IBInspectable CGFloat   progressAngle;

/* The width of the progress bar (user space units)	[0,∞) */
@property (nonatomic,assign) IBInspectable CGFloat   progressLineWidth;

/* The color of the progress bar */
@property (nonatomic,strong) IBInspectable UIColor   *progressColor;

/* The color of the progress bar frame */
@property (nonatomic,strong) IBInspectable UIColor   *progressStrokeColor;

/* The shape of the progress bar cap	{kCGLineCapButt=0, kCGLineCapRound=1, kCGLineCapSquare=2} */
@property (nonatomic,assign) IBInspectable NSInteger progressCapType;

/* The width of the background bar (user space units)	[0,∞) */
@property (nonatomic,assign) IBInspectable CGFloat   emptyLineWidth;

/* The color of the background bar */
@property (nonatomic,strong) IBInspectable UIColor   *emptyLineColor;

/* The shape of the background bar cap	{kCGLineCapButt=0, kCGLineCapRound=1, kCGLineCapSquare=2} */
@property (nonatomic,assign) IBInspectable NSInteger emptyCapType;

/* Set the value of the progress bar with animation */
-(void)setValue:(CGFloat)value animateWithDuration:(NSTimeInterval)duration;

@end
