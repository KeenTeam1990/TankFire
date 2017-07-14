//
//  ViewController.h
//  TankWar1
//
//  Created by yq on 15/9/18.
//  Copyright © 2015年 test. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

/*
 *  游戏暂停
 */
+ (void)pauseGame;

/*
 *  重新开始
 */
- (void)restart;

+ (void)stopBadTankIn6s;



@end

