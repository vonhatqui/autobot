#import <UIKit/UIKit.h>

#define PANDA_API_KEY @"a3fa4a9c-15db-4552-90ac-adba83012e7c"

@interface VncheatFF : UIView <UITextFieldDelegate>
@property (nonatomic, strong) UITextField *kField;
@property (nonatomic, strong) UIButton *bBtn;
@end

@implementation VncheatFF

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.95];
        self.layer.cornerRadius = 15;
        self.layer.borderWidth = 2;
        self.layer.borderColor = [UIColor redColor].CGColor;
        self.layer.shadowColor = [UIColor redColor].CGColor;
        self.layer.shadowOpacity = 0.5;
        self.layer.shadowRadius = 10;

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
        self.kField.delegate = self;
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
    }
    return self;
}

- (void)checkKey {
    NSString *k = self.kField.text;
    if (k.length < 1) return;
    
    [self.bBtn setTitle:@"ĐANG QUÉT..." forState:UIControlStateNormal];
    self.bBtn.enabled = NO;

    NSURL *u = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.pandakey.net/v1/verify?key=%@&api_key=%@", k, PANDA_API_KEY]];
    [[[NSURLSession sharedSession] dataTaskWithURL:u completionHandler:^(NSData *d, NSURLResponse *r, NSError *e) {
        BOOL ok = NO;
        if (d) {
            NSDictionary *j = [NSJSONSerialization JSONObjectWithData:d options:0 error:nil];
            if (j && [j[@"status"] isEqualToString:@"success"]) ok = YES;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (ok) {
                [UIView animateWithDuration:0.4 animations:^{ self.alpha = 0; } completion:^(BOOL f) { [self removeFromSuperview]; }];
            } else {
                exit(0);
            }
        });
    }] resume];
}

// Ẩn bàn phím khi ấn Return
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
@end

%ctor {
    // Free Fire cần delay lâu để qua mặt bước check file gốc lúc bắt đầu
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *w = nil;
        // Cách lấy Window an toàn cho Game Engine (Unity/Cocos)
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
            v.layer.zPosition = 9999; // Đè lên menu hack cũ
            [w addSubview:v];
        }
    });
}

