//
//  ViewController.m
//  QGEImageAnimationDemo
//
//  Created by wei1 on 2017/4/20.
//  Copyright © 2017年 qge. All rights reserved.
//

#import "ViewController.h"
#import "QGEViewAnimationController.h"
#define ViewWH 400
#define ScreenW [UIScreen mainScreen].bounds.size.width

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    QGEViewAnimationController *vc = [[QGEViewAnimationController alloc] initWithViewFrame:CGRectMake((ScreenW - ViewWH)/2, 0, ViewWH, ViewWH)];
    
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
    self.view.backgroundColor = [UIColor blueColor];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
