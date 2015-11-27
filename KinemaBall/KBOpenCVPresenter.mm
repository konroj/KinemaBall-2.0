//
//  KBOpenCVPresenter.m
//  KinemaBall
//
//  Created by Konrad Roj on 23.11.2015.
//  Copyright © 2015 Konrad Roj. All rights reserved.
//

#import "KBOpenCVPresenter.h"
#import "BallPosition.h"

@interface KBOpenCVPresenter()
@property (strong, nonatomic) NSMutableArray *matImages;
@property (strong, nonatomic) NSMutableArray *positions;
@property (assign, nonatomic) CGFloat avgRadius;
@property (strong, nonatomic) NSString *stringDate;
@end

using namespace cv;

@implementation KBOpenCVPresenter

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    
    self.images = [NSMutableArray new];
    self.grayImages = [NSMutableArray new];
    self.positions = [NSMutableArray new];
    self.avgRadius = 0.0f;
    
    return self;
}

void UIImageToMat(const UIImage *image, cv::Mat& m, bool alphaExist) {
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width, rows = image.size.height;
    CGContextRef contextRef;
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedLast;
    if (CGColorSpaceGetModel(colorSpace) == 0) {
        m.create(rows, cols, CV_8UC1);
        //8 bits per component, 1 channel
        bitmapInfo = kCGImageAlphaNone;
        if (!alphaExist)
            bitmapInfo = kCGImageAlphaNone;
        contextRef = CGBitmapContextCreate(m.data, m.cols, m.rows, 8, m.step[0], colorSpace, bitmapInfo);
    } else {
        m.create(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
        if (!alphaExist)
            bitmapInfo = kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault;
        contextRef = CGBitmapContextCreate(m.data, m.cols, m.rows, 8, m.step[0], colorSpace, bitmapInfo);
    }
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
}

- (UIImage *)uIImageFromCVMat:(cv::Mat)cvMat {
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

- (void)save {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
    
    self.stringDate = [dateFormatter stringFromDate:[NSDate date]];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *frames = [NSString stringWithFormat:@"%@.dat", self.stringDate];
    NSString *grayFrames = [NSString stringWithFormat:@"grayframes%@.dat", self.stringDate];
    NSString *positions = [NSString stringWithFormat:@"positions%@.dat", self.stringDate];
    NSString *first = [NSString stringWithFormat:@"first%@.png", self.stringDate];
    
    NSString *framesPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:frames];
    NSString *positionsPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:positions];
    NSString *firstPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:first];
    NSString *grayPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:grayFrames];
    
    NSMutableArray *normalImages = [NSMutableArray new];
    for (UIImage *image in self.images) {
        NSData *data = UIImagePNGRepresentation(image);
        NSString *base64 = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        [normalImages addObject:base64];
    }
    
    NSMutableArray *grayImages = [NSMutableArray new];
    for (UIImage *image in self.grayImages) {
        NSData *data = UIImagePNGRepresentation(image);
        NSString *base64 = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        [grayImages addObject:base64];
    }
    
    NSData *dataImages = [NSKeyedArchiver archivedDataWithRootObject:normalImages];
    NSData *dataGrayImages = [NSKeyedArchiver archivedDataWithRootObject:grayImages];
    NSData *dataPositions = [NSKeyedArchiver archivedDataWithRootObject:self.positions];
    
    [dataPositions writeToFile:positionsPath atomically:YES];
    [dataImages writeToFile:framesPath atomically:YES];
    [dataGrayImages writeToFile:grayPath atomically:YES];
    [UIImagePNGRepresentation(self.images.firstObject) writeToFile:firstPath atomically:YES];
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        Measurement *measurement = [Measurement MR_createEntityInContext:localContext];
        measurement.time = self.stringDate;
        measurement.framesPath = frames;
        measurement.positionsPath = positions;
        measurement.frame = first;
        measurement.fps = [NSNumber numberWithInt:self.FPS];
        measurement.mass = @(50);
        measurement.size = @(0.15);
    } completion:^(BOOL success, NSError *error) {
        if (success && [self.delegate respondsToSelector:@selector(didSaved:sender:)]) {
            [self.delegate didSaved:success sender:self.stringDate];
        }
    }];
}

