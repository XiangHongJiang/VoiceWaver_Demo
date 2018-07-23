//
//  WaverExampleTableViewController.m
//  VoiceWaver_Demo
//
//  Created by MrYeL on 2018/7/20.
//  Copyright © 2018年 MrYeL. All rights reserved.
//

#import "WaverExampleTableViewController.h"

#import "VolumeWaverView.h"
#import <AVFoundation/AVFoundation.h>

@interface WaverExampleTableViewController ()<AVAudioRecorderDelegate>

/** 音频视图*/
@property (nonatomic, strong) VolumeWaverView * volume;

/** AVAudioRecorder*/
@property (nonatomic, strong) AVAudioRecorder * recorder;
/** timer录音计时器*/
@property (nonatomic, strong) NSTimer * timer;
/** updateFequency波形更新间隔*/
@property (nonatomic, assign) CGFloat updateFequency;
/** recordTime录音时间*/
@property (nonatomic, assign) CGFloat recordTime;
/** soundMeterCount声音数据数组容量*/
@property (nonatomic, assign) NSInteger soundMeterCount;
/** soundMeters声音数据数组*/
@property (nonatomic, strong) NSMutableArray * soundMeters;


/** 数据Array*/
@property (nonatomic, copy) NSArray * dataArray;

@end


@implementation WaverExampleTableViewController

- (NSMutableArray *)soundMeters {
    
    if (_soundMeters == nil) {
        _soundMeters = [NSMutableArray new];
    }
    return _soundMeters;
}

- (VolumeWaverView *)volume {
    
    if (_volume == nil) {
        _volume = [[VolumeWaverView alloc] initWithFrame:CGRectMake(0, 70, 375, 60) andType:VolumeWaverType_Bar];
    }
    return _volume;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    
    self.navigationItem.title = @"波形图";
    self.dataArray = @[@"启用",@"暂停",@"取消"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    
    [self configRecorder];
    
    self.tableView.tableHeaderView = [self headerView];
    
    self.soundMeterCount = Xcount;
    self.updateFequency = 0.25/self.soundMeterCount;//0.5/self.soundMeterCount;//100毫秒刷新一次

}
- (UIView *)headerView {
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 375, 200)];
    contentView.backgroundColor = [UIColor whiteColor];
    [contentView addSubview:self.volume];
    return contentView;
    
}
- (void)configRecorder {
    
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
        [recordSetting setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSURL *)url {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [path stringByAppendingPathComponent:@"test_voice.caf"];
    NSURL *url =  [NSURL fileURLWithPath:filePath];
    NSLog(@"filePath:\n%@",filePath);
    return url;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    cell.textLabel.text = self.dataArray[indexPath.row];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case 0:
            [self start];
            break;
        case 1:
            [self pause];
            break;
        case 2:
            [self cancle];
            break;
        default:
            break;
    }
    
}
#pragma mark - Action
- (void)start {
    if (!self.recorder) return;
    
    [self.recorder record];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.updateFequency target:self selector:@selector(updateMeters) userInfo:nil repeats:YES];
}
- (void)pause {
    
}
- (void)cancle {
    
}
- (void)updateMeters {
    
    [self.recorder updateMeters];
    self.recordTime += self.updateFequency;
    
    //分贝值
    float db = [self test2];
//    [self test1];
    [self test3];
   
    //赋值
    [self addSoundMeter:db];
    
   //结束
    if (self.recordTime > 60.0) {
        //end
        [self cancle];
    }
}
- (void)addSoundMeter:(CGFloat)itemValue {
    
    if (self.soundMeters.count > self.soundMeterCount - 1) {//清除
        [self.soundMeters removeAllObjects];
    }
    
    [self.soundMeters addObject:@(itemValue)];//收集
   
    if (self.soundMeters.count == self.soundMeterCount) {//刷新视图
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateMeters" object:self.soundMeters];
    }
  
}
- (void)postSound {
    
//    if (self.soundMeters.count == self.soundMeterCount) {
//
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateMeters" object:self.soundMeters];
//    }
    
}
- (float)test1 {
    float   level;
    float   minDecibels = -60.0f;
    float   decibels    = [self.recorder averagePowerForChannel:0];
    if (decibels < minDecibels)    {
        level = 0.0f;
    }    else if (decibels >= 0.0f)    {
        level = 1.0f;
    }    else    {
        float   root = 2.0f;
        float   minAmp = powf(10.0f, 0.05f * minDecibels);
        float   inverseAmpRange = 1.0f / (1.0f - minAmp);
        float   amp = powf(10.0f, 0.05f * decibels);
        float   adjAmp = (amp - minAmp) * inverseAmpRange;
        level = powf(adjAmp, 1.0f / root);
    }
    double dB = level*85;
    NSLog(@"dB = %f", dB);
    
    return dB;

}

- (float)test2 {// 0 ~ 110  
    
    float power = [self.recorder averagePowerForChannel:0];// -160  ~  0;
    
    CGFloat progress = (1.0 / 160.0) * (power + 160.0);// -160 ~ 0;
    
    power = power + 160  - 40;//  + 120?
    
    double dB = 0;
    if (power < 0.f) {
        dB = 0;
    } else if (power < 40.f) {//0-35
        dB = (int)(power * 0.875);
    } else if (power < 100.f) {//25-85
        dB = (int)(power - 15);
    } else if (power < 110.f) {//85-110
        dB = (int)(power * 2.5 - 165);
    } else {
        dB = 110;
    }
    
    NSLog(@"progress = %f, dB = %f", progress, dB);
    return dB;
    
}

- (float)test3 {
    CGFloat agv = pow(10, (0.05 * [self.recorder averagePowerForChannel:0]));
    double dB = agv*100 ;
    NSLog(@"test3: %f",dB);
 
    return dB;
}

@end
