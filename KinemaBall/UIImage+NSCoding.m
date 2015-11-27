//
//  UIImage+NSCoding.m
//  PixoDżule
//
//  Created by Konrad Roj on 11.11.2014.
//  Copyright (c) 2014 Konrad Roj. All rights reserved.
//

#import "UIImage+NSCoding.h"
#define kEncodingKey        @"UIImage"

@implementation UIImage(NSCoding)

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {
        NSData *data = [decoder decodeObjectForKey:kEncodingKey];
        self = [self initWithData:data];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    NSData *data = UIImageJPEGRepresentation(self,1.0);
    [encoder encodeObject:data forKey:kEncodingKey];
}
@end