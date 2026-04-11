#import <UIKit/UIKit.h>

#define PANDA_API_KEY @"f28a862d-3425-4078-a08e-a6516879e66f"
#define MENU_TITLE @"Cheating VIP - PRIME CR"

@interface VncheatManager : NSObject
+ (void)checkKey;
@end

@implementation VncheatManager

+ (void)checkKey {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        UIViewController *rootVC = window.rootViewController;

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:MENU_TITLE 
                                    message:@"VUI LÒNG NHẬP KEY ĐỂ KÍCH HOẠT" 
                                    preferredStyle:UIAlertControllerStyleAlert];

        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"Nhập Key tại đây...";
            textField.secureTextEntry = NO;
        }];

        UIAlertAction *action = [UIAlertAction actionWithTitle:@"KÍCH HOẠT" style:UIAlertActionStyleDefault handler:^(UIAlertAction *login) {
            NSString *userKey = alert.textFields.firstObject.text;
            [self verify:userKey];
        }];

        [alert addAction:action];
        [rootVC presentViewController:alert animated:YES completion:nil];
    });
}

+ (void)verify:(NSString *)key {
    NSString *urlStr = [NSString stringWithFormat:@"https://api.pandakey.net/v1/verify?key=%@&api_key=%@", key, PANDA_API_KEY];
    NSURL *url = [NSURL URLWithString:urlStr];

    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if ([json[@"status"] isEqualToString:@"success"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    // ĐĂNG NHẬP THÀNH CÔNG - CODE MỞ MENU HACK CỦA ĐẠI CA ĐẶT Ở ĐÂY
                    UIAlertController *success = [UIAlertController alertControllerWithTitle:@"THÀNH CÔNG" message:@"Done!" preferredStyle:UIAlertControllerStyleAlert];
                    [success addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:success animated:YES completion:nil];
                });
            } else {
                exit(0); // KEY LỎ - VĂNG APP
            }
        }
    }] resume];
}
@end

%ctor {
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [VncheatManager checkKey];
    }];
}
