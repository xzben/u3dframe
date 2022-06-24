//
//  MobCommonUtil.h
//

#ifndef MobCommonUtil_h
#define MobCommonUtil_h

#import <Foundation/Foundation.h>

@interface MobCommonUtil : NSObject

@property(nonatomic,strong) NSMutableDictionary *adData;

+ (instancetype)getInstance;

- (NSString *)bannerAdId;

- (NSString *)videoAdId;

- (NSString *)splashAdId;

- (NSString *)interstitialAdId;

- (void) initData:(NSDictionary *)adDatas;

- (void) initAd;


@end


#endif /* MobCommonUtil_h */
