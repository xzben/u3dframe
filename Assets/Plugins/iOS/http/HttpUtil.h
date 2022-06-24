

#ifndef HttpUtil_h
#define HttpUtil_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@protocol HttpDelegate <NSObject>

- (void)onSuccess:(NSData *)data;

- (void)onFail:(int)code msg:(NSString *)msg;

@end


@interface HttpUtil : NSObject

//@property (weak, nonatomic) id<HttpDelegate> delegate;

+ (instancetype)getInstance;

- (void) httpGet:(NSString *)url delegate:(nullable id<HttpDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END

#endif
