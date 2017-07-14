//
//  XibUtil.h
//  TankWar1
//
//  Created by yq on 15/9/25.
//  Copyright © 2015年 test. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Wall.h"

@interface XibUtil : NSObject

/**
 * frame 是主视图的frame，用来计算等比例缩放
 */
- (UIView *)zoomWidthXibName:(NSString *)xibName;

/**
 * frame 是主视图的frame，用来计算等比例缩放
 */
- (NSMutableArray<Wall *> *)getWallsFromXib:(NSString *)xibName;

/**
 *改变地图
 */
- (NSMutableArray<Wall *> *)changeMap:(NSString *)mapName;

- (instancetype)initWithMainView:(UIView *)mainView;

+ (NSMutableArray<Wall *> *)getAllWalls;
@end
