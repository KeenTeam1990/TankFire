//
//  Rectangle.m
//  TankWar1
//
//  Created by yq on 15/9/21.
//  Copyright © 2015年 test. All rights reserved.
//

#import "Rectangle.h"

@implementation Rectangle


- (void)setCenter:(CGPoint)center {
    _center = center;
    self.imgView.center = center;
}

@end
