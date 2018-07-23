//
//  VolumeWaverView.m
//  VoiceWaver_Demo
//
//  Created by MrYeL on 2018/7/20.
//  Copyright © 2018年 MrYeL. All rights reserved.
//

#import "VolumeWaverView.h"

@implementation VolumeWaverView

- (instancetype)initWithFrame:(CGRect)frame andType:(VolumeWaverType)type {

    if (self = [self initWithFrame:frame]) {
        
        self.showType = type;
    }
    return self;
    
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentMode = UIViewContentModeRedraw;
        self.backgroundColor = [UIColor cyanColor];
        //监听声波改变
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateView:) name:@"updateMeters" object:nil];

    }
    return self;
}
#pragma mark - Action
- (void)updateView:(NSNotification *)notice{
    
    self.soundMeters = notice.object;
    [self setNeedsDisplay];
}
- (void)drawRect:(CGRect)rect {
    
    if (self.soundMeters && self.soundMeters.count) {
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetLineCap(context, kCGLineCapRound);
        
        CGContextSetLineJoin(context, kCGLineJoinRound);
        
        CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
        
        CGFloat noVoice = 0.0;// 0db
        CGFloat maxVolume = 110.0; //110db
        
        switch (self.showType) {
            case VolumeWaverType_Bar:{
                
                CGFloat lineWidth = (self.frame.size.width - (Xcount - 1) *Xmargin)/Xcount;
                
                CGContextSetLineWidth(context, lineWidth);
                
                for (int i = 0; i < self.soundMeters.count; i ++) {
                    
                    CGFloat soundValue = [self.soundMeters[self.soundMeters.count - i - 1] floatValue];
                    CGFloat barHeight = soundValue /maxVolume * self.frame.size.height;
                    CGPoint point = CGPointMake(i * (lineWidth + Xmargin), 60);
                    CGContextMoveToPoint(context, point.x, point.y);
                    CGContextAddLineToPoint(context, point.x, barHeight);

                }
            }
                break;
                
            case VolumeWaverType_Line:{
                CGFloat lineWidth = 1.5;
                CGContextSetLineWidth(context, lineWidth);
                for (int i = 0; i < self.soundMeters.count; i ++) {
                    
                    CGFloat soundValue = [self.soundMeters[i] floatValue];
                    CGFloat barHeight = maxVolume - (soundValue - noVoice);
                    
                    CGPoint point = CGPointMake(i * (lineWidth + Xmargin), 60);
                    
                    CGContextAddLineToPoint(context, point.x, barHeight);
                    CGContextMoveToPoint(context, point.x, barHeight);

                }
                
            }
                
                break;
                
            default:
                break;
        }
        
        CGContextStrokePath(context);
        
    }
   
}
@end
