#import "QueryProductUtil.h"
#include "../utils/AppUtil.h"
#include "../utils/StoreUtil.h"

@implementation QueryProductUtil

#pragma mark -
#pragma mark Singleton

static QueryProductUtil *mInstace = nil;

+ (instancetype)getInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mInstace = [[super allocWithZone:NULL] init];
    });
    return mInstace;
}
+ (id)allocWithZone:(struct _NSZone *)zone {
    return [QueryProductUtil getInstance];
}

+ (id)copyWithZone:(struct _NSZone *)zone {
    return [QueryProductUtil getInstance];
}

#pragma mark -
#pragma mark Application lifecycle


#pragma mark- SKRequestDelegate
- (void)requestDidFinish:(SKRequest *)request{
    
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
    
    NSMutableArray *products = [NSMutableArray arrayWithCapacity:myProduct.count];
    for(SKProduct *product in myProduct){
        NSLog(@"product info");
        NSLog(@"产品标题 %@" , product.localizedTitle);
        NSLog(@"产品描述信息: %@" , product.localizedDescription);
        NSLog(@"价格: %@" , product.price);
        NSLog(@"Product id: %@" , product.productIdentifier);
        
        NSNumberFormatter*numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [numberFormatter setLocale:product.priceLocale];
        NSString*formattedPrice = [numberFormatter stringFromNumber:product.price];
        NSLog(@"Product local_price: %@" , formattedPrice);
      
        NSMutableDictionary* mdict = [[NSMutableDictionary alloc]init];
        [mdict setObject:product.productIdentifier forKey:@"productId"];
        [mdict setObject:product.price forKey:@"price"];
        [mdict setObject:formattedPrice forKey:@"priceLocale"];
        [products addObject:mdict];
    }
    
    NSMutableDictionary* mdict = [[NSMutableDictionary alloc]init];
    [mdict setObject:products forKey:@"products"];
    [AppUtil NotifyEngine:@"onQueryProducts" dic:mdict];
}

#pragma mark- SKProductsRequestDelegate <SKRequestDelegate>
//查询失败后的回调
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Product Request error: %@" , error.localizedDescription);
}


- (void)query:(NSArray *)productIds
{
    if ([SKPaymentQueue canMakePayments]) {
        NSMutableSet *set = [NSMutableSet setWithArray:productIds];
        //从Apple查询用户点击购买的产品的信息
        SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
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


+ (void)queryProducts:(NSString *)json{
    NSLog(@"applePay:json = %@", json);
    NSDictionary *dict = [AppUtil jsonStringToDictionary: json];
    NSArray *products = [dict objectForKey:@"products"];
    NSMutableArray *productIds = [NSMutableArray arrayWithCapacity:products.count];
    for( int i = 0; i < products.count; i++){
        NSDictionary *dict = [products objectAtIndex:i];
        NSString *productId = [dict objectForKey:@"productId"];
        [productIds addObject:productId];
    }
    NSLog(@"applePay:productCount = %ld", productIds.count);
    [[QueryProductUtil getInstance] query:productIds];
}


@end
