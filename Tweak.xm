#import <UIKit/UIKit.h>

// LINK API KẾT NỐI ĐẾN SERVICE CỦA ĐẠI CA
#define PANDA_API @"https://new.pandadevelopment.net/api/v1/service/b4ae0cee-620b-470a-9dea-4d2ddfb599b4/key/verify"

@interface VncheatPandaMenu : UIView
@property (nonatomic, strong) UITextField *keyInput;
@property (nonatomic, strong) UIButton *authBtn;
@property (nonatomic, strong) UILabel *statusLabel;
@end

@implementation VncheatPandaMenu

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Giao diện Đỏ - Đen Cyberpunk cực chất
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.9];
        self.layer.cornerRadius = 15;
        self.layer.borderWidth = 2;
        self.layer.borderColor = [UIColor redColor].CGColor;
        self.layer.shadowColor = [UIColor redColor].CGColor;
        self.layer.shadowRadius = 10;
        self.layer.shadowOpacity = 0.5;

        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, frame.size.width, 30)];
        title.text = @"VNCHEAT VIP × PANDA";
        title.textColor = [UIColor redColor];
        title.font = [UIFont boldSystemFontOfSize:18];
        title.textAlignment = NSTextAlignmentCenter;
        [self addSubview:title];

        self.keyInput = [[UITextField alloc] initWithFrame:CGRectMake(20, 55, frame.size.width - 40, 40)];
        self.keyInput.placeholder = @"Nhập License Key...";
        self.keyInput.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.1];
        self.keyInput.textColor = [UIColor whiteColor];
        self.keyInput.textAlignment = NSTextAlignmentCenter;
        self.keyInput.layer.cornerRadius = 8;
        // Chỉnh màu cho chữ placeholder
        self.keyInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.keyInput.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
        [self addSubview:self.keyInput];

        self.authBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 110, frame.size.width - 40, 45)];
        self.authBtn.backgroundColor = [UIColor redColor];
        [self.authBtn setTitle:@"KÍCH HOẠT" forState:UIControlStateNormal];
        self.authBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        self.authBtn.layer.cornerRadius = 8;
        [self.authBtn addTarget:self action:@selector(verifyKey) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.authBtn];

        self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 165, frame.size.width, 25)];
        self.statusLabel.textColor = [UIColor whiteColor];
        self.statusLabel.font = [UIFont systemFontOfSize:11];
        self.statusLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.statusLabel];
    }
    return self;
}

- (void)verifyKey {
    NSString *key = [self.keyInput.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (key.length == 0) {
        self.statusLabel.text = @"Vui lòng nhập Key!";
        return;
    }

    [self.authBtn setTitle:@"ĐANG KIỂM TRA..." forState:UIControlStateNormal];
    self.authBtn.enabled = NO;

    // Lấy UDID máy để Panda khóa Key vào máy này
    NSString *hwid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:PANDA_API]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    // Gửi đúng định dạng JSON cho Panda
    NSDictionary *params = @{@"key": key, @"hwid": hwid};
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];

    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error || !data) {
                self.statusLabel.text = @"Lỗi kết nối Server!";
                self.authBtn.enabled = YES;
                [self.authBtn setTitle:@"THỬ LẠI" forState:UIControlStateNormal];
                return;
            }

            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            // Panda trả về field 'success' (true/false)
            if ([json[@"success"] boolValue] == YES) {
                self.statusLabel.text = @"KÍCH HOẠT THÀNH CÔNG!";
                self.statusLabel.textColor = [UIColor greenColor];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [UIView animateWithDuration:0.5 animations:^{ self.alpha = 0; } completion:^(BOOL f) { [self removeFromSuperview]; }];
                });
            } else {
                // Nếu lỗi, Panda trả về lý do trong 'message'
                self.statusLabel.text = json[@"message"] ? json[@"message"] : @"Key không hợp lệ!";
                self.statusLabel.textColor = [UIColor redColor];
                self.authBtn.enabled = YES;
                [self.authBtn setTitle:@"KÍCH HOẠT" forState:UIControlStateNormal];
            }
        });
    }] resume];
}
@end

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *win = [UIApplication sharedApplication].keyWindow;
        if (win) {
            VncheatPandaMenu *menu = [[VncheatPandaMenu alloc] initWithFrame:CGRectMake(0, 0, 300, 200)];
            menu.center = win.center;
            [win addSubview:menu];
        }
    });
}

