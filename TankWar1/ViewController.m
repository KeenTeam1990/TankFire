//
//  ViewController.m
//  tankTest
//https://github.com/liwang110110
//  Created by yq on 15/9/16.
//  Copyright (c) 2015年 test. All rights reserved.
//

#import "ViewController.h"
#import "Factory.h"
#import <AudioToolbox/AudioToolbox.h>
#import "XibUtil.h"
#import "PassViewController.h"
#import "WelcomeViewController.h"

@interface ViewController ()

@property (strong, nonatomic) UIView *mainView;

@property (strong, nonatomic) UIView *controlView;

@property (strong, nonatomic) Tank  *mainTank;

@property (strong, nonatomic) UIButton *leftBtn;
@property (strong, nonatomic) UIButton *rightBtn;
@property (strong, nonatomic) UIButton *upBtn;
@property (strong, nonatomic) UIButton *downBtn;
@property (strong, nonatomic) UIButton *fireBtn;

@property (strong, nonatomic) Factory *factory;

@property (strong, nonatomic) UILabel *info;

@property (strong, nonatomic) UILabel *zj;

#pragma mark - 常量
@property (assign, nonatomic) CGFloat width;
@property (assign, nonatomic) CGFloat height;

@property (assign, nonatomic) CGFloat minWidth;


@end

/**
 *  刷新时间
 */
double interval_refresh = 0.025;
int oneSeconeCount = 40;
double interval_tankMove = 0.35;
int baseTag = 100;
int fireTag = 1000;
static UIButton *_playBtn;
static NSTimer *_timer;

//是否显示欢迎界面
static bool welcomed = false;



static int stage = 0;
static int totalStatge = 4;

#pragma mark - 工需要产生多少个敌方坦克
static int badTankCount = 13;
#pragma mark - 初始化几个坦克
int const count_tank_init = 3;
#pragma mark - 无敌时间
int wuditime = 10;


CGFloat scale;


//当前的坦克计数
int count_tank = count_tank_init;

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    [self initUI];
    //[self randBadTank];
}

- (void)randBadTank {
#pragma mark - 产生初始坦克
    [self.factory randomBadTank:bornLocation_left];
    [self.factory randomBadTank:bornLocation_middle];
    [self.factory randomBadTank:bornLocation_right];
}

- (void)restart {
    [Factory clearAll];
    [Factory setIsGameover:false];
    _mainTank.life = 3;
    stage = -1;
    stageCount = 1;
    _mainTank.level = 0;
    count_tank = count_tank_init;
}

- (void)initData {
    self.width = self.view.frame.size.width;
    self.height = self.view.frame.size.height;
    CGFloat mainViewWidth = self.width - 20;
    //13大格子，每个大格子4个小的
    self.minWidth = mainViewWidth / 13 / 2;
    
}

- (void)initUI {
    CGFloat mainViewWidth = self.width - margin_x * 2;
    
    self.view.backgroundColor = [UIColor greenColor];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imgView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"4.jpg" ofType:nil]];
    [self.view addSubview:imgView];
    
    _mainView = [[UIView alloc] initWithFrame:CGRectMake(margin_x, margin_y, mainViewWidth , mainViewWidth)];
    _mainView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_mainView];
    
    _zj = [[UILabel alloc] initWithFrame:CGRectMake(-20, -10, 100, 40)];
    _zj.text = @"";//主角光环
    _zj.textColor = [UIColor redColor];
    _zj.tag = 2333;
    [_mainTank.imgView addSubview:_zj];
    
    //按键初始化-------
    [self initControlBtns];
    
    //初始化工厂
    _factory = [Factory new];
    _factory.tankFrame = CGRectMake(0, 0, _minWidth * 2, _minWidth * 2);
    _factory.mainView = _mainView;
    
    CGFloat btnWidth = 40;
    CGFloat marginTop = 40;
    
    _info = [[UILabel alloc] initWithFrame:CGRectMake(mainViewWidth / 2, self.width - 20 + marginTop - 5, mainViewWidth / 2, btnWidth)];
    _info.textAlignment = NSTextAlignmentLeft;
    _info.textColor = [UIColor orangeColor];
    
    [_info setFont:[UIFont fontWithName:@"Helvetica-BoldOblique" size:15]];
    
    [self.view addSubview:_info];

    
    _factory.info = _info;
    
    //坦克初始化后使用
    //初始化timer
    _timer = [NSTimer timerWithTimeInterval:interval_refresh target:self selector:@selector(refresh:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    //_timer.fireDate = [NSDate distantFuture];
    CGPoint mc = self.mainView.center;
    _mainTank = [_factory createTank:TankTypeMain direction:TankDirectioneUp center:CGPointMake(mc.x - 100, mc.y + _mainView.frame.size.width / 2 - 60)];
    
    //[self.mainView bringSubviewToFront:_mainTank.imgView];
    
    XibUtil *util = [[XibUtil alloc] initWithMainView:self.mainView];
    for (Wall *w in [util getWallsFromXib:@"Map0"]) {
        [self.mainView addSubview:w.imgView];
        [self.mainView bringSubviewToFront:w.imgView];
    }
    
    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(mainViewWidth / 2 - btnWidth, self.width - 20 + marginTop, 30, 30)];
    iv.image = [UIImage imageNamed:@"1048576_4"];
    [self.view addSubview:iv];
}

