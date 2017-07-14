//
//  Bullet.m
//  tankTest
//
//  Created by yq on 15/9/18.
//  Copyright © 2015年 test. All rights reserved.
//

#import "Bullet.h"
#import "AVFoundation/AVFoundation.h"
#import "Tank.h"
#import "Factory.h"

@interface Bullet ()

//不写在这回报错，不知道为什么
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) int i;
@property (strong, nonatomic) UIImageView *bombImgview;

@end

//int i = 0;
@implementation Bullet

#pragma mark - 爆炸

- (void)setIsDeath:(bool)isDeath {
    _isDeath = isDeath;
    _i = 0;
    if (!_timer) {
        _timer = [NSTimer timerWithTimeInterval:0.025 target:self selector:@selector(startBomb) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    if (isDeath) {
        self.bombImgview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.imgView.frame.size.width * 2.6, self.imgView.frame.size.height * 2.6)];
        self.imgView.hidden = YES;
        self.bombImgview.center = self.imgView.center;
        [self.mainView addSubview:self.bombImgview];
        _timer.fireDate = [NSDate distantPast];
        self.canMove = false;
    }
}

//爆炸产生
- (void)startBomb {    
    self.bombImgview.image = [UIImage imageNamed:[NSString stringWithFormat:@"bomb%d", _i]];
    
    self.bobming = true;
    if (_i >= 9) {
        //爆炸完成后清理
         _timer.fireDate = [NSDate distantFuture];
        
        [self.bombImgview removeFromSuperview];
        
        #pragma mark - 子弹升级
        if (self.tank.level > 2) {
            self.imgView.image = [UIImage imageNamed:@"daodan"];
            CGRect f = self.imgView.frame;
            self.imgView.frame = CGRectMake(f.origin.x, f.origin.y, self.tank.imgView.frame.size.width / 1.2, self.tank.imgView.frame.size.height / 1.2);
        } else {
            CGRect f = self.imgView.frame;
            self.imgView.image = [UIImage imageNamed:_isGood ? @"goodBullet" : @"badBullet"];
            self.imgView.frame = CGRectMake(f.origin.x, f.origin.y, self.tank.imgView.frame.size.width / 2, self.tank.imgView.frame.size.height / 2);
        }
        self.isDeath = false;
        self.bobming = false;
        _i = 0;
//        self.center = self.tank.center;
//        self.dir = self.tank.dir;
        self.fireVoice = false;
    }
    _i++;
}


- (void)setCenter:(CGPoint)center {
    _center = center;
    self.imgView.center = center;
}

- (void)setDir:(TankDirectione)dir {
    _dir = dir;
 
    switch (dir) {
        case TankDirectioneLeft:
            self.imgView.transform = CGAffineTransformMakeRotation(M_PI / 2 *3);
            break;
            
        case TankDirectioneRight:
            self.imgView.transform = CGAffineTransformMakeRotation(M_PI / 2);
            break;
            
        case TankDirectioneDown:
            self.imgView.transform = CGAffineTransformMakeRotation(M_PI);
            break;
            
        case TankDirectioneUp:
            self.imgView.transform = CGAffineTransformMakeRotation(0);
            break;
            
        default:
            break;
    }
}




@end
