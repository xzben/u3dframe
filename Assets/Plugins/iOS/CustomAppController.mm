#import "UnityAppController.h"
#include "utils/AppUtil.h"
 
@interface CustomAppController : UnityAppController
@end
 
IMPL_APP_CONTROLLER_SUBCLASS (CustomAppController)
 
@implementation CustomAppController
 
- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    [super application:application didFinishLaunchingWithOptions:launchOptions];
    [[AppUtil getInstance] initSdk:application launchOptions:launchOptions viewCtr:UnityGetGLViewController()];
    return YES;
}

- (BOOL)application:(UIApplication*)application openURL:(NSURL*)url options:(NSDictionary<NSString*, id>*)options
{
    [super application:application openURL:url options:options];
    [[AppUtil getInstance] application:application openURL:url];
    return YES;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray<id<UIUserActivityRestoring>> * __nullable restorableObjects))restorationHandler
{
    [[AppUtil getInstance] application:application continueUserActivity:userActivity restorationHandler:restorationHandler];
    return YES;
}
 
@end


