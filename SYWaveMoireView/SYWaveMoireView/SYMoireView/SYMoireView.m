//
//  SYMoireView.m
//  SYMoireView
//
//  Created by Simon on 2018/1/30.
//  Copyright © 2018年 sunshixiang. All rights reserved.
//

#import "SYMoireView.h"

@interface SYMoireView ()
{
    CAShapeLayer *_insideWaveLayer;         //内层水波纹layer
    CAShapeLayer *_outsideWaveLayer;        //外层水波纹layer
    CAGradientLayer *_insideGradientLayer;  //内层水波纹渐变layer
    CAGradientLayer *_outsideGradientLayer; //外层水波纹渐变layer
    
    CADisplayLink *_waveDisplaylink;        //CADisplaylink 是一个计时器对象，可以使用这个对象来保持绘制与显示刷新的同步
    
    float variable;                         // 可变参数 更加真实 模拟波纹
    BOOL increase;                          // 增减变化
    CGFloat waterWaveWidth;                 // 宽度
    CGFloat offsetX;                        // 波浪x位移
    CGFloat currentWavePointY;              // 当前波浪上升高度Y
    CGFloat kExtraHeight;                   // 保证水波波峰不被裁剪，增加部分额外的高度
}
@end

@implementation SYMoireView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self inital];
    }
    return self;
}

#pragma mark --- 初始化
-(void)inital
{
    
    self.percent = 0;
    self.waveAmplitude = 0;
    self.waveGrowth = 1.00;
    self.waveSpeed = 0.2/M_PI;
    self.isRound = YES;
    if (self.isRound) {
        self.layer.cornerRadius = CGRectGetWidth(self.frame)/2.0;
        self.layer.masksToBounds = YES;
    }
    
    waterWaveWidth  = CGRectGetWidth(self.frame);
    if (waterWaveWidth > 0) {
        self.waveCycle =  1.29 * M_PI / waterWaveWidth;
    }
    
    [self resetProperty];
}

#pragma mark --- 重置数据
- (void)resetProperty
{
    currentWavePointY = CGRectGetHeight(self.frame) * self.percent;
    
    offsetX = 0;
    variable = 1.6;
    increase = NO;
    
    kExtraHeight = 0;
    if (_percent>0 && _percent<1) {
        kExtraHeight = 20;
    }
}

