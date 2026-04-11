#import <UIKit/UIKit.h>

// --- THÔNG SỐ KEYAUTH CỦA ĐẠI CA ---
#define KA_NAME @"Jinwwostore.vn's Application"
#define KA_OWNER @"sK9GJV69ef"
#define KA_SECRET @"0f88b8a157655d61fe91144f12e9df34b97d9e5c269f1ac0cd0faa110d92b579"
#define KA_VERSION @"1.0" // Lưu ý: Trên Dashboard đặt bản nhiêu thì sửa ở đây bấy nhiêu

@interface VncheatFF : UIView
@property (nonatomic, strong) UITextField *kField;
@property (nonatomic, strong) UIButton *bBtn;
@property (nonatomic, strong) UILabel *statusLabel;
@end

@implementation VncheatFF

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // --- GIAO DIỆN CYBERPUNK (NHISM IEU STYLE) ---
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
    
    [self.bBtn setTitle:@"ĐANG XÁC THỰC..." forState:UIControlStateNormal];
    self.bBtn.enabled = NO;

    // BƯỚC 1: INIT SESSION
    NSString *url = [NSString stringWithFormat:@"https://keyauth.win/api/1.1/?type=init&name=%@&ownerid=%@&ver=%@", 
                    [KA_NAME stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]], 
                    KA_OWNER, KA_VERSION];
    
    [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData *d, NSURLResponse *r, NSError *e) {
        if (d) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:d options:0 error:nil];
            if ([json[@"success"] boolValue]) {
                [self loginWithKey:k session:json[@"sessionid"]];
            } else {
                [self showStatus:NO msg:@"INIT FAILED"];
            }
        } else {
            [self showStatus:NO msg:@"SERVER ERROR"];
        }
    }] resume];
}

- (void)loginWithKey:(NSString *)key session:(NSString *)sid {
    // BƯỚC 2: LICENSE LOGIN
    NSString *url = [NSString stringWithFormat:@"https://keyauth.win/api/1.1/?type=license&key=%@&sessionid=%@&name=%@&ownerid=%@", 
                    key, sid, [KA_NAME stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]], KA_OWNER];
    
    [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData *d, NSURLResponse *r, NSError *e) {
        BOOL ok = NO;
        if (d) {
            NSDictionary *res = [NSJSONSerialization JSONObjectWithData:d options:0 error:nil];
            NSLog(@"[VNCHEAT] Response: %@", res);
            if ([res[@"success"] boolValue]) ok = YES;
        }
        [self showStatus:ok msg:ok ? @"THÀNH CÔNG!" : @"SAI KEY"];
    }] resume];
}

- (void)showStatus:(BOOL)ok msg:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.statusLabel.text = [NSString stringWithFormat:@"%@\n%@", msg, ok ? @"✅" : @"❌"];
        self.statusLabel.textColor = ok ? [UIColor greenColor] : [UIColor redColor];
        self.statusLabel.font = [UIFont boldSystemFontOfSize:22];
        [UIView animateWithDuration:0.3 animations:^{ self.statusLabel.alpha = 1; }];
        
        if (ok) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.5 animations:^{ self.alpha = 0; } completion:^(BOOL f) { [self removeFromSuperview]; }];
            });
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.3 animations:^{ self.statusLabel.alpha = 0; }];
                [self.bBtn setTitle:@"KÍCH HOẠT" forState:UIControlStateNormal];
                self.bBtn.enabled = YES;
            });
        }
    });
}
@end

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *w = nil;
        if (@available(iOS 13.0, *)) {
            for (UIWindowScene* s in [UIApplication sharedApplication].connectedScenes) {
                if (s.activationState == UISceneActivationStateForegroundActive) {
                    w = s.windows.firstObject; break;
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
