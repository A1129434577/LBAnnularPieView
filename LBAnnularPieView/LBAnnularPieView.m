//
//  LBAnnularPieView.m
//  LBAnnularPieView
//
//  Created by 刘彬 on 2017/9/9.
//  Copyright © 2017年 liubin. All rights reserved.
//

#import "LBAnnularPieView.h"

@interface LBAnnularPieView ()
@property (nonatomic, strong) CAShapeLayer *defaultShapeLayer;

@property (nonatomic, assign) CGPoint centerPoint;


@property (nonatomic, strong) NSMutableArray<NSNumber *> *startAngleArray;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *itemCenterAngleArray;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *endAngleArray;

@property (nonatomic, strong) NSMutableArray<NSString *> *itemCenterAngleRightArray;
@property (nonatomic, strong) NSMutableArray<NSString *> *itemCenterAngleLeftArray;

@property (nonatomic, strong) NSMutableArray<NSTimer *>  *allTimerArray;


@property (nonatomic, strong) NSMutableArray<NSNumber *> *timeStartArray;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *durationArray;

@property (nonatomic, assign) CGFloat rightAverageHeight;
@property (nonatomic, assign) CGFloat leftAverageHeight;

@end


@implementation LBAnnularPieView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.centerPoint = CGPointMake(frame.size.width/2, frame.size.height/2);
        self.lineWidth = 40;
        self.radius = MIN(CGRectGetWidth(frame), CGRectGetHeight(frame))/2-self.lineWidth/2;
        self.textFont = [UIFont systemFontOfSize:14];
        self.startAngle = -M_PI;
        self.animationDuration = 1.5f;
        self.leadLineWidth = 1;
        
        self.showAnimation = YES;
        self.showItemText = YES;
    }
    
    return self;
}

- (void)strokePath {
    [self removeAllSubLayers];
    
    [self drawDefaultPie];
    
    [self.allTimerArray enumerateObjectsUsingBlock:^(NSTimer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj invalidate];
    }];
    
    [self loadSubviewLayers];
    
}

