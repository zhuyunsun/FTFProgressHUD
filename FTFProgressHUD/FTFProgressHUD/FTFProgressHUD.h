//
//  FTFProgressHUD.h
//  FTFProgressHUD
//
//  Created by 朱运 on 2021/12/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger,FTFHUDStyle){
    FTFHUDStyleDefault = 1,
    FTFHUDStyleSpot,
    FTFHUDStyleFire,
    FTFHUDStyleBlink,
    FTFHUDStyleCircle  //红黄绿 三种颜色
                       //波纹效果
};
UIKIT_STATIC_INLINE NSString* FTFProgressHUDSDKVersion(FTFHUDStyle state){
    NSString *FTFProgressHUDSDKVersionStr = @"1.0.0";
    NSLog(@"FTFProgressHUDSDKVersion:12.31 = %@,类型:%ld",FTFProgressHUDSDKVersionStr,state);
    return FTFProgressHUDSDKVersionStr;
}

@interface FTFProgressHUD : UIView
-(instancetype)init NS_UNAVAILABLE;
+(instancetype)new NS_UNAVAILABLE;
#pragma mark 使用类方法方便使用
///展示HUD
+(instancetype)showHudInView:(UIView *)view mode:(FTFHUDStyle)mode;
///隐藏HUD
+(BOOL)hideHudInView:(UIView *)view;

@end

#pragma mark style views

@interface FTFSpotView : UIView
-(void)removeTimer1;
@end


@interface FTFFireView : UIView
-(void)beginFire;
-(void)removeTimer2;
@end


@interface FTFBlinkView : UIView
-(void)removeBlinkTimer;
@end


@interface FTFCircleView : UIView
-(void)removeCurrentTimer;
@end
NS_ASSUME_NONNULL_END
