//
//  CJSInterstitialUtil.h
//

#ifndef CJSInterstitialUtil_h
#define CJSInterstitialUtil_h

#import <BUAdSDK/BUNativeExpressFullscreenVideoAd.h>
#import <BUAdSDK/BUAdSDK.h>

@interface CSJInterstitialUtil :NSObject<BUNativeExpressFullscreenVideoAdDelegate>

@property(nonatomic, strong) BUNativeExpressFullscreenVideoAd *m_interstitialView;

+(CSJInterstitialUtil*) getInstance;

- (void) createAd:(NSString*)adid width:(int)width height:(int)height;
- (void) showAd;

+ (void) createInterstitialAd:(NSString *)json;

@end

#endif /* CJSInterstitialUtil_h */
