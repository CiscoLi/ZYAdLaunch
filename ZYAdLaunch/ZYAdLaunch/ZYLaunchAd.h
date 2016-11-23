//
//  ZYLaunchAd.h
//  ZYAdLaunch
//
//  Created by zhaoyang on 2016/11/23.
//  Copyright © 2016年 zhaoyang. All rights reserved.
//

@class ZYLaunchAd;

//声明block
typedef void(^clickBlock)();
typedef void(^setAdImageBlock)(ZYLaunchAd *launchAd);
typedef void(^showFinishBlock)();


#import <UIKit/UIKit.h>

@interface ZYLaunchAd : UIViewController

//显示启动广告
- (void)showWithAdFrame:(CGRect)frame setAdImage:(setAdImageBlock)setAdImage showFinish:(showFinishBlock)showFinish;

@end
