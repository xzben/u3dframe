#import "EmailUtil.h"
#include "../utils/AppUtil.h"

@implementation EmailUtil

#pragma mark -
#pragma mark Singleton

static EmailUtil *mInstace = nil;

+ (instancetype)getInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mInstace = [[super allocWithZone:NULL] init];
    });
    return mInstace;
}
+ (id)allocWithZone:(struct _NSZone *)zone {
    return [EmailUtil getInstance];
}

+ (id)copyWithZone:(struct _NSZone *)zone {
    return [EmailUtil getInstance];
}

#pragma mark -
#pragma mark Application lifecycle
- (void)sendEmail:(NSString *)emailto title:(NSString*)title content:(NSString*)content{
    if([MFMailComposeViewController canSendMail]) {// 判断设备是否支持发送邮件
        // Email Content
        // To address
        NSArray *toRecipents = [NSArray arrayWithObject:emailto];

        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];

        mc.mailComposeDelegate = self;
        [mc setSubject:title];//邮件主题

        [mc setMessageBody:content isHTML:NO];//邮件部分内容

        [mc setToRecipients:toRecipents];//发送地址
        [mc.navigationBar setTintColor:[UIColor whiteColor]];

        UIViewController *adView = [[AppUtil getInstance] getView];
        [adView presentViewController:mc animated:YES completion:NULL];

    }else{
        //[MBProgressHUD ll_showErrorMessage:@"请先设置登录邮箱号"];
        NSString * recipients = [NSString stringWithFormat:@"mailto:%@?subject=%@",emailto,title];
        NSString *body = [NSString stringWithFormat:@"&body=%@",content];
        NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
                  email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
    }

}


#pragma mark 调起系统邮箱的代理方法
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error{
    NSString*message;
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            //message=[NSString stringWithFormat:@"%@",@"Mail cancelled"];
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            // message=[NSString stringWithFormat:@"%@",@"Mail saved"];
            break;
        case MFMailComposeResultSent:
            {
                NSLog(@"Mail sent");
                // message=[NSString stringWithFormat:@"%@",@"Mail sent"];
                NSMutableDictionary* mdict = [[NSMutableDictionary alloc]init];
                [AppUtil NotifyEngine:@"onSendMail" dic:mdict];
            }
            break;
        case MFMailComposeResultFailed:
            {
                NSString *code = [NSString stringWithFormat:@"%ld",error.code];
                NSMutableDictionary* mdict = [[NSMutableDictionary alloc]init];
                [mdict setObject:code forKey:@"errorCode"];
                [mdict setObject:error.localizedDescription forKey:@"errorMsg"];
                [AppUtil NotifyEngine:@"onSendMailError" dic:mdict];
            }
            break;
        default:
            break;
    }
    UIViewController *adView = [[AppUtil getInstance] getView];
    [adView dismissViewControllerAnimated:YES completion:NULL];
}


+ (void)sendMail:(NSString *)json{
    NSLog(@"sendEmail:json = %@", json);
    NSDictionary *dict = [AppUtil jsonStringToDictionary: json];
    NSString* mailto = [dict objectForKey:@"mailto"];
    NSString* title = [dict objectForKey:@"title"];
    NSString* content = [dict objectForKey:@"content"];
    [[EmailUtil getInstance] sendEmail:mailto title:title content:content];
}


@end
