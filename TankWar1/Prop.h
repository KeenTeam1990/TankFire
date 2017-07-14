//
//  Prop.h
//  TankWar1
//
//  Created by yq on 15/10/9.
//  Copyright © 2015年 test. All rights reserved.
//

#import "Rectangle.h"
#import "CommonData.h"


/**
 *  障碍物
 */
@interface Prop : Rectangle

+ (instancetype)getInstance;

@property (assign, nonatomic) PropType type;

/**
 * 设置类型
 */
- (void)setType:(PropType)type mainView:(UIView *)mainView;

@end
