//
//  Tank.m
//  tankTest
//
//  Created by yq on 15/9/16.
//  Copyright (c) 2015年 test. All rights reserved.
//

#import "Tank.h"
#import "Factory.h"
#import "XibUtil.h"
#import "ViewController.h"
#import "Prop.h"



@interface Tank ()

@property (assign, nonatomic) int i;
@property (strong, nonatomic) UIImageView *bombImgview;
@property (strong, nonatomic) NSTimer *timer;

@end


@implementation Tank

- (instancetype)init
{
    self = [super init];
    if (self) {
        _notNeedChecks = [NSMutableArray array];
    }
    return self;
}

- (void)setCenter:(CGPoint)center {
    _center = center;
    self.imgView.center = center;
}

+ (NSString *)getImageName:(TankType)type dir:(TankDirectione)dir {
    return [NSString stringWithFormat:@"%ld_%ld", type, dir];
}

- (void)setDir:(TankDirectione)dir {
    _dir = dir;
    self.imgView.image = [UIImage imageNamed:[Tank getImageName:_type dir:dir]];
    for (Bullet *b in self.bullets) {
        if (!b.canMove && b.isDeath) {
            b.dir = dir;
        }
    }
}

- (void)setLevel:(int)level {
    _level = level;
    switch (level) {
        case 1:{//1级，子弹加速
            for (Bullet *b in self.bullets) {
                b.speed += 5;
            }
        }
            break;
            
        case 2:{//2级， 双发子弹
            self.blood = 2;
            Factory *f = [Factory new];
            f.mainView = self.mainView;
            f.tankFrame = self.imgView.frame;
            Bullet *b = [f createBullet:self.dir isGood:YES];
            b.tank = self;
            [self.bullets addObject:b];
            CGFloat sp = b.speed;
            for (Bullet *b in self.bullets) {
                b.speed = 5 + sp;
            }
        }
            break;
            
        case 3:{//3级， 威力提升
            self.blood = 2;
            Factory *f = [Factory new];
            f.mainView = self.mainView;
            f.tankFrame = self.imgView.frame;
            
            if (self.bullets.count < 2) {
                Bullet *b = [f createBullet:self.dir isGood:YES];
                b.tank = self;
                [self.bullets addObject:b];
                CGFloat sp = b.speed;
                for (Bullet *b in self.bullets) {
                    b.speed = 5 + sp;
                }
            }
        }
            break;
            
        case 0:{//0级， 清除特殊待遇
            if (self.bullets.count > 1) {
                self.bullets.firstObject.speed -= 5;
                [self.bullets removeObject:self.bullets.lastObject];
            }
        }
            break;
            
        default:{//其他
            
        }
            break;
    }
}

- (void)createProp {
    NSInteger badCount = [Factory instanceOfBadTankArray].count;
    NSInteger randNum_location = arc4random() % badCount;
    
    NSInteger randNum_type = arc4random() % 7;
    if (randNum_type != 6) {//降低奖命的概率
        randNum_type = randNum_type % 3;
    } else {
        randNum_type = 3;
    }
    Prop *prop = [Prop getInstance];
    [prop setType:randNum_type mainView:self.mainView];
    prop.imgView.frame = [Factory instanceOfBadTankArray][randNum_location].imgView.frame;
    [self playingSoundEffectWith:@"chuxian.wav"];
}

- (void)changeType {
    NSInteger type = arc4random() % 5 + 10;
    self.type = 1 << type;
    self.imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%ld_%ld", self.type, self.dir]];
}

#pragma mark - 爆炸
NSTimer *timer = nil;
- (void)setIsDeath:(bool)isDeath {
    _isDeath = isDeath;
    _i = 0;
    if (isDeath) {
        //红坦克，创建道具
        if (TankTypeRed == self.type) {
            [self createProp];
            [self changeType];
        }
        
        if (self.blood > 0) {
            self.blood--;
            if (1 >= self.blood) {
                self.level = 0;
            }
            if (0 >= self.blood) {
                if (!_timer) {
                    _timer = [NSTimer timerWithTimeInterval:0.05 target:self selector:@selector(startBomb) userInfo:nil repeats:YES];
                    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
                }
               
                [self playingSoundEffectWith:@"blast.wav"];
                
                self.bombImgview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.imgView.frame.size.width, self.imgView.frame.size.height)];
                
                self.bombImgview.center = self.imgView.center;
                [self.mainView addSubview:self.bombImgview];
                
                //移除子弹
                for (Bullet *b in self.bullets) {
                    b.imgView.hidden = YES;
                    [b.imgView removeFromSuperview];
                    [[Factory instanceOfNeedCheckKnocked] removeObject:b];
                }
                
                _timer.fireDate = [NSDate distantPast];
                _imgView.hidden = YES;
            } else {
                if (self.type == TankTypeMain) {
                   // self.level = 0;
                }
                _isDeath = false;
            }
            
        }
    }
}

