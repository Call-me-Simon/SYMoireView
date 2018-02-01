//
//  SYMoireView.h
//  SYMoireView
//
//  Created by Simon on 2018/1/30.
//  Copyright © 2018年 sunshixiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SYMoireView;
@protocol SYMoireViewDelegate <NSObject>

@optional
//自定义背景渐变
- (void)drawBgGradient:(SYMoireView*)waveView context:(CGContextRef)context;

@end

@interface SYMoireView : UIView

@property (nonatomic, assign) CGFloat percent;           // 百分比 (默认:0)
@property (nonatomic, assign) BOOL isRound;              // 圆形/方形 (默认:YES)
@property (nonatomic, assign) CGFloat waveAmplitude;     // 波纹振幅 (默认:0)
@property (nonatomic, assign) CGFloat waveCycle;         // 波纹周期 (默认:1.29 * M_PI / self.frame.size.width)
@property (nonatomic, assign) CGFloat waveSpeed;         // 波纹速度 (默认:0.2/M_PI)
@property (nonatomic, assign) CGFloat waveGrowth;        // 波纹上升速度 (默认:1.00)

@property (nonatomic, strong) NSArray *insideColors;     // 内层渐变的颜色数组 (有默认颜色)
@property (nonatomic, strong) NSArray *outsideColors;    // 外层渐变的颜色数组 (有默认颜色)

@property (nonatomic, weak) id <SYMoireViewDelegate>delegate;

// 开始波浪
- (void)startWave;
// 停止波动
- (void)stopWave;
// 继续波动
- (void)goOnWave;
// 清空波浪
- (void)resetWave;

@end
