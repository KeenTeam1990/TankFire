//
//  Factory.h
//  tankTest
//
//  Created by yq on 15/9/16.
//  Copyright (c) 2015年 test. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tank.h"
@class Wall;

enum bornLocation {bornLocation_left = 0, bornLocation_middle, bornLocation_right};

@interface Factory : NSObject

@property (assign, nonatomic) CGRect tankFrame;
@property (strong, nonatomic) NSMutableArray<UIImageView *> *bomb;
@property (weak, nonatomic) UIView *mainView;
@property (weak, nonatomic) UILabel *info;

+ (bool)isGameover;

+ (void)setIsGameover:(bool)isGameover;

/**
 *  创建坦克
 *
 *  @param tankType 坦克类型
 *  @param dir      坦克方向
 *
 *  @return
 */
- (Tank *)createTank:(TankType)tankType direction:(TankDirectione)dir center:(CGPoint)center;

- (Bullet *)createBullet:(TankDirectione)dir isGood:(BOOL)isGood;

/**
 *  清空全部
 */
+ (void)clearAll;

/**
 * 是否撞击检测
 */
+ (BOOL)checkIsKnockedWithRect:(UIView *)r1 r2:(UIView *)r2;

/**
 * 是否撞击检测,检测全部
 */
+ (Rectangle *)checkIsKnockedWithRectArray:(Rectangle *)r1;

/**
 * 检测是否和任意的坦撞 
 */
+ (NSMutableArray<Rectangle *> *)checkKnockWidthTank:(Rectangle *)r1;

/**
 * 检测是否和任意的障碍物相撞
 */
+ (NSMutableArray<Rectangle *> *)checkKnockWidthWall:(Rectangle *)r1;

/**
 * 是否出界
 */
+ (BOOL)outOfMainView:(CGRect)r mainView:(CGRect)mainView;

/**
 * 随机产生一辆敌方坦克，产生后直接显示，不需要加入view
 * 不指定location就随机
 */
- (BOOL)randomBadTank:(NSInteger)location;

+ (NSMutableArray<Rectangle *> *)instanceOfNeedCheckKnocked;

+ (NSMutableArray<Rectangle *> *)instanceOfBadTankArray;

+ (BOOL)isBorining;

@end
