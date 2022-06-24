

#import "ADUtil.h"
#include "../utils/AppUtil.h"
#import "../utils/StoreUtil.h"
#import "./csj/CSJCommonUtil.h"
#import "./csj/CSJSplashUtil.h"
#import "./csj/CSJBannerUtil.h"
#import "./csj/CSJVideoUtil.h"
#import "./csj/CSJSplashUtil.h"
#import "./csj/CSJInterstitialUtil.h"
#import "./mob/MobCommonUtil.h"
#import "./mob/MobSplashUtil.h"
#import "./mob/MobBannerUtil.h"
#import "./mob/MobVideoUtil.h"
#import "./mob/MobSplashUtil.h"
#import "./mob/MobInterstitialUtil.h"

@implementation ADUtil

#pragma mark -
#pragma mark Singleton

static ADUtil *mInstace = nil;
static NSString *adType = @"csj";
static BOOL is_goto_main = false;

+ (instancetype)getInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mInstace = [[super allocWithZone:NULL] init];
    });
    return mInstace;
}
+ (id)allocWithZone:(struct _NSZone *)zone {
    return [ADUtil getInstance];
}

+ (id)copyWithZone:(struct _NSZone *)zone {
    return [ADUtil getInstance];
}

#pragma mark -
#pragma mark Application lifecycle

/**
 app显示给用户之前执行最后的初始化操作
 */
- (void)initAdView:(UIViewController*)viewController {
    NSLog(@"====initAdView=====");
    is_goto_main = false;
    self.m_viewController = viewController;
    [self startOutTimer:3];//<做个保护，超时自动跳过>
    NSDictionary* adDatasDict = [StoreUtil getObjectItem:@"__adDatas__"];
    adType = [StoreUtil getStringItem:@"__adUseType__" defValue:adType];
    if ([adType isEqualToString:@"csj"]) {
        [[CSJCommonUtil getInstance] initData:adDatasDict];
    }else if ([adType isEqualToString:@"mob"]) {
        [[MobCommonUtil getInstance] initData:adDatasDict];
    }else{
        [self gotoMain];
    }
    //跳过开屏广告
    //[self gotoMain];
}

- (UIViewController*)getAdView{
    return self.m_viewController;
}


-(void)startOutTimer:(int)interval{
    //开启定时器<这里防止开屏没有响应，超时跳过直接进入main.js>
    self.m_outtimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(gotoMain) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:self.m_outtimer forMode:NSRunLoopCommonModes];
}

-(void)stopOutTimer{
    if (self.m_outtimer != nil) {
        //取消定时器(永久性停止)
        [self.m_outtimer invalidate];
        //释放计时器
        self.m_outtimer = nil;
    }
}

/**
 执行main.js <开屏广告后可以执行这个>
 */
- (void)gotoMain{
    [self stopOutTimer];
    if (is_goto_main == false) {
        is_goto_main = true;
        NSLog(@"===gotoMain====");
        [AppUtil NotifyEngine:@"onSplashGoto" dic:nil];
    }
}

+ (NSString*)getStringItem:(NSString *)json{
    NSLog(@"ADUtil:getStringItem:json = %@", json);
    NSDictionary *dict = [AppUtil jsonStringToDictionary: json];
    NSString* key = [dict objectForKey:@"key"];
    NSString* defValue = [dict objectForKey:@"defValue"];
    return [StoreUtil getStringItem:key defValue:defValue];
}

+ (void)setStringItem:(NSString *)json{
    NSLog(@"ADUtil:setStringItem:json = %@", json);
    NSDictionary *dict = [AppUtil jsonStringToDictionary: json];
    NSString* key = [dict objectForKey:@"key"];
    NSString* value = [dict objectForKey:@"value"];
    [StoreUtil setStringItem:key value:value];
}


+ (void) createBannerAd:(NSString *)json{
    if ([adType isEqualToString:@"csj"]) {
        [CSJBannerUtil createBannerAd:json];
    }else if ([adType isEqualToString:@"mob"]) {
        [MobBannerUtil createBannerAd:json];
    }
}

+ (void) clearBannerAd:(NSString *)json{
    if ([adType isEqualToString:@"csj"]) {
        [CSJBannerUtil clearAd:json];
    }else if ([adType isEqualToString:@"mob"]) {
        [MobBannerUtil clearAd:json];
    }
}

+ (void) createVideoAd:(NSString *)json{
    if ([adType isEqualToString:@"csj"]) {
        [CSJVideoUtil createVideoAd:json];
    }else if ([adType isEqualToString:@"mob"]) {
        [MobVideoUtil createVideoAd:json];
    }
}

+ (void) createInterstitialAd:(NSString *)json{
    if ([adType isEqualToString:@"csj"]) {
        [CSJInterstitialUtil createInterstitialAd:json];
    }else if ([adType isEqualToString:@"mob"]) {
        [MobInterstitialUtil createInterstitialAd:json];
    }
}

+ (void) createSplashAd:(NSString *)json{
    NSLog(@"ADUtil:createSplashAd:json = %@", json);
    
    NSDictionary *dict = [AppUtil jsonStringToDictionary: json];
    const int timeout = [[dict objectForKey:@"timeout"] intValue];
    
    is_goto_main = false;
    [[ADUtil getInstance] startOutTimer:timeout*0.001];//<做个保护，超时自动跳过>
    if ([adType isEqualToString:@"csj"]) {
        [CSJSplashUtil createSplashAd:json];
    }else if ([adType isEqualToString:@"mob"]) {
        [MobSplashUtil createSplashAd:json];
    }else{
        [[ADUtil getInstance] gotoMain];
    }
}


@end
