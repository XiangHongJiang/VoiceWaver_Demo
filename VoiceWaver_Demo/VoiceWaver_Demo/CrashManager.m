//
//  CrashManager.m
//  VoiceWaver_Demo
//
//  Created by MrYeL on 2018/7/24.
//  Copyright © 2018年 MrYeL. All rights reserved.
//

#import "CrashManager.h"

@implementation CrashManager
/** 奔溃调用*/
void uncaughtExceptionHandler(NSException *exception)  {
    
    //获取系统当前时间，（注：用[NSDate date]直接获取的是格林尼治时间，有时差）
    NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *crashTime = [formatter stringFromDate:[NSDate date]];
    
    //异常处堆栈
    NSArray *stackArr = [exception callStackSymbols];
    
    //异常原因
    NSString *reason = [exception reason];
    
    //异常名称
    NSString *name = [exception name];
    
    //拼接错误信息
    NSString *exceptionInfo = [NSString stringWithFormat:@"\ncrashTime: %@ \nException reason: %@\nException name: %@\nException stack:%@", crashTime, name, reason, stackArr];
    
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    [dict setObject:crashTime.length?crashTime:@"" forKey:@"crashTime"];
    [dict setObject:reason.length?reason:@"" forKey:@"Exception_reason"];
    [dict setObject:name.length?name:@"" forKey:@"Exception_name"];
    [dict setObject:stackArr forKey:@"Exception_stack"];
    
    NSLog(@"%@",exceptionInfo);

    
}
@end
