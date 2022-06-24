#import "AppleLoginUtil.h"
#include "../utils/AppUtil.h"
#include "../utils/StoreUtil.h"

@implementation AppleLoginUtil

#pragma mark -
#pragma mark Singleton

static AppleLoginUtil *mInstace = nil;

+ (instancetype)getInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mInstace = [[super allocWithZone:NULL] init];
    });
    return mInstace;
}
+ (id)allocWithZone:(struct _NSZone *)zone {
    return [AppleLoginUtil getInstance];
}

+ (id)copyWithZone:(struct _NSZone *)zone {
    return [AppleLoginUtil getInstance];
}

#pragma mark -
#pragma mark Application lifecycle

/**
 app显示给用户之前执行最后的初始化操作
 */
- (void)initApple
{
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

//移除监听
-(void)dealloc
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

#pragma mark- 授权苹果ID
- (void)authApple {
    
    if (@available(iOS 13.0, *)) {
        
        ASAuthorizationAppleIDProvider * appleIDProvider = [[ASAuthorizationAppleIDProvider alloc] init];
        ASAuthorizationAppleIDRequest * authAppleIDRequest = [appleIDProvider createRequest];
        ASAuthorizationPasswordRequest * passwordRequest = [[[ASAuthorizationPasswordProvider alloc] init] createRequest];

        NSMutableArray <ASAuthorizationRequest *> * array = [NSMutableArray arrayWithCapacity:2];
        if (authAppleIDRequest) {
            [array addObject:authAppleIDRequest];
        }

        NSArray <ASAuthorizationRequest *> * requests = [array copy];
        
        ASAuthorizationController * authorizationController = [[ASAuthorizationController alloc] initWithAuthorizationRequests:requests];
        authorizationController.delegate = self;
        authorizationController.presentationContextProvider = self;
        [authorizationController performRequests];
        
    } else {
        // 处理不支持系统版本
        NSLog(@"系统不支持Apple登录");
    }
}

#pragma mark- ASAuthorizationControllerDelegate
// 授权成功
- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithAuthorization:(ASAuthorization *)authorization API_AVAILABLE(ios(13.0)) {
    
    if ([authorization.credential isKindOfClass:[ASAuthorizationAppleIDCredential class]]) {
        
        ASAuthorizationAppleIDCredential * credential = authorization.credential;
        
        // 苹果用户唯一标识符，该值在同一个开发者账号下的所有 App 下是一样的，开发者可以用该唯一标识符与自己后台系统的账号体系绑定起来。
        NSString * userID = credential.user;
        
        // 苹果用户信息 如果授权过，可能无法再次获取该信息
        NSPersonNameComponents * fullName = credential.fullName;
        NSString * email = credential.email;
        
        // 服务器验证需要使用的参数
        NSString * authorizationCode = [[NSString alloc] initWithData:credential.authorizationCode encoding:NSUTF8StringEncoding];
        NSString * identityToken = [[NSString alloc] initWithData:credential.identityToken encoding:NSUTF8StringEncoding];
        
        // 用于判断当前登录的苹果账号是否是一个真实用户，取值有：unsupported、unknown、likelyReal
        ASUserDetectionStatus realUserStatus = credential.realUserStatus;
        
        [[NSUserDefaults standardUserDefaults] setObject:userID forKey:@"appleID"];
        
        NSLog(@"userID: %@", userID);
        NSLog(@"email: %@", email);
        NSLog(@"authorizationCode: %@", authorizationCode);
        NSLog(@"identityToken: %@", identityToken);

        NSMutableDictionary* mdict = [[NSMutableDictionary alloc]init];
        [mdict setObject:userID forKey:@"userID"];
        [mdict setObject:authorizationCode forKey:@"code"];
        [mdict setObject:identityToken forKey:@"token"];
        [AppUtil NotifyEngine:@"onAppleLogin" dic:mdict];
        
    }
    else if ([authorization.credential isKindOfClass:[ASPasswordCredential class]]) {
        
        // 用户登录使用现有的密码凭证
        ASPasswordCredential * passwordCredential = authorization.credential;
        // 密码凭证对象的用户标识 用户的唯一标识
        NSString * user = passwordCredential.user;
        // 密码凭证对象的密码
        NSString * password = passwordCredential.password;
        
        NSLog(@"userID: %@", user);
        NSLog(@"password: %@", password);
        
    } else {
        
    }
}

// 授权失败
- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithError:(NSError *)error API_AVAILABLE(ios(13.0)) {
    
    NSString *errorMsg = nil;
    
    switch (error.code) {
        case ASAuthorizationErrorCanceled:
            errorMsg = @"用户取消了授权请求";
            break;
        case ASAuthorizationErrorFailed:
            errorMsg = @"授权请求失败";
            break;
        case ASAuthorizationErrorInvalidResponse:
            errorMsg = @"授权请求响应无效";
            break;
        case ASAuthorizationErrorNotHandled:
            errorMsg = @"未能处理授权请求";
            break;
        case ASAuthorizationErrorUnknown:
            errorMsg = @"授权请求失败未知原因";
            break;
    }
    NSLog(@"%@", errorMsg);
    NSString *code = [NSString stringWithFormat:@"%ld",error.code];
    NSMutableDictionary* mdict = [[NSMutableDictionary alloc]init];
    [mdict setObject:code forKey:@"errorCode"];
    [mdict setObject:errorMsg forKey:@"errorMsg"];
    [AppUtil NotifyEngine:@"onAppleLoginError" dic:mdict];
}

#pragma mark- ASAuthorizationControllerPresentationContextProviding
- (ASPresentationAnchor)presentationAnchorForAuthorizationController:(ASAuthorizationController *)controller {
    UIViewController *uiview = [[AppUtil getInstance] getView];
    return uiview.view.window;
}

#pragma mark- apple授权状态 更改通知
- (void)handleSignInWithAppleStateChanged:(NSNotification *)notification
{
    NSLog(@"%@", notification.userInfo);
}


#pragma mark- SKProductsRequestDelegate
// 查询成功后的回调
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *myProduct = response.products;
    if (myProduct.count == 0) {
        NSLog(@"无法获取产品信息，购买失败。");
        return;
    }
    for(SKProduct *product in myProduct){
        NSLog(@"product info");
        NSLog(@"产品标题 %@" , product.localizedTitle);
        NSLog(@"产品描述信息: %@" , product.localizedDescription);
        NSLog(@"价格: %@" , product.price);
        NSLog(@"Product id: %@" , product.productIdentifier);
    }
    SKPayment * payment = [SKPayment paymentWithProduct:myProduct[0]];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

#pragma mark- SKProductsRequestDelegate <SKRequestDelegate>
//查询失败后的回调
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Product Request error: %@" , error.localizedDescription);
}

