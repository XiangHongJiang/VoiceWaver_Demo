//
//  RecordManager.h
//  VoiceWaver_Demo
//
//  Created by MrYeL on 2018/7/24.
//  Copyright © 2018年 MrYeL. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVFoundation/AVFoundation.h>

typedef void (^ReturnTimeCount)(NSTimer *timer,int second);

@interface RecordManager : NSObject

/** AVAudioRecorder*/
@property (nonatomic, strong) AVAudioRecorder * recorder;
/** 最大录音时间(秒)s:*/
@property (nonatomic, assign) int maxSecond;
/** timer录音计时器*/
@property (nonatomic, strong) NSTimer * timer;
/** recordTime录音时间*/
@property (nonatomic, assign) CGFloat recordTime;
/** updateFequency波形更新间隔*/
@property (nonatomic, assign) CGFloat updateFequency;

/** soundMeterCount声音数据数组容量*/
@property (nonatomic, assign) NSInteger soundMeterCount;
/** soundMeters声音数据数组*/
@property (nonatomic, strong) NSMutableArray * soundMeters;

/** 文件存储地址*/
@property (nonatomic, copy) NSString * filePath;
/** 回调*/
@property (nonatomic, copy) ReturnTimeCount returnTime;


/** 录音工具的单例 */
+ (instancetype)sharedRecordTool;

#pragma mark - Method Action

/** 启动/继续*/
- (void)startRecord;
/** 暂停/停止*/
- (void)pauseRecord;
/** 取消(删除)*/
- (void)cancleRecord;



@end
