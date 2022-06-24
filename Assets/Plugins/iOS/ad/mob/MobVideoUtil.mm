//
//  MobVideoUtil.c
//

#import "MobVideoUtil.h"
#import "../ADUtil.h"
#import "../../utils/AppUtil.h"
#import "MobCommonUtil.h"

@implementation MobVideoUtil

static MobVideoUtil *singleton = nil;

+(MobVideoUtil*) getInstance
{
    if(!singleton){
        singleton = [[self alloc] init];
    }
    return singleton;
}


+ (void) createVideoAd:(NSString *)json{
    NSLog(@"MobVideoUtil:createSplashAd:json = %@", json);
    NSDictionary *dict = [AppUtil jsonStringToDictionary: json];
    const char* _userId = [[dict objectForKey:@"userId"] UTF8String];
    NSString* userId = [[NSString alloc] initWithUTF8String:_userId];
    NSString* adId = [[MobCommonUtil getInstance] videoAdId];
    [[MobVideoUtil getInstance] createVideoAd:userId adid:adId];
}


- (void) createVideoAd:(NSString*)userId adid:(NSString*) adid
{
    //先判断是否预加载好了
    UIViewController *adView = [[ADUtil getInstance] getAdView];
    if (self.m_videoView != nil && [self.m_videoView
                                           canPresentFromRootViewController:adView
                                                                      error:nil]){
        [self showAd];
    } else {
        [self preLoadVideoAd:^(NSError *error) {
            if (error) {
                NSLog(@"load video error: %@", [error localizedDescription]);
                return;
            }
            NSLog(@"video ad loaded.");
            [self showAd];
        }];
    }
    
}

- (void) preLoadVideoAd:(AdLoadCompletionHandler)completionHandler{
    self.m_completionHandler = completionHandler;
    GADRequest *request = [GADRequest request];
    NSString* adId = [[MobCommonUtil getInstance] videoAdId];
    [GADRewardedAd loadWithAdUnitID:adId
                              request:request
                    completionHandler:^(GADRewardedAd *ad, NSError *error) {
        if (error) {
            NSLog(@"Failed to preLoadVideoAd ad with error: %@", [error localizedDescription]);
            if (self.m_completionHandler) {
                _m_completionHandler(error);
            }
            return;
        }
        self.m_videoView = ad;
        self.m_videoView.fullScreenContentDelegate = self;
        if (self.m_completionHandler) {
            _m_completionHandler(nil);
        }
    }];
}

- (void) clearAd
{
    if(self.m_videoView != nil){
        //[self.m_videoView release];
    }
    self.m_videoView = nil;
}

- (void) showAd
{
    UIViewController *adView = [[ADUtil getInstance] getAdView];
    if (self.m_videoView != nil && [self.m_videoView
                                           canPresentFromRootViewController:adView
                                                                      error:nil]){
        UIViewController *adView = [[ADUtil getInstance] getAdView];
        [self.m_videoView presentFromRootViewController:adView
                          userDidEarnRewardHandler:^{
                            GADAdReward *reward = self.m_videoView.adReward;
                            NSString *rewardMessage = [NSString
                                stringWithFormat:@"Reward received with currency %@ , amount %lf",
                                                 reward.type, [reward.amount doubleValue]];
                            NSLog(@"%@", rewardMessage);
                            // Reward the user for watching the video.
                            [AppUtil NotifyEngine:@"onRewardVerify" dic:nil];
                          }];
    } else {
        NSLog(@"videoAd not ready");
    }
    
}

#pragma mark - GADFullScreenContentDelegate
/// Tells the delegate that the ad failed to present full screen content.
- (void)ad:(nonnull id<GADFullScreenPresentingAd>)ad
didFailToPresentFullScreenContentWithError:(nonnull NSError *)error {
    NSLog(@"Ad did fail to present full screen content.");
    NSLog(@"%s",__func__);
    NSString *code = [NSString stringWithFormat:@"%ld",error.code];
    NSMutableDictionary* mdict = [[NSMutableDictionary alloc]init];
    [mdict setObject:code forKey:@"errorCode"];
    [mdict setObject:error.localizedDescription forKey:@"errorMsg"];
    [AppUtil NotifyEngine:@"onVideoError" dic:mdict];
}

/// Tells the delegate that the ad presented full screen content.
- (void)adDidPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    NSLog(@"%s",__func__);
    [AppUtil NotifyEngine:@"onVideoShow" dic:nil];
}

/// Tells the delegate that the ad dismissed full screen content.
- (void)adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    [AppUtil NotifyEngine:@"onVideoClose" dic:nil];
    [self preLoadVideoAd:nil]; //预加载下一个
}

@end
