//
//  WelcomeViewController.m
//  TankWar1
//
//  Created by yq on 15/10/8.
//  Copyright © 2015年 test. All rights reserved.
//

#import "WelcomeViewController.h"
#import "ViewController.h"

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

- (void)initUI {
    self.view.backgroundColor = [UIColor blackColor];
    CGFloat width = self.view.frame.size.width;
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
    imgView.center = self.view.center;
    imgView.image = [UIImage imageNamed:@"welcome"];
    [self.view addSubview:imgView];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.viewController restart];
}

@end
