#import <UIKit/UIKit.h>

#define PANDA_API_KEY @"f28a862d-3425-4078-a08e-a6516879e66f"

@interface VncheatManager : NSObject
+ (void)showKeyAlert;
@end

@implementation VncheatManager
+ (void)showKeyAlert {
    dispatch_async(dispatch_get_main_queue(), ^{
        // Cách lấy Window mới nhất để tránh lỗi Deprecated
        UIWindow *window = nil;
        if (@available(iOS 13.0, *)) {
            for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes) {
                if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                    window = windowScene.windows.firstObject;
                    break;
                }
            }
        } else {
            window = [UIApplication sharedApplication].keyWindow;
        }

        if (!window) return;

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"VNCHEAT VIP" 
                                    message:@"NHẬP KEY PANDA ĐỂ TIẾP TỤC" 
                                    preferredStyle:UIAlertControllerStyleAlert];

        [alert addTextFieldWithConfigurationHandler:^(UITextField *field) {
            field.placeholder = @"Nhập Key...";
        }];

        [alert addAction:[UIAlertAction actionWithTitle:@"VÀO GAME" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSString *userKey = alert.textFields.firstObject.text;
            NSString *urlStr = [NSString stringWithFormat:@"https://api.pandakey.net/v1/verify?key=%@&api_key=%@", userKey, PANDA_API_KEY];
            
            [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:urlStr] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                if (data) {
                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    if ([json[@"status"] isEqualToString:@"success"]) {
                        NSLog(@"[Vncheat] Key chuẩn!");
                    } else {
                        exit(0);
                    }
                }
            }] resume];
        }]];

        [window.rootViewController presentViewController:alert animated:YES completion:nil];
    });
}
@end

%ctor {
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [VncheatManager showKeyAlert];
    }];
}
y
