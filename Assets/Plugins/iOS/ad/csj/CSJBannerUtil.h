//
//  CSJBannerUtil.h
//
//

#ifndef CSJBannerUtil_h
#define CSJBannerUtil_h

#import <BUAdSDK/BUNativeExpressBannerView.h>
#import <BUAdSDK/BUAdSDK.h>


@interface CSJBannerUtil : NSObject<BUNativeExpressBannerViewDelegate>
@property(nonatomic, strong) BUNativeExpressBannerView *m_bannerView;

+(CSJBannerUtil*) getInstance;

- (void) createBannerAd:(NSString*) adid isDeepLink:(BOOL)isDeepLink index:(int)index width:(float)width height:(float)height;
- (void) clearAd;


+ (void) createBannerAd:(NSString *)json;
+ (void) clearAd:(NSString *)json;

@end

#endif /* CSJBannerUtil_h */
