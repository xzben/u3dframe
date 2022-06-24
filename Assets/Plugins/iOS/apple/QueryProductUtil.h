#ifndef QueryProductUtil_h
#define QueryProductUtil_h

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QueryProductUtil : NSObject<SKProductsRequestDelegate>

+ (instancetype)getInstance;

- (void)query:(NSArray *)productIds;

+ (void)queryProducts:(NSString *)json;

@end

NS_ASSUME_NONNULL_END

#endif
