#import <UIKit/UIKit.h>
#import <substrate.h>
#import <mach-o/dyld.h>
#import <dlfcn.h>
#import <sys/types.h>
#import <objc/runtime.h>

// --- KHAI BÁO HÀM HỆ THỐNG (Sửa lỗi undeclared ptrace) ---
extern "C" int ptrace(int request, pid_t pid, caddr_t addr, int data);

// --- BIẾN ĐIỀU KHIỂN ---
bool isAimbot = false;
bool isEsp = false;
int aimPart = 0; // 0: Đầu, 1: Cổ, 2: Bụng
float aimFov = 90.0f;

#define CYBER_BLUE [UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1.0]

// --- DANH SÁCH GIẤU DYLIB (ANTIBAN) ---
static const char* hidden_list[] = {
    "Vncheat", 
    "Libsqlite3", 
    "EreenTst",
    "CydiaSubstrate"
};

// --- GIAO DIỆN MENU ---
@interface VncheatMenu : UIView
@property (nonatomic, strong) UIView *bg;
@end

@implementation VncheatMenu
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.bg = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,380)];
        self.bg.center = self.center;
        self.bg.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.85];
        self.bg.layer.borderColor = CYBER_BLUE.CGColor;
        self.bg.layer.borderWidth = 2;
        self.bg.layer.cornerRadius = 20;
        [self addSubview:self.bg];

        UILabel *logo = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 320, 45)];
        logo.text = @"Cheating";
        logo.font = [UIFont fontWithName:@"Zapfino" size:18];
        logo.textColor = CYBER_BLUE;
        logo.textAlignment = NSTextAlignmentCenter;
        [self.bg addSubview:logo];

        int y = 70;
        [self addSwitch:@"Kích hoạt Aimbot" y:&y var:&isAimbot];
        
        UISegmentedControl *sc = [[UISegmentedControl alloc] initWithItems:@[@"Đầu", @"Cổ", @"Bụng"]];
        sc.frame = CGRectMake(15, y, 290, 35);
        sc.selectedSegmentIndex = 0;
        [sc addTarget:self action:@selector(changePart:) forControlEvents:UIControlEventValueChanged];
        [self.bg addSubview:sc]; y += 50;

        [self addSwitch:@"Hiện ESP" y:&y var:&isEsp];
    }
    return self;
}

- (void)addSwitch:(NSString *)title y:(int *)y var:(bool *)var {
    UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(15, *y, 200, 30)];
    lb.text = title; lb.textColor = [UIColor whiteColor];
    [self.bg addSubview:lb];
    UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(250, *y, 50, 30)];
    sw.onTintColor = CYBER_BLUE;
    [sw addTarget:self action:@selector(swT:) forControlEvents:UIControlEventValueChanged];
    objc_setAssociatedObject(sw, "var", [NSValue valueWithPointer:var], OBJC_ASSOCIATION_RETAIN);
    [self.bg addSubview:sw]; *y += 45;
}

- (void)swT:(UISwitch *)s { 
    // Sửa lỗi ép kiểu (bool *) ở đây
    bool *v = (bool *)[objc_getAssociatedObject(s, "var") pointerValue]; 
    if (v) *v = s.isOn; 
}
- (void)changePart:(UISegmentedControl *)s { aimPart = (int)s.selectedSegmentIndex; }
@end

// --- HOOK ANTIBAN (Tàng hình) ---
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

%hookf(const char *, _dyld_get_image_name, uint32_t index) {
    const char *name = %orig(index);
    if (name) {
        for (int i = 0; i < 4; i++) {
            if (strstr(name, hidden_list[i])) return "/usr/lib/libobjc.A.dylib";
        }
    }
    return name;
}

%hookf(int, ptrace, int req, pid_t pid, caddr_t addr, int data) {
    if (req == 31) return 0;
    return %orig;
}

// --- GESTURE MỞ MENU ---
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

