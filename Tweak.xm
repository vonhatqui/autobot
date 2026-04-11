#import <UIKit/UIKit.h>

#define PANDA_API_KEY @"f28a862d-3425-4078-a08e-a6516879e66f"

@interface VncheatManager : NSObject
+ (void)show;
@end

@implementation VncheatManager
+ (void)show {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if (!window || !window.rootViewController) return;

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"VNCHEAT" 
                                    message:@"NHẬP KEY PANDA" 
                                    preferredStyle:UIAlertControllerStyleAlert];

        [alert addTextFieldWithConfigurationHandler:nil];

        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" 
                                   style:UIAlertActionStyleDefault 
                                   handler:^(UIAlertAction *action) {
            NSString *k = alert.textFields.firstObject.text;
            NSString *u = [NSString stringWithFormat:@"https://api.pandakey.net/v1/verify?key=%@&api_key=%@", k, PANDA_API_KEY];
            [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:u] completionHandler:^(NSData *d, NSURLResponse *r, NSError *e) {
                if (d) {
                    NSDictionary *j = [NSJSONSerialization JSONObjectWithData:d options:0 error:nil];
                    if (![j[@"status"] isEqualToString:@"success"]) exit(0);
                }
            }] resume];
        }];

        [alert addAction:okAction];
        [window.rootViewController presentViewController:alert animated:YES completion:nil];
    });
}
@end

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [VncheatManager show];
    });
}


