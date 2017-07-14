//
//  Tank.h
//  tankTest
//
//  Created by yq on 15/9/16.
//  Copyright (c) 2015年 test. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Rectangle.h"
#import "Bullet.h"
@class Prop;

@interface Tank : Rectangle


@property (assign, nonatomic) TankType type;
@property (assign, nonatomic) TankDirectione dir;
@property (assign, nonatomic) CGFloat speed;

@property (assign, nonatomic) bool beCalled;

@property (weak, nonatomic) UILabel *info;

@property (strong, nonatomic) NSMutableArray<Bullet *> *bullets;

@property (assign, nonatomic) int level;

/**
 *  已经检测过，不需要再检测碰撞的坦克和建筑
 */
@property (strong, nonatomic) NSMutableArray<Rectangle *> *notNeedChecks;

/**
 *  有几条命
 */
@property (assign, nonatomic) NSInteger life;


/**
 *  是否能移动
 */
@property (assign, nonatomic) bool canMove;

/**
 *  装甲等级
 */
@property (assign, nonatomic) NSInteger blood;


/**
 *  一次发射几个子弹
 */
@property (assign, nonatomic) NSInteger fireOfBulletCount;

//存储2进制，判断哪些方向不能移动
@property (assign, nonatomic) NSInteger canNotMoveDir;


/**
 *  爆炸中
 */
@property (assign, nonatomic) bool bobming;


+ (NSString *)getImageName:(TankType)type dir:(TankDirectione)dir;

#pragma mark - tank移动
- (void)move:(TankDirectione)dir timer:(NSTimer *)timer;

#pragma mark - 开炮
- (void)fire:(Bullet *)bullet timer:(NSTimer *)timer;

/**
 *  强制死亡
 */
- (void)goDie:(BOOL)prop;

@end
