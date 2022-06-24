//
//  MobCommonUtil.c
//

#import "MobCommonUtil.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "../../utils/AppUtil.h"
#import "MobSplashUtil.h"
#import "MobVideoUtil.h"
#import "MobInterstitialUtil.h"

@implementation MobCommonUtil

#pragma mark -
#pragma mark Singleton

static MobCommonUtil *mInstace = nil;
static NSString *AD_APPID = @"ca-app-pub-9276732315528267~5092556372";
static NSString *AD_BANNER_ADID = @"ca-app-pub-9276732315528267/9961739671";
static NSString *AD_VIDEO_ADID = @"ca-app-pub-9276732315528267/8265514624";
static NSString *AD_INTERST_ADID = @"ca-app-pub-9276732315528267/3396331325";
static NSString *AD_SPLASH_ADID = @"ca-app-pub-9276732315528267/5798299237";

+ (instancetype)getInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mInstace = [[super allocWithZone:NULL] init];
    });
    return mInstace;
}
+ (id)allocWithZone:(struct _NSZone *)zone {
    return [MobCommonUtil getInstance];
}

+ (id)copyWithZone:(struct _NSZone *)zone {
    return [MobCommonUtil getInstance];
}

#pragma mark -
#pragma mark Application lifecycle

- (NSString *)bannerAdId{
    return AD_BANNER_ADID;
}

- (NSString *)videoAdId{
    return AD_VIDEO_ADID;
}

- (NSString *)splashAdId{
    return AD_SPLASH_ADID;
}

- (NSString *)interstitialAdId{
    return AD_INTERST_ADID;
}

- (void) initData:(NSDictionary*)adDatas
{
    if (adDatas != nil) {
        NSString* adData = [[NSString alloc]initWithString:[adDatas objectForKey:@"csj"]];
        NSDictionary *dict = [AppUtil jsonStringToDictionary: adData];
        
        AD_APPID = [[NSString alloc]initWithString:[dict objectForKey:@"appId"]];
        AD_BANNER_ADID = [[NSString alloc]initWithString:[dict objectForKey:@"bannerId"]];
        AD_VIDEO_ADID = [[NSString alloc]initWithString:[dict objectForKey:@"videoId"]];
        AD_SPLASH_ADID = [[NSString alloc]initWithString:[dict objectForKey:@"splashId"]];
        AD_INTERST_ADID = [[NSString alloc]initWithString:[dict objectForKey:@"insertId"]];
    }
    [self initAd];
}

- (void) initAd
{
    const char* appId = [AD_APPID UTF8String];
    NSLog(@"MobCommonUtil:init:appid = %s", appId);
    [[GADMobileAds sharedInstance] startWithCompletionHandler:nil];
    
    [[GADMobileAds sharedInstance] startWithCompletionHandler:^(GADInitializationStatus *_Nonnull status) {
        if (status) {
            NSLog(@"startWithCompletionHandler: %@", [status description]);
            [[MobVideoUtil getInstance] preLoadVideoAd:nil];
            [[MobInterstitialUtil getInstance] preLoadAd:nil];
            return;
        }
    }];
    [[MobSplashUtil getInstance] showSplashAd];
}


@end

