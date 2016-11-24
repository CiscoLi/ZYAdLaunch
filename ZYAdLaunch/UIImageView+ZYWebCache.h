//
//  UIImage+ZYWebCache.h
//  ZYAdLaunch
//
//  Created by zhaoyang on 2016/11/24.
//  Copyright © 2016年 zhaoyang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ZYWebImageDownload.h"

@interface UIImageView (ZYWebCache)

/**
 异步加载网络图片带本地缓存

 @param url                 图片Url
 */
- (void)zy_setImageWithUrl:(NSURL *)url;

/**
 异步加载网络图片带本地缓存,同时可以设置占位图

 @param url                 图片Url
 @param placeholder         占位图
 */
- (void)zy_setImageWithUrl:(NSURL *)url placeholderImage:(UIImage *)placeholder;

/**
 异步加载网络图片带本地缓存,加载完成后回调

 @param url                 图片Url
 @param placeholder         占位图
 @param completedBlock      完成后回调
 */
- (void)zy_setImageWithUrl:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(ZYWebImageCompletionBlock)completedBlock;

/**
 异步加载网络图片带本地缓存,支持选择缓存机制,和完成回调

 @param url                 图片Url
 @param placeholder         占位图
 @param options             缓存机制选择
 @param completedBlock      完成回调
 */
- (void)zy_setImageWithUrl:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(ZYWebImageOptions)options completed:(ZYWebImageCompletionBlock)completedBlock;

@end
