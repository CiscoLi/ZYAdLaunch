//
//  ZYSkipButton.m
//  ZYAdLaunch
//
//  Created by zhaoyang on 2016/11/23.
//  Copyright © 2016年 zhaoyang. All rights reserved.
//

#import "ZYSkipButton.h"

@implementation ZYSkipButton

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.frame = frame;
        self.timeLabel = [[UILabel alloc]initWithFrame:self.bounds];
        self.timeLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        self.timeLabel.textColor = [UIColor whiteColor];
        self.timeLabel.layer.masksToBounds = YES;
        self.timeLabel.textAlignment = NSTextAlignmentCenter;
        self.timeLabel.font = [UIFont systemFontOfSize:13.5];
        [self addSubview:self.timeLabel];
    }
    return self;
}

- (void)zy_stateWithSkipType:(SkipType)skipType andDuration:(NSInteger)duration
{
    switch (skipType) {
        case SkipTypeNone:
            self.hidden = YES;
            break;
            
        case SkipTypeTime:
            self.timeLabel.text = [NSString stringWithFormat:@"%ld S",duration];
            break;
            
        case SkipTypeText:
            self.timeLabel.text = @"跳过";
            break;
            
        case SkipTypeTimeText:
            self.timeLabel.text = [NSString stringWithFormat:@"%ld 跳过",duration];
            break;
            
        default:
            break;
    }
}

@end
