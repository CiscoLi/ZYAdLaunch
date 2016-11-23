//
//  UIImage+ZYGIF.h
//  ZYAdLaunch
//
//  Created by zhaoyang on 2016/11/23.
//  Copyright © 2016年 zhaoyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ZYGIF)


/**
 data转成image

 @param data data数据
 @return 图片
 */
+ (UIImage *)zy_animatedGIFWithData:(NSData *)data;

@end
