#ifndef ApplePayUtil_h
#define ApplePayUtil_h

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ApplePayUtil : NSObject<SKProductsRequestDelegate, SKPaymentTransactionObserver>

+ (instancetype)getInstance;

- (void)initApplePay;
- (void)BuyPay:(NSString *)productId;
- (void)rePurchases;

+ (void)applePay:(NSString *)json;
+ (void)restorePurchases:(NSString *)json;

@end

NS_ASSUME_NONNULL_END

#endif
