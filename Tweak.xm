#import <UIKit/UIKit.h>

#define PANDA_API_KEY @"57e43370-32ca-491a-83d1-af6a12227e25"
#define SERVICE_ID @"vncheatff"

@interface VncheatFF : UIView
@property (nonatomic, strong) UITextField *kField;
@property (nonatomic, strong) UIButton *bBtn;
@property (nonatomic, strong) UILabel *statusLabel;
@end

@implementation VncheatFF

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.95];
        self.layer.cornerRadius = 15;
        self.layer.borderWidth = 2.5;
        self.layer.borderColor = [UIColor redColor].CGColor;
        self.layer.zPosition = 9999;

        UILabel *t = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, frame.size.width, 25)];
        t.text = @"VNCHEAT × FREE FIRE";
        t.textColor = [UIColor redColor];
        t.font = [UIFont boldSystemFontOfSize:18];
        t.textAlignment = NSTextAlignmentCenter;
        [self addSubview:t];

        self.kField = [[UITextField alloc] initWithFrame:CGRectMake(20, 55, frame.size.width - 40, 40)];
        self.kField.placeholder = @"Nhập Key...";
        self.kField.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1];
        self.kField.textColor = [UIColor whiteColor];
        self.kField.layer.cornerRadius = 8;
        self.kField.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.kField];

        self.bBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.bBtn.frame = CGRectMake(20, 110, frame.size.width - 40, 45);
        self.bBtn.backgroundColor = [UIColor redColor];
        [self.bBtn setTitle:@"KÍCH HOẠT" forState:UIControlStateNormal];
        self.bBtn.layer.cornerRadius = 8;
        [self.bBtn addTarget:self action:@selector(checkKey) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.bBtn];

        UILabel *copy = [[UILabel alloc] initWithFrame:CGRectMake(0, 160, frame.size.width, 20)];
        copy.text = @"© nhism ieu";
        copy.textColor = [UIColor grayColor];
        copy.font = [UIFont systemFontOfSize:10];
        copy.textAlignment = NSTextAlignmentCenter;
        [self addSubview:copy];

        self.statusLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.statusLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.98];
        self.statusLabel.layer.cornerRadius = 15;
        self.statusLabel.textAlignment = NSTextAlignmentCenter;
        self.statusLabel.numberOfLines = 0;
        self.statusLabel.alpha = 0;
        [self addSubview:self.statusLabel];
    }
    return self;
}

- (void)checkKey {

    NSString *k = [self.kField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (k.length < 1) return;

    [self.bBtn setTitle:@"ĐANG QUÉT..." forState:UIControlStateNormal];
    self.bBtn.enabled = NO;

    // ✅ API MỚI (FIX 404)
    NSString *apiPath = [NSString stringWithFormat:
        @"https://pandadevelopment.net/api/verify?key=%@&service=%@&api_key=%@",
        [k stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]],
        SERVICE_ID,
        PANDA_API_KEY
    ];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:apiPath]];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];

    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *d, NSURLResponse *r, NSError *e) {

        BOOL isOk = NO;

        if (e) {
            NSLog(@"ERROR: %@", e);
        }

        if (d) {
            NSString *raw = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
            NSLog(@"RAW RESPONSE: %@", raw);

            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:d options:0 error:nil];
            NSLog(@"JSON: %@", json);

            // ✅ FIX LOGIC CHECK
            if (json) {
                if ([json[@"success"] boolValue] == YES) {
                    isOk = YES;
                }
                else if ([json[@"status"] boolValue] == YES) {
                    isOk = YES;
                }
                else if ([json[@"status"] isKindOfClass:[NSString class]] &&
                         [json[@"status"] isEqualToString:@"success"]) {
                    isOk = YES;
                }
            }
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            if (isOk) {

                self.statusLabel.text = @"THÀNH CÔNG!\n✅";
                self.statusLabel.textColor = [UIColor greenColor];
                self.statusLabel.alpha = 1;

                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self removeFromSuperview];
                });

            } else {

                self.statusLabel.text = @"KEY SAI / API LỖI\n❌";
                self.statusLabel.textColor = [UIColor redColor];
                self.statusLabel.alpha = 1;

                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.statusLabel.alpha = 0;
                    [self.bBtn setTitle:@"KÍCH HOẠT" forState:UIControlStateNormal];
                    self.bBtn.enabled = YES;
                });
            }
        });

    }] resume];
}
@end

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *w = nil;

        if (@available(iOS 13.0, *)) {
            for (UIWindowScene* s in [UIApplication sharedApplication].connectedScenes) {
                if (s.activationState == UISceneActivationStateForegroundActive) {
                    w = s.windows.firstObject;
                    break;
                }
            }
        }

        if (!w) w = [UIApplication sharedApplication].keyWindow;

        if (w) {
            VncheatFF *v = [[VncheatFF alloc] initWithFrame:CGRectMake(0, 0, 280, 185)];
            v.center = CGPointMake(w.bounds.size.width / 2, w.bounds.size.height / 2);
            [w addSubview:v];
        }
    });
}