- (void)goDie:(BOOL)prop {
    _isDeath = true;
    _i = 0;
    
    //红坦克，创建道具
    if (TankTypeRed == self.type && prop) {
        [self createProp];
        [self changeType];
    }
    
    if (!_timer) {
        _timer = [NSTimer timerWithTimeInterval:0.05 target:self selector:@selector(startBomb) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    
    [self playingSoundEffectWith:@"blast.wav"];
    
    self.bombImgview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.imgView.frame.size.width, self.imgView.frame.size.height)];
    
    self.bombImgview.center = self.imgView.center;
    [self.mainView addSubview:self.bombImgview];
    
    //移除子弹
    for (Bullet *b in self.bullets) {
        b.imgView.hidden = YES;
        [b.imgView removeFromSuperview];
        [[Factory instanceOfNeedCheckKnocked] removeObject:b];
    }
    
    _timer.fireDate = [NSDate distantPast];
    _imgView.hidden = YES;
}

//爆炸产生
- (void)startBomb {
    self.bombImgview.image = [UIImage imageNamed:[NSString stringWithFormat:@"tankbomb%d", _i]];
    self.bobming = true;
    if (_i >= 36) {
        //爆炸完成后清理
        [_timer invalidate];
        
        //移除坦克
        [self.imgView removeFromSuperview];
        [[Factory instanceOfNeedCheckKnocked] removeObject:self];
        [[Factory instanceOfBadTankArray] removeObject:self];
        for (Bullet *b in self.bullets) {
            [b.imgView removeFromSuperview];
        }
        _i = 0;
    }
    _i++;
}

#pragma mark - 和道具的检测
- (void)checkKnockedWithProp {
    if ([Prop getInstance].imgView.isHidden || self.type != TankTypeMain) {
        return;
    }
    if (CGRectIntersectsRect(self.imgView.frame , [Prop getInstance].imgView.frame)) {
        [Prop getInstance].imgView.hidden = YES;
        
        Prop *p = [Prop getInstance];
        switch (p.type) {
            case PropType_star:{
                if (self.level < 4) {
                    self.level += 1;
                    [self playingSoundEffectWith:@"jianqi.wav"];
                }
            }
                break;
                
            case PropType_bomb:{
                for (Tank *t in [Factory instanceOfBadTankArray]) {
                    [t goDie:NO];
                    [self playingSoundEffectWith:@"jianqi.wav"];
                }
            }
                break;
                
            case PropType_timer:{
                [ViewController stopBadTankIn6s];
                [self playingSoundEffectWith:@"jianqi.wav"];
            }
                break;
                
            case PropType_add:{
                self.life++;
                self.info.text = [NSString stringWithFormat:@"我方：%ld", self.life];
                [self playingSoundEffectWith:@"add.wav"];
            }
                break;
                
            default:
                break;
        }
    }
}

#pragma mark - tank移动
- (void)move:(TankDirectione)dir timer:(NSTimer *)timer {
    Tank *tank = self;
    //判断方向是否相同，不同的话先改变方向在移动
    if (tank.dir != dir) {
        tank.dir = dir;
        return;
    }
    if (tank.canMove) {
        __block NSInteger x = tank.center.x;
        __block NSInteger y = tank.center.y;
        CGFloat tank_2 = tank.imgView.frame.size.width / 2.0;
        
        self.canNotMoveDir = 0;
        
        NSMutableArray<Rectangle *> *t1 = [Factory checkKnockWidthWall:self];
        [self checkTank:tank t:t1];
        NSMutableArray<Rectangle *> *t = [Factory checkKnockWidthTank:self];
        [self checkTank:tank t:t];
        
        //道具
        [self checkKnockedWithProp];
      
        
        if (TankDirectioneLeft == dir && x - tank.speed > tank_2) {
            if (!(self.canNotMoveDir & TankDirectioneLeft)) {
                x -= tank.speed;
            }
        } else if (TankDirectioneRight == dir && x + tank.speed < tank.mainView.frame.size.width - tank_2) {
            if (!(self.canNotMoveDir & TankDirectioneRight)) {
                x += tank.speed;
            }
        } else if (TankDirectioneUp == dir && y - tank.speed > tank_2) {
            if (!(self.canNotMoveDir & TankDirectioneUp)) {
                y -= tank.speed;
            }
        } else if (TankDirectioneDown == dir && y + tank.speed < tank.mainView.frame.size.height - tank_2) {
            if (!(self.canNotMoveDir & TankDirectioneDown)) {
                y += tank.speed;
            }
        }
        
        tank.center = CGPointMake(x, y);
    }
}

