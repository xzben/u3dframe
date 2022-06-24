//
//  CSJCommonUtil.h
//

#ifndef CSJCommonUtil_h
#define CSJCommonUtil_h

#import <Foundation/Foundation.h>

@interface CSJCommonUtil : NSObject

@property(nonatomic,strong) NSMutableDictionary *adData;

+ (instancetype)getInstance;

- (NSString *)bannerAdId;

- (NSString *)videoAdId;

- (NSString *)splashAdId;

- (NSString *)interstitialAdId;

- (void) initData:(NSDictionary *)adDatas;

- (void) initAd;


@end


#endif /* CSJCommonUtil_h */
