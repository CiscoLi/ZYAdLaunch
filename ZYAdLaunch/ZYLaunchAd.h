//
//  ZYLaunchAd.h
//  ZYAdLaunch
//
//  Created by zhaoyang on 2016/11/23.
//  Copyright © 2016年 zhaoyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UIImageView+ZYWebCache.h"
#import "ZYSkipButton.h"

@class ZYLaunchAd;

//声明block
typedef void(^clickBlock)();
typedef void(^setAdImageBlock)(ZYLaunchAd *launchAd);
typedef void(^showFinishBlock)();

@interface ZYLaunchAd : UIViewController


/**
 没有广告数据.启动页面停留时间默认三秒,最小一秒
 !!!!!----请在向服务器请求广告数据前,设置此属性-----!!!!!
 */
@property (nonatomic,assign) NSInteger noDataDuration;

@property (nonatomic,assign) CGRect adFrame;


/**
 显示自定义启动图

 @param frame           广告frame
 @param setAdImage      设置AdImage回调
 @param showFinish      广告显示完成回调(在这里进行操作)
 */
- (void)showWithAdFrame:(CGRect)frame setAdImage:(setAdImageBlock)setAdImage showFinish:(showFinishBlock)showFinish;

/**
 数据源方法

 @param imageUrl        图片Url
 @param duration        广告时间(默认5秒,小于0都属于默认)
 @param skipType        跳过按钮类型
 @param options         图片的缓存机制
 @param completedBlock  加载完图片回调
 @param click           点击了广告回调
 */
- (void)setImageUrl:(NSString *)imageUrl duration:(NSInteger)duration skipType:(SkipType)skipType options:(ZYWebImageOptions)options completed:(ZYWebImageCompletionBlock)completedBlock click:(clickBlock)click;

@end