#pragma mark- SKPaymentTransactionObserver
//购买操作后的回调
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased://交易完成
                NSLog(@"transactionIdentifier: %@" , transaction.transactionIdentifier);
                
                [self completeTransaction:transaction];
                break;
                
            case SKPaymentTransactionStateFailed://交易失败
                [self failedTransaction:transaction];
                break;
                
            case SKPaymentTransactionStateRestored://已经购买过该商品
                [self restoreTransaction:transaction];
                break;
                
            case SKPaymentTransactionStatePurchasing://商品添加进列表
                NSLog(@"商品添加进列表，请稍后");
                break;
                
            default:
                break;
        }
    }
}


- (void)completeTransaction:(SKPaymentTransaction *)transaction {//成功的时候发送凭证给服务器
    NSString * productId = transaction.payment.productIdentifier;// 产品id
    NSLog(@"completeTransaction productId = %@ ", productId);
    
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    NSLog(@"completeTransaction receiptURL = %@ ", receiptURL);
    
    NSData *ndreceipt = [NSData dataWithContentsOfURL:receiptURL];
   
    NSUInteger len  =  [ ndreceipt length];
    if( [productId length] > 0 && len > 0)
    {
        NSString *receiptBase64 = [[transaction transactionReceipt]base64Encoding];
        NSString *stransactionId = transaction.transactionIdentifier;
        
        NSLog(@"productId: %@", productId);
        NSLog(@"receiptBase64: %@", receiptBase64);
        NSLog(@"stransactionId: %@", stransactionId);

        NSMutableDictionary* mdict = [[NSMutableDictionary alloc]init];
        [mdict setObject:productId forKey:@"productId"];
        [mdict setObject:receiptBase64 forKey:@"receiptBase64"];
        [mdict setObject:stransactionId forKey:@"orderId"];
        
        int size = [StoreUtil getIntValue:@"apple_pay_size" defValue:0] + 1;
        [StoreUtil setIntValue:@"apple_pay_size" value:size];
        
        NSString *key = [NSString stringWithFormat:@"apple_pay_item_%d",size];
        [StoreUtil setObjectItem:key obj:mdict];
        
        [AppUtil NotifyEngine:@"onApplePay" dic:mdict];

        [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
    }

}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"failedTransaction  transactionIdentifier = %@", transaction.payment.productIdentifier);
    NSLog(@"%ld ",transaction.error.code);
    NSLog(@"transaction.error description]==%@",[transaction.error description]);
    NSString *detail= @"";
    if (transaction.error != nil) {
        switch (transaction.error.code) {
                
            case SKErrorUnknown:
                
                NSLog(@"SKErrorUnknown");
                detail = @"未知的错误，您可能正在使用越狱手机";
                break;
                
            case SKErrorClientInvalid:
                
                NSLog(@"SKErrorClientInvalid");
                detail = @"当前苹果账户无法购买商品(如有疑问，可以询问苹果客服)";
                break;
                
            case SKErrorPaymentCancelled:
                NSLog(@"SKErrorPaymentCancelled");
                detail = @"订单已取消";
                break;
            case SKErrorPaymentInvalid:
                NSLog(@"SKErrorPaymentInvalid");
                detail = @"订单无效(如有疑问，可以询问苹果客服)";
                break;
                
            case SKErrorPaymentNotAllowed:
                NSLog(@"SKErrorPaymentNotAllowed");
                detail = @"当前苹果设备无法购买商品(如有疑问，可以询问苹果客服)";
                break;
                
            case SKErrorStoreProductNotAvailable:
                NSLog(@"SKErrorStoreProductNotAvailable");
                detail = @"当前商品不可用";
                break;
                
            default:
                
                NSLog(@"No Match Found for error");
                detail = @"未知错误";
                break;
        }
        
        NSString *code = [NSString stringWithFormat:@"%ld",transaction.error.code];
        NSMutableDictionary* mdict = [[NSMutableDictionary alloc]init];
        [mdict setObject:code forKey:@"errorCode"];
        [mdict setObject:detail forKey:@"errorMsg"];
        [AppUtil NotifyEngine:@"onApplePayError" dic:mdict];
    }
    
    NSLog(@"%@",detail);
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}


