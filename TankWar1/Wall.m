//
//  Wall.m
//  TankWar1
//
//  Created by yq on 15/9/28.
//  Copyright © 2015年 test. All rights reserved.
//

#import "Wall.h"
#import "XibUtil.h"
#import <AudioToolbox/AudioToolbox.h>
#import "CommonData.h"
#import "Factory.h"

@implementation Wall

- (void)setIsDeath:(bool)isDeath {
    _isDeath = isDeath;
    if (isDeath) {
        if (self.wallType == WallType_symbol) {
            self.imgView.image = [UIImage imageNamed:@"destory"];
            [Factory setIsGameover:true];
        } else {
            [self.imgView removeFromSuperview];
        }
        [[XibUtil getAllWalls] removeObject:self];
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
