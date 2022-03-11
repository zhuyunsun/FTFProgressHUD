//
//  FTFProgressHUD.m
//  FTFProgressHUD
//
//  Created by 朱运 on 2021/12/23.
//

#import "FTFProgressHUD.h"

//视图加载需要在主线程中进行
#define FTFMainThreadAssert() NSAssert([NSThread isMainThread], @"FTFProgressHUD需要在主线程加载!");
//小视图的默认宽度
//#define FTFSmallWidth() 70.f

UIKIT_STATIC_INLINE CGFloat FTFSmallWidth(){
    return 70.f;
}

@interface FTFProgressHUD(){
    /*
     设计几种常见的动画加载hud
     注意的事情:
     1,在主线程调用
    */
    
    UIView *currentView;
    CGFloat width;
    CGFloat height;
    FTFHUDStyle currentMode;
    UIView *backView;
    
    FTFSpotView *spointView;
    UIActivityIndicatorView *activityIndicator;
    FTFFireView *fireView;
    FTFBlinkView *blinkView;
    FTFCircleView *circleView;
    
}
@end
@implementation FTFProgressHUD


- (instancetype)initWithFrame:(CGRect)frame mode:(FTFHUDStyle)mode{
    self = [super initWithFrame:frame];
    if (self) {
        //创建hud
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        currentMode = mode;
        
        width = frame.size.width;
        height = frame.size.height;
        
        currentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
        currentView.userInteractionEnabled = NO;
        [self addSubview:currentView];
        
        [self myBackView];
        
        if (mode == FTFHUDStyleDefault) {
            [self createDefault];
        }
        if (mode == FTFHUDStyleSpot) {
            [self createSpot];
        }
        if (mode == FTFHUDStyleFire) {
            [self createFire];
        }
        if (mode == FTFHUDStyleBlink) {
            [self createBall];
        }
        if (mode == FTFHUDStyleCircle) {
            [self createCircle];
        }

    }
    return self;
}

+(instancetype)showHudInView:(UIView *)view mode:(FTFHUDStyle)mode{
    FTFProgressHUDSDKVersion(mode);
    FTFMainThreadAssert();
    FTFProgressHUD *hud = [[FTFProgressHUD alloc]initWithView:view mode:mode];
    hud.alpha = 0.01;
    [UIView animateWithDuration:0.5 animations:^{
        hud.alpha = 1;
    } completion:^(BOOL finished) {
        [view addSubview:hud];
    }];
    return hud;
}
- (id)initWithView:(UIView *)view mode:(FTFHUDStyle)mode{
    //需要hud父视图的宽高
    return [self initWithFrame:view.bounds mode:mode];
}

#pragma mark 移除当前HUD

-(void)hudHide:(FTFProgressHUD *)hud{
    /*
     根据当前不同的mode进行不同的移除操作
     */
    if (currentMode == FTFHUDStyleDefault) {
        [activityIndicator stopAnimating];
    }
    if (currentMode == FTFHUDStyleSpot) {
        [spointView removeTimer1];
    }
    if (currentMode == FTFHUDStyleFire) {
        [fireView removeTimer2];
    }
    if (currentMode == FTFHUDStyleBlink) {
        [blinkView removeBlinkTimer];
    }
    if (currentMode == FTFHUDStyleCircle) {
        [circleView removeCurrentTimer];
    }

    [UIView animateWithDuration:0.3 animations:^{
        hud.alpha = 0.01;
    } completion:^(BOOL finished) {
        [hud removeFromSuperview];
    }];
}
+(BOOL)hideHudInView:(UIView *)view{
    FTFMainThreadAssert();
    /*
     通过枚举查找加载在view视图上的FTFProgressHUD,并移除它.
     */
    FTFProgressHUD *hud = [self HUDForView:view];
    if (hud != nil) {
        [hud hudHide:hud];
        return YES;
    }
    return NO;
}

+ (FTFProgressHUD *)HUDForView:(UIView *)view{
    NSEnumerator *subviewsEnum = [view.subviews reverseObjectEnumerator];
    for (UIView *subview in subviewsEnum) {
        if ([subview isKindOfClass:self]) {
            FTFProgressHUD *hud = (FTFProgressHUD *)subview;
//            if (hud.hasFinished == NO) {
//                return hud;
//            }
            return hud;
        }
    }
    return nil;
}


