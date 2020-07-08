//
//  LBAnnularPieView.h
//  LBAnnularPieView
//
//  Created by 刘彬 on 2017/9/9.
//  Copyright © 2017年 liubin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LBAnnularPieView : UIView


@property (nonatomic, strong) NSMutableArray<NSNumber *> *valueArray;
@property (nonatomic, strong) NSMutableArray<NSString *> *textArray;
@property (nonatomic, strong) NSMutableArray<UIColor *>  *colorArray;

@property (nonatomic, assign) CGFloat animationDuration;//动画总时长
@property (nonatomic, assign) CGFloat startAngle;//起始角

@property (nonatomic, assign) CGFloat radius;//圆环半径
@property (nonatomic, assign) CGFloat lineWidth;//圆环宽

@property (nonatomic, strong) UIFont *textFont;
@property (nonatomic, assign) CGFloat leadLineWidth;//引线粗

@property (nonatomic, assign, getter=isShowAnimation) BOOL showAnimation;
@property (nonatomic, assign, getter=isShowItemLabel) BOOL showItemText;


- (void)strokePath;

@end
