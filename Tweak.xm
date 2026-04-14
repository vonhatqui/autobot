#import <UIKit/UIKit.h>
#import <substrate.h>
#import <mach-o/dyld.h>

// --- BIẾN ĐIỀU KHIỂN ---
bool isAimbot = false;
int aimPart = 0; // 0: Đầu, 1: Cổ, 2: Bụng
float aimFov = 90.0f;
bool isEspLine = false;
bool isEspBox = false;

// --- MÀU SẮC GIAO DIỆN (XANH DƯƠNG CYBER) ---
#define CYBER_BLUE [UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1.0]

@interface VncheatDylibOnly : UIView
@property (nonatomic, strong) UIView *menuView;
@property (nonatomic, strong) UIScrollView *scroll;
@end

@implementation VncheatDylibOnly

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Khung Menu chính
        self.menuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 400)];
        self.menuView.center = self.center;
        self.menuView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.85];
        self.menuView.layer.borderColor = CYBER_BLUE.CGColor;
        self.menuView.layer.borderWidth = 2.0;
        self.menuView.layer.cornerRadius = 15;
        [self addSubview:self.menuView];

        // Chữ ký Logo
        UILabel *logo = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 320, 45)];
        logo.text = @"Cheating";
        logo.font = [UIFont fontWithName:@"Zapfino" size:18];
        logo.textColor = CYBER_BLUE;
        logo.textAlignment = NSTextAlignmentCenter;
        [self.menuView addSubview:logo];

        self.scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 60, 300, 330)];
        [self.menuView addSubview:self.scroll];

        int y = 0;
        [self addLabel:@"--- AIMBOT OB53 ---" y:&y];
        [self addSwitch:@"Kích hoạt Aimbot" y:&y var:&isAimbot];
        
        [self addLabel:@"Vị trí mục tiêu:" y:&y];
        UISegmentedControl *parts = [[UISegmentedControl alloc] initWithItems:@[@"Đầu", @"Cổ", @"Bụng"]];
        parts.frame = CGRectMake(10, y, 280, 35);
        parts.selectedSegmentIndex = 0;
        [parts addTarget:self action:@selector(partChange:) forControlEvents:UIControlEventValueChanged];
        [self.scroll addSubview:parts]; y += 50;

        [self addLabel:@"Phạm vi FOV" y:&y];
        UISlider *fov = [[UISlider alloc] initWithFrame:CGRectMake(10, y, 280, 25)];
        fov.maximumValue = 180; fov.value = 90;
        [fov addTarget:self action:@selector(fovChange:) forControlEvents:UIControlEventValueChanged];
        [self.scroll addSubview:fov]; y += 40;

        [self addLabel:@"--- VISUALS ---" y:&y];
        [self addSwitch:@"ESP Line" y:&y var:&isEspLine];
        [self addSwitch:@"ESP Box" y:&y var:&isEspBox];

        self.scroll.contentSize = CGSizeMake(300, y + 20);
    }
    return self;
}

// Hàm hỗ trợ UI
- (void)addLabel:(NSString *)txt y:(int *)y {
    UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(10, *y, 280, 20)];
    lb.text = txt; lb.textColor = [UIColor grayColor]; lb.font = [UIFont systemFontOfSize:12];
    [self.scroll addSubview:lb]; *y += 25;
}

- (void)addSwitch:(NSString *)title y:(int *)y var:(bool *)var {
    UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(10, *y, 200, 30)];
    lb.text = title; lb.textColor = [UIColor whiteColor];
    [self.scroll addSubview:lb];
    UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(230, *y, 50, 30)];
    sw.onTintColor = CYBER_BLUE;
    [sw addTarget:self action:@selector(swToggled:) forControlEvents:UIControlEventValueChanged];
    objc_setAssociatedObject(sw, "variable", [NSValue valueWithPointer:var], OBJC_ASSOCIATION_RETAIN);
    [self.scroll addSubview:sw]; *y += 45;
}

- (void)swToggled:(UISwitch *)sw {
    bool *v = [objc_getAssociatedObject(sw, "variable") pointerValue];
    *v = sw.isOn;
}
- (void)partChange:(UISegmentedControl *)sc { aimPart = (int)sc.selectedSegmentIndex; }
- (void)fovChange:(UISlider *)sl { aimFov = sl.value; }
@end

// --- ANTIBAN THẾ HỆ MỚI ---
%hookf(int, ptrace, int request, pid_t pid, caddr_t addr, int data) {
    if (request == 31) return 0; // Chặn Anti-Debug
    return %orig;
}

%hookf(uint32_t, _dyld_get_image_count) {
    return %orig() - 1; // Giấu dylib
}

// --- LOGIC HACK (Hook vào Class game) ---
%hook PlayerController
- (void)Update {
    %orig;
    if (isAimbot) {
        // Tự động xử lý Aim theo aimPart (8:Đầu, 7:Cổ, 4:Bụng)
    }
}
%end

// --- KHỞI CHẠY (3 NGÓN CHẠM 2 LẦN) ---
static VncheatDylibOnly *vMenu;
%hook UnityViewController
- (void)viewDidLoad {
    %orig;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleVnMenu)];
    tap.numberOfTouchesRequired = 3;
    tap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tap];
}

%new - (void)toggleVnMenu {
    if (!vMenu) {
        vMenu = [[VncheatDylibOnly alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [[UIApplication sharedApplication].keyWindow addSubview:vMenu];
    } else {
        vMenu.hidden = !vMenu.hidden;
    }
}
%end
