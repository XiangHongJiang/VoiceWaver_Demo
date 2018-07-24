//
//  GridsView.m
//  VoiceWaver_Demo
//
//  Created by MrYeL on 2018/7/24.
//  Copyright © 2018年 MrYeL. All rights reserved.
//

#import "GridsView.h"


@interface  GridsView()

/** 线宽度*/
@property (nonatomic, assign) CGFloat lineWidth;
/** 横轴数量*/
@property (nonatomic, assign) NSInteger xCount;
/** 横轴数量*/
@property (nonatomic, assign) NSInteger yCount;

@end

@implementation GridsView

- (void)configLineWidth:(CGFloat)width andXcount:(NSInteger)xCount yCount:(NSInteger)yCount {

    self.lineWidth = width;
    self.xCount = xCount;
    self.yCount = yCount;
    
    self.backgroundColor = [UIColor clearColor];
    
//    [self setNeedsDisplay];//重绘
    [self drawXYLine];
}
- (void)drawXYLine {
    
    if (self.lineWidth >0 && self.xCount) {
        
        
        UIBezierPath *path_X = [UIBezierPath bezierPath];//X轴
        UIBezierPath *path_Y = [UIBezierPath bezierPath];//Y轴
        
        CGFloat Xspace = (self.frame.size.width - (self.xCount - 1) *self.lineWidth)/self.xCount;
        CGFloat Ysapce = (self.frame.size.height - (self.yCount - 1) *self.lineWidth)/self.yCount;
        
        for (int i = 0; i < self.xCount - 1; i ++) {//画Y轴:竖线
            
            CGPoint point = CGPointMake(self.lineWidth * 0.5+Xspace + (Xspace + self.lineWidth)* i, self.frame.size.height);
            [path_X moveToPoint:point];
            [path_X addLineToPoint:CGPointMake(point.x,0)];
        }
        
        for (int i = 0; i < self.yCount - 1; i ++) {//画X轴:横线
            
            CGPoint point = CGPointMake(0,self.frame.size.height - Ysapce -(Ysapce + self.lineWidth)* i - self.lineWidth *0.5);
            [path_Y moveToPoint:point];
            [path_Y addLineToPoint:CGPointMake(self.frame.size.width,point.y)];
        }
        
        //3.渲染X路径
        CAShapeLayer *shapeLayer_X = [CAShapeLayer layer];
        shapeLayer_X.path = path_X.CGPath;
        shapeLayer_X.strokeColor = [UIColor whiteColor].CGColor;
        shapeLayer_X.fillColor = [UIColor whiteColor].CGColor;
        shapeLayer_X.lineWidth = self.lineWidth;
        [self.layer addSublayer:shapeLayer_X];
        
        //4.渲染Y路径
        CAShapeLayer *shapeLayer_Y = [CAShapeLayer layer];
        shapeLayer_Y.path = path_Y.CGPath;
        shapeLayer_Y.strokeColor = [UIColor whiteColor].CGColor;
        shapeLayer_Y.fillColor = [UIColor clearColor].CGColor;
        shapeLayer_Y.lineWidth = self.lineWidth;
        [self.layer addSublayer:shapeLayer_Y];
        
    }
    

}


- (void)drawRect:(CGRect)rect {
    
//    if (self.lineWidth >0 && self.xCount) {
//
//        CGContextRef ctx = UIGraphicsGetCurrentContext();
//
//        UIBezierPath *path_X = [UIBezierPath bezierPath];//X轴
//        UIBezierPath *path_Y = [UIBezierPath bezierPath];//Y轴
//
//        CGFloat Xspace = (rect.size.width - (self.xCount - 1) *self.lineWidth)/self.xCount;
//        CGFloat Ysapce = (rect.size.height - (self.yCount - 1) *self.lineWidth)/self.yCount;
//
//        for (int i = 0; i < self.xCount - 1; i ++) {//画Y轴:竖线
//
//            CGPoint point = CGPointMake(Xspace + Xspace * i, rect.size.height);
//            [path_X moveToPoint:point];
//            [path_X addLineToPoint:CGPointMake(point.x,0)];
//        }
//
//        for (int i = 0; i < self.yCount - 1; i ++) {//画X轴:横线
//
//            CGPoint point = CGPointMake(0, Ysapce + Ysapce * i);
//            [path_Y moveToPoint:point];
//            [path_Y addLineToPoint:CGPointMake(point.x,rect.size.width)];
//        }
//
//
//        // 设置线宽
//        CGContextSetLineWidth(ctx, self.lineWidth);
//        // 设置线的连接样式
//        CGContextSetLineJoin(ctx, kCGLineJoinRound);
//        // 设置线的顶角样式
//        CGContextSetLineCap(ctx, kCGLineCapSquare);
//        // 设置颜色
//        [[UIColor whiteColor] set];
//        // 3.把描述的内容添加到上下文
//        // UIBezierPath:UIKit框架 ,CGPathRef:CoreGraphics框架
//        CGContextAddPath(ctx, path_X.CGPath);
////        CGContextAddPath(ctx, path_Y.CGPath);
//
//        // 4.把上下文内容显示到View上(渲染到View的layer)
//        CGContextStrokePath(ctx);
//
//
//
//    }

}

@end
