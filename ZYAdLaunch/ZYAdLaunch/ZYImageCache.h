//
//  ZYImageCache.h
//  ZYAdLaunch
//
//  Created by zhaoyang on 2016/11/23.
//  Copyright © 2016年 zhaoyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ZYImageCache : NSObject


/**
 获取缓存照片

 @param url 图片url
 @return 图片
 */
+ (UIImage *)zy_getCacheImageWithUrl:(NSURL *)url;


/**
 缓存图片

 @param data imageData
 @param url 图片Url
 */
+ (void)zy_saveImageData:(NSData *)data imageUrl:(NSURL *)url;


/**
 获取缓存路径

 @return path
 */
+ (NSString *)zy_cacheImagePath;


/**
 check路径

 @param path 路径
 */
+ (void)zy_checkDirectory:(NSString *)path;

@end
