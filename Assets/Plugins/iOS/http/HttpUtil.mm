

#import "HttpUtil.h"

@implementation HttpUtil

#pragma mark -
#pragma mark Singleton

static HttpUtil *mInstace = nil;

+ (instancetype)getInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mInstace = [[super allocWithZone:NULL] init];
    });
    return mInstace;
}
+ (id)allocWithZone:(struct _NSZone *)zone {
    return [HttpUtil getInstance];
}

+ (id)copyWithZone:(struct _NSZone *)zone {
    return [HttpUtil getInstance];
}

#pragma mark -
#pragma mark Application lifecycle


- (void) httpGet:(NSString*)url delegate:(nullable id<HttpDelegate>)delegate;
{
    NSLog(@"HttpUtil:httpGet:json = %@", url);
    // 1.创建一个网络路径
    NSURL *nsurl = [NSURL URLWithString:[NSString stringWithFormat:url]];
    // 2.创建一个网络请求
    NSURLRequest *request =[NSURLRequest requestWithURL:nsurl];
    // 3.获得会话对象
    NSURLSession *session = [NSURLSession sharedSession];
    
    // 4.根据会话对象，创建一个Task任务：
    NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error)
         {
             [delegate onFail:error.code msg:@"unknown"];
         }
        else
         {
             [delegate onSuccess:(NSData *)data];
         }
    }];
    
    //执行任务（resume也是继续执行）:
    [sessionDataTask resume];
}


@end
