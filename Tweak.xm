#import <UIKit/UIKit.h>

#define PANDA_API_KEY @"API_CỦA_ĐẠI_CA"

@interface VncheatHub : UIView
@property (nonatomic, strong) UITextField *keyField;
@property (nonatomic, strong) UIButton *loginBtn;
@end

@implementation VncheatHub

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Nền đen nhám
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.85];
        self.layer.cornerRadius = 15;
        self.layer.borderWidth = 1.5;
        self.layer.borderColor = [UIColor redColor].CGColor;
        
        // Hiệu ứng kính mờ (Glassmorphism)
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
        blurView.frame = self.bounds;
        blurView.layer.cornerRadius = 15;
        blurView.clipsToBounds = YES;
        [self addSubview:blurView];

        // Tiêu đề chính
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, frame.size.width, 30)];
        title.text = @"Cheating PRIME";
        title.textColor = [UIColor redColor];
        title.font = [UIFont boldSystemFontOfSize:20];
        title.textAlignment = NSTextAlignmentCenter;
        [self addSubview:title];

        // Ô nhập Key
        self.keyField = [[UITextField alloc] initWithFrame:CGRectMake(20, 55, frame.size.width - 40, 40)];
        self.keyField.placeholder = @" Nhập Key tại đây...";
        self.keyField.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1];
        self.keyField.textColor = [UIColor whiteColor];
        self.keyField.layer.cornerRadius = 8;
        self.keyField.textAlignment = NSTextAlignmentCenter;
        self.keyField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.keyField.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
        [self addSubview:self.keyField];

        // Nút Kích hoạt
        self.loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.loginBtn.frame = CGRectMake(20, 105, frame.size.width - 40, 45);
        self.loginBtn.backgroundColor = [UIColor redColor];
        [self.loginBtn setTitle:@"KÍCH HOẠT" forState:UIControlStateNormal];
        self.loginBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        self.loginBtn.layer.cornerRadius = 8;
        [self.loginBtn addTarget:self action:@selector(handleLogin) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.loginBtn];

        // DÒNG BẢN QUYỀN (Copyright)
        UILabel *copyright = [[UILabel alloc] initWithFrame:CGRectMake(0, 155, frame.size.width, 20)];
        copyright.text = @"© nhism ieu ><";
        copyright.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
        copyright.font = [UIFont systemFontOfSize:11];
        copyright.textAlignment = NSTextAlignmentCenter;
        [self addSubview:copyright];
    }
    return self;
}

- (void)handleLogin {
    NSString *key = self.keyField.text;
    if (key.length < 1) return;

    [self.loginBtn setTitle:@"ĐANG XÁC THỰC..." forState:UIControlStateNormal];
    self.loginBtn.enabled = NO;

    NSString *urlStr = [NSString stringWithFormat:@"https://api.pandakey.net/v1/verify?key=%@&api_key=%@", key, PANDA_API_KEY];
    
    [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:urlStr] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        BOOL success = NO;
        if (data) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if (json && [json[@"status"] isEqualToString:@"success"]) success = YES;
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                [self.loginBtn setTitle:@"THÀNH CÔNG!" forState:UIControlStateNormal];
                [self.loginBtn setBackgroundColor:[UIColor colorWithRed:0.0 green:0.8 blue:0.0 alpha:1.0]];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [UIView animateWithDuration:0.4 animations:^{
                        self.alpha = 0;
                        self.transform = CGAffineTransformMakeScale(0.8, 0.8);
                    } completion:^(BOOL finished) {
                        [self removeFromSuperview];
                    }];
                });
            } else {
                exit(0);
            }
        });
    }] resume];
}
@end

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if (window) {
            // Tăng chiều cao lên 185 để chứa dòng bản quyền
            VncheatHub *hub = [[VncheatHub alloc] initWithFrame:CGRectMake(0, 0, 280, 185)];
            hub.center = window.center;
            [window addSubview:hub];
        }
    });
}



