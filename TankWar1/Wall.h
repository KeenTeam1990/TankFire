//
//  Wall.h
//  TankWar1
//
//  Created by yq on 15/9/28.
//  Copyright © 2015年 test. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Rectangle.h"

typedef NS_ENUM(NSUInteger, WallType) {
    /**草*/
    WallType_grss = 0,
    /**砖*/
    WallType_brick,
    /**水*/
    WallType_water,
    /**铁*/
    WallType_steel,
    /**boss */
    WallType_symbol,
    /**保护罩 */
    WallType_cover,
};

@interface Wall : Rectangle

@property (assign, nonatomic) WallType wallType;


@end
