//
//  Bullet.h
//  tankTest
//
//  Created by yq on 15/9/18.
//  Copyright © 2015年 test. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CommonData.h"
#import "Rectangle.h"
#import <AudioToolbox/AudioToolbox.h>

@class Tank;

@interface Bullet : Rectangle

@property (weak, nonatomic) Tank *tank;

@property (assign, nonatomic) CGFloat speed;

/**
 *  是否播放过开火音效
 */
@property (assign, nonatomic) bool fireVoice;



/**
 * 炮弹初始位置，坦克可能会变方向，所以自己保存一个
 */
@property (assign, nonatomic) TankDirectione dir;

/**
 *  子弹的威力等级
 */
@property (assign, nonatomic) NSInteger bulletLevel;


/**
 *  是否能移动
 */
@property (assign, nonatomic) bool canMove;

/**
 *  爆炸中
 */
@property (assign, nonatomic) bool bobming;

@end