#pragma mark --- 开始波纹
-(void)startWave
{
    //添加水波纹layer
    if (!_insideWaveLayer) {//创建内层水波纹layer
        _insideWaveLayer = [CAShapeLayer layer];
    }
    
    if (!_outsideWaveLayer) {//创建外层水波纹layer
        _outsideWaveLayer = [CAShapeLayer layer];
    }
    
    //添加水波纹渐变layer
    if (_insideGradientLayer) {
        [_insideGradientLayer removeFromSuperlayer];
        _insideGradientLayer = nil;
    }
    
    _insideGradientLayer = [CAGradientLayer layer];
    _insideGradientLayer.frame = [self gradientLayerFrame];
    [_insideGradientLayer setMask:_insideWaveLayer];
    [self.layer addSublayer:_insideGradientLayer];
    
    if (_outsideGradientLayer) {
        [_outsideGradientLayer removeFromSuperlayer];
        _outsideGradientLayer = nil;
    }
    
    _outsideGradientLayer = [CAGradientLayer layer];
    _outsideGradientLayer.frame = [self gradientLayerFrame];
    [_outsideGradientLayer setMask:_outsideWaveLayer];
    [self.layer addSublayer:_outsideGradientLayer];
    
    //设置渐变层颜色
    [self setupGradientLayerColor];
    
    //启动定时调用
    if (_waveDisplaylink) {
        [_waveDisplaylink invalidate];
        _waveDisplaylink = nil;
    }
    
    _waveDisplaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(getCurrentWave:)];
    [_waveDisplaylink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

#pragma mark --- 设置渐变层frame
-(CGRect)gradientLayerFrame
{
    CGFloat gradientLayerHeight = CGRectGetHeight(self.frame) * self.percent;
    if (gradientLayerHeight > CGRectGetHeight(self.frame)) {
        gradientLayerHeight = CGRectGetHeight(self.frame);
    }
    
    CGRect rect = CGRectMake(0, CGRectGetHeight(self.frame) - gradientLayerHeight, CGRectGetWidth(self.frame), gradientLayerHeight);
    
    return rect;
}

#pragma mark --- 设置渐变层颜色
- (void)setupGradientLayerColor
{
    if (self.insideColors.count < 1) self.insideColors = [self defaultColors];
    if (self.outsideColors.count < 1) self.outsideColors = [self defaultColors];
    
    _insideGradientLayer.colors = self.insideColors;
    _outsideGradientLayer.colors = self.outsideColors;
    
    //设置颜色分割点
    NSInteger nums = 1.0/self.insideColors.count;       //分割点数量
    NSMutableArray *locations = [NSMutableArray array];
    for (NSInteger i = 0; i < nums; i ++) {
        NSNumber *nub = @(nums + nums * i);
        [locations addObject:nub];
    }
    [locations addObject:@(1.0)];
    
//    _insideGradientLayer.locations = locations;
//    _outsideGradientLayer.locations = locations;
    
    //设置渐变的方向 (0,0) --> (1,0)垂直方向 (0,0) --> (1,1) 从左上角到右下角
    _insideGradientLayer.startPoint = CGPointMake(0, 0);
    _insideGradientLayer.endPoint = CGPointMake(1, 0);
    
    _outsideGradientLayer.startPoint = CGPointMake(0, 0);
    _outsideGradientLayer.endPoint = CGPointMake(1, 0);
}

#pragma mark --- layer默认颜色
-(NSArray *)defaultColors
{
    // 默认的渐变色
    UIColor *color0 = [UIColor colorWithRed:166 / 255.0 green:240 / 255.0 blue:255 / 255.0 alpha:0.5];
    UIColor *color1 = [UIColor colorWithRed:240 / 255.0 green:250 / 255.0 blue:255 / 255.0 alpha:0.5];
    
    NSArray *colors = @[(__bridge id)color0.CGColor, (__bridge id)color1.CGColor];
    return colors;
}

#pragma mark --- 获取实时波动，绘制path
-(void)getCurrentWave:(CADisplayLink *)displaylink
{
    [self animateWave];
    
    if (![self waveFinished]) {
        currentWavePointY -= self.waveGrowth;
    }
    
    // 波浪位移
    offsetX += self.waveSpeed;
    
    [self setCurrentInsideWaveLayerPath];
    
    [self setCurrentOutsideWaveLayerPath];
}

#pragma mark --- 设置内层layer path
-(void)setCurrentInsideWaveLayerPath
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat y = currentWavePointY;
    CGPathMoveToPoint(path, nil, 0, y);
    for (float x = 0.0f; x <=  waterWaveWidth ; x++) {
        // 正弦波浪公式
        y = self.waveAmplitude * sin(self.waveCycle * x + offsetX) + currentWavePointY;
        CGPathAddLineToPoint(path, nil, x, y);
    }
    
    CGPathAddLineToPoint(path, nil, waterWaveWidth, self.frame.size.height);
    CGPathAddLineToPoint(path, nil, 0, self.frame.size.height);
    CGPathCloseSubpath(path);
    
    _insideWaveLayer.path = path;
    CGPathRelease(path);
}

#pragma mark --- 设置外层layer path
-(void)setCurrentOutsideWaveLayerPath
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat y = currentWavePointY;
    CGPathMoveToPoint(path, nil, 0, y);
    for (float x = 0.0f; x <=  waterWaveWidth ; x++) {
        // 余弦波浪公式
        y = self.waveAmplitude * cos(self.waveCycle * x + offsetX) + currentWavePointY;
        CGPathAddLineToPoint(path, nil, x, y);
    }
    
    CGPathAddLineToPoint(path, nil, waterWaveWidth, self.frame.size.height);
    CGPathAddLineToPoint(path, nil, 0, self.frame.size.height);
    CGPathCloseSubpath(path);
    
    _outsideWaveLayer.path = path;
    CGPathRelease(path);
}

#pragma mark --- 可变振幅
-(void)animateWave
{
    if (increase) {
        variable += 0.01;
    }else{
        variable -= 0.01;
    }
    
    if (variable <= 1.0) {
        increase = YES;
    }else if (variable >= 1.6) {
        increase = NO;
    }
    
    //可变振幅
    self.waveAmplitude = variable * 3;
}