#pragma mark - 控制键
- (void)initControlBtns {
    scale = [UIScreen mainScreen].bounds.size.width / 414;
    CGFloat mainViewWidth = self.width - 20 * scale;
    CGFloat margin = 10 * scale;
    CGFloat btnWidth = 40 * scale;
    CGFloat marginTop = 40 * scale;
    _controlView = [[UIView alloc] initWithFrame:CGRectMake(10, 40 * scale + mainViewWidth, mainViewWidth, mainViewWidth)];
    [self.view addSubview:_controlView];
    
    [_controlView addSubview:[self createBtn:@"dir_left" frame:CGRectMake(margin, btnWidth + marginTop, btnWidth, btnWidth) tag:baseTag + TankDirectioneLeft]];
    
    [_controlView addSubview:[self createBtn:@"dir_right" frame:CGRectMake(margin + btnWidth * 2, btnWidth + marginTop, btnWidth, btnWidth) tag:baseTag + TankDirectioneRight]];
    
    [_controlView addSubview:[self createBtn:@"dir_up" frame:CGRectMake(margin + btnWidth, 0 + marginTop, btnWidth, btnWidth) tag:baseTag + TankDirectioneUp]];
    
    [_controlView addSubview:[self createBtn:@"dir_down" frame:CGRectMake(margin + btnWidth, btnWidth * 2 + marginTop, btnWidth, btnWidth) tag:baseTag + TankDirectioneDown]];
    
    [_controlView addSubview:[self createBtn:@"fire" frame:CGRectMake(_controlView.frame.size.width - margin - btnWidth * 2, btnWidth + marginTop, btnWidth * 2, btnWidth * 1.6) tag:fireTag]];
    
    _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _playBtn.frame = CGRectMake(_controlView.frame.size.width - margin - btnWidth * 5, btnWidth + marginTop, btnWidth * 1.4, btnWidth * 1.4);
    [_playBtn addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
    [_playBtn setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    [_playBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateSelected];
    [_controlView addSubview:_playBtn];
    
}

#pragma mark - 创建按钮
- (UIButton *)createBtn:(NSString *)title frame:(CGRect)frame tag:(int)tag {
    UIButton *btn = [[UIButton alloc] initWithFrame:frame];
    //[btn setTitle:title forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchDown];
    [btn addTarget:self action:@selector(btnClickUp:) forControlEvents:UIControlEventTouchUpInside];
    
    btn.tag = tag;
    
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:30];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    
    [btn setImage:[UIImage imageNamed:title] forState:UIControlStateNormal];
    
    [self.controlView addSubview:btn];
    return btn;
}

#pragma mark - 暂停
- (void)play:(UIButton *)sender {
    if (![Factory isGameover]) {
        _playBtn.selected = !_playBtn.selected;
        if (_playBtn.selected) {
            _timer.fireDate = [NSDate distantFuture];
        } else {
            _timer.fireDate = [NSDate distantPast];
        }
    }
}

+ (void)pauseGame {
    _playBtn.selected = YES;
    _timer.fireDate = [NSDate distantFuture];
}

#pragma mark - 按键点击
- (void)btnClick:(UIButton *)sender {
    if (fireTag != sender.tag && !_playBtn.selected && ![Factory isGameover]) {//方向键
        self.mainTank.canMove = true;
        //sender.tag - baseTag就是方向的枚举
        _mainTank.dir = sender.tag - baseTag;
                
    } else {//fire
        for (Bullet *b in _mainTank.bullets) {
            if (!b.canMove) {
                b.canMove = true;
                break;
            }
        }
    }
}

- (void)btnClickUp:(UIButton *)sender {
    if (fireTag != sender.tag) {//方向键
       self.mainTank.canMove = false;
    } else {//fire
        
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

int count_time = 0;
int hideZj = 0;
#pragma mark - 主坦克刷新
- (void)refresh:(NSTimer *)timer {
    count_time++;
    //每 几 秒产生新坦克,5秒后，开始随机，因为此时，count_time才大于oneSeconeCount * 5 才有机会求得的余数是0
    int rn = arc4random() % 20;
    if (count_tank < badTankCount && count_time > oneSeconeCount * 5 && rn < 2) {
        count_time = 0;
        if ([self.factory randomBadTank:-1]){
            count_tank++;
        }
        
        if (rn == 1) {
            if ([self.factory randomBadTank:-1]){
                count_tank++;
            }
        }
    }
    
    if (!_zj.isHidden) {
        hideZj ++;
    }
    if (hideZj >= wuditime * oneSeconeCount) {
        hideZj = 0;
        _zj.hidden = YES;
        [_zj removeFromSuperview];
    }
    
    [self pass];
    
    //创建新主战坦克
    if (_mainTank.life > 0 && _mainTank.isDeath) {
        if (_mainTank.life > 0) {
            CGPoint mc = self.mainView.center;
            CGFloat width = self.mainView.frame.size.width;
            NSInteger life = _mainTank.life - 1;
            _mainTank = [_factory createTank:TankTypeMain direction:TankDirectioneUp center:CGPointMake(mc.x - 100, mc.y + width / 2 - 60)];
            _mainTank.life = life;
            _info.text = [NSString stringWithFormat:@"我方：%ld", _mainTank.life];
            
            [self zjgh];
        }
    }
    if (_mainTank.life <= 0 && _mainTank.isDeath) {
        [Factory setIsGameover:true];
    }

    [_mainTank move:_mainTank.dir timer:_timer];
    
    for (Bullet *b in self.mainTank.bullets) {
        [self.mainTank fire:b timer:_timer];
    }
    [self randTankMoveAndFire];
}

#pragma mark - 无敌
- (void)zjgh {
    [_mainTank.imgView addSubview:_zj];
    hideZj = 0;
    _zj.hidden = NO;
}

#pragma mark - 过关
static int stageCount = 1;
- (void)pass {
    if ([Factory isGameover]) {
        sleep(2.0);
        [self excessive:@"GAME OVER"];
    }
    
    
    if (count_tank >= badTankCount && [Factory instanceOfBadTankArray].count == 0 && ![Factory isBorining] && ![Factory isGameover]) {
        [self excessive:[NSString stringWithFormat:@"SCENARIO : %d", ++stageCount]];
    }
}

//过度画面
- (void)excessive:(NSString *)tip {
    PassViewController *pv = [PassViewController new];
    pv.tip = tip;
    _timer.fireDate = [NSDate distantFuture];
    //清空界面
    [Factory clearAll];
    pv.viewController = self;
    
    CATransition *animation = [CATransition animation]; animation.duration = 2.5;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
//    animation.type = @"pageCurl";
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromRight;
    [self.view.window.layer addAnimation:animation forKey:nil];
    [self presentViewController:pv animated:NO completion:nil];
    
}

static bool badTankStop = false;
int stopCount = 0;
+ (void)stopBadTankIn6s {
    badTankStop = true;
    stopCount = 0;
}

#pragma mark - 坦克随机移动
- (void)randTankMoveAndFire {
    if (badTankStop) {
        stopCount++;
        if (stopCount >= oneSeconeCount * 6) {
            badTankStop = false;
            stopCount = 0;
        }
        return;
    }
    
    for (Tank *t in [Factory instanceOfBadTankArray]) {
        //1到100变换方向的概率
        NSInteger changeDir = arc4random() % 100 + 1;
        
        //有5%的概率不移动 有75%的概率改变方向
        if (changeDir > 95) {
            t.canMove = false;
            t.dir = 1 << arc4random() % 4;
        } else {
            t.canMove = true;
            [t move:t.dir timer:_timer];
        }
        //百分之2概率开火,只要没有发射子弹
        #pragma mark - fire
        if (changeDir < 4 && !t.isDeath && !t.bobming) {
            t.bullets.firstObject.canMove = true;
        }
        
        [t fire:t.bullets.firstObject timer:_timer];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!welcomed) {
        welcomed = true;
        [self presentViewController:[WelcomeViewController new] animated:YES completion:nil];
        [self restart];
        _timer.fireDate = [NSDate distantFuture];
        return;
    }
    _timer.fireDate = [NSDate distantPast];
    [self playingSoundEffectWith:@"start.wav"];
    
    if (![Factory isBorining] && ![Factory isGameover]) {
        stage++;
        
        if (stage >= totalStatge) {
            stage = 0;
        }
        
        count_tank = count_tank_init;
        [self randBadTank];
        
        CGPoint mc = self.mainView.center;
        CGFloat width = self.mainView.frame.size.width;
        NSInteger life = _mainTank.life;
        int level = _mainTank.level;
        
        _mainTank = [_factory createTank:TankTypeMain direction:TankDirectioneUp center:CGPointMake(mc.x - 100, mc.y + width / 2 - 60)];
        [self zjgh];
        
        _mainTank.life = life;
        _mainTank.level = level;
#pragma mark - 开挂
//        _mainTank.level = 3;
        
        XibUtil *util = [[XibUtil alloc] initWithMainView:self.mainView];
        for (Wall *w in [util changeMap:[NSString stringWithFormat:@"Map%d", stage]]) {
            [self.mainView addSubview:w.imgView];
            [self.mainView bringSubviewToFront:w.imgView];
        }
    }

    _info.text = [NSString stringWithFormat:@"我方：%ld", _mainTank.life];
}


@end
