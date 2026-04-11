#import <UIKit/UIKit.h>

// --- CẤU HÌNH DASHBOARD PANDA ---
#define PANDA_API_KEY @"e3b3864d-edb9-4fdb-b451-662993b95815" // Lấy ở mục API Settings trên web
#define SERVICE_ID @"vncheatff"          // Phải trùng 100% với Identifier trên web

@interface VncheatFF : UIView
@property (nonatomic, strong) UITextField *kField;
@property (nonatomic, strong) UIButton *bBtn;
@property (nonatomic, strong) UILabel *statusLabel;
@end

@implementation VncheatFF

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // --- GIAO DIỆN CYBERPUNK ---
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.95];
        self.layer.cornerRadius = 15;
        self.layer.borderWidth = 2.5;
        self.layer.borderColor = [UIColor redColor].CGColor;
        self.layer.shadowColor = [UIColor redColor].CGColor;
        self.layer.shadowOpacity = 0.6;
        self.layer.shadowRadius = 12;
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
        self.bBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        self.bBtn.layer.cornerRadius = 8;
        [self.bBtn addTarget:self action:@selector(checkKey) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.bBtn];

        UILabel *copy = [[UILabel alloc] initWithFrame:CGRectMake(0, 160, frame.size.width, 20)];
        copy.text = @"© nhism ieu";
        copy.textColor = [UIColor grayColor];
        copy.font = [UIFont systemFontOfSize:10];
        copy.textAlignment = NSTextAlignmentCenter;
        [self addSubview:copy];

        // --- LỚP TRẠNG THÁI ---
        self.statusLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.statusLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.98];
        self.statusLabel.layer.cornerRadius = 15;
        self.statusLabel.clipsToBounds = YES;
        self.statusLabel.textAlignment = NSTextAlignmentCenter;
        self.statusLabel.numberOfLines = 0;
        self.statusLabel.alpha = 0;
        [self addSubview:self.statusLabel];
    }
    return self;
}

- (void)checkKey {
    NSString *k = self.kField.text;
    if (k.length < 1) return;
    
    [self.bBtn setTitle:@"ĐANG QUÉT..." forState:UIControlStateNormal];
    self.bBtn.enabled = NO;

    // LINK API CHUẨN KHỚP VỚI IDENTIFIER vncheatff
    NSString *apiPath = [NSString stringWithFormat:@"https://api.pandadevelopment.net/v1/verify?key=%@&service=%@&api_key=%@", k, SERVICE_ID, PANDA_API_KEY];
    
    NSURL *u = [NSURL URLWithString:apiPath];
    [[[NSURLSession sharedSession] dataTaskWithURL:u completionHandler:^(NSData *d, NSURLResponse *r, NSError *e) {
        BOOL isOk = NO;
        if (d) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:d options:0 error:nil];
            if (json && [json[@"status"] isEqualToString:@"success"]) isOk = YES;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isOk) {
                self.statusLabel.text = @"THÀNH CÔNG!\n✅";
                self.statusLabel.textColor = [UIColor greenColor];
                self.statusLabel.font = [UIFont boldSystemFontOfSize:22];
                [UIView animateWithDuration:0.3 animations:^{ self.statusLabel.alpha = 1; }];

                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [UIView animateWithDuration:0.5 animations:^{ self.alpha = 0; } completion:^(BOOL f) { [self removeFromSuperview]; }];
                });
            } else {
                self.statusLabel.text = @"LỖI KEY\nNHẬP LẠI\n❌";
                self.statusLabel.textColor = [UIColor redColor];
                self.statusLabel.font = [UIFont boldSystemFontOfSize:20];
                [UIView animateWithDuration:0.3 animations:^{ self.statusLabel.alpha = 1; }];

                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [UIView animateWithDuration:0.3 animations:^{ self.statusLabel.alpha = 0; }];
                    [self.bBtn setTitle:@"KÍCH HOẠT" forState:UIControlStateNormal];
                    self.bBtn.enabled = YES;
                });
            }
        });
    }] resume];
}
@end

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
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



