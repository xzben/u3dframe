//
//  CJSInterstitialUtil.c
//

#import "CSJInterstitialUtil.h"
#import "../ADUtil.h"
#import "../../utils/AppUtil.h"
#import "CSJCommonUtil.h"

@implementation CSJInterstitialUtil

static CSJInterstitialUtil *singleton = nil;

+(CSJInterstitialUtil*) getInstance
{
    if(!singleton){
        singleton = [[self alloc] init];
    }
    
    return singleton;
}


+ (void) createInterstitialAd:(NSString *)json{
    NSLog(@"CSJInterstitialUtil:createInterstitialAd:json = %@", json);
    NSDictionary *dict = [AppUtil jsonStringToDictionary: json];
    const int width = [[dict objectForKey:@"width"] intValue];
    const int height = [[dict objectForKey:@"height"] intValue];
    NSString* adId = [[CSJCommonUtil getInstance] interstitialAdId];
    [[CSJInterstitialUtil getInstance] createAd:adId width:width height:height];
}



- (void) createAd:(NSString*)adid width:(int)width height:(int)height
{
  self.m_interstitialView = [[BUNativeExpressFullscreenVideoAd alloc] initWithSlotID:adid];
  self.m_interstitialView.delegate = self;
  [self.m_interstitialView loadAdData];
}

- (void) showAd
{
   if (self.m_interstitialView != nil && self.m_interstitialView.isAdValid)
   {
       [self.m_interstitialView showAdFromRootViewController:[[ADUtil getInstance] getAdView]];
   }
}

#pragma ---BUNativeExpressFullscreenVideoAdDelegate
- (void)nativeExpressFullscreenVideoAdDidLoad:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd
{
    NSLog(@"%s",__func__);
    [AppUtil NotifyEngine:@"onInsertComplete" dic:nil];
}

- (void)nativeExpressFullscreenVideoAd:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *)error
{
    NSLog(@"%s %@",__func__, error);
    NSString *code = [NSString stringWithFormat:@"%ld",error.code];
    NSMutableDictionary* mdict = [[NSMutableDictionary alloc]init];
    [mdict setObject:code forKey:@"errorCode"];
    [mdict setObject:error.localizedDescription forKey:@"errorMsg"];
    [AppUtil NotifyEngine:@"onInsertError" dic:mdict];
    
}

- (void)nativeExpressFullscreenVideoAdDidDownLoadVideo:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd;
{
    NSLog(@"%s",__func__);
    [AppUtil NotifyEngine:@"onInsertShow" dic:nil];
    [self showAd];
}

- (void)nativeExpressFullscreenVideoAdViewRenderFail:(BUNativeExpressFullscreenVideoAd *)rewardedVideoAd error:(NSError *)error;
{
    NSLog(@"%s %@",__func__, error);
    NSString *code = [NSString stringWithFormat:@"%ld",error.code];
    NSMutableDictionary* mdict = [[NSMutableDictionary alloc]init];
    [mdict setObject:code forKey:@"errorCode"];
    [mdict setObject:error.localizedDescription forKey:@"errorMsg"];
    [AppUtil NotifyEngine:@"onInsertError" dic:mdict];
}

@end