#pragma mark 创建对应的HUD

#pragma mark  FTFHUDStyleDefault
-(void)createDefault{
    if (@available(iOS 13.0, *)) {
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
        activityIndicator.color = [UIColor whiteColor];

    } else {
       activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    }
    
    activityIndicator.center = CGPointMake(FTFSmallWidth() / 2, FTFSmallWidth() / 2);
    [backView addSubview:activityIndicator];
    
    [activityIndicator startAnimating];
}
//创建有圆角的四方框
-(UIView *)myBackView{
    backView = [[UIView alloc]init];
    backView.frame = CGRectMake(0, 0, FTFSmallWidth(), FTFSmallWidth());
    backView.backgroundColor = [UIColor blackColor];
    backView.center = currentView.center;
    backView.layer.cornerRadius = 5;
    [currentView addSubview:backView];
    return backView;
}
#pragma mark FTFHUDStyleSpot
-(void)createSpot{
    spointView = [[FTFSpotView alloc]initWithFrame:CGRectMake(0, 0, FTFSmallWidth(), 25)];
    spointView.center = CGPointMake(width / 2, height / 2);
    [currentView addSubview:spointView];
}

#pragma mark FTFHUDStyleFire
-(void)createFire{
    CGRect r1 = CGRectMake(0, 0, backView.frame.size.width, backView.frame.size.height);
    fireView = [[FTFFireView alloc]initWithFrame:r1];
    [backView addSubview:fireView];
    [fireView beginFire];
}
#pragma mark FTFHUDStyleBlink
-(void)createBall{
    //有规律的闪烁,还是随机闪烁
    CGFloat blinkWidth = backView.frame.size.width *0.8;
    CGRect r1 = CGRectMake(0, 0, blinkWidth, blinkWidth);
    blinkView = [[FTFBlinkView alloc]initWithFrame:r1];
    blinkView.center = CGPointMake(backView.frame.size.width / 2, backView.frame.size.width / 2);
    [backView addSubview:blinkView];
}
#pragma mark  FTFHUDStyleCircle
-(void)createCircle{
    CGRect r1 = CGRectMake(0, 0, backView.frame.size.width, backView.frame.size.height);
    circleView = [[FTFCircleView alloc]initWithFrame:r1];
    [backView addSubview:circleView];
}
@end


#pragma mark 3个点,连续暗和亮
@interface FTFSpotView(){
    UIView *spot1;
    UIView *spot2;
    UIView *spot3;
    
    UIColor *blackColor;
    UIColor *whiteColor;
    
    NSTimer *currentTimer;
    NSUInteger currentIndex;
}
@end



#pragma mark ==============
@implementation FTFSpotView
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        blackColor = [UIColor grayColor];
        whiteColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor blackColor];
        self.layer.cornerRadius = 3;
        self.clipsToBounds = YES;
        
        CGFloat spotHeight = frame.size.height *0.45;
        CGFloat middleWidth = (frame.size.width - spotHeight *3) / 4;
        CGFloat spotMaxY = (frame.size.height - spotHeight) / 2;
        
        for (NSUInteger i = 0; i < 3; i ++) {
            UIView *view = [[UIView alloc]init];
            view.frame = CGRectMake(middleWidth + (spotHeight  + middleWidth) *i, spotMaxY, spotHeight, spotHeight);
            view.backgroundColor = whiteColor;
            view.layer.cornerRadius = spotHeight / 2;
            [self addSubview:view];
            
            if (i == 0) {
                spot1 = view;
            }
            if (i == 1) {
                spot2 = view;
                spot2.backgroundColor = blackColor;
            }
            if (i == 2) {
                spot3 = view;
                spot3.backgroundColor = blackColor;
            }

            
        }
        
        currentIndex = 0;
        NSTimer *timer = [NSTimer timerWithTimeInterval:0.3 target:self selector:@selector(currentTimerAction) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        currentTimer = timer;

        [currentTimer fire];
        
    }
    return self;
}

