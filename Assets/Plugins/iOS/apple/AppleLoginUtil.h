#ifndef AppleLoginUtil_h
#define AppleLoginUtil_h

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import <AuthenticationServices/AuthenticationServices.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppleLoginUtil : NSObject<ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding, SKProductsRequestDelegate, SKPaymentTransactionObserver>

+ (instancetype)getInstance;

- (void)initApple;
- (void)authApple;
- (void)BuyPay:(NSString *)productId;

+ (void)appleLogin:(NSString *)json;
+ (void)applePay:(NSString *)json;

@end

NS_ASSUME_NONNULL_END

#endif
