#import <UIKit/UIKit.h>

#define PANDA_API_KEY @"f28a862d-3425-4078-a08e-a6516879e66f"

@interface VncheatManager : NSObject
+ (void)showKey;
@end

@implementation VncheatManager
+ (void)showKey {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if (!window) return;

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"VNCHEAT VIP" message:@"NHẬP KEY PANDA" preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:nil];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSString *key = alert.textFields.firstObject.text;
            NSString *api = [NSString stringWithFormat:@"https://api.pandakey.net/v1/verify?key=%@&api_key=%@", key, PANDA_API_KEY];
            [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:api] completionHandler:^(NSData *d, NSURLResponse *r, NSError *e) {
                if (d) {
                    NSDictionary *js = [NSJSONSerialization JSONObjectWithData:d options:0 error:nil];
                    if (![js[@"status"] isEqualToString:@"success"]) exit(0);
                }
            }] resume];
        }]];
        [window.rootViewController presentViewController:alert animated:YES completion:nil];
    });
}
@end

%ctor {
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *n) {
        [VncheatManager showKey];
    }];
}
