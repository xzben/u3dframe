//
//  CSJVideoUtil.c
//

#import "CSJVideoUtil.h"
#import "../ADUtil.h"
#import "../../utils/AppUtil.h"
#import "CSJCommonUtil.h"

@implementation CSJVideoUtil

static CSJVideoUtil *singleton = nil;

+(CSJVideoUtil*) getInstance
{
    if(!singleton){
        singleton = [[self alloc] init];
    }
    return singleton;
}


+ (void) createVideoAd:(NSString *)json{
    NSLog(@"CSJVideoUtil:createSplashAd:json = %@", json);
    NSDictionary *dict = [AppUtil jsonStringToDictionary: json];
    const char* _userId = [[dict objectForKey:@"userId"] UTF8String];
    NSString* userId = [[NSString alloc] initWithUTF8String:_userId];
    NSString* adId = [[CSJCommonUtil getInstance] videoAdId];
    [[CSJVideoUtil getInstance] createVideoAd:userId adid:adId];
}


- (void) createVideoAd:(NSString*)userId adid:(NSString*) adid
{
    BURewardedVideoModel *model = [[BURewardedVideoModel alloc] init];
    model.userId = userId;
    
    self.m_videoView = [[BURewardedVideoAd alloc] initWithSlotID:adid rewardedVideoModel:model];
    self.m_videoView.delegate = self;
    [self.m_videoView loadAdData];
}

- (void) clearAd
{
    if(self.m_videoView != nil)
    {
        //[self.m_videoView release];
    }
    self.m_videoView = nil;
}

- (void) showAd
{
    if(self.m_videoView != nil)
    {
        [self.m_videoView showAdFromRootViewController:[[ADUtil getInstance] getAdView]];
    }
}

#pragma mark - BURewardedVideoAdDelegate
- (void)rewardedVideoAdDidLoad:(BURewardedVideoAd *)rewardedVideoAd
{
    NSLog(@"%s",__func__);
}

- (void)rewardedVideoAdVideoDidLoad:(BURewardedVideoAd *)rewardedVideoAd
{
    NSLog(@"%s",__func__);
    [self showAd];
    [AppUtil NotifyEngine:@"onVideoShow" dic:nil];
}

- (void)rewardedVideoAd:(BURewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *_Nullable)error
{
    NSLog(@"%s",__func__);
    NSString *code = [NSString stringWithFormat:@"%ld",error.code];
    NSMutableDictionary* mdict = [[NSMutableDictionary alloc]init];
    [mdict setObject:code forKey:@"errorCode"];
    [mdict setObject:error.localizedDescription forKey:@"errorMsg"];
    [AppUtil NotifyEngine:@"onVideoError" dic:mdict];
}

- (void)rewardedVideoAdDidPlayFinish:(BURewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *_Nullable)error
{
    NSLog(@"%s",__func__);
    if (error == nil) {
        [AppUtil NotifyEngine:@"onRewardVerify" dic:nil];
    }else{
        NSString *code = [NSString stringWithFormat:@"%ld",error.code];
        NSMutableDictionary* mdict = [[NSMutableDictionary alloc]init];
        [mdict setObject:code forKey:@"errorCode"];
        [mdict setObject:error.localizedDescription forKey:@"errorMsg"];
        [AppUtil NotifyEngine:@"onVideoError" dic:mdict];
    }
}


- (void)rewardedVideoAdDidClose:(BURewardedVideoAd *)rewardedVideoAd
{
    NSLog(@"%s",__func__);
    [AppUtil NotifyEngine:@"onVideoClose" dic:nil];
}

@end
