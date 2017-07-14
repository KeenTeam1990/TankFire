//
//  CommonData.h
//  tankTest
//
//  Created by yq on 15/9/17.
//  Copyright © 2015年 test. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TankType) {
    TankTypeGreen = 1 << 10,
    TankTypeYellow = 1 << 11,
    TankTypeGray = 1 << 12,
    TankTypeGreenStrong = 1 << 13,
    TankTypeYellowStrong = 1 << 14,
    TankTypeRed = 1 << 15,
    /**
     *  主战坦克
     */
    TankTypeMain = 1 << 20
};

typedef NS_ENUM(NSUInteger, TankDirectione) {
    TankDirectioneLeft = 1 << 0,
    TankDirectioneRight = 1 << 1,
    TankDirectioneUp = 1 << 2,
    TankDirectioneDown = 1 << 3
};

typedef NS_ENUM(NSUInteger, PropType) {
    PropType_star = 0,
    PropType_bomb,
    PropType_timer,
    PropType_add
};

typedef NS_ENUM(NSUInteger, BobmType) {
    BobmTypeBullet = 1 << 0,
    BobmTypeTank = 1 << 1,
};


static double margin_x = 10;

static double margin_y = 20;







