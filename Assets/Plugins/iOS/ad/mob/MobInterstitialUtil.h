//
//  MobInterstitialUtil.h
//

#ifndef MobInterstitialUtil_h
#define MobInterstitialUtil_h

#import <GoogleMobileAds/GoogleMobileAds.h>
#import <UIKit/UIKit.h>

@interface MobInterstitialUtil : NSObject<GADFullScreenContentDelegate>

typedef void (^AdLoadCompletionHandler)(NSError * error);

@property(nonatomic, strong) GADInterstitialAd *m_interstitialView;
@property(nonatomic, strong) AdLoadCompletionHandler m_completionHandler;

+(MobInterstitialUtil*) getInstance;

- (void) createAd:(NSString*)adid width:(int)width height:(int)height;
- (void) preLoadAd:(AdLoadCompletionHandler)completionHandler;
- (void) showAd;

+ (void) createInterstitialAd:(NSString *)json;

@end

#endif /* MobInterstitialUtil_h */
