//
//  CSJSplashUtil.c [开屏广告]
//
#import "CSJSplashUtil.h"
#import "../ADUtil.h"
#import "../../utils/AppUtil.h"
#import <UIKit/UIApplication.h>
#import "CSJCommonUtil.h"


@implementation CSJSplashUtil

static CSJSplashUtil *singleton = nil;

+(CSJSplashUtil*) getInstance
{
    if(!singleton){
        singleton = [[self alloc] init];
    }
    
    return singleton;
}


- (void) showSplashAd{
    NSString* adId = [[CSJCommonUtil getInstance] splashAdId];
    NSLog(@"CSJSplashUtil:createSplashAd:splashId = %@", adId);
    [self createAd:adId outtime:3000];
}


-(void) handleChangeScreenOrientation:(bool)isLand
{
    UIInterfaceOrientation interfaceOrientation = UIInterfaceOrientationUnknown;
    if(isLand){
        interfaceOrientation = UIInterfaceOrientationLandscapeRight;
    }else{
        interfaceOrientation = UIInterfaceOrientationPortrait;
    }
    
    NSNumber* resetOrientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
    [[UIDevice currentDevice] setValue:resetOrientationTarget forKey:@"orientation"];
    NSNumber* orientationTarget = [NSNumber numberWithInt:interfaceOrientation];
    [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
}

- (void) clearAd
{
    if(self.m_splashView != nil)
    {
        [self.m_splashView removeFromSuperview];
    }
    self.m_splashView = nil;
    NSLog(@"===============create clearAd================");
}

- (void) createAd:(NSString*)adid outtime:(int)outtime
{
    [self handleChangeScreenOrientation:false];

    UIWindow *keyWindow = [UIApplication sharedApplication].windows.firstObject;

    CGRect frame = [UIScreen mainScreen].bounds;
    self.m_splashView = [[BUSplashAdView alloc] initWithSlotID:adid frame:frame];
    self.m_splashView.delegate = self;
    self.m_splashView.tolerateTimeout = outtime*0.001;
    
    [self.m_splashView loadAdData];
    [[[ADUtil getInstance] getAdView].view addSubview:self.m_splashView];
    self.m_splashView.rootViewController = [[ADUtil getInstance] getAdView];
    self.m_splashView.alpha = 0.0;
    
    NSLog(@"===============create splashUtil================");
}

- (void)splashAdDidLoad:(BUSplashAdView *)splashAd
{
    NSLog(@"===splashAdDidLoad %s",__func__);
}


- (void)splashAd:(BUSplashAdView *)splashAd didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError== %s %@",__func__, error);
    [self handleChangeScreenOrientation:true];
    [self clearAd];
    [[ADUtil getInstance] gotoMain];
}

- (void)splashAdWillVisible:(BUSplashAdView *)splashAd
{
    NSLog(@"splashAdWillVisible==%s",__func__);
    self.m_splashView.alpha = 1.0;

}

- (void)splashAdDidClick:(BUSplashAdView *)splashAd
{
    NSLog(@"splashAdDidClick==%s",__func__);
}

- (void)splashAdDidClose:(BUSplashAdView *)splashAd
{
    NSLog(@"splashAdDidClose==%s",__func__);
    [[ADUtil getInstance] gotoMain];
}

- (void)splashAdWillClose:(BUSplashAdView *)splashAd
{
    NSLog(@"splashAdWillClose===%s",__func__);
    [self handleChangeScreenOrientation:true];
    [self clearAd];
    [[ADUtil getInstance] gotoMain];
}


+ (void) createSplashAd:(NSString *)json{
    NSLog(@"CSJSplashUtil:createSplashAd:json = %@", json);
    NSDictionary *dict = [AppUtil jsonStringToDictionary: json];
    const int timeout = [[dict objectForKey:@"timeout"] intValue];
    const bool isLand = [[dict objectForKey:@"isLand"] boolValue];
    NSString* adId = [[CSJCommonUtil getInstance] splashAdId];
    [[CSJSplashUtil getInstance] createAd:adId outtime:timeout];
}

@end
