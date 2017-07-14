//
//  Factory.m
//  tankTest
//
//  Created by yq on 15/9/16.
//  Copyright (c) 2015年 test. All rights reserved.
//

#import "Factory.h"
#import "XibUtil.h"

//全是子弹
static NSMutableArray<Rectangle *> *needCheckKnocked;
static NSMutableArray<Rectangle *> *badTankArray;

static NSMutableArray<UIImage *> *bornImgs;

static UIView *tmpMainView;

UIView *tmpView;
UIImageView *imgLeft;
UIImageView *imgMiddle;
UIImageView *imgRight;

static bool isGameEnd = false;

static bool isBorning = false;


@implementation Factory
NSMutableArray<UIImage *> *bobms_bullet;

int bulletSpeed = 8.5;

+ (bool)isGameover {
    return isGameEnd;
}

+ (void)setIsGameover:(bool)isGameover {
    isGameEnd = isGameover;
}

+ (NSMutableArray<Rectangle *> *)instanceOfNeedCheckKnocked {
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        needCheckKnocked = [NSMutableArray array];
    });
    return needCheckKnocked;
}

+ (NSMutableArray<Rectangle *> *)instanceOfBadTankArray {
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        badTankArray = [NSMutableArray array];
    });
    return badTankArray;
}

- (Tank *)createTank:(TankType)tankType direction:(TankDirectione)dir center:(CGPoint)center {
    [self checkIsEmpty];
    Tank *tank = [Tank new];
    tank.type = tankType;
    tank.dir = dir;
    tank.size = self.tankFrame.size;
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:_tankFrame];
    imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%ld_%ld", tank.type, tank.dir]];
    tank.imgView = imgView;
    tank.blood = 1;
    tank.mainView = self.mainView;
    tank.center = center;
    
    tank.isGood = tank.type == TankTypeMain;
    tank.speed = 2;
    
    //子弹是否为自己的
    tank.bullets = [NSMutableArray array];
    Bullet *b = [self createBullet:dir isGood:tankType == TankTypeMain];
    
    if (tankType == TankTypeMain) {
        tank.life = 3;
    } else {
        tank.life = 1;
    }
    
    [tank.bullets addObject:b];
    b.tank = tank;
    
    [needCheckKnocked addObject:tank];
    
    //暂时设定只加入一颗子弹
    
    [self.mainView addSubview:tank.imgView];
    [self.mainView sendSubviewToBack:tank.imgView];
    tank.info = self.info;

    return tank;
}



- (Bullet *)createBullet:(TankDirectione)dir isGood:(BOOL)isGood {
    [self checkIsEmpty];
    Bullet *bu = [Bullet new];
    bu.isGood = isGood;
    bu.dir = dir;
    bu.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(100, 100, _tankFrame.size.width / 2, _tankFrame.size.width / 2)];
//    bu.bulletImgView.backgroundColor = [UIColor blackColor];
    bu.speed = bulletSpeed;
    bu.isDeath = NO;
    bu.imgView.hidden = YES;
    bu.imgView.image = [UIImage imageNamed:isGood ? @"goodBullet" : @"badBullet"];
    bu.mainView = self.mainView;
    [self.mainView addSubview:bu.imgView];
    //用户与碰撞检测
    [[Factory instanceOfNeedCheckKnocked] addObject:bu];
    return bu;
}

#pragma mark - 随机坦克
- (BOOL)randomBadTank:(NSInteger)location {
    //计算初始位置，3个，左中右
    CGFloat y = self.tankFrame.size.height / 2.0 + 10;
    CGFloat x0 = self.tankFrame.size.width;
    CGFloat x1 = self.mainView.frame.size.width / 2;
    CGFloat x2 = self.mainView.frame.size.width - self.tankFrame.size.width;
    
    NSInteger tankX = arc4random() % 3;
    
    if (location < 3 && location >= 0 ) {
        tankX = location;
    }
    
    if (!imgLeft) {
        imgLeft = [self createImgView:CGPointMake(x0, y)];
        imgMiddle = [self createImgView:CGPointMake(x1, y)];
        imgRight = [self createImgView:CGPointMake(x2, y)];
    }
    
    UIImageView *imgView = nil;
    switch (tankX) {
        case 0:
            imgView = imgLeft;
            break;
            
        case 1:
            imgView = imgMiddle;
            break;
            
        case 2:
            imgView = imgRight;
            break;
            
        default:
            break;
    }
    
    
    //位置被占用不能出生
    if (![self canBorn:imgView]) {
        for (int i = 0; i < 3; i++) {
            switch (i) {
                case 0:
                    imgView = imgLeft;
                    break;
                case 1:
                    imgView = imgMiddle;
                    break;
                case 2:
                    imgView = imgRight;
                    break;
                default:
                    break;
            }
            //能出生，直接在这里产生新坦克
            if ([self canBorn:imgView]) {
                [self bornAnimation:imgView];
                return YES;
            }
        }
        return NO;
    }
    
    [self bornAnimation:imgView];
    return YES;
}

- (UIImageView *)createImgView:(CGPoint)center {
    UIImageView *img = [[UIImageView alloc] initWithFrame:self.tankFrame];
    img.center = center;
    return img;
}

