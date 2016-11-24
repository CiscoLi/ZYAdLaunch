//
//  ZYLaunchAd.m
//  ZYAdLaunch
//
//  Created by zhaoyang on 2016/11/23.
//  Copyright © 2016年 zhaoyang. All rights reserved.
//

#import "ZYLaunchAd.h"
#import "ZYImageCache.h"

/*
 * 没有数据源,启动页默认停留时间
 */
static NSInteger const noDataDefaultDuration = 3;

@interface ZYLaunchAd()

@property (nonatomic,copy) showFinishBlock showFinishBlock;                         //显示完成回调

@property (nonatomic ,strong) UIImageView *launchImgView;                           //背景视图

@property (nonatomic ,strong) UIImageView *adImgView;                               //广告视图

@property(nonatomic,assign) BOOL isShowFinish;                                      //是否显示完成

@property(nonatomic,copy) dispatch_source_t noDataTimer;                            //无数据倒计时

@property(nonatomic,copy) dispatch_source_t skipButtonTimer;                        //跳转按钮倒计时

@end

@implementation ZYLaunchAd

// ==============================================================
#pragma mark - 私有初始化函数
// ==============================================================

/**
 初始化函数

 @param frame 尺寸
 @param showFinish 显示完成的block
 @return 初始完成后self
 */
- (instancetype)initWithFrame:(CGRect)frame showFinish:(void(^)())showFinish
{
    if (self = [super init])
    {
        self.adFrame = frame;
        self.noDataDuration = noDataDefaultDuration;
        self.showFinishBlock = [showFinish copy];
        [self.view addSubview:self.launchImgView];
        //开启无数据倒计时服务
        [self startNoDataDispath_timer];
    }
    return self;
}


/**
 视图即将显示

 @param animated 动画属性
 */
- (void)viewWillAppear:(BOOL)animated
{
    
}
// ==============================================================
#pragma mark - 辅助函数
// ==============================================================

/**
 开启无数据倒计时服务
 */
- (void)startNoDataDispath_timer
{
    NSTimeInterval period = 1.0;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.noDataTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(self.noDataTimer, dispatch_walltime(NULL, 0), period * NSEC_PER_SEC, 0);
    
    __block NSInteger duration = self.noDataDuration;
    dispatch_source_set_event_handler(self.noDataTimer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (duration == 0) {
                dispatch_source_cancel(self.noDataTimer);
                [self remove];
            }
            duration--;
        });
    });
    //dispatch_resume函数恢复指定的Dispatch Queue
    dispatch_resume(self.noDataTimer);
}

// ==============================================================
#pragma mark - 移除函数
// ==============================================================
- (void)remove
{
    [UIView transitionWithView:[[UIApplication sharedApplication].delegate window] duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        //判断动画是否结束
        BOOL oldState = [UIView areAnimationsEnabled];
        [UIView setAnimationsEnabled:NO];
        self.isShowFinish = YES;
        if (self.showFinishBlock) self.showFinishBlock();
        [UIView setAnimationsEnabled:oldState];
    } completion:NULL];
}

@end
