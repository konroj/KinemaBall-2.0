//
//  KBOpenCVPresenter.h
//  KinemaBall
//
//  Created by Konrad Roj on 23.11.2015.
//  Copyright © 2015 Konrad Roj. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OpenCVPresenterDelegate <NSObject>

- (void)didSaved:(BOOL)success sender:(id)sender;

@end

@interface KBOpenCVPresenter : NSObject
@property (assign, nonatomic) int FPS;
@property (strong, nonatomic) NSMutableArray *images;
@property (strong, nonatomic) NSMutableArray *grayImages;

@property (weak, nonatomic) id<OpenCVPresenterDelegate> delegate;

// C++ Methods
void UIImageToMat(const UIImage *image, cv::Mat& m, bool alphaExist = false);

// Obj-C Methods
- (UIImage *)uIImageFromCVMat:(cv::Mat)cvMat;
- (void)save;
- (UIImage *)compressForUpload:(UIImage *)original scale:(CGFloat)scale;
- (void)processImage:(UIImage *)image frame:(NSInteger)frame choosenColor:(UIColor *)choosenColor;
- (void)clearPresenter;

@end
