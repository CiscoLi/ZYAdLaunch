//
//  UIImage+ZYWebCache.m
//  ZYAdLaunch
//
//  Created by zhaoyang on 2016/11/24.
//  Copyright © 2016年 zhaoyang. All rights reserved.
//

#import "UIImageView+ZYWebCache.h"

@implementation UIImageView (ZYWebCache)

/**
 异步加载网络图片带本地缓存
 
 @param url 图片Url
 */
- (void)zy_setImageWithUrl:(NSURL *)url
{
    [self zy_setImageWithUrl:url placeholderImage:nil];
}

/**
 异步加载网络图片带本地缓存,同时可以设置占位图
 
 @param url 图片Url
 @param placeholder 占位图
 */
- (void)zy_setImageWithUrl:(NSURL *)url placeholderImage:(UIImage *)placeholder
{
    [self zy_setImageWithUrl:url placeholderImage:placeholder completed:nil];
}

/**
 异步加载网络图片带本地缓存,加载完成后回调
 
 @param url 图片Url
 @param placeholder 占位图
 @param completedBlock 完成后回调
 */
- (void)zy_setImageWithUrl:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(ZYWebImageCompletionBlock)completedBlock
{
    [self zy_setImageWithUrl:url placeholderImage:placeholder options:ZYWebImageDefault completed:completedBlock];
}

/**
 异步加载网络图片带本地缓存,支持选择缓存机制,和完成回调
 
 @param url 图片Url
 @param placeholder 占位图
 @param options 缓存机制选择
 @param completedBlock 完成回调
 */
- (void)zy_setImageWithUrl:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(ZYWebImageOptions)options completed:(ZYWebImageCompletionBlock)completedBlock
{
    if (placeholder) self.image = placeholder;
    if (url) {
        __weak __typeof(self)wself = self;
        
        [ZYWebImageDownload zy_downLoadImage_asyncWithUrl:url options:options completed:^(UIImage *image, NSURL *url) {
            if (!wself) return ;
            wself.image = image;
            if (image&&completedBlock) {
                completedBlock(image,url);
            }
        }];
    }
}

@end
