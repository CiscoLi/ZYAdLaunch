//
//  ZYSkipButton.h
//  ZYAdLaunch
//
//  Created by zhaoyang on 2016/11/23.
//  Copyright © 2016年 zhaoyang. All rights reserved.
//

#import <UIKit/UIKit.h>

//倒计时类型
typedef NS_ENUM(NSInteger,SkipType) {
    
    SkipTypeNone        = 1,//无
    SkipTypeTime        = 2,//倒计时
    SkipTypeText        = 3,//跳过
    SkipTypeTimeText    = 4,//倒计时+跳过
};

@interface ZYSkipButton : UIButton

@property (nonatomic ,strong) UILabel *timeLabel;

@property (nonatomic,assign) CGFloat leftRightSpace;

@property (nonatomic,assign) CGFloat topBottomSpace;


/**
 设置skipButton状态

 @param skipType        状态枚举
 @param duration        持续时间
 */
- (void)zy_stateWithSkipType:(SkipType)skipType andDuration:(NSInteger)duration;

@end
