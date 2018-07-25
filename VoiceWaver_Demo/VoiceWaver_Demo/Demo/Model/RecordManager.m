//
//  RecordManager.m
//  VoiceWaver_Demo
//
//  Created by MrYeL on 2018/7/24.
//  Copyright © 2018年 MrYeL. All rights reserved.
//

#import "RecordManager.h"

static RecordManager *shareRecord = nil;

@interface RecordManager ()<AVAudioRecorderDelegate>

/** 倒计时*/
@property (nonatomic, strong) NSTimer * countTimer;

/** 倒计时数量*/
@property (nonatomic, assign) int count;


@end

@implementation RecordManager
#pragma mark - lazyLoad
- (NSTimer *)timer {
    
    if (_timer == nil) {
        CGFloat time = self.updateFequency;
        if (self.type == RecordValuePostType_FullCount) {
          time = self.updateFequency /self.soundMeterCount;
        }
        _timer = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(updateMeters) userInfo:nil repeats:YES];
        
    }
    return _timer;
}
- (NSTimer *)countTimer
{
    if(!_countTimer){
        _countTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
    }
    return _countTimer;
}
- (NSMutableArray *)soundMeters {
    if (_soundMeters == nil) {
        
        _soundMeters = [NSMutableArray new];
    }
    return _soundMeters;
}
/** 录音工具的单例 */
+ (instancetype)sharedRecordTool {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        shareRecord = [[RecordManager alloc] init];
    });
    return shareRecord;
    
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [self initial];
        
    }
    return self;
}
#pragma mark - Config
/** 初始化默认值*/
- (void)initial {
    
    self.soundMeterCount = 3;
    self.updateFequency = 0.25;
    self.maxSecond = 60;
    self.count = self.maxSecond;
    self.type = RecordValuePostType_FullCount;
    
    [self configRecord];

}
/** 配置record*/
- (void)configRecord {
    
    //判断是否可用
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *sessionError;
    [session requestRecordPermission:^(BOOL granted) {
        if (!granted) {
            return;
        }
    }];
    
    if( [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:&sessionError]){
        NSLog(@"session config Succeed");
        
        //录音设置
        NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
        //设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）, 采样率必须要设为11025才能使转化成mp3格式后不会失真
        [recordSetting setValue:[NSNumber numberWithFloat:11025] forKey:AVSampleRateKey];
        //录音的质量
        [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityLow] forKey:AVEncoderAudioQualityKey];
        //录音通道数  1 或 2 ，要转换成mp3格式必须为双通道 : 音轨
        [recordSetting setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
        //设置录音格式  AVFormatIDKey==kAudioFormatLinearPCM
        [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
        //线性采样位数  8、16、24、32
        [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        
        self.recorder = [[AVAudioRecorder alloc] initWithURL:[self url] settings:recordSetting error:nil];
        
        self.recorder.delegate = self;
        [self.recorder prepareToRecord];
        [self.recorder setMeteringEnabled:YES];
        [session setActive:YES error:nil];
        
    }else {
        NSLog(@"session config failed");
    }
}
#pragma mark - Setter and Getter
- (NSURL *)url {
 
    NSURL *url =  [NSURL fileURLWithPath:self.filePath];
    NSLog(@"filePath:\n%@",_filePath);
    return url;
}

- (NSString *)filePath {
    
    if (!_filePath) {
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        _filePath = [path stringByAppendingPathComponent:@"test_voice.caf"];
    }
    return _filePath;
}
#pragma mark - Method Action
- (void)startRecord {
    if (!self.recorder || self.recorder.isRecording) return;
    
    [self.recorder record];
    [self.timer setFireDate:[NSDate distantPast]];
    [self.countTimer setFireDate:[NSDate distantPast]];

}

- (void)pauseRecord {
    [self.timer setFireDate:[NSDate distantFuture]];
    [self.countTimer setFireDate:[NSDate distantFuture]];

    [self.recorder stop];
}

- (void)cancleRecord {

    [self finished];
    
    //删除文件
    [self destructionRecordingFile];
}
- (void)finished {
    [self.timer invalidate];
    self.timer = nil;
    
    [self.countTimer invalidate];
    self.countTimer = nil;
    
    [self.recorder stop];
    self.recordTime = 0;
    self.count = self.maxSecond;
    
    if (self.returnTime) {
        self.returnTime(nil, self.maxSecond);
    }
    
}
#pragma mark -  Timmer
- (void)updateMeters {
    
    [self.recorder updateMeters];
    if (self.type == RecordValuePostType_FullTime) {
        self.recordTime += self.updateFequency;

    }else {
        self.recordTime += (self.updateFequency/self.soundMeterCount);
    }
    
    float   decibels = [self.recorder averagePowerForChannel:0];
    [self addSoundMeter:decibels];
    
    if (self.recordTime > self.maxSecond) {
        //end
        [self finished];
    }
}
- (void)addSoundMeter:(CGFloat)itemValue {
    
        if (self.soundMeters.count > self.soundMeterCount - 1) {
            
            if (self.type == RecordValuePostType_FullCount) {
                [self.soundMeters removeAllObjects];
            }else {
                [self.soundMeters removeObjectAtIndex:0];
            }
        }
    
        [self.soundMeters addObject:@(itemValue)];
    
    if (self.type == RecordValuePostType_FullTime) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateMeters" object:self.soundMeters];

    }else {
        
        if (self.soundMeters.count == self.soundMeterCount) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateMeters" object:self.soundMeters];

        }
    }
    
}
#pragma mark - 倒计时
- (void)timerFired:(NSTimer *)_timer
{
    if (self.returnTime) {
        _count --;
        if (_count < 0) {
            _count = _maxSecond;
          
            [self finished];
        }
        self.returnTime(_timer,_count);
    }
}

- (void)destructionRecordingFile {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([self url]) {
        [fileManager removeItemAtURL:[self url] error:NULL];
    }
}
@end
