//
//  MobVideoUtil.h
//

#ifndef MobVideoUtil_h
#define MobVideoUtil_h

#import <GoogleMobileAds/GoogleMobileAds.h>
#import <UIKit/UIKit.h>

@interface MobVideoUtil : NSObject<GADFullScreenContentDelegate>

typedef void (^AdLoadCompletionHandler)(NSError * error);

@property(nonatomic, strong) GADRewardedAd *m_videoView;
@property(nonatomic, strong) AdLoadCompletionHandler m_completionHandler;

+(MobVideoUtil*) getInstance;

- (void) createVideoAd:(NSString*)userId adid:(NSString*) adid;
- (void) preLoadVideoAd:(AdLoadCompletionHandler)completionHandler;
- (void) showAd;

+ (void) createVideoAd:(NSString *)json;

@end

#endif /* MobVideoUtil_h */
