//
//  CrashManager.h
//  VoiceWaver_Demo
//
//  Created by MrYeL on 2018/7/24.
//  Copyright © 2018年 MrYeL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CrashManager : NSObject

void uncaughtExceptionHandler(NSException *exception);

@end