- (void)loadSubviewLayers {
    self.allTimerArray = [NSMutableArray array];
    for (NSInteger i=0; i<self.valueArray.count; i++) {
        if (self.isShowAnimation) {
            NSDictionary * userInfo = @{@"index":@(i)};
            NSTimer * timer = [NSTimer timerWithTimeInterval:[self.timeStartArray[i] floatValue] target:self selector:@selector(timerAction:) userInfo:userInfo repeats:NO];
            [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
            [self.allTimerArray addObject:timer];
        }else {
            [self drawEachPieWithIndex:i];
        }
    }
}

#pragma mark - 定时器
- (void)timerAction:(NSTimer *)sender{
    NSInteger index = [[sender.userInfo objectForKey:@"index"] integerValue];
    [self drawEachPieWithIndex:index];
    
    [sender invalidate];
    sender = nil;
}

- (void)setValueArray:(NSMutableArray *)valueArray {
    _valueArray = valueArray;
    
    //计算开始和持续时间数组
    self.timeStartArray = [NSMutableArray array];
    self.durationArray = [NSMutableArray array];
    CGFloat startTime = 0.5f;
    [self.timeStartArray  addObject:[NSNumber numberWithFloat:startTime]];
    for (NSInteger i=0; i<valueArray.count; i++) {
        self.durationArray[i] = [NSNumber numberWithFloat:[valueArray[i] floatValue] * self.animationDuration];
        startTime += [valueArray[i] floatValue] * self.animationDuration;
        [self.timeStartArray  addObject:[NSNumber numberWithFloat:startTime]];
    }
    //计算开始和结束角度数组
    self.startAngleArray = [NSMutableArray array];
    self.endAngleArray = [NSMutableArray array];
    self.itemCenterAngleArray = [NSMutableArray array];
    self.itemCenterAngleRightArray = [NSMutableArray array];

    NSMutableArray<NSString *> *secondQuadrantCenterAngleArray = [NSMutableArray array];
    NSMutableArray<NSString *> *thirdQuadrantCenterAngleArray = [NSMutableArray array];

    CGFloat startAngle = self.startAngle, endAngle;
    for (NSInteger i=0; i<valueArray.count; i++) {
        [self.startAngleArray  addObject:[NSNumber numberWithFloat:startAngle]];
        endAngle = startAngle + [self.valueArray[i] floatValue] * 2 * M_PI;
        [self.endAngleArray  addObject:[NSNumber numberWithFloat:endAngle]];
        
        CGFloat centerAngle = (startAngle + (endAngle-startAngle)/2.0);
        [self.itemCenterAngleArray addObject:[NSNumber numberWithFloat:(startAngle + (endAngle-startAngle)/2.0)]];
        
        
        CGFloat standardCenterAngle = fabs(centerAngle)-(int)(centerAngle/(2*M_PI));//换算成一个2*M_PI内坐标
        if (centerAngle<0) {
            standardCenterAngle = 2*M_PI-standardCenterAngle;
        }
        if ((standardCenterAngle>=M_PI/2*3 && standardCenterAngle<2*M_PI) ||
            (standardCenterAngle>=0 && standardCenterAngle<M_PI/2)) {//右半边
            [self.itemCenterAngleRightArray addObject:[NSString stringWithFormat:@"%.4f",standardCenterAngle]];
        }
        else if (standardCenterAngle>=M_PI/2 && standardCenterAngle<M_PI) {//第三象限
            [thirdQuadrantCenterAngleArray addObject:[NSString stringWithFormat:@"%.4f",standardCenterAngle]];
        }
        else if (standardCenterAngle>=M_PI && standardCenterAngle<M_PI/2*3) {//第二象限
            [secondQuadrantCenterAngleArray addObject:[NSString stringWithFormat:@"%.4f",standardCenterAngle]];
        }
        
        startAngle = endAngle;
    }
    self.itemCenterAngleRightArray = [self.itemCenterAngleRightArray objectEnumerator].allObjects.mutableCopy;
    
    secondQuadrantCenterAngleArray = [secondQuadrantCenterAngleArray objectEnumerator].allObjects.mutableCopy;
    thirdQuadrantCenterAngleArray = [thirdQuadrantCenterAngleArray objectEnumerator].allObjects.mutableCopy;
    
    [thirdQuadrantCenterAngleArray addObjectsFromArray:secondQuadrantCenterAngleArray];
    self.itemCenterAngleLeftArray = thirdQuadrantCenterAngleArray;
    
    _rightAverageHeight = CGRectGetHeight(self.bounds)/self.itemCenterAngleRightArray.count;
    _leftAverageHeight = CGRectGetHeight(self.bounds)/self.itemCenterAngleLeftArray.count;
}

- (void)drawDefaultPie {
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:self.centerPoint radius:self.radius startAngle:0 endAngle:2*M_PI clockwise:YES];
    CAShapeLayer *defaultShapeLayer = [CAShapeLayer new];
    defaultShapeLayer.path = [path CGPath];
    defaultShapeLayer.lineWidth = self.lineWidth;
    if (@available(iOS 13.0, *)) {
        defaultShapeLayer.strokeColor = [UIColor systemGroupedBackgroundColor].CGColor;
    } else {
        defaultShapeLayer.strokeColor = [UIColor groupTableViewBackgroundColor].CGColor;
    }
    defaultShapeLayer.fillColor = [UIColor clearColor].CGColor;
    [self.layer addSublayer:defaultShapeLayer];
    _defaultShapeLayer = defaultShapeLayer;
}

- (void)drawEachPieWithIndex:(NSInteger)index {
    if (self.colorArray.count<self.valueArray.count) {
        return;
    }
    
    CGFloat startAngle = [self.startAngleArray[index] floatValue];
    CGFloat endAngle = [self.endAngleArray[index] floatValue];
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:self.centerPoint radius:self.radius startAngle:startAngle endAngle:endAngle  clockwise:YES];
    CAShapeLayer *shapeLayer = [CAShapeLayer new];
    shapeLayer.path = [path CGPath];
    shapeLayer.lineWidth = self.lineWidth;
    shapeLayer.strokeColor = ((UIColor *)self.colorArray[index]).CGColor;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    
    if (self.isShowAnimation) {
        [shapeLayer addAnimation:[self animationWithDuration:[self.durationArray[index] floatValue]] forKey:nil];
    }
    [self.layer insertSublayer:shapeLayer above:_defaultShapeLayer];
    
    if (self.isShowItemLabel) {
        [self drawEachItemLabelWithIndex:index];
    }
}

