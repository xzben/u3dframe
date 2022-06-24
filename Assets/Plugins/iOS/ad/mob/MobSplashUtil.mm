//
//  MobSplashUtil.c [开屏广告]
//
#import "MobSplashUtil.h"
#import "../ADUtil.h"
#import "../../utils/AppUtil.h"
#import <UIKit/UIApplication.h>
#import "MobCommonUtil.h"


@implementation MobSplashUtil

static MobSplashUtil *singleton = nil;

+(MobSplashUtil*) getInstance
{
    if(!singleton){
        singleton = [[self alloc] init];
    }
    return singleton;
}


- (void) showSplashAd{
    NSString* adId = [[MobCommonUtil getInstance] splashAdId];
    NSLog(@"MobSplashUtil:createSplashAd:splashId = %@", adId);
    [self createAd:adId outtime:3000];
}


-(void) handleChangeScreenOrientation:(bool) isLand
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
    self.m_splashView = nil;
    NSLog(@"===============create clearAd================");
}

- (void) createAd:(NSString*) adid outtime:(int)outtime
{
    self.m_splashView = nil;
    [GADAppOpenAd loadWithAdUnitID:adid
                         request:[GADRequest request]
                     orientation:UIInterfaceOrientationPortrait
               completionHandler:^(GADAppOpenAd *_Nullable appOpenAd, NSError *_Nullable error) {
                    if (error) {
                        NSLog(@"Failed to load app open ad: %@", error);
                        return;
                    }
                    self.m_splashView = appOpenAd;
                    self.m_splashView.fullScreenContentDelegate = self;
        
                    UIViewController *adView = [[ADUtil getInstance] getAdView];
                    if (self.m_splashView != nil && [self.m_splashView
                                                           canPresentFromRootViewController:adView
                                                                                      error:nil]){
                        UIViewController *adView = [[ADUtil getInstance] getAdView];
                        [self.m_splashView presentFromRootViewController:adView];
                    } else {
                        NSLog(@"videoAd not ready");
                    }
                    
               }];
    NSLog(@"===============create splashUtil================");
}

#pragma mark - GADFullScreenContentDelegate
/// Tells the delegate that the ad failed to present full screen content.
- (void)ad:(nonnull id<GADFullScreenPresentingAd>)ad
    didFailToPresentFullScreenContentWithError:(nonnull NSError *)error {
    NSLog(@"didFailWithError== %s %@",__func__, error);
    [self clearAd];
    [[ADUtil getInstance] gotoMain];
}

/// Tells the delegate that the ad presented full screen content.
- (void)adDidPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    NSLog(@"adDidPresentFullScreenContent");
    [[ADUtil getInstance] stopOutTimer];
}

/// Tells the delegate that the ad dismissed full screen content.
- (void)adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    NSLog(@"adDidDismissFullScreenContent");
    [[ADUtil getInstance] gotoMain];
    [self clearAd];
}


+ (void) createSplashAd:(NSString *)json{
    NSLog(@"MobSplashUtil:createSplashAd:json = %@", json);
    NSDictionary *dict = [AppUtil jsonStringToDictionary: json];
    const int timeout = [[dict objectForKey:@"timeout"] intValue];
    const bool isLand = [[dict objectForKey:@"isLand"] boolValue];
    NSString* adId = [[MobCommonUtil getInstance] splashAdId];
    [[MobSplashUtil getInstance] createAd:adId outtime:timeout];
}

@end
