//
//  MobInterstitialUtil.mm
//

#import "MobInterstitialUtil.h"
#import "../ADUtil.h"
#import "../../utils/AppUtil.h"
#import "MobCommonUtil.h"

@implementation MobInterstitialUtil

static MobInterstitialUtil *singleton = nil;

+(MobInterstitialUtil*) getInstance
{
    if(!singleton){
        singleton = [[self alloc] init];
    }
    
    return singleton;
}


+ (void) createInterstitialAd:(NSString *)json{
    NSLog(@"MobInterstitialUtil:createInterstitialAd:json = %@", json);
    NSDictionary *dict = [AppUtil jsonStringToDictionary: json];
    const int width = [[dict objectForKey:@"width"] intValue];
    const int height = [[dict objectForKey:@"height"] intValue];
    NSString* adId = [[MobCommonUtil getInstance] interstitialAdId];
    [[MobInterstitialUtil getInstance] createAd:adId width:width height:height];
}


- (void) createAd:(NSString*)adid width:(int)width height:(int)height
{
    //先判断是否预加载好了
    UIViewController *adView = [[ADUtil getInstance] getAdView];
    if (self.m_interstitialView != nil && [self.m_interstitialView
                                           canPresentFromRootViewController:adView
                                                                      error:nil]){
        [self showAd];
    } else {
        [self preLoadAd:^(NSError *error) {
            if (error) {
                NSLog(@"load interstitial error: %@", [error localizedDescription]);
                return;
            }
            [self showAd];
        }];
    }
}


- (void) preLoadAd:(AdLoadCompletionHandler)completionHandler
{
    self.m_completionHandler = completionHandler;
    GADRequest *request = [GADRequest request];
    NSString* adId = [[MobCommonUtil getInstance] interstitialAdId];
    [GADInterstitialAd loadWithAdUnitID:adId
                              request:request
                    completionHandler:^(GADInterstitialAd *ad, NSError *error) {
        if (error) {
            NSLog(@"Failed to load interstitial ad with error: %@", [error localizedDescription]);
            if (self.m_completionHandler) {
                _m_completionHandler(error);
            }
            return;
        }
        self.m_interstitialView = ad;
        self.m_interstitialView.fullScreenContentDelegate = self;
        if (self.m_completionHandler) {
            _m_completionHandler(nil);
        }
    }];
}


- (void) showAd
{
    UIViewController *adView = [[ADUtil getInstance] getAdView];
    if (self.m_interstitialView != nil && [self.m_interstitialView
                                           canPresentFromRootViewController:adView
                                                                      error:nil]){
        [self.m_interstitialView presentFromRootViewController:adView];
    } else {
        NSLog(@"InsertAd not ready");
    }
}

#pragma ---GADFullScreenContentDelegate
// Tells the delegate that the ad failed to present full screen content.
- (void)ad:(nonnull id<GADFullScreenPresentingAd>)ad
didFailToPresentFullScreenContentWithError:(nonnull NSError *)error {
    NSLog(@"Ad did fail to present full screen content.");
    NSLog(@"%s %@",__func__, error);
    NSString *code = [NSString stringWithFormat:@"%ld",error.code];
    NSMutableDictionary* mdict = [[NSMutableDictionary alloc]init];
    [mdict setObject:code forKey:@"errorCode"];
    [mdict setObject:error.localizedDescription forKey:@"errorMsg"];
    [AppUtil NotifyEngine:@"onInsertError" dic:mdict];
}

/// Tells the delegate that the ad presented full screen content.
- (void)adDidPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    NSLog(@"onInsertShow.");
    [AppUtil NotifyEngine:@"onInsertShow" dic:nil];
}

/// Tells the delegate that the ad dismissed full screen content.
- (void)adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    NSLog(@"onInsertClose.");
    [AppUtil NotifyEngine:@"onInsertClose" dic:nil];
    [self preLoadAd:nil]; //预加载下一个
}


@end