- (void)bornAnimation:(UIImageView *)imgView {
    isBorning = true;
    imgView.hidden = NO;
    if (!bornImgs) {
        bornImgs = [NSMutableArray array];
        for (int i = 1; i < 5; i++) {
            [bornImgs addObject:[UIImage imageNamed:[NSString stringWithFormat:@"born%d", i]]];
        }
    }
    [self.mainView addSubview:imgView];
    imgView.animationImages = bornImgs;
    imgView.animationDuration = 0.5;
    imgView.animationRepeatCount = 4;
    [imgView startAnimating];
    [self performSelector:@selector(clearImgAnimation:) withObject:imgView afterDelay:2];
}

- (void)clearImgAnimation:(UIImageView *)imgView {
    imgView.hidden = YES;
    Tank *bad = [Tank new];
    NSInteger tankType = arc4random() % 6 + 10;
    
    
    //红坦克
    if (1 << tankType == TankTypeRed) {
        bad = [self createTank:TankTypeRed direction:TankDirectioneDown center:imgView.center];
        bad.blood = 2;
    } else {
        bad = [self createTank:1 << tankType direction:TankDirectioneDown center:imgView.center];
    }
    #pragma mark - 测试
   // bad = [self createTank:TankTypeRed direction:TankDirectioneDown center:imgView.center];
//    bad.blood = 2;
    
    [self.mainView addSubview:bad.imgView];
    //加入敌方坦克数组
    [[Factory instanceOfBadTankArray] addObject:bad];
    
    isBorning = false;
}

- (BOOL)canBorn:(UIImageView *)view {
    for (Rectangle *r in badTankArray) {
        //检测到碰撞
        if (CGRectIntersectsRect(r.imgView.frame, view.frame)) {
            return NO;
        }
    }
    return YES;
}

- (void)checkIsEmpty {
    if ([self checkRectIsEmpty:_tankFrame]) {
        @throw [NSException exceptionWithName:@"参数不全" reason:@"tankSize没有初始化" userInfo:nil];
    }
    if (!_mainView) {
        @throw [NSException exceptionWithName:@"参数不全" reason:@"mainView没有初始化" userInfo:nil];
    }
}

- (BOOL)checkRectIsEmpty:(CGRect)rect {
    return 0 == rect.origin.x && 0 == rect.origin.y && 0 == rect.size.width && 0 == rect.size.height;
}

+ (BOOL)checkIsKnockedWithRect:(UIView *)r1 r2:(UIView *)r2 {
    if (r1.hidden || r2.hidden) {//隐藏不检测
        return NO;
    }
    return CGRectIntersectsRect(r1.frame, r2.frame);
}

#pragma mark - 和坦克的碰撞检测
+ (NSMutableArray<Rectangle *> *)checkKnockWidthTank:(Rectangle *)r1 {
    NSMutableArray *arr = [NSMutableArray array];
    for (Rectangle *r in needCheckKnocked) {
        //检测到碰撞
        if (r1 != r && [Factory checkIsKnockedWithRect:r1.imgView r2:r.imgView]) {
            [arr addObject:r];
        }
    }
    return arr;
}


#pragma mark - 和障碍物的碰撞检测
+ (NSMutableArray<Rectangle *> *)checkKnockWidthWall:(Rectangle *)r1 {
    NSMutableArray<Rectangle *> *arr = [NSMutableArray array];
    for (Wall *r in [XibUtil getAllWalls]) {
        //检测到碰撞
        if (r1 != r && [Factory checkIsKnockedWithRect:r1.imgView r2:r.imgView]) {
            if (r.wallType == WallType_grss) {//草不检测
                continue;
            }
            [arr addObject:r];
        }
    }
    return arr;
}

#pragma mark - 碰撞检测用于子弹
+ (Rectangle *)checkIsKnockedWithRectArray:(Rectangle *)r1 {
    for (Rectangle *r in badTankArray) {
        //检测到碰撞
        if (!r.isDeath && r1.isGood != r.isGood && r1 != r && [Factory checkIsKnockedWithRect:r1.imgView r2:r.imgView]) {
            return r;
        }
    }
    for (Rectangle *r in needCheckKnocked) {
        //检测到碰撞
        if (!r.isDeath && r1.isGood != r.isGood && r1 != r && [Factory checkIsKnockedWithRect:r1.imgView r2:r.imgView]) {
            return r;
        }
    }
    
//    for (Wall *r in [XibUtil getAllWalls]) {
//        //检测到碰撞
//        if (!r.isDeath && r1 != r && [Factory checkIsKnockedWithRect:r1.imgView r2:r.imgView]) {
//            if (r.wallType == WallType_grss) {//草不检测
//                continue;
//            }
//            return r;
//        }
//    }
    return nil;
}


+ (BOOL)outOfMainView:(CGRect)r mainView:(CGRect)mainView {
    CGPoint move = r.origin;
    return move.x <= 0 || move.x >= mainView.size.width - r.size.width || move.y <= 0 || move.y >= mainView.size.height - r.size.height;
}

- (void)setMainView:(UIView *)mainView {
    _mainView = mainView;
    tmpMainView = mainView;
}

+ (void)clearAll {
    [needCheckKnocked removeAllObjects];
    [badTankArray removeAllObjects];
    for (UIView *view in tmpMainView.subviews) {
        [view removeFromSuperview];
    }
}

+ (BOOL)isBorining {
    return isBorning;
}

@end
