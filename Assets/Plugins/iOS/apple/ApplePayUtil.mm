#import "ApplePayUtil.h"
#include "../utils/AppUtil.h"
#include "../utils/StoreUtil.h"

@implementation ApplePayUtil

#pragma mark -
#pragma mark Singleton

static ApplePayUtil *mInstace = nil;

+ (instancetype)getInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mInstace = [[super allocWithZone:NULL] init];
    });
    return mInstace;
}
+ (id)allocWithZone:(struct _NSZone *)zone {
    return [ApplePayUtil getInstance];
}

+ (id)copyWithZone:(struct _NSZone *)zone {
    return [ApplePayUtil getInstance];
}

#pragma mark -
#pragma mark Application lifecycle

/**
 app显示给用户之前执行最后的初始化操作
 */
- (void)initApplePay
{
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

//移除监听
-(void)dealloc
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
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
        //NSLog(@"receiptBase64: %@", receiptBase64);
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
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];

}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"failedTransaction  transactionIdentifier = %@", transaction.payment.productIdentifier);
    NSLog(@"%ld ",transaction.error.code);
    NSLog(@"transaction.error description]==%@",[transaction.error description]);
    NSString *detail= @"";
    NSString *code = [NSString stringWithFormat:@"%ld",transaction.error.code];
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
        
        
        NSMutableDictionary* mdict = [[NSMutableDictionary alloc]init];
        [mdict setObject:code forKey:@"errorCode"];
        [mdict setObject:detail forKey:@"errorMsg"];
        [AppUtil NotifyEngine:@"onApplePayError" dic:mdict];
    }
    
    NSLog(@"%@",detail);
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
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
        NSLog(@"stransactionId: %@", stransactionId);

        NSMutableDictionary* mdict = [[NSMutableDictionary alloc]init];
        [mdict setObject:productId forKey:@"productId"];
        [mdict setObject:receiptBase64 forKey:@"receiptBase64"];
        [mdict setObject:stransactionId forKey:@"orderId"];
        
        int size = [StoreUtil getIntValue:@"apple_pay_size" defValue:0] + 1;
        [StoreUtil setIntValue:@"apple_pay_size" value:size];
        
        NSString *key = [NSString stringWithFormat:@"apple_pay_item_%d",size];
        [StoreUtil setObjectItem:key obj:mdict];
        
        [AppUtil NotifyEngine:@"onRestorePurchases" dic:mdict];
    }else{
        [AppUtil NotifyEngine:@"onRestorePurchases" dic:nil];
    }
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

-(void)rePurchases{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}


/**
 * 支付接口
 */
+ (void)applePay:(NSString *)json{
    NSLog(@"applePay:json = %@", json);
    NSDictionary *dict = [AppUtil jsonStringToDictionary: json];
    NSString* productId = [dict objectForKey:@"productId"];
    NSLog(@"applePay:product = %@", productId);
    [[ApplePayUtil getInstance] BuyPay:productId];
}


/**
 * 查询购买交易
 */
+ (void)restorePurchases:(NSString *)json{
    NSLog(@"restorePurchases:json = %@", json);
    [[ApplePayUtil getInstance] rePurchases];
}

@end
