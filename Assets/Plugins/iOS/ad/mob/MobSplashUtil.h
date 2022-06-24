//
//  MobSplashUtil.h
//

#ifndef MobSplashUtil_h
#define MobSplashUtil_h

#import <GoogleMobileAds/GoogleMobileAds.h>
#import <UIKit/UIKit.h>

@interface MobSplashUtil : NSObject<GADFullScreenContentDelegate>

@property(strong, nonatomic) GADAppOpenAd* m_splashView;

+(MobSplashUtil*) getInstance;

- (void) createAd:(NSString*) adid outtime:(int)outtime;

- (void) showSplashAd;

+ (void) createSplashAd:(NSString *)json;

@end

#endif /* MobSplashUtil_h */