-(void)currentTimerAction{
//    NSLog(@"update = %ld",currentIndex);
    /*
     从第一个走到第三个,第三个走回第一个,循环往复;
     */
    if (currentIndex == 0) {
        spot1.backgroundColor = blackColor;
        spot2.backgroundColor = whiteColor;
        currentIndex = 1;
    }else if (currentIndex == 1) {
        spot2.backgroundColor = blackColor;
        spot3.backgroundColor = whiteColor;
        currentIndex = 2;
    }else{
        spot3.backgroundColor = blackColor;
        spot1.backgroundColor = whiteColor;
        currentIndex = 0;
    }


    
}
-(void)removeTimer1{
    [currentTimer invalidate];
    currentTimer = nil;
}
- (void)dealloc{
    [self removeTimer1];
}
@end

#pragma mark ===============

@interface FTFFireView(){
    CGFloat width;
    CGFloat height;
    CGFloat middleWidth;
    CGFloat middleHeight;
    CGFloat moreWidthX;//右边2个x坐标
    CGFloat moreHeightY;//底下2个y坐标
    CGPoint p1;
    CGPoint p2;
    CGPoint p3;
    CGPoint p4;
    NSUInteger currentPoint;
    
    NSTimer *fireTimer;
    UIView *ani;
    NSTimeInterval maxVal;
}
@end

@implementation FTFFireView
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        width = frame.size.width;
        height = frame.size.height;
        
        CGFloat lineWidth = width *0.5;
        UIView *lineView = [[UIView alloc]init];
        lineView.frame = CGRectMake(0, 0, lineWidth, lineWidth);
        lineView.backgroundColor = [UIColor clearColor];
        lineView.center = CGPointMake(width / 2, width / 2);
        lineView.layer.borderColor = [[UIColor grayColor] CGColor];
        lineView.layer.borderWidth = 1.1;
        [self addSubview:lineView];
        
        
        middleWidth = (width - lineWidth) / 2;
        middleHeight = middleWidth;
        moreWidthX = middleWidth + lineWidth;
        moreHeightY = middleHeight + lineWidth;
        
        p1 = CGPointMake(middleWidth, middleHeight);
        p2 = CGPointMake(moreWidthX, middleHeight);
        p3 = CGPointMake(moreWidthX, moreHeightY);
        p4 = CGPointMake(middleWidth, moreHeightY);
        
        
        ani = [[UIView alloc]init];
        ani.frame = CGRectMake(0, 0, 10, 10);
        ani.center = p1;
        ani.layer.cornerRadius = 5;
        ani.backgroundColor = [UIColor lightGrayColor];
        [self  addSubview:ani];
        
        currentPoint = 1;
        maxVal = 0.3;
        
        [self createEmit];
    }
    return self;
}
-(void)beginFire{
    [self removeTimer2];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSTimer *timer = [NSTimer timerWithTimeInterval:maxVal target:self selector:@selector(aniTimerAction) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        fireTimer = timer;
        [timer fire];

    });
}
-(void)aniTimerAction{
    //执行一次就是走四分之一
//    NSLog(@"currentPoint = %ld",currentPoint);
    if (currentPoint == 1) {
        [UIView animateWithDuration:maxVal animations:^{
            ani.center = p2;
        }];
        currentPoint = 2;
    }else if (currentPoint == 2){
        [UIView animateWithDuration:maxVal animations:^{
            ani.center = p3;
        }];
        currentPoint = 3;
    }else if (currentPoint == 3){
        [UIView animateWithDuration:maxVal animations:^{
            ani.center = p4;
        }];
        currentPoint = 4;
    }else{
        [UIView animateWithDuration:maxVal animations:^{
            ani.center = p1;
        }];
        currentPoint = 1;
    }
}
-(void)removeTimer2{
    [fireTimer invalidate];
    fireTimer = nil;
}
-(void)dealloc{
    [self removeTimer2];
}


-(void)createEmit{
    

}
@end


#pragma mark ===============

@interface FTFBlinkView(){
    CGFloat width;
    CGFloat height;

    NSUInteger index;
    NSTimer *blinkTimer;
    NSMutableArray <UIView *>*arrView;
    NSUInteger currentIndex;
    
