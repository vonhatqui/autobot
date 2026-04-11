#import <UIKit/UIKit.h>

// --- CẤU HÌNH API PANDA ---
#define PANDA_API_KEY @"a3fa4a9c-15db-4552-90ac-adba83012e7c" 

@interface VncheatHub : UIView
@property (nonatomic, strong) UITextField *keyField;
@property (nonatomic, strong) UIButton *loginBtn;
@property (nonatomic, strong) UILabel *statusLabel;
@end

@implementation VncheatHub

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // 1. Nền Cyberpunk Đen nhám + Viền Đỏ
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.92];
        self.layer.cornerRadius = 15;
        self.layer.borderWidth = 2.0;
        self.layer.borderColor = [UIColor redColor].CGColor;
        self.clipsToBounds = YES;
        
        // 2. Hiệu ứng Kính mờ (Để nhìn xuyên qua Menu Hack cũ)
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
        blurView.frame = self.bounds;
        [self addSubview:blurView];

        // 3. Tiêu đề
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, frame.size.width, 30)];
        title.text = @"VNCHEATING LOGIN";
        title.textColor = [UIColor redColor];
        title.font = [UIFont boldSystemFontOfSize:22];
        title.textAlignment = NSTextAlignmentCenter;
        [self addSubview:title];

        // 4. Ô nhập Key
        self.keyField = [[UITextField alloc] initWithFrame:CGRectMake(25, 60, frame.size.width - 50, 40)];
        self.keyField.placeholder = @"Nhập Key của bạn...";
        self.keyField.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1];
        self.keyField.textColor = [UIColor whiteColor];
        self.keyField.layer.cornerRadius = 8;
        self.keyField.textAlignment = NSTextAlignmentCenter;
        self.keyField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.keyField.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor grayColor]}];
        [self addSubview:self.keyField];

        // 5. Nút Kích hoạt
        self.loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.loginBtn.frame = CGRectMake(25, 115, frame.size.width - 50, 45);
        self.loginBtn.backgroundColor = [UIColor redColor];
        [self.loginBtn setTitle:@"KÍCH HOẠT" forState:UIControlStateNormal];
        self.loginBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        self.loginBtn.layer.cornerRadius = 8;
        [self.loginBtn addTarget:self action:@selector(handleLogin) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.loginBtn];

        // 6. Bản quyền nhism
        UILabel *cp = [[UILabel alloc] initWithFrame:CGRectMake(0, 165, frame.size.width, 20)];
        cp.text = @"© nhism - Vncheat Project";
        cp.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.4];
        cp.font = [UIFont systemFontOfSize:10];
        cp.textAlignment = NSTextAlignmentCenter;
        [self addSubview:cp];
    }
    return self;
}

- (void)handleLogin {
    NSString *key = self.keyField.text;
    if (key.length < 2) return;

    [self.loginBtn setTitle:@"ĐANG XÁC THỰC..." forState:UIControlStateNormal];
    self.loginBtn.enabled = NO;

    // Chạy ngầm (Background Thread) để không làm treo Game
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *u = [NSString stringWithFormat:@"https://api.pandakey.net/v1/verify?key=%@&api_key=%@", key, PANDA_API_KEY];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:u]];
        
        BOOL isOk = NO;
        if (data) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if (json && [json[@"status"] isEqualToString:@"success"]) isOk = YES;
        }

        // Quay lại luồng chính (Main Thread) để xử lý UI
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isOk) {
                [self.loginBtn setTitle:@"THÀNH CÔNG!" forState:UIControlStateNormal];
                self.loginBtn.backgroundColor = [UIColor colorWithRed:0.0 green:0.7 blue:0.0 alpha:1.0];
                
                // Hiệu ứng biến mất mượt mà để nhường chỗ cho Menu Hack
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [UIView animateWithDuration:0.5 animations:^{
                        self.alpha = 0;
                        self.transform = CGAffineTransformMakeScale(0.5, 0.5);
                    } completion:^(BOOL f) {
                        [self removeFromSuperview];
                    }];
                });
            } else {
                // Key sai là đóng app ngay lập tức
                exit(0);
            }
        });
    });
}
@end

// --- KHỞI CHẠY ---
%ctor {
    // Để 8 giây cho Game và EreenTst.dylib ổn định rồi mới hiện Menu Login
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        if (keyWindow) {
            VncheatHub *hub = [[VncheatHub alloc] initWithFrame:CGRectMake(0, 0, 300, 195)];
            hub.center = keyWindow.center;
            
            // CỰC KỲ QUAN TRỌNG: Đẩy Menu của Đại ca lên lớp cao nhất (đè bệt Menu Hack cũ)
            hub.layer.zPosition = MAXFLOAT; 
            
            [keyWindow addSubview:hub];
        }
    });
}
