
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>


NS_ASSUME_NONNULL_BEGIN

@interface AppUtil : NSObject

@property(nonatomic, strong) UIViewController *m_viewController;

+ (instancetype)getInstance;
+ (void)NotifyEngine:(NSString*)event dic:(NSMutableDictionary *__nullable) dic;

//可变字典转换成json字符串
+ (NSString*)dictionaryToJsonString:(NSMutableDictionary *)dic;

//json字符串转换成字典
+ (NSDictionary *)jsonStringToDictionary:(NSString *)jsonString;

- (UIViewController*)getView;

- (void)initSdk:(UIApplication *)application launchOptions:(NSDictionary *)launchOptions viewCtr:(UIViewController*)viewCtr;
- (void)application:(UIApplication *)application handleOpenURL:(NSURL *)url;
- (void)application:(UIApplication *)application openURL:(NSURL *)url;
- (void)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray<id<UIUserActivityRestoring>> * __nullable restorableObjects))restorationHandler;


+ (void)Vibrator:(NSString *)json;
+ (NSString *)getAppVersionName;
+ (NSString *)getCurrentLanguage;
+ (NSString *)getUniqueCode:(NSString *)json;
+ (int)checkAppExist:(NSString *)urlSchemes;

@end

NS_ASSUME_NONNULL_END