- (void)checkTank:(Tank *)tank t:(NSMutableArray<Rectangle *> *)ts {
    
    for (Rectangle *t in ts) {
        CGFloat w = tank.imgView.frame.size.width / 2 + t.imgView.frame.size.width / 2;
        CGFloat h = tank.imgView.frame.size.height / 2 + t.imgView.frame.size.height / 2;
        
        //障碍物在上方,判断擦边
        BOOL u = self.center.y - h >= t.center.y - self.speed && self.center.y - h <= t.center.y;
        BOOL d = self.center.y + h <= t.center.y + self.speed && self.center.y + h >= t.center.y;
        BOOL r = self.center.x + w <= t.center.x + self.speed && self.center.y + w >= t.center.x;
        BOOL l = self.center.x - w >= t.center.x - self.speed && self.center.y - w <= t.center.x;
        
        //左右移动检查y，上下移动检查x是否只是擦边
        if (tank.center.x +  w - self.speed <= t.center.x) {//在左边
            //检测到碰撞后，用2进制处理哪些方向不能移动
            if(!u && !d) {
                self.canNotMoveDir = self.canNotMoveDir | TankDirectioneRight;
            }
        }
        if (tank.center.x -  w + self.speed >= t.center.x) {//在右边
            if(!u && !d) {
                self.canNotMoveDir = self.canNotMoveDir | TankDirectioneLeft;
            }
        }
        if (tank.center.y -  h +self.speed >= t.center.y) {//在下边
            if(!l && !r) {
                self.canNotMoveDir = self.canNotMoveDir | TankDirectioneUp;
            }
            
        }
        if (tank.center.y +  h - self.speed <= t.center.y) {//在上边
            if(!l && !r) {
                self.canNotMoveDir = self.canNotMoveDir | TankDirectioneDown;
            }
        }
    }

}

int count = 0;
#pragma mark - 开炮
- (void)fire:(Bullet *)bullet timer:(NSTimer *)timer {
    TankDirectione dir = bullet.dir;

    if (bullet.canMove && !bullet.isDeath) {
        if (!bullet.fireVoice) {
            [self playingSoundEffectWith:@"fire.wav"];
            bullet.fireVoice = true;
        }
        
        bullet.imgView.hidden = NO;
        __block NSInteger x = bullet.center.x;
        __block NSInteger y = bullet.center.y;
        if (TankDirectioneLeft == dir) {
            x -= bullet.speed;
        } else if (TankDirectioneRight == dir) {
            x += bullet.speed;
        } else if (TankDirectioneUp == dir) {
            y -= bullet.speed;
        } else {
            y += bullet.speed;
        }
        bullet.center = CGPointMake(x, y);
        
        Rectangle *r = [Factory checkIsKnockedWithRectArray:bullet];
        if (r) {
            UIView *v = [r.imgView viewWithTag:2333];
            if (!v || v.isHidden) {
                if (self.level > 2 && [r isKindOfClass:[Tank class]]) {
                    [((Tank *) r) goDie:YES];
                } else {
                   r.isDeath = true;
                }
            }
            
            bullet.isDeath = true;
            bullet.canMove = false;
        }
        
        //和障碍物撞击检测
        NSMutableArray *knockedWalls = [Factory checkKnockWidthWall:bullet];
        if (knockedWalls) {
            for (Wall *w in knockedWalls) {
                if (w.wallType == WallType_brick) {//砖就直接打
                    w.isDeath = true;
                } else if (w.wallType == WallType_steel) {
                    if (self.level > 2) {
                        w.isDeath = true;
                    } else {
                        [self playingSoundEffectWith:@"hit.wav"];
                    }
                } else if (w.wallType == WallType_symbol) {
                    //timer.fireDate = [NSDate distantFuture];
                    w.isDeath = true;
                }
                
                if (w.wallType != WallType_water) {//水直接穿过
                    bullet.isDeath = true;
                }
            }            
        }
        
        //出界爆炸
        if ([Factory outOfMainView:bullet.imgView.frame mainView:bullet.mainView.frame]) {
            bullet.isDeath = true;
            [self playingSoundEffectWith:@"Explosion.wav"];
        }

    } else {
        bullet.dir = self.dir;
        bullet.imgView.hidden = YES;
        bullet.center = self.center;
    }
}

- (void)playingSoundEffectWith:(NSString *)filename {
    NSURL *fileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:filename ofType:nil]];
    if (fileURL != nil) {
        SystemSoundID theSoundID;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)fileURL, &theSoundID);
        AudioServicesPlaySystemSound(theSoundID);
    }
}

@end
