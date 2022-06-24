

#import "StoreUtil.h"


#include <algorithm>

@interface StoreUtil ()

@end

@implementation StoreUtil

#pragma mark -
#pragma mark Application lifecycle

+ (NSString*)getItem:(NSString *)key defValue:(NSString *)defValue{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *temp = [userDefaults stringForKey:key];
    if (temp != nil && ![temp isEqualToString:@""]) {
        NSString* value = [[NSString alloc] initWithString:temp];
        return value;
    }
    return defValue;
}

+ (void)setItem:(NSString *)key value:(NSString *)value{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:value forKey:key];
    [userDefaults synchronize];
}

+ (void)removeItem:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
}


+ (NSString*)getStringItem:(NSString *)key defValue:(NSString *)defValue{
    NSString *value = [StoreUtil getItem:key defValue:defValue];
    return value;
}

+ (void)setStringItem:(NSString *)key value:(NSString *)value{
    [StoreUtil setItem:key value:value];
}

+ (int)getIntValue:(NSString *)key defValue:(int)defValue{
    NSString *value = [StoreUtil getItem:key defValue:nil];
    if(value == nil || [value isEqualToString:@""]){
        return defValue;
    }
    NSInteger s = [value intValue];
    return s;
}

+ (void)setIntValue:(NSString *)key value:(int)value{
    NSString* text = [[NSString alloc] initWithFormat:@"%d", value];
    [StoreUtil setItem:key value:text];
}

+ (NSDictionary*)getObjectItem:(NSString *)key{
    NSString* jsonString = [StoreUtil getStringItem:key defValue:nil];
    if (jsonString == nil || [jsonString isEqualToString:@""]) {
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

+ (void)setObjectItem:(NSString *)key obj:(NSDictionary*)obj{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:obj options:NSJSONWritingPrettyPrinted error:&parseError];
    if(parseError){
        NSLog(@"json解析失败 code");
        return;
    }
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [StoreUtil setItem:key value:jsonString];
}



+ (NSString*)getStringItem:(NSString *)json{
    NSLog(@"StoreUtil:getStringItem:json = %@", json);
    NSDictionary *dict = [AppUtil jsonStringToDictionary: json];
    NSString* key = [dict objectForKey:@"key"];
    NSString* defValue = [dict objectForKey:@"defValue"];
    return [StoreUtil getStringItem:key defValue:defValue];
}

+ (void)setStringItem:(NSString *)json{
    NSLog(@"StoreUtil:setStringItem:json = %@", json);
    NSDictionary *dict = [AppUtil jsonStringToDictionary: json];
    NSString* key = [dict objectForKey:@"key"];
    NSString* value = [dict objectForKey:@"value"];
    [StoreUtil setStringItem:key value:value];
}


@end
