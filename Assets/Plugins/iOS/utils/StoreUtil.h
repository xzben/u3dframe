

#ifndef StoreUtil_h
#define StoreUtil_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN


@interface StoreUtil : NSObject

+ (NSString*)getItem:(NSString *)key defValue:(NSString *)defValue;

+ (void)setItem:(NSString *)key value:(NSString *)value;

+ (void)removeItem:(NSString *)key;

+ (NSString*)getStringItem:(NSString *)key defValue:(NSString *)defValue;

+ (void)setStringItem:(NSString *)key value:(NSString *)value;

+ (int)getIntValue:(NSString *)key defValue:(int)defValue;

+ (void)setIntValue:(NSString *)key value:(int)value;

+ (NSDictionary*)getObjectItem:(NSString *)key;

+ (void)setObjectItem:(NSString *)key obj:(NSDictionary*)obj;

+ (NSString*)getStringItem:(NSString *)json;
+ (void)setStringItem:(NSString *)json;


@end

NS_ASSUME_NONNULL_END

#endif