- (void)BuyPay:(NSString *)productId
{
    if ([SKPaymentQueue canMakePayments]) {
        //从Apple查询用户点击购买的产品的信息
        SKProductsRequest *productsRequest = [[SKProductsRequest alloc]
                                              initWithProductIdentifiers:[NSSet setWithObject:productId]];
        productsRequest.delegate = self;
        [productsRequest start];
        NSLog(@"正在购买，请稍后");
    } else {
        NSLog(@"用户禁止应用内付费购买");
        NSMutableDictionary* mdict = [[NSMutableDictionary alloc]init];
        [mdict setObject:@"1000000" forKey:@"errorCode"];
        [mdict setObject:@"用户禁止应用内付费购买" forKey:@"errorMsg"];
        [AppUtil NotifyEngine:@"onApplePayError" dic:mdict];
    }
}


+(void)appleLogin: (NSString *)json
{
    NSLog(@"appleLogin:json = %@", json);
    [[AppleLoginUtil getInstance] authApple];
}

+ (void)applePay:(NSString *)json{
    NSLog(@"applePay:json = %@", json);
    NSDictionary *dict = [AppUtil jsonStringToDictionary: json];
    NSString* productId = [dict objectForKey:@"productId"];
    NSLog(@"applePay:product = %@", productId);
    [[AppleLoginUtil getInstance] BuyPay:productId];
}


@end
