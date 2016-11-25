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

@property(nonatomic,assign) NSInteger duration;                                     //持续时间

@property(nonatomic,assign) BOOL isClick;                                           //是否点击

@property(nonatomic,assign) SkipType skipType;                                      //倒计时类型

@property(nonatomic,copy) clickBlock clickBlock;                                    //点击广告block

@property(nonatomic,strong)ZYSkipButton *skipButton;                                //倒计时按钮

@end

@implementation ZYLaunchAd

// ==============================================================
#pragma mark - 对外暴露函数
// ==============================================================

/**
 显示自定义启动图
 
 @param frame           广告frame
 @param setAdImage      设置AdImage回调
 @param showFinish      广告显示完成回调(在这里进行操作)
 */
+ (void)showWithAdFrame:(CGRect)frame setAdImage:(setAdImageBlock)setAdImage showFinish:(showFinishBlock)showFinish
{
    ZYLaunchAd *AdVC = [[ZYLaunchAd alloc] initWithFrame:frame showFinish:showFinish];
    [[UIApplication sharedApplication].delegate window].rootViewController = AdVC;
    if(setAdImage) setAdImage(AdVC);
}

/**
 数据源方法
 
 @param imageUrl        图片Url
 @param duration        广告时间(默认5秒,小于0都属于默认)
 @param skipType        跳过按钮类型
 @param options         图片的缓存机制
 @param completedBlock  加载完图片回调
 @param click           点击了广告回调
 */
- (void)setImageUrl:(NSString *)imageUrl duration:(NSInteger)duration skipType:(SkipType)skipType options:(ZYWebImageOptions)options completed:(ZYWebImageCompletionBlock)completedBlock click:(clickBlock)click
{
    if(self.isShowFinish) return;
    if ([self imageUrlError:imageUrl]) return;
    
    //后台缓存本次不显示,缓存完成以后下次显示
    if (options&ZYWebImageCacheInBackground)
    {
        if (_noDataTimer) dispatch_source_cancel(_noDataTimer);
        [[UIImageView alloc]zy_setImageWithUrl:[NSURL URLWithString:imageUrl] placeholderImage:nil options:options completed:nil];
        [self remove];
        return;
    }
    
    _duration = duration;
    _skipType = skipType;
    _clickBlock = [click copy];
    [self setupAdImgViewAndSkipButton];
    [_adImgView zy_setImageWithUrl:[NSURL URLWithString:imageUrl] placeholderImage:nil options:options completed:completedBlock];
}

+(void)clearDiskCache
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *path = [ZYImageCache zy_cacheImagePath];
        [fileManager removeItemAtPath:path error:nil];
        [ZYImageCache zy_checkDirectory:[ZYImageCache zy_cacheImagePath]];
        
    });
}

+(float)imagesCacheSize {
    NSString *directoryPath = [ZYImageCache zy_cacheImagePath];
    BOOL isDir = NO;
    unsigned long long total = 0;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:&isDir]) {
        if (isDir) {
            NSError *error = nil;
            NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:&error];
            
            if (error == nil) {
                for (NSString *subpath in array) {
                    NSString *path = [directoryPath stringByAppendingPathComponent:subpath];
                    NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:path
                                                                                          error:&error];
                    if (!error) {
                        total += [dict[NSFileSize] unsignedIntegerValue];
                    }
                }
            }
        }
    }
    return total/(1024.0*1024.0);
}

// ==============================================================
#pragma mark - 私有初始化函数
// ==============================================================

/**
 初始化函数

 @param frame           尺寸
 @param showFinish      显示完成的block
 @return                初始完成后self
 */
- (instancetype)initWithFrame:(CGRect)frame showFinish:(void(^)())showFinish
{
    if (self = [super init])
    {
        _adFrame = frame;
        _noDataDuration = noDataDefaultDuration;
        _showFinishBlock = [showFinish copy];
        [self.view addSubview:self.launchImgView];
        //开启无数据倒计时服务
        [self startNoDataDispath_timer];
    }
    return self;
}


/**
 视图即将显示

 @param animated        动画属性
 */
- (void)viewWillAppear:(BOOL)animated
{
    if (_skipButtonTimer && _duration > 0 && self.isClick) {
        //dispatch_resume函数恢复指定的Dispatch Queue
        dispatch_resume(_skipButtonTimer);
    }
    self.isClick = NO;
}


/**
 视图即将消失

 @param animated        动画属性
 */
- (void)viewDidDisappear:(BOOL)animated
{
    if (_skipButtonTimer && _duration > 0 && _isClick) {
        //dispatch_suspend函数挂起指定的Dispatch Queue
        dispatch_suspend(self.skipButtonTimer);
    }
}

- (void)setupAdImgViewAndSkipButton
{
    [self.view addSubview:self.adImgView];
    [self.view addSubview:self.skipButton];
    [self animateStart];
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
    _noDataTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_noDataTimer, dispatch_walltime(NULL, 0), period * NSEC_PER_SEC, 0);
    
    __block NSInteger duration = _noDataDuration;
    dispatch_source_set_event_handler(_noDataTimer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (duration == 0) {
                dispatch_source_cancel(_noDataTimer);
                [self remove];
            }
            duration--;
        });
    });
    //dispatch_resume函数恢复指定的Dispatch Queue
    dispatch_resume(_noDataTimer);
}

