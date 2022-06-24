//
//  CSJCommonUtil.c
//

#import "CSJCommonUtil.h"
#import <BUAdSDK/BUAdSDKManager.h>
#import "../../utils/AppUtil.h"
#import "CSJSplashUtil.h"

@implementation CSJCommonUtil

#pragma mark -
#pragma mark Singleton

static CSJCommonUtil *mInstace = nil;
static NSString *AD_APPID = @"5230762";
static NSString *AD_BANNER_ADID = @"946991179";
static NSString *AD_VIDEO_ADID = @"947173989";
static NSString *AD_INTERST_ADID = @"947173972";
static NSString *AD_SPLASH_ADID = @"887608792";

+ (instancetype)getInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mInstace = [[super allocWithZone:NULL] init];
    });
    return mInstace;
}
+ (id)allocWithZone:(struct _NSZone *)zone {
    return [CSJCommonUtil getInstance];
}

+ (id)copyWithZone:(struct _NSZone *)zone {
    return [CSJCommonUtil getInstance];
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
    NSLog(@"CSJCommonUtil:init:appid = %s", appId);
    [BUAdSDKManager setAppID:[[NSString alloc] initWithUTF8String:appId]];
    [BUAdSDKManager setLoglevel:BUAdSDKLogLevelDebug];
    [[CSJSplashUtil getInstance] showSplashAd];
}


@end

