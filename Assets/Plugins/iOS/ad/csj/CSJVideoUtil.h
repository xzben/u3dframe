//
//  CSJVideoUtil.h
//

#ifndef CSJVideoUtil_h
#define CSJVideoUtil_h

#import <BUAdSDK/BURewardedVideoAd.h>
#import <BUAdSDK/BURewardedVideoModel.h>
#import <BUAdSDK/BUAdSDK.h>

@interface CSJVideoUtil :NSObject<BURewardedVideoAdDelegate>

@property(nonatomic, strong) BURewardedVideoAd *m_videoView;
@property(nonatomic, strong) BURewardedVideoModel *m_rewardedVideoModel;

+(CSJVideoUtil*) getInstance;


- (void) createVideoAd:(NSString*)userId adid:(NSString*) adid;
- (void) showAd;

+ (void) createVideoAd:(NSString *)json;

@end

#endif /* CSJVideoUtil_h */
