//
//  ViewController.m
//  LBAnnularPieViewExample
//
//  Created by 刘彬 on 2020/7/8.
//  Copyright © 2020 刘彬. All rights reserved.
//

#import "ViewController.h"
#import "LBAnnularPieView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    LBAnnularPieView *pieView = [[LBAnnularPieView alloc] initWithFrame:CGRectMake(50, 100, CGRectGetWidth(self.view.frame)-50*2, 400)];
    pieView.radius = 80;
    pieView.valueArray = @[@0.25,@0.25,@0.25,@0.25].mutableCopy;
    pieView.colorArray = @[[UIColor redColor],[UIColor blueColor],[UIColor magentaColor],[UIColor cyanColor]].mutableCopy;
    pieView.textArray = @[@"25%",@"25%",@"25%",@"25%"].mutableCopy;
    [pieView strokePath];
    [self.view addSubview:pieView];
    
    
    
}


@end