- (UIImage *)compressForUpload:(UIImage *)original scale:(CGFloat)scale {
    // Calculate new size given scale factor.
    CGSize originalSize = original.size;
    CGSize newSize = CGSizeMake(originalSize.width * scale, originalSize.height * scale);
    
    // Scale the original image to match the new size.
    UIGraphicsBeginImageContext(newSize);
    [original drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *compressedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return compressedImage;
}

- (NSArray *)getHsvFromUIColor:(UIColor *)color {
    HSV hsv;
    [color getHue:&hsv.h saturation:&hsv.s brightness:&hsv.v alpha:nil];
    
    CGFloat hue = hsv.h * 180.0f;
    CGFloat saturation = hsv.s * 255.0f;
    CGFloat value = hsv.v * 255.0f;
    
    return @[@(hue), @(saturation), @(value)];
}

- (void)processImage:(UIImage *)image frame:(NSInteger)frame choosenColor:(UIColor *)choosenColor {
    /// Declarations
    Mat matrixImage, endImage;
    UIImageToMat(image, matrixImage);
    UIImageToMat(image, endImage);
    Mat thresholdMat;
    
    /// Convert to HSV
    cvtColor(matrixImage, matrixImage, COLOR_RGBA2BGR);
    cvtColor(matrixImage, matrixImage, COLOR_BGR2HSV);
    
    /// Convert choosen color from RGB to HSV
    HSV hsv;
    [choosenColor getHue:&hsv.h saturation:&hsv.s brightness:&hsv.v alpha:nil];
    
    CGFloat H = hsv.h*180.0f;
    CGFloat S = hsv.s*255.0f < 170.0f ? hsv.s*255.0f : 170.0f;
    CGFloat V = hsv.v*255.0f < 170.0f ? hsv.v*255.0f : 170.0f;
    
    /// Reduce color range of image
    inRange(matrixImage, Scalar(H-10.0f, S-84.0f, V-84.0f), Scalar(H+10.0f, S+84.0f, V+84.0f), thresholdMat);
    
    /// Reduce the noise so we avoid false circle detection
    Canny(thresholdMat, thresholdMat, 5, 70, 3);
    GaussianBlur(thresholdMat, thresholdMat, cv::Size(9, 9), 2, 2 );
    
    std::vector<Vec3f> circles;
    
    /// Apply the Hough Transform to find the circles
    HoughCircles(thresholdMat, circles, HOUGH_GRADIENT, 2, thresholdMat.rows / 4, 200, 50, 20, 100);
    
    /// Initial position is false
    BallPosition *position = [[BallPosition alloc] initWithX:-1 y:-1 radius:-1 andFrame:-1];
    
    /// Apply position
    for (size_t i = 0; i < circles.size(); i++) {
        cv::Point center(cvRound(circles[0][0]), cvRound(circles[0][1]));
        BallPosition *lastPosition = (BallPosition *)(self.positions.lastObject);
        
        CGFloat distance = sqrt( (lastPosition.x-center.x)*(lastPosition.x-center.x)+(lastPosition.y-center.y)*(lastPosition.y-center.y) );
        
        if (distance > 6 || !self.positions) {
            position = [[BallPosition alloc] initWithX:cvRound(circles[0][0]) y:cvRound(circles[0][1]) radius:cvRound(circles[0][2]) andFrame:frame];
            
            /// Average radius
            if (self.avgRadius == 0.0f) {
                self.avgRadius = floor(cvRound(circles[0][2]));
            } else {
                self.avgRadius = cvRound(circles[0][2]) > self.avgRadius ? floor(cvRound(circles[0][2])) : floor(self.avgRadius);
            }
            
            /// Draw circles
            cvtColor(thresholdMat, thresholdMat, COLOR_GRAY2RGB);
            circle(endImage, center, 3, Scalar(0, 255, 0), -1, 8, 0);
            circle(endImage, center, self.avgRadius, Scalar(0, 0, 255), 3, 8, 0);
            circle(thresholdMat, center, 3, Scalar(0, 255, 0), -1, 8, 0);
            circle(thresholdMat, center, self.avgRadius, Scalar(0, 0, 255), 3, 8, 0);
        }
    }
    
    [self.positions addObject:position];
    
    /// Compress and append to list
    [self compressAndAppendData:endImage darkImage:thresholdMat];
    
    /// Memory management
    thresholdMat.release();
    matrixImage.release();
    endImage.release();
}

- (void)compressAndAppendData:(Mat)colorImage darkImage:(Mat)darkImage {
    UIImage *compressedImage = [self compressForUpload:[self uIImageFromCVMat:colorImage] scale:0.4];
    [self.images addObject:compressedImage];
    
    compressedImage = [self compressForUpload:[self uIImageFromCVMat:darkImage] scale:0.4];
    [self.grayImages addObject:compressedImage];
}

- (void)clearPresenter {
    self.matImages = nil;
    self.images = nil;
    self.grayImages = nil;
}


@end
