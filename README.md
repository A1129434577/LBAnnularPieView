# LBAnnularPieView
一个支持动画的环形比例图，带引线文字标注。
```ObjC
LBAnnularPieView *pieView = [[LBAnnularPieView alloc] initWithFrame:CGRectMake(50, 100, CGRectGetWidth(self.view.frame)-50*2, 400)];
pieView.radius = 80;
pieView.valueArray = @[@0.25,@0.25,@0.25,@0.25].mutableCopy;
pieView.colorArray = @[[UIColor redColor],[UIColor blueColor],[UIColor magentaColor],[UIColor cyanColor]].mutableCopy;
pieView.textArray = @[@"25%",@"25%",@"25%",@"25%"].mutableCopy;
[pieView strokePath];
[self.view addSubview:pieView];
```
![](https://github.com/A1129434577/LBAnnularPieView/blob/master/LBAnnularPieView.png?raw=true)
