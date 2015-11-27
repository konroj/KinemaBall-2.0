//
//  UIImage+NSCoding.h
//  PixoDżule
//
//  Created by Konrad Roj on 11.11.2014.
//  Copyright (c) 2014 Konrad Roj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageNSCoding <NSCoding>
- (id)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)encoder;
@end
