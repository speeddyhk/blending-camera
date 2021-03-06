//
//  DistImageProcessor.h
//  distortionCamera
//
//  Created by 武田 祐一 on 2012/12/26.
//  Copyright (c) 2012年 武田 祐一. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>

@interface DistImageProcessor : NSObject
@property (nonatomic, strong) CIDetector *faceDetector;
@property (nonatomic, strong) CIFilter *filter;
@property (nonatomic, strong) CIFilter *colorAdjustmentFilter;
@property (nonatomic, strong) CIContext *ciContext;
@property (nonatomic, readonly) CIImage *ouputImage;
@property (nonatomic, strong) CIImage *inputImage;

- (id)initWithEAGLContext:(EAGLContext *)eaglContext;
- (CIImage *)applyEffect:(CIImage *)srcImage options:(NSDictionary *)options;

@end
