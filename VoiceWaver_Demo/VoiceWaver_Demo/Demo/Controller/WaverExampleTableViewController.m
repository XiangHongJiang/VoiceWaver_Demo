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
    
    self.navigationItem.title = @"波形图";
    self.dataArray = @[@"启用",@"暂停",@"取消"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    
    [self configRecorder];
    
    self.tableView.tableHeaderView = [self headerView];
    
    
    self.soundMeterCount = 20;
    self.updateFequency = 0.25/self.soundMeterCount;
    
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
        [recordSetting setValue:[NSNumber numberWithFloat:44100] forKey:AVSampleRateKey];
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
    
    float   decibels = [self.recorder averagePowerForChannel:0];
    [self addSoundMeter:decibels];

   
    if (self.recordTime > 60.0) {
        //end
        [self cancle];
    }
}
- (void)addSoundMeter:(CGFloat)itemValue {
    
    if (self.soundMeters.count > self.soundMeterCount - 1) {

        [self.soundMeters removeAllObjects];

    }
    [self.soundMeters addObject:@(itemValue)];
    
    if (self.soundMeters.count == self.soundMeterCount) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateMeters" object:self.soundMeters];

    }
    
    

  
}

@end