    UIView *movingView;
    UIView *downView;
    NSUInteger downIndex;
    NSMutableArray <UIView *>*arrDownView;
    NSTimer *downTimer;
    
    NSTimeInterval val1;
}
@end

@implementation FTFBlinkView
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor blackColor];
        
        width = frame.size.width;
        height = frame.size.height;

        NSUInteger count = 4;
        CGFloat v1Height = width *0.15;
        CGFloat middleHeight = (width - v1Height *count) / (count + 1);
        
        index = 0;
        arrView = [[NSMutableArray alloc]init];
        arrDownView = [[NSMutableArray alloc]init];
        
        //小圆点的颜色
        UIColor *color = [UIColor grayColor];
//        color = [UIColor whiteColor];
        
        for (NSUInteger i = 0; i < count; i ++) {
            
            CGFloat y = middleHeight + (middleHeight + v1Height) *i;
            for (NSUInteger j = 0; j < count; j ++) {
                CGFloat x = middleHeight + (middleHeight + v1Height) *j;
                UIView *v1 = [[UIView alloc]init];
                v1.frame = CGRectMake(x, y, v1Height, v1Height);
                v1.backgroundColor = color;
                v1.tag = 1000000 + index;
                v1.layer.cornerRadius = v1Height / 2;
                v1.clipsToBounds = YES;
                [self addSubview:v1];
                
                if (index < 8) {
                    [arrView addObject:v1];
                }
                if (8<= index && index < 16) {
                    [arrDownView addObject:v1];
                }
                index ++;
                if (i == 0 && j == 0) {
                    movingView = [[UIView alloc]init];
                    movingView.frame = v1.frame;
                    movingView.layer.cornerRadius = v1Height / 2;
                    movingView.backgroundColor = [UIColor redColor];
                }
                if (i == (count - 1) && j == (count - 1)) {
                    downView = [[UIView alloc]init];
                    downView.frame = v1.frame;
                    downView.layer.cornerRadius = v1Height / 2;
                    downView.backgroundColor = [UIColor blueColor];
                }

            }
            
            
        }
        
        [self addSubview:movingView];
        [self addSubview:downView];
        
        currentIndex = 0;
        downIndex = 7;//下标
        //
        val1 = 0.18;
        [self removeBlinkTimer];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSTimer *timer = [NSTimer timerWithTimeInterval:val1 target:self selector:@selector(blinkTimerAction) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
            blinkTimer = timer;
            [timer fire];

            
            NSTimer *timer1 = [NSTimer timerWithTimeInterval:val1 target:self selector:@selector(downTimerAction) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:timer1 forMode:NSRunLoopCommonModes];
            downTimer = timer1;
            [timer1 fire];

        });

    }
    return self;
}

-(void)blinkTimerAction{
    
    if (currentIndex == 0) {
        currentIndex = currentIndex + 5;
        [self animatedIndexView:currentIndex];
    }
    else if(currentIndex == 5){
        currentIndex = currentIndex - 3;
        [self animatedIndexView:currentIndex];
    }
    else if(currentIndex == 2){
        currentIndex = currentIndex + 5;
        [self animatedIndexView:currentIndex];
    }
    else if(currentIndex == 7){
        currentIndex = currentIndex - 4;
        [self animatedIndexView:currentIndex];
    }
    else if(currentIndex == 3){
        currentIndex = currentIndex + 3;
        [self animatedIndexView:currentIndex];
    }
    else if(currentIndex == 6){
        currentIndex = currentIndex - 5;
        [self animatedIndexView:currentIndex];
    }
    else if(currentIndex == 1){
        currentIndex = currentIndex + 3;
        [self animatedIndexView:currentIndex];
    }else if(currentIndex == 4){
        currentIndex = currentIndex - 4;
        [self animatedIndexView:currentIndex];
    }
    
}
-(void)downTimerAction{
    if (downIndex == 7) {
        downIndex = 2;
        [self downAnimatedIndexView:downIndex];
    }
    else if(downIndex == 2){
        downIndex = 5;
        [self downAnimatedIndexView:downIndex];
    }
    else if(downIndex == 5){
        downIndex = 0;
        [self downAnimatedIndexView:downIndex];
    }
    else if(downIndex == 0){
        downIndex = 4;
        [self downAnimatedIndexView:downIndex];
    }
    else if(downIndex == 4){
        downIndex = 1;
        [self downAnimatedIndexView:downIndex];
    }
    else if(downIndex == 1){
        downIndex = 6;
        [self downAnimatedIndexView:downIndex];
    }
    else if(downIndex == 6){
        downIndex = 3;
        [self downAnimatedIndexView:downIndex];
    }
    else if(downIndex == 3){
        downIndex = 7;
        [self downAnimatedIndexView:downIndex];
    }



}
-(void)downAnimatedIndexView:(NSUInteger)code{
    UIView *v1 = arrDownView[code];
    [UIView animateWithDuration:val1 animations:^{
        downView.frame = v1.frame;
    }];
}