/**
 开启跳转倒计时服务
 */
-(void)startSkipButtonTimer
{
    if(_noDataTimer) dispatch_source_cancel(_noDataTimer);
    
    NSTimeInterval period = 1.0;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _skipButtonTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_skipButtonTimer, dispatch_walltime(NULL, 0), period * NSEC_PER_SEC, 0);
    
    dispatch_source_set_event_handler(_skipButtonTimer, ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_skipButton zy_stateWithSkipType:_skipType andDuration:_duration];
            if(_duration==0)
            {
                dispatch_source_cancel(_skipButtonTimer);
                
                [self remove];
            }
            _duration--;
        });
    });
    dispatch_resume(_skipButtonTimer);
}


/**
 判断图片url是否合法

 @param imageUrl        图片地址
 @return                图片地址是否合法
 */
- (BOOL)imageUrlError:(NSString *)imageUrl
{
    if (imageUrl == nil || imageUrl.length == 0 || ![imageUrl hasPrefix:@"http"]) {
        NSLog(@"图片地址有误");
        return YES;
    }
    return NO;
}


/**
 开启动画效果
 */
- (void)animateStart
{
    CGFloat duration = _duration;
    duration = duration/4.0;
    if (duration > 1.0) duration = 1.0;
    [UIView animateWithDuration:duration animations:^{
        self.adImgView.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
    

}


/**
 获取Launch图片

 @return Launch图片
 */
-(UIImage *)getLaunchImage
{
    UIImage *imageP = [self launchImageWithType:@"Portrait"];
    if(imageP) return imageP;
    UIImage *imageL = [self launchImageWithType:@"Landscape"];
    if(imageL) return imageL;
    NSLog(@"获取LaunchImage失败!请检查是否添加启动图,或者规格是否有误.");
    return nil;
}


/**
 获取Launch图片

 @param type 图片类型
 @return Launch图片
 */
-(UIImage *)launchImageWithType:(NSString *)type
{
    CGSize viewSize = [UIScreen mainScreen].bounds.size;
    NSString *viewOrientation = type;
    NSString *launchImageName = nil;
    NSArray* imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    for (NSDictionary* dict in imagesDict)
    {
        CGSize imageSize = CGSizeFromString(dict[@"UILaunchImageSize"]);
        
        if([viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]])
        {
            if([dict[@"UILaunchImageOrientation"] isEqualToString:@"Landscape"])
            {
                imageSize = CGSizeMake(imageSize.height, imageSize.width);
            }
            if(CGSizeEqualToSize(imageSize, viewSize))
            {
                launchImageName = dict[@"UILaunchImageName"];
                UIImage *image = [UIImage imageNamed:launchImageName];
                return image;
            }
        }
    }
    return nil;
}

// ==============================================================
#pragma mark - 懒加载函数
// ==============================================================

- (UIImageView *)launchImgView
{
    if (_launchImgView == nil) {
        _launchImgView = [[UIImageView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        _launchImgView.image = [self getLaunchImage];
        
    }
    return _launchImgView;
}

- (UIImageView *)adImgView
{
    if (_adImgView == nil) {
        _adImgView = [[UIImageView alloc]initWithFrame:_adFrame];
        _adImgView.userInteractionEnabled = YES;
        _adImgView.alpha = 0.2;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
        [_adImgView addGestureRecognizer:tap];
    }
    return _adImgView;
}

-(ZYSkipButton *)skipButton
{
    if(_skipButton == nil)
    {
        _skipButton = [[ZYSkipButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-70,25, 70, 40)];
        [_skipButton addTarget:self action:@selector(skipAction) forControlEvents:UIControlEventTouchUpInside];
        _skipButton.leftRightSpace = 5;
        _skipButton.topBottomSpace = 5;
        if(!_duration||_duration<=0) _duration = 5;//停留时间传nil或<=0,默认5s
        if(!_skipType) _skipType = SkipTypeTimeText;//类型传nil,默认TimeText
        [_skipButton zy_stateWithSkipType:_skipType andDuration:_duration];
        [self startSkipButtonTimer];
    }
    return _skipButton;
}

-(void)setAdFrame:(CGRect)adFrame
{
    _adFrame = adFrame;
    _adImgView.frame = adFrame;
}

-(void)setNoDataDuration:(NSInteger)noDataDuration
{
    if(noDataDuration<1) noDataDuration=1;
    _noDataDuration = noDataDuration;
    dispatch_source_cancel(_noDataTimer);
    [self startNoDataDispath_timer];
}

// ==============================================================
#pragma mark - 事件函数
// ==============================================================

/**
 广告图点击事件

 @param tap 点击手势
 */
-(void)tapAction:(UITapGestureRecognizer *)tap
{
    if(_duration>0)
    {
        self.isClick = YES;
        if(_clickBlock) _clickBlock();
    }
}


/**
 跳过按钮点击事件
 */
-(void)skipAction{
    
    if(_skipType != SkipTypeTime)
    {
        self.isClick = NO;
        if (_skipButtonTimer) dispatch_source_cancel(_skipButtonTimer);
        [self remove];
    }
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
        _isShowFinish = YES;
        if (self.showFinishBlock) self.showFinishBlock();
        [UIView setAnimationsEnabled:oldState];
    } completion:NULL];
}

@end