#pragma mark --- 波浪上升动画是否完成
- (BOOL)waveFinished
{
    // 波浪上升动画是否完成
    CGFloat d = CGRectGetHeight(self.frame) - CGRectGetHeight(_insideGradientLayer.frame);
    CGFloat extraH = MIN(d, kExtraHeight);
    BOOL bFinished = currentWavePointY <= extraH;
    
    return bFinished;
}

#pragma mark --- 停止波动
-(void)stopWave
{
    [_waveDisplaylink invalidate];
    _waveDisplaylink = nil;
}

#pragma mark --- 继续波动
- (void)goOnWave
{
    if (_waveDisplaylink) {
        [self stopWave];
    }
    
    // 启动定时调用
    _waveDisplaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(getCurrentWave:)];
    [_waveDisplaylink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

#pragma mark --- 清空波浪
- (void)resetWave
{
    [self stopWave];
    [self resetProperty];
    
    [_insideWaveLayer removeFromSuperlayer];
    _insideWaveLayer = nil;
    [_outsideWaveLayer removeFromSuperlayer];
    _outsideWaveLayer = nil;
    
    [_insideGradientLayer removeFromSuperlayer];
    _insideGradientLayer = nil;
    [_outsideGradientLayer removeFromSuperlayer];
    _outsideGradientLayer = nil;
}

#pragma mark --- set 
- (void)setPercent:(CGFloat)percent
{
    _percent = percent;
    currentWavePointY = CGRectGetHeight(self.frame) * self.percent;
    if (_percent>0 && _percent<1) {
        kExtraHeight = 20;
    }
}

-(void)setIsRound:(BOOL)isRound
{
    if (isRound) {
        self.layer.cornerRadius = CGRectGetWidth(self.frame)/2.0;
        self.layer.masksToBounds = YES;
    }else{
        self.layer.cornerRadius = 0;
        self.layer.masksToBounds = YES;
    }
}

#pragma mark 背景渐变
- (void)drawRect:(CGRect)rect
{
    CGContextRef context=UIGraphicsGetCurrentContext();
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(drawBgGradient:context:)]) {
        [self.delegate drawBgGradient:self context:context];
    } else {
        //默认径向渐变
        [self drawRadialGradient:context];
    }
}

-(void)drawRadialGradient:(CGContextRef)context{
    //使用rgb颜色空间
    CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
    
    /*指定渐变色
     space:颜色空间
     components:颜色数组,注意由于指定了RGB颜色空间，那么四个数组元素表示一个颜色（red、green、blue、alpha），
     如果有三个颜色则这个数组有4*3个元素
     locations:颜色所在位置（范围0~1），这个数组的个数不小于components中存放颜色的个数
     count:渐变个数，等于locations的个数
     */
    CGFloat compoents[8]={
        1.0,1.0,1.0,1.0,
        241.0/255.0,251.0/255.0,255.0/255.0,1
    };
    
    CGFloat locations[2]={0,0.4};
    CGGradientRef gradient= CGGradientCreateWithColorComponents(colorSpace, compoents, locations, 2);
    
    /*绘制径向渐变
     context:图形上下文
     gradient:渐变色
     startCenter:起始点位置
     startRadius:起始半径（通常为0，否则在此半径范围内容无任何填充）
     endCenter:终点位置（通常和起始点相同，否则会有偏移）
     endRadius:终点半径（也就是渐变的扩散长度）
     options:绘制方式,kCGGradientDrawsBeforeStartLocation 开始位置之前就进行绘制，但是到结束位置之后不再绘制，
     kCGGradientDrawsAfterEndLocation开始位置之前不进行绘制，但到结束点之后继续填充
     */
    CGPoint center = CGPointMake(waterWaveWidth/2, waterWaveWidth/2);
    CGContextDrawRadialGradient(context, gradient, center,0, center, waterWaveWidth/2, kCGGradientDrawsAfterEndLocation);
    //释放颜色空间
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
}

#pragma mark --- dealloc
- (void)dealloc
{
    [self resetWave];
}

@end
