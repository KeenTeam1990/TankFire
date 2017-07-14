//
//  Prop.m
//  TankWar1
//
//  Created by yq on 15/10/9.
//  Copyright © 2015年 test. All rights reserved.
//

#import "Prop.h"

static NSArray<NSString *> *types;

@implementation Prop

+ (instancetype)getInstance {
    static Prop *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[self alloc] init];
        types = @[@"star", @"bomb", @"timer", @"add"];
    });
    
    return instance;
}

- (void)setType:(PropType)type mainView:(UIView *)mainView {
    if (self.imgView) {
        self.imgView.hidden = NO;
    } else {
        self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    }
    self.type = type;
    self.imgView.image = [UIImage imageNamed:types[type]];
    [mainView addSubview:self.imgView];
}

@end
