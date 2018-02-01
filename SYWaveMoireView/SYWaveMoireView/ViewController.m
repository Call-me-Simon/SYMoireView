//
//  ViewController.m
//  SYMoireView
//
//  Created by Simon on 2018/1/30.
//  Copyright © 2018年 sunshixiang. All rights reserved.
//

#import "ViewController.h"
#import "SYMoireView.h"

#define mHexColor(hex) [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16))/255.0 green:((float)((hex & 0xFF00) >> 8))/255.0 blue:((float)(hex & 0xFF))/255.0 alpha:1.0]

@interface ViewController ()<SYMoireViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //默认圆形波浪
    CGFloat waveWidth = 160;
    SYMoireView *waveView = [[SYMoireView alloc]initWithFrame:CGRectMake(100, 100, waveWidth, waveWidth)];
    [self.view addSubview:waveView];
    waveView.clipsToBounds = YES;
    waveView.insideColors = @[(__bridge id)mHexColor(0x209b93).CGColor,(__bridge id)mHexColor(0x27a192).CGColor];//内层
    waveView.outsideColors = @[(__bridge id)mHexColor(0x3cb4a6).CGColor,(__bridge id)mHexColor(0x70cfac).CGColor];//外层
    waveView.percent = 0.7;
    waveView.isRound = YES;//是否是圆形
    waveView.waveAmplitude = 50;
    [waveView startWave];
    
    //自定义背景渐变-圆形波浪
    SYMoireView *customWave = [[SYMoireView alloc] initWithFrame:CGRectMake(10, 420, waveWidth, waveWidth)];
    [self.view addSubview:customWave];
    customWave.insideColors = @[(__bridge id)mHexColor(0x209b93).CGColor,(__bridge id)mHexColor(0x27a192).CGColor];//内层
    customWave.outsideColors = @[(__bridge id)mHexColor(0x3cb4a6).CGColor,(__bridge id)mHexColor(0x70cfac).CGColor];//外层
    customWave.percent = 0.4;
    customWave.delegate = self;
    [customWave startWave];
    
    
    //方形波浪
    SYMoireView *rectWave = [[SYMoireView alloc] initWithFrame:CGRectMake(200, 560, 140, 100)];
    [self.view addSubview:rectWave];
    rectWave.insideColors = @[(__bridge id)mHexColor(0x209b93).CGColor,(__bridge id)mHexColor(0x27a192).CGColor];//内层
    rectWave.outsideColors = @[(__bridge id)mHexColor(0x3cb4a6).CGColor,(__bridge id)mHexColor(0x70cfac).CGColor];//外层
    rectWave.percent = 0.7;
    rectWave.isRound = NO;
    rectWave.delegate = self;
    [rectWave startWave];
    
    // Do any additional setup after loading the view, typically from a nib.
}

//自定义背景渐变
- (void)drawBgGradient:(SYMoireView *)waveView context:(CGContextRef)context
{
    CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
    CGFloat compoents[8]={
        1.0,1.0,1.0,1.0,
        166/255.0,240/255.0,255.0/255.0,1
    };
    
    CGFloat locations[2]={0,0.7};
    CGGradientRef gradient= CGGradientCreateWithColorComponents(colorSpace, compoents, locations, 2);
    
    CGFloat width = CGRectGetWidth(waveView.frame);
    CGFloat height = CGRectGetHeight(waveView.frame);
    CGPoint center = CGPointMake(width/2, height/2);
    
    //    if (waveView == _rectWave) {
    //        //线性渐变
    //        CGContextDrawLinearGradient(context, gradient, CGPointMake(0, 0), CGPointMake(width, height), kCGGradientDrawsAfterEndLocation);
    //    } else {
    //径向渐变
    CGContextDrawRadialGradient(context, gradient, center,0, center, width/2, kCGGradientDrawsAfterEndLocation);
    //    }
    
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

