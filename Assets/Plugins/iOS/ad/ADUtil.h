

#ifndef ADUtil_h
#define ADUtil_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ADUtil : NSObject

@property(nonatomic, strong) UIViewController *m_viewController;
@property(nonatomic, strong) NSTimer *m_outtimer;

+ (instancetype)getInstance;

- (void)initAdView:(UIViewController*)viewController;
- (UIViewController*)getAdView;
- (void)gotoMain;
- (void)stopOutTimer;
- (void)startOutTimer:(int)interval;

+ (NSString*)getStringItem:(NSString *)json;
+ (void)setStringItem:(NSString *)json;

+ (void) createBannerAd:(NSString *)json;
+ (void) clearBannerAd:(NSString *)json;

+ (void) createVideoAd:(NSString *)json;

+ (void) createInterstitialAd:(NSString *)json;

+ (void) createSplashAd:(NSString *)json;

@end

NS_ASSUME_NONNULL_END

#endif
