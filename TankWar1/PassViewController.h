//
//  PassViewController.h
//  TankWar1
//
//  Created by yq on 15/9/29.
//  Copyright © 2015年 test. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ViewController;

@interface PassViewController : UIViewController

@property (strong, nonatomic) NSString *tip;

@property (weak, nonatomic) ViewController *viewController;

@end
