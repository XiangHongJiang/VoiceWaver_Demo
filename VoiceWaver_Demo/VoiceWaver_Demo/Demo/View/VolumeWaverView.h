//
//  VolumeWaverView.h
//  VoiceWaver_Demo
//
//  Created by MrYeL on 2018/7/20.
//  Copyright © 2018年 MrYeL. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,VolumeWaverType){
    
    VolumeWaverType_Bar,//跳动均衡器
    VolumeWaverType_BarMove,//移动
    VolumeWaverType_Line,//顺序

};

@interface VolumeWaverView : UIView

#define Xcount 30
#define Xmargin 1

/** 显示类型*/
@property (nonatomic, assign) VolumeWaverType showType;//bar line

/** 音频数组*/
@property (nonatomic, copy) NSArray * soundMeters;//float value

- (instancetype)initWithFrame:(CGRect)frame andType:(VolumeWaverType)type;


@end
