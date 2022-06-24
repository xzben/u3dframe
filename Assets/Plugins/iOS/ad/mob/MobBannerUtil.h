//
//  MobBannerUtil.h
//
//

#ifndef MobBannerUtil_h
#define MobBannerUtil_h

#import <GoogleMobileAds/GoogleMobileAds.h>
#import <UIKit/UIKit.h>

@interface MobBannerUtil : NSObject<GADBannerViewDelegate>
@property(nonatomic, strong) GADBannerView *m_bannerView;

+(MobBannerUtil*) getInstance;

- (void) createBannerAd:(NSString*) adid isDeepLink:(BOOL)isDeepLink index:(int)index width:(float)width height:(float)height;
- (void) clearAd;


+ (void) createBannerAd:(NSString *)json;
+ (void) clearAd:(NSString *)json;

@end

#endif /* MobBannerUtil_h */
