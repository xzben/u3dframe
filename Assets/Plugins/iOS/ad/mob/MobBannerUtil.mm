//
//  MobBannerUtil.c
//

#include "MobBannerUtil.h"
#import "../ADUtil.h"
#import "../../utils/AppUtil.h"
#import "MobCommonUtil.h"

@implementation MobBannerUtil

static MobBannerUtil *singleton = nil;

+(MobBannerUtil*) getInstance
{
    if(!singleton){
        singleton = [[self alloc] init];
    }
    
    return singleton;
}

+ (void) createBannerAd:(NSString *)json{
    NSLog(@"MobBannerUtil:createBannerAd:json = %@", json);
    NSDictionary *dict = [AppUtil jsonStringToDictionary: json];
    const BOOL isDeepLink = [[dict objectForKey:@"isDeepLink"] boolValue];
    const int index = [[dict objectForKey:@"index"] intValue];
    const int width = [[dict objectForKey:@"width"] intValue];
    const int height = [[dict objectForKey:@"height"] intValue];
    NSString* adId = [[MobCommonUtil getInstance] bannerAdId];
    [[MobBannerUtil getInstance] createBannerAd:adId isDeepLink:isDeepLink index:index width:width height:height];
}

+ (void) clearAd:(NSString *)json{
    [[MobBannerUtil getInstance] clearAd];
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

    UIViewController *adView = [[ADUtil getInstance] getAdView];
    self.m_bannerView = [[GADBannerView alloc]initWithAdSize:kGADAdSizeBanner];
    self.m_bannerView.adUnitID = adid;
    self.m_bannerView.rootViewController = adView;
    self.m_bannerView.delegate  = self;
    self.m_bannerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.m_bannerView loadRequest:[GADRequest request]];

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

#pragma mark - google ad delegate
- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView {
    NSLog(@"bannerViewDidReceiveAd");
    UIViewController *adView = [[ADUtil getInstance] getAdView];
    [adView.view addSubview:self.m_bannerView];
    [adView.view addConstraints:@[
        [NSLayoutConstraint constraintWithItem:self.m_bannerView
                                attribute:NSLayoutAttributeBottom
                                relatedBy:NSLayoutRelationEqual
                                    toItem:adView.bottomLayoutGuide
                                attribute:NSLayoutAttributeTop
                                multiplier:1
                                    constant:0],
        [NSLayoutConstraint constraintWithItem:self.m_bannerView
                                attribute:NSLayoutAttributeCenterX
                                relatedBy:NSLayoutRelationEqual
                                    toItem:adView.view
                                attribute:NSLayoutAttributeCenterX
                                multiplier:1
                                    constant:0]
                                    ]];
}

- (void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error {
    NSLog(@"bannerView:didFailToReceiveAdWithError: %@", [error localizedDescription]);
    NSString *code = [NSString stringWithFormat:@"%ld",error.code];
    NSMutableDictionary* mdict = [[NSMutableDictionary alloc]init];
    [mdict setObject:code forKey:@"errorCode"];
    [mdict setObject:error.localizedDescription forKey:@"errorMsg"];
    [AppUtil NotifyEngine:@"onBannerError" dic:mdict];
}

- (void)bannerViewDidRecordImpression:(GADBannerView *)bannerView {
    NSLog(@"bannerViewDidRecordImpression");
}

- (void)bannerViewWillPresentScreen:(GADBannerView *)bannerView {
    NSLog(@"bannerViewWillPresentScreen");
}

- (void)bannerViewWillDismissScreen:(GADBannerView *)bannerView {
    NSLog(@"bannerViewWillDismissScreen");
}

- (void)bannerViewDidDismissScreen:(GADBannerView *)bannerView {
    NSLog(@"bannerViewDidDismissScreen");
}


@end
