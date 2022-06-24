
#include <thread>
#import "AppUtil.h"
#include "../ad/ADUtil.h"
#include "../apple/ApplePayUtil.h"
//#include "weChat/WeChatUtil.h"
//#include "../analytics/AnalyticsUtil.h"


#include <algorithm>
#include <string>
#include <vector>
#import <Foundation/Foundation.h>


@interface AppUtil ()

@end

@implementation AppUtil

#pragma mark -
#pragma mark Singleton

static AppUtil *mInstace = nil;

+ (instancetype)getInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mInstace = [[super allocWithZone:NULL] init];
    });
    return mInstace;
}
+ (id)allocWithZone:(struct _NSZone *)zone {
    return [AppUtil getInstance];
}

+ (id)copyWithZone:(struct _NSZone *)zone {
    return [AppUtil getInstance];
}

#pragma mark -
#pragma mark Application lifecycle



//初始化sdk
- (void)initSdk:(UIApplication *)application launchOptions:(NSDictionary *)launchOptions viewCtr:(UIViewController*)viewCtr{
    self.m_viewController = viewCtr;
    [[ADUtil getInstance] initAdView:viewCtr];
    [[ApplePayUtil getInstance] initApplePay];
    //[[WeChatUtil getInstance] initWX];
    //[[AnalyticsUtil getInstance] initTalk];
}

- (UIViewController*)getView{
    return self.m_viewController;
}


//通知游戏前端
//定义参数的返回
+(void)NotifyEngine:(NSString*) event dic:(NSMutableDictionary *) dic
{
    if (dic == nil) {
        dic = [[NSMutableDictionary alloc]init];
    }
    [dic setObject:event forKey:@"funcName"];

    NSString *dicStr = [AppUtil dictionaryToJsonString: dic];
    NSString *jsCallNS = [dicStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    //jsCallNS = [jsCallNS stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    //jsCallNS = [jsCallNS stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\""];
    std::string jsCallStr = [jsCallNS UTF8String];
    NSLog(@"  NotifyEngine:%s", jsCallStr.c_str());
    UnitySendMessage("GameManager", "callEngine", jsCallStr.c_str());
}


//提供引擎的外部方法
extern "C"{
    char* makeStringCopy(const char* string){
       if (string == NULL)
           return NULL;
       char* res = (char*)malloc(strlen(string) + 1);
       strcpy(res, string);
       return res;
    }

    //解析引擎调用oc的函数
    void executeStaticMethod(const char *className, const char *methodName, const char *json, int &rval1, std::string &rval2){
        NSLog(@"=======__callStaticMethod=========");
        if (!className || !methodName) {
            NSLog(@"error 类名或者静态函数名为null");
            return;
        }
        
        NSString *classname = [NSString stringWithCString:className encoding:NSUTF8StringEncoding];
        NSString *methodname = [NSString stringWithCString:methodName encoding:NSUTF8StringEncoding];
        
        Class targetClass = NSClassFromString(classname);
        if (!targetClass) {
            NSLog(@"error targetClass %@ 类找不到!", classname);
            return;
        }
        
        SEL methodSel;
        methodSel = NSSelectorFromString(methodname);
        if (!methodSel) {
            NSLog(@"error methodSel %@ 静态函数找不到!", methodname);
            return;
        }
        NSMethodSignature *methodSig = [targetClass methodSignatureForSelector:(SEL)methodSel];
        if (methodSig == nil) {
            NSLog(@"error %@.%@  类静态函数参数对应不上!", classname, methodname);
            return;
        }
        
        @try{
            NSUInteger argumentCount = [methodSig numberOfArguments];
            if (!(argumentCount == 2 || argumentCount == 3)) {
                NSLog(@"error NSUInteger 不支持超过一个参数%@, 请使用json参数", methodname);
                return ;
            }else{
                if(argumentCount == 2 && json != nil){
                    NSLog(@"error NSUInteger 函数指明不需要带参数%@，不能带json参数", methodname);
                    return ;
                }
                else if(argumentCount == 3 && json == nil){
                    NSLog(@"error NSUInteger 函数指明需要带参数%@，需要带json参数", methodname);
                    return ;
                }
            }
            
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
            [invocation setTarget:targetClass];
            [invocation setSelector:methodSel];
            
            if (json != nil) {
                NSString *str = [NSString stringWithCString:json encoding:NSUTF8StringEncoding];
                [invocation setArgument:&str atIndex:2];
            }
            
            NSUInteger returnLength = [methodSig methodReturnLength];
            std::string returnType = [methodSig methodReturnType];
            [invocation invoke];

            if (returnLength > 0) {
                if (returnType == "@") {
                    id objcVal;
                    [invocation getReturnValue:&objcVal];
                    if (objcVal == nil)
                        return;
                    if ([objcVal isKindOfClass:[NSNumber class]]) {
                        NSNumber *number = (NSNumber *)objcVal;
                        std::string numberType = [number objCType];
                        if (numberType == @encode(BOOL) || numberType == @encode(bool)) {
                            rval1 = [number boolValue] == TRUE ? 1 : 0;
                        } else if (numberType == @encode(int) || numberType == @encode(long) || numberType == @encode(short) || numberType == @encode(unsigned int) || numberType == @encode(unsigned long) || numberType == @encode(unsigned short) || numberType == @encode(float) || numberType == @encode(double) || numberType == @encode(char) || numberType == @encode(unsigned char)) {
                            rval1 = [number intValue];
                        } else {
                            NSLog(@"Unknown number type: %s", numberType.c_str());
                        }
                    } else if ([objcVal isKindOfClass:[NSString class]]) {
                        const char *content = [objcVal cStringUsingEncoding:NSUTF8StringEncoding];
                        rval2 = content;
                    } else if ([objcVal isKindOfClass:[NSDictionary class]]) {
                        NSLog(@"doesn't support to bind NSDictionary!");
                    } else {
                        const char *content = [[NSString stringWithFormat:@"%@", objcVal] cStringUsingEncoding:NSUTF8StringEncoding];
                        rval2 = content;
                    }
                    
                } else if (returnType == @encode(BOOL) || returnType == @encode(bool)) {
                    bool ret;
                    [invocation getReturnValue:&ret];
                    rval1 = ret == TRUE ? 1 : 0;
                }
                else if (returnType == @encode(int)) {
                    int ret;
                    [invocation getReturnValue:&ret];
                    rval1 = ret;
                } else if (returnType == @encode(long)) {
                    long ret;
                    [invocation getReturnValue:&ret];
                    rval1 = ret;
                } else if (returnType == @encode(short)) {
                    short ret;
                    [invocation getReturnValue:&ret];
                    rval1 = ret;
                } else if (returnType == @encode(unsigned int)) {
                    unsigned int ret;
                    [invocation getReturnValue:&ret];
                    rval1 = ret;
                } else if (returnType == @encode(unsigned long)) {
                    unsigned long ret;
                    [invocation getReturnValue:&ret];
                    rval1 = ret;
                } else if (returnType == @encode(unsigned short)) {
                    unsigned short ret;
                    [invocation getReturnValue:&ret];
                    rval1 = ret;
                } else if (returnType == @encode(float)) {
                    float ret;
                    [invocation getReturnValue:&ret];
                    rval1 = ret;
                } else if (returnType == @encode(double)) {
                    double ret;
                    [invocation getReturnValue:&ret];
                    rval1 = ret;
                } else if (returnType == @encode(char)) {
                    int8_t ret;
                    [invocation getReturnValue:&ret];
                    rval1 = ret;
                } else if (returnType == @encode(unsigned char)) {
                    uint8_t ret;
                    [invocation getReturnValue:&ret];
                    rval1 = ret;
                } else {
                    NSLog(@"not support return type = %s", returnType.c_str());
                    return;
                }
            }
        }@catch (NSException *exception) {
            NSLog(@"EXCEPTION THROW: %@", exception);
            return ;
        }
    }
    
    void __callStaticMethod(const char *className, const char *methodName, const char *json){
        NSLog(@"=======__callStaticMethod=========");
        int rval1 = 0;
        std::string rval2 = "";
        executeStaticMethod(className, methodName, json, rval1, rval2);
    }
    
    int __callStaticMethodReturnInt(const char *className, const char *methodName, const char *json){
        NSLog(@"=======__callStaticMethodReturnInt=========");
        int rval1 = 0;
        std::string rval2 = "";
        executeStaticMethod(className, methodName, json, rval1, rval2);
        return rval1;
    }
    
    const char* __callStaticMethodReturnString(const char *className, const char *methodName, const char *json){
        NSLog(@"=======__callStaticMethodReturnString=========");
        int rval1 = 0;
        std::string rval2 = "";
        executeStaticMethod(className, methodName, json, rval1, rval2);
        return makeStringCopy(rval2.c_str());
    }
    
}

//字典转换成json字符串
+ (NSString*)dictionaryToJsonString:(NSMutableDictionary *)dic
{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

//json字符串转换成字典
+(NSDictionary *)jsonStringToDictionary:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    NSError *err = nil;
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err){
        NSLog(@"json解析失败 code");
        return nil;
    }
    return dic;
}


