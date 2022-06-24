//
//  CSJBannerUtil.c
//

#include "CSJBannerUtil.h"
#import "../ADUtil.h"
#import "../../utils/AppUtil.h"
#import "CSJCommonUtil.h"

@implementation CSJBannerUtil

static CSJBannerUtil *singleton = nil;

+(CSJBannerUtil*) getInstance
{
    if(!singleton){
        singleton = [[self alloc] init];
    }
    
    return singleton;
}

+ (void) createBannerAd:(NSString *)json{
    NSLog(@"CSJBannerUtil:createBannerAd:json = %@", json);
    NSDictionary *dict = [AppUtil jsonStringToDictionary: json];
    const BOOL isDeepLink = [[dict objectForKey:@"isDeepLink"] boolValue];
    const int index = [[dict objectForKey:@"index"] intValue];
    const int width = [[dict objectForKey:@"width"] intValue];
    const int height = [[dict objectForKey:@"height"] intValue];
    NSString* adId = [[CSJCommonUtil getInstance] bannerAdId];
    [[CSJBannerUtil getInstance] createBannerAd:adId isDeepLink:isDeepLink index:index width:width height:height];
}

+ (void) clearAd:(NSString *)json{
    [[CSJBannerUtil getInstance] clearAd];
}


-(CGRect) getShowRect:(int) index width:(float)width height:(float)height
{
    int x = 0;
    int y = 0;
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    switch (index) {
        case 1:
        {
            x = y = 0;
            break;
        }
        case 2:
        {
            x = (screenSize.width - width)/2;
            y = 0;
            break;
        }
        case 3:
        {
            x =(screenSize.width - width);
            y = 0;
            break;
        }
        case 4:
        {
            x = 0;
            y = screenSize.height - height;
            break;
        }
        case 5:
        {
            x = (screenSize.width - width)/2;
            y = screenSize.height - height;
            break;
        }
        case 6:
        {
            x =(screenSize.width - width);
            y = screenSize.height - height;
            break;
        }
    }
    CGRect rect = {CGPointMake(x,y), CGSizeMake(width, height)};

    return rect;
}

- (void) createBannerAd:(NSString*) adid isDeepLink:(BOOL)isDeepLink index:(int)index width:(float)width height:(float)height
{
    [self clearAd];
    CGRect rect = [self getShowRect:index width:width height:height];
    self.m_bannerView = [[BUNativeExpressBannerView alloc] initWithSlotID:adid
                                                     rootViewController:[[ADUtil getInstance] getAdView]
                                                    adSize:CGSizeMake(width, height)
                                                    IsSupportDeepLink:isDeepLink];
    
    self.m_bannerView.frame = rect;
    self.m_bannerView.delegate = self;
    [[[[ADUtil getInstance] getAdView] view] addSubview:self.m_bannerView];
    
    [self.m_bannerView loadAdData];
}

- (void) clearAd
{
    if (self.m_bannerView != nil) {
        [self.m_bannerView removeFromSuperview];
    }
    self.m_bannerView = nil;
}

- (void) refreshAd
{

}

#pragma BUNativeExpressBannerViewDelegate
- (void)nativeExpressBannerAdViewDidLoad:(BUNativeExpressBannerView *)bannerAdView {
    NSLog(@"%s",__func__);
    [AppUtil NotifyEngine:@"onBannerLoad" dic:nil];
}

- (void)nativeExpressBannerAdView:(BUNativeExpressBannerView *)bannerAdView didLoadFailWithError:(NSError *)error {
    NSLog(@"%s",__func__);
    NSString *code = [NSString stringWithFormat:@"%ld",error.code];
    NSMutableDictionary* mdict = [[NSMutableDictionary alloc]init];
    [mdict setObject:code forKey:@"errorCode"];
    [mdict setObject:error.localizedDescription forKey:@"errorMsg"];
    [AppUtil NotifyEngine:@"onBannerError" dic:mdict];
}

- (void)nativeExpressBannerAdViewRenderSuccess:(BUNativeExpressBannerView *)bannerAdView {
    NSLog(@"%s",__func__);
    [AppUtil NotifyEngine:@"onBannerShow" dic:nil];
}

- (void)nativeExpressBannerAdViewRenderFail:(BUNativeExpressBannerView *)bannerAdView error:(NSError *)error {
    NSLog(@"%s",__func__);
    NSString *code = [NSString stringWithFormat:@"%ld",error.code];
    NSMutableDictionary* mdict = [[NSMutableDictionary alloc]init];
    [mdict setObject:code forKey:@"errorCode"];
    [mdict setObject:error.localizedDescription forKey:@"errorMsg"];
    [AppUtil NotifyEngine:@"onBannerError" dic:mdict];
}

- (void)nativeExpressBannerAdViewWillBecomVisible:(BUNativeExpressBannerView *)bannerAdView {
    NSLog(@"%s",__func__);
}

- (void)nativeExpressBannerAdViewDidClick:(BUNativeExpressBannerView *)bannerAdView {
    NSLog(@"%s",__func__);
    [AppUtil NotifyEngine:@"onBannerClicked" dic:nil];
}

- (void)nativeExpressBannerAdView:(BUNativeExpressBannerView *)bannerAdView dislikeWithReason:(NSArray<BUDislikeWords *> *)filterwords {
    NSLog(@"%s",__func__);
    [AppUtil NotifyEngine:@"onBannerClosed" dic:nil];
    [UIView animateWithDuration:0.25 animations:^{
        self.m_bannerView.alpha = 0;
    } completion:^(BOOL finished) {
        [self clearAd];
    }];
}

@end
