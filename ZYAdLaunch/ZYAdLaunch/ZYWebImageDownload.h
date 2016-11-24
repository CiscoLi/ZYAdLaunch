//
//  ZYWebImageDownload.h
//  ZYAdLaunch
//
//  Created by zhaoyang on 2016/11/23.
//  Copyright © 2016年 zhaoyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


typedef NS_OPTIONS(NSUInteger, ZYWebImageOptions){
    
    /*
     * 有缓存,读取缓存,不重新加载,没缓存先加载,并缓存
     */
    ZYWebImageDefault = 1 << 0,
    
    /*
     * 只加载,不缓存
     */
    ZYWebImageOnlyLoad = 1 << 1,
    
    /*
     * 先读缓存,再加载刷新图片和缓存
     */
    ZYWebImageRefreshCached = 1 << 2,
    
    /*
     * 后台缓存本次不显示,缓存完成以后下次显示
     */
    
    ZYWebImageCacheInBackground = 1 << 3

};

typedef void(^ZYWebImageCompletionBlock)(UIImage *image,NSURL *url);

@interface ZYWebImageDownload : NSObject


/**
 异步下载图片

 @param url                     图片url
 @param options                 缓存机制选项
 @param completedBlock          下载完成回调
 */
+ (void)zy_downLoadImage_asyncWithUrl:(NSURL *)url options:(ZYWebImageOptions)options completed:(ZYWebImageCompletionBlock)completedBlock;


@end