- (void)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    //[[WeChatUtil getInstance] handleOpenURL:url];
}

- (void)application:(UIApplication *)application openURL:(NSURL *)url {
    //[[WeChatUtil getInstance] openURL:url];
}

- (void)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray<id<UIUserActivityRestoring>> * __nullable restorableObjects))restorationHandler
{
    //[[WeChatUtil getInstance] continueUserActivity:userActivity];
}

+ (void)Vibrator:(NSString *)json{
    NSLog(@"AppUtil:Vibrator:json = %@", json);
    NSDictionary *dict = [AppUtil jsonStringToDictionary: json];
    const int type = [[dict objectForKey:@"type"] intValue];
    const int ms = [[dict objectForKey:@"ms"] intValue];
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

+ (NSString *)getAppVersionName{
    NSDictionary *bundleDic = [[NSBundle mainBundle] infoDictionary];
    NSString *versionName = [bundleDic objectForKey:@"CFBundleShortVersionString"];
    return versionName;
}

+ (NSString *)getCurrentLanguage{
    id langs = [NSLocale preferredLanguages];
    if(langs != nil && [langs count] > 0)
        return [langs objectAtIndex:0];
    return [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
}

+ (NSString *)getUniqueCode:(NSString *)json
{
    NSString *identifierForVendor = [[UIDevice currentDevice].identifierForVendor UUIDString];
    NSLog(@"identifierForVendor == %@",identifierForVendor);
    return identifierForVendor;
}

+ (int)checkAppExist:(NSString *)urlSchemes
{
    if ([urlSchemes isEqualToString:@"apple://"]) {
        if (@available(iOS 13.0, *)) {
            return 1;
        }
        return 0;
    }
    BOOL isExist = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlSchemes]];
    return (isExist == YES) ? 1 : 0;
}





@end