- (void)drawEachItemLabelWithIndex:(NSInteger)index {
    if (self.textArray.count<self.valueArray.count || self.colorArray.count<self.valueArray.count) {
        return;
    }
    
    CGFloat centerAngle = [self.itemCenterAngleArray[index] floatValue];
    
    //计算引线和text位置并绘制
    CGPoint lineStartPoint = [self pointWithAngle:centerAngle radius:self.radius+self.lineWidth/2];
    
    CGPoint lineInflectionPoint = CGPointZero;
    
    CGPoint lineEndPoint = CGPointZero;
    
    CGRect textRect = CGRectZero;
    
    UILabel *sizeLabel = [[UILabel alloc] init];
    sizeLabel.numberOfLines = 0;
    sizeLabel.textAlignment = NSTextAlignmentCenter;
    sizeLabel.font = self.textFont;
    sizeLabel.text = self.textArray[index];
    [sizeLabel sizeToFit];
    CGFloat textHeight = CGRectGetHeight(sizeLabel.bounds)+5;
    
    
    CGFloat standardCenterAngle = fabs(centerAngle)-(int)(centerAngle/(2*M_PI));//换算成一个2*M_PI内坐标
    if (centerAngle<0) {
        standardCenterAngle = 2*M_PI-standardCenterAngle;
    }
    if ((standardCenterAngle>=M_PI/2*3 && standardCenterAngle<2*M_PI) ||
        (standardCenterAngle>=0 && standardCenterAngle<M_PI/2)) {//右半边
        NSUInteger drawRightIndex = [self.itemCenterAngleRightArray indexOfObject:[NSString stringWithFormat:@"%.4f",standardCenterAngle]];

        lineInflectionPoint.y = self.rightAverageHeight*drawRightIndex+self.rightAverageHeight/2;

        lineInflectionPoint.x = self.centerPoint.x + (self.radius + self.lineWidth/2 + 10);

        lineEndPoint = CGPointMake(CGRectGetWidth(self.bounds), lineInflectionPoint.y);
        textRect = CGRectMake(lineInflectionPoint.x, lineEndPoint.y-textHeight, lineEndPoint.x-lineInflectionPoint.x, textHeight);
    }
    else if (standardCenterAngle>=M_PI/2 && standardCenterAngle<M_PI/2*3) {//左半边
        NSUInteger drawLeftIndex = [self.itemCenterAngleLeftArray indexOfObject:[NSString stringWithFormat:@"%.4f",standardCenterAngle]];
        lineInflectionPoint.y = (CGRectGetHeight(self.bounds)-self.leftAverageHeight*drawLeftIndex)-self.leftAverageHeight/2;

        lineInflectionPoint.x = self.centerPoint.x - (self.radius + self.lineWidth/2 + 10);

        lineEndPoint = CGPointMake(0, lineInflectionPoint.y);
        textRect = CGRectMake(lineEndPoint.x, lineEndPoint.y-textHeight, lineInflectionPoint.x-lineEndPoint.x, textHeight);
    }
    
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path moveToPoint:lineStartPoint];
    [path addLineToPoint:lineInflectionPoint];
    [path addLineToPoint:lineEndPoint];
    
    CAShapeLayer *linwShapeLayer = [CAShapeLayer new];
    linwShapeLayer.path = [path CGPath];
    linwShapeLayer.lineWidth = self.leadLineWidth;
    linwShapeLayer.strokeColor = self.colorArray[index].CGColor;
    linwShapeLayer.fillColor = [UIColor clearColor].CGColor;
    
    //绘制text
    UILabel *textLayer = [[UILabel alloc] initWithFrame:textRect];
    textLayer.adjustsFontSizeToFitWidth = YES;
    textLayer.textAlignment = NSTextAlignmentCenter;
    textLayer.font = self.textFont;
    textLayer.text = self.textArray[index];
    textLayer.textColor = self.colorArray[index];
    
    
    if (self.isShowAnimation) {
        [linwShapeLayer addAnimation:[self animationWithDuration:[self.durationArray[index] floatValue]] forKey:nil];
    }
    [self.layer addSublayer:linwShapeLayer];
    [self addSubview:textLayer];
}

- (CGPoint)pointWithAngle:(CGFloat)angle radius:(CGFloat)radius {
    CGFloat x = self.centerPoint.x + cosf(angle) * radius;
    CGFloat y = self.centerPoint.y + sinf(angle) * radius;
    return CGPointMake(x, y);
}

- (CABasicAnimation *)animationWithDuration:(CGFloat)duraton {
    CABasicAnimation * fillAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    fillAnimation.duration = duraton;
    fillAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    fillAnimation.fillMode = kCAFillModeForwards;
    fillAnimation.removedOnCompletion = NO;
    fillAnimation.fromValue = @(0.f);
    fillAnimation.toValue = @(1.f);
    return fillAnimation;
}

- (void)removeAllSubLayers{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    
    NSArray * subviews = [NSArray arrayWithArray:self.subviews];
    for (UIView * view in subviews) {
        [view removeFromSuperview];
    }
    
    NSArray * subLayers = [NSArray arrayWithArray:self.layer.sublayers];
    for (CALayer * layer in subLayers) {
        [layer removeAllAnimations];
        [layer removeFromSuperlayer];
    }
}
@end
