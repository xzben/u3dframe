#ifndef EmailUtil_h
#define EmailUtil_h

#import <Foundation/Foundation.h>
#import <MessageUI/MFMailComposeViewController.h>

NS_ASSUME_NONNULL_BEGIN

@interface EmailUtil : NSObject<MFMailComposeViewControllerDelegate>

+ (instancetype)getInstance;

- (void)sendEmail:(NSString *)emailto title:(NSString*)title content:(NSString*)content;

+ (void)sendMail:(NSString *)json;

@end

NS_ASSUME_NONNULL_END

#endif
