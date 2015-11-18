//
//  UIImage+Scale.h
//  AddToHomeScreen
//
//  Created by WangBin on 15/11/17.
//  Copyright © 2015年 WangBin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Scale)
- (UIImage *)imageByScalingAndCroppingForTargetSize:(CGSize)targetSize;
@end
