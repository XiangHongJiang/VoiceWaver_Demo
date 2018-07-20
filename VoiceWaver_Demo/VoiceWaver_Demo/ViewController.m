//
//  ViewController.m
//  VoiceWaver_Demo
//
//  Created by MrYeL on 2018/7/20.
//  Copyright © 2018年 MrYeL. All rights reserved.
//

#import "ViewController.h"
#import "WaverExampleTableViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UILabel* tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];
    tipLabel.text = @"点击一下去使用";
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.center = self.view.center;
    [self.view addSubview:tipLabel];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self.navigationController pushViewController:[WaverExampleTableViewController new] animated:YES];
    //    [self presentViewController:[LogsExampleTableViewController new] animated:YES completion:nil];
}


@end