-(void)animatedIndexView:(NSUInteger)code{
    UIView *v1 = arrView[code];
    [UIView animateWithDuration:val1 animations:^{
        movingView.frame = v1.frame;
    }];
}
-(void)removeBlinkTimer{
    [blinkTimer invalidate];
    blinkTimer = nil;
    
    [downTimer invalidate];
    downTimer = nil;
}
- (void)dealloc{
    [self removeBlinkTimer];
}
@end

#pragma mark ===============
@interface FTFCircleView(){
    CGFloat width;
    CGFloat height;
    
    UIView *circle1;
    UIView *circle2;
    UIView *circle3;
    
    NSTimer *timer;
    
    UIColor *changeColor;
    UIColor *c1Color;
    NSUInteger currentIndex;
    
    UIColor *yellowColor;
    UIColor *redColor;
    UIColor *greenColor;
    
}
@end
@implementation FTFCircleView


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        width = frame.size.width;
        height = frame.size.height;
        
        changeColor = [UIColor whiteColor];
        c1Color = [UIColor lightGrayColor];
        
        yellowColor = [UIColor yellowColor];
        redColor = [UIColor redColor];
        greenColor = [UIColor greenColor];
        
        CGFloat h1 = width *0.3;
        circle1 = [self circleLineWidth:h1];
        
        
        CGFloat h2 = width *0.6;
        circle2 = [self circleLineWidth:h2];

        CGFloat h3 = width *0.8;
        circle3 = [self circleLineWidth:h3];

        
        currentIndex = 0;
        circle1.layer.borderColor = [redColor CGColor];
        circle2.layer.borderColor = [yellowColor CGColor];
        circle3.layer.borderColor = [greenColor CGColor];
        NSTimeInterval val1 = 0.2;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            timer = [NSTimer timerWithTimeInterval:val1 target:self selector:@selector(circleTimerAction) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
            [timer fire];

        });
        
        
    }
    return self;
}
//红 黄 绿
-(void)circleTimerAction{
    if (currentIndex == 0) {
        circle1.layer.borderColor = [yellowColor CGColor];
        circle2.layer.borderColor = [greenColor CGColor];
        circle3.layer.borderColor = [redColor CGColor];
        currentIndex = 1;
    }else if(currentIndex == 1){
        circle1.layer.borderColor = [greenColor CGColor];
        circle2.layer.borderColor = [redColor CGColor];
        circle3.layer.borderColor = [yellowColor CGColor];
        currentIndex = 2;
    }else{
        circle1.layer.borderColor = [redColor CGColor];
        circle2.layer.borderColor = [yellowColor CGColor];
        circle3.layer.borderColor = [greenColor CGColor];
        currentIndex = 0;
    }
    
    
}
-(void)removeCurrentTimer{
    [timer invalidate];
    timer = nil;
}
-(void)dealloc{
    [self removeCurrentTimer];
}
-(UIView *)circleLineWidth:(CGFloat)v1Height{
    CGPoint center = self.center;
    
    UIView *v1 = [[UIView alloc]init];
    v1.frame = CGRectMake(0, 0, v1Height, v1Height);
    v1.clipsToBounds = YES;
    v1.layer.cornerRadius = v1Height / 2;
    v1.layer.borderColor = [c1Color CGColor];
    v1.layer.borderWidth = 1.3f;
    v1.backgroundColor = [UIColor clearColor];
    v1.center = center;
    [self addSubview:v1];
    return v1;
}
@end
