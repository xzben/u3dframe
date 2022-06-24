//
//  CSJSplashUtil.h
//

#ifndef CSJSplashUtil_h
#define CSJSplashUtil_h

#import <BUAdSDK/BUSplashAdView.h>
#import <BUAdSDK/BUAdSDK.h>

@interface CSJSplashUtil :NSObject<BUSplashAdDelegate>

@property(nonatomic, strong) BUSplashAdView *m_splashView;
@property(nonatomic, strong) UIImageView *m_bgImageView;

+(CSJSplashUtil*) getInstance;

- (void) createAd:(NSString*)adid  outtime:(int)outtime;

- (void) showSplashAd;

+ (void) createSplashAd:(NSString *)json;

@end

#endif /* CSJSplashUtil_h */
