#import <UIKit/UIKit.h>

#define PANDA_API_KEY @"6d8a255d-9b64-43eb-89f4-a670c5953ab6"

@interface VncheatHub : UIView
@property (nonatomic, strong) UITextField *keyField;
@property (nonatomic, strong) UIButton *loginBtn;
@end

@implementation VncheatHub

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        self.layer.cornerRadius = 15;
        self.layer.borderWidth = 2;
        self.layer.borderColor = [UIColor redColor].CGColor;
        self.clipsToBounds = YES;

        // Hiệu ứng Kính mờ (Glassmorphism)
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurView.frame = self.bounds;
        [self addSubview:blurView];

        // Tiêu đề
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, frame.size.width, 30)];
        title.text = @"VNCHEAT PRIME";
        title.textColor = [UIColor redColor];
        title.font = [UIFont boldSystemFontOfSize:20];
        title.textAlignment = NSTextAlignmentCenter;
        [self addSubview:title];

        // Ô nhập Key
        self.keyField = [[UITextField alloc] initWithFrame:CGRectMake(20, 60, frame.size.width - 40, 40)];
        self.keyField.placeholder = @" Nhập Key VIP tại đây...";
        self.keyField.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1];
        self.keyField.layer.cornerRadius = 8;
        self.keyField.textColor = [UIColor whiteColor];
        self.keyField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.keyField.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
        [self addSubview:self.keyField];

        // Nút Login
        self.loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.loginBtn.frame = CGRectMake(20, 115, frame.size.width - 40, 45);
        self.loginBtn.backgroundColor = [UIColor redColor];
        [self.loginBtn setTitle:@"KÍCH HOẠT" forState:UIControlStateNormal];
        self.loginBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        self.loginBtn.layer.cornerRadius = 8;
        [self.loginBtn addTarget:self action:@selector(handleLogin) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.loginBtn];
    }
    return self;
}

- (void)handleLogin {
    NSString *key = self.keyField.text;
    if (key.length < 1) return; // Không nhập gì thì không làm gì cả

    [self.loginBtn setTitle:@"ĐANG KIỂM TRA..." forState:UIControlStateNormal];
    self.loginBtn.enabled = NO;

    NSString *u = [NSString stringWithFormat:@"https://api.pandakey.net/v1/verify?key=%@&api_key=%@", key, PANDA_API_KEY];
    [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:u] completionHandler:^(NSData *d, NSURLResponse *r, NSError *e) {
        BOOL ok = NO;
        if (d) {
            NSDictionary *j = [NSJSONSerialization JSONObjectWithData:d options:0 error:nil];
            if (j && [j[@"status"] isEqualToString:@"success"]) ok = YES;
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            if (ok) {
                [UIView animateWithDuration:0.5 animations:^{ self.alpha = 0; } completion:^(BOOL f) { [self removeFromSuperview]; }];
            } else {
                exit(0); // Key sai hoặc trống là sút luôn
            }
        });
    }] resume];
}
@end

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *win = [UIApplication sharedApplication].keyWindow;
        if (win) {
            VncheatHub *hub = [[VncheatHub alloc] initWithFrame:CGRectMake(0, 0, 280, 180)];
            hub.center = win.center;
            [win addSubview:hub];
        }
    });
}


