//
//  ZYWebImageDownload.m
//  ZYAdLaunch
//
//  Created by zhaoyang on 2016/11/23.
//  Copyright © 2016年 zhaoyang. All rights reserved.
//

#import "ZYWebImageDownload.h"
#import "ZYImageCache.h"
#import "UIImage+ZYGIF.h"

@implementation ZYWebImageDownload


/**
 异步下载图片
 
 @param url 图片url
 @param options 缓存机制选项
 @param completedBlock 下载完成回调
 */
+ (void)zy_downLoadImage_asyncWithUrl:(NSURL *)url options:(ZYWebImageOptions)options completed:(ZYWebImageCompletionBlock)completedBlock
{
    if (!options) options = ZYWebImageDefault;
    
    //只加载,不缓存
    if (options&ZYWebImageOnlyLoad)
    {
        [self zy_asyncDownLoadImageWithUrl:url completed:completedBlock];
    }
    else if (options&ZYWebImageRefreshCached)
    {
        //先读缓存,再加载刷新图片和缓存
        UIImage *cacheImage = [ZYImageCache zy_getCacheImageWithUrl:url];
        if (cacheImage) {
            if (completedBlock) {
                completedBlock(cacheImage,url);
            }
        }
        [self zy_asyncDownLoadImageAndCacheWithUrl:url completed:completedBlock];
    }
    else if (options&ZYWebImageCacheInBackground)
    {
        //后台缓存本次不显示,缓存完成以后下次显示
        UIImage *cacheImage = [ZYImageCache zy_getCacheImageWithUrl:url];
        if (cacheImage) {
            if (completedBlock) {
                completedBlock(cacheImage,url);
            }
        }else{
            [self zy_asyncDownLoadImageAndCacheWithUrl:url completed:nil];
        }
    }
    else
    {
        //有缓存,读取缓存,不重新加载,没缓存先加载,并缓存
        UIImage *cacheImage = [ZYImageCache zy_getCacheImageWithUrl:url];
        if (cacheImage) {
            if (completedBlock) {
                completedBlock(cacheImage,url);
            }
        }else{
            [self zy_asyncDownLoadImageAndCacheWithUrl:url completed:completedBlock];
        }
    }
}

/**
 异步下载同时缓存图片

 @param url 图片url
 @param completedBlock 图片回调
 */
+ (void)zy_asyncDownLoadImageAndCacheWithUrl:(NSURL *)url completed:(ZYWebImageCompletionBlock)completedBlock
{
    if (url == nil) return;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [self zy_downLoadImageAndCacheWithUrl:url];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completedBlock) {
                completedBlock(image,url);
            }
        });
    });
}

/**
 异步下载图片但是不缓存

 @param url 图片Url
 @param completedBlock 图片回调
 */
+ (void)zy_asyncDownLoadImageWithUrl:(NSURL *)url completed:(ZYWebImageCompletionBlock)completedBlock
{
    if(url==nil) return;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [self zy_downLoadImageWithUrl:url];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completedBlock) {
                completedBlock(image,url);
            }
        });
    });
}

/**
 根据url下载图片但是不缓存,直接返回下载完成图片

 @param url 图片url
 @return 下载成功图片
 */
+ (UIImage *)zy_downLoadImageWithUrl:(NSURL *)url
{
    if(url == nil) return nil;
    NSData *data = [NSData dataWithContentsOfURL:url];
    return [UIImage zy_animatedGIFWithData:data];
}

/**
 根据url下载图片并缓存起来

 @param url 图片url
 @return 返回下载成功图片
 */
+ (UIImage *)zy_downLoadImageAndCacheWithUrl:(NSURL *)url
{
    if(url == nil) return nil;
    NSData *data = [NSData dataWithContentsOfURL:url];
    [ZYImageCache zy_saveImageData:data imageUrl:url];
    return [UIImage zy_animatedGIFWithData:data];
}



@end
