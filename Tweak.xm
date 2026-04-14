#import <UIKit/UIKit.h>
#import <substrate.h>
#import <mach-o/dyld.h>
#import <dlfcn.h>
#import <sys/types.h>
#import <objc/runtime.h>

// --- KHAI BÁO THƯ VIỆN HỆ THỐNG ---
extern "C" int ptrace(int request, pid_t pid, caddr_t addr, int data);

// --- KHAI BÁO INTERFACE (Sửa lỗi property 'view' not found) ---
@interface UnityViewController : UIViewController
- (void)handleVn;
@end

// --- BIẾN ĐIỀU KHIỂN ---
static bool isAimbot = false;
static bool isEsp = false;
static int aimPart = 0; 

#define CYBER_BLUE [UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1.0]

// --- DANH SÁCH GIẤU DYLIB ---
static const char* hidden_list[] = {"Vncheat", "Libsqlite3", "EreenTst", "CydiaSubstrate"};

// --- GIAO DIỆN MENU ---
@interface VncheatMenu : UIView
@property (nonatomic, strong) UIView *bg;
@end

@implementation VncheatMenu
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.bg = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,350)];
        self.bg.center = self.center;
        self.bg.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.9];
        self.bg.layer.borderColor = CYBER_BLUE.CGColor;
        self.bg.layer.borderWidth = 2;
        self.bg.layer.cornerRadius = 20;
        [self addSubview:self.bg];

        UILabel *logo = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 320, 45)];
        logo.text = @"Vncheat Prime";
        logo.textColor = CYBER_BLUE;
        logo.textAlignment = NSTextAlignmentCenter;
        [self.bg addSubview:logo];

        int y = 80;
        [self addSwitch:@"Aimbot" y:&y var:&isAimbot];
        [self addSwitch:@"ESP" y:&y var:&isEsp];
    }
    return self;
}

- (void)addSwitch:(NSString *)title y:(int *)y var:(bool *)var {
    UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(20, *y, 200, 30)];
    lb.text = title; lb.textColor = [UIColor whiteColor];
    [self.bg addSubview:lb];
    
    UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(240, *y, 50, 30)];
    sw.onTintColor = CYBER_BLUE;
    [sw addTarget:self action:@selector(swT:) forControlEvents:UIControlEventValueChanged];
    // Sửa lỗi ép kiểu bool *
    objc_setAssociatedObject(sw, "var", [NSValue valueWithPointer:var], OBJC_ASSOCIATION_RETAIN);
    [self.bg addSubview:sw]; *y += 50;
}

- (void)swT:(UISwitch *)s { 
    bool *v = (bool *)[[objc_getAssociatedObject(s, "var") pointerValue] pointerValue]; 
    if (v) *v = s.isOn; 
}
@end

// --- HOOK CHỐNG QUÉT (ANTIBAN) ---
%hookf(uint32_t, _dyld_get_image_count) {
    uint32_t count = %orig();
    uint32_t hidden = 0;
    for (uint32_t i = 0; i < count; i++) {
        const char* name = _dyld_get_image_name(i);
        if (name) {
            for (int j = 0; j < 4; j++) {
                if (strstr(name, hidden_list[j])) { hidden++; break; }
            }
        }
    }
    return count - hidden;
}

%hookf(int, ptrace, int req, pid_t pid, caddr_t addr, int data) {
    if (req == 31) return 0;
    return %orig;
}

// --- GESTURE & MENU ---
static VncheatMenu *menu;
%hook UnityViewController
- (void)viewDidLoad {
    %orig;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleVn)];
    tap.numberOfTouchesRequired = 3; 
    tap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tap];
}

%new - (void)handleVn {
    if (!menu) {
        menu = [[VncheatMenu alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [[UIApplication sharedApplication].keyWindow addSubview:menu];
    } else {
        menu.hidden = !menu.hidden;
    }
}
%end
