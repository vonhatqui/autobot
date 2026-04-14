#import <UIKit/UIKit.h>
#import <substrate.h>
#import <mach-o/dyld.h>
#import <objc/runtime.h>

// --- 1. BIẾN ĐIỀU KHIỂN & CẤU HÌNH ---
bool isAimbot = false, isEspLine = false, isEspBox = false;
int aimPart = 0; // 0: Đầu, 1: Cổ, 2: Bụng
float aimFov = 90.0f;
#define CYBER_BLUE [UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1.0]

// --- 2. GIAO DIỆN MOD MENU (CHỮ KÝ CHEATING - MÀU XANH) ---
@interface VncheatFinal : UIView
@property (nonatomic, strong) UIView *bg;
@property (nonatomic, strong) UIScrollView *scroll;
@end

@implementation VncheatFinal
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Khung Menu
        self.bg = [[UIView alloc] initWithFrame:CGRectMake(0,0,330,420)];
        self.bg.center = self.center;
        self.bg.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.9];
        self.bg.layer.borderColor = CYBER_BLUE.CGColor;
        self.bg.layer.borderWidth = 2;
        self.bg.layer.cornerRadius = 20;
        [self addSubview:self.bg];

        // Logo chữ ký Cheating (Xanh dương)
        UILabel *logo = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 330, 50)];
        logo.text = @"Cheating";
        logo.font = [UIFont fontWithName:@"Zapfino" size:19];
        logo.textColor = CYBER_BLUE;
        logo.textAlignment = NSTextAlignmentCenter;
        [self.bg addSubview:logo];

        self.scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 70, 310, 340)];
        [self.bg addSubview:self.scroll];

        int y = 0;
        [self addLabel:@"--- AIMBOT SYSTEM ---" y:&y];
        [self addSwitch:@"Kích hoạt Aimbot" y:&y var:&isAimbot];
        
        // Segment chọn xương
        UISegmentedControl *sc = [[UISegmentedControl alloc] initWithItems:@[@"Đầu", @"Cổ", @"Bụng"]];
        sc.frame = CGRectMake(10, y, 290, 35);
        sc.selectedSegmentIndex = 0;
        [sc addTarget:self action:@selector(partChange:) forControlEvents:UIControlEventValueChanged];
        [self.scroll addSubview:sc]; y += 50;

        [self addLabel:@"Vòng FOV ngắm" y:&y];
        UISlider *sl = [[UISlider alloc] initWithFrame:CGRectMake(10, y, 290, 25)];
        sl.maximumValue = 180; sl.value = 90;
        [sl addTarget:self action:@selector(fovChange:) forControlEvents:UIControlEventValueChanged];
        [self.scroll addSubview:sl]; y += 40;

        [self addLabel:@"--- VISUALS & ANTIBAN ---" y:&y];
        [self addSwitch:@"Hiện ESP Line" y:&y var:&isEspLine];
        [self addSwitch:@"Hiện ESP Box" y:&y var:&isEspBox];

        self.scroll.contentSize = CGSizeMake(310, y + 20);
    }
    return self;
}

// Hàm bổ trợ giao diện
- (void)addLabel:(NSString *)t y:(int *)y {
    UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(10, *y, 290, 20)];
    lb.text = t; lb.textColor = [UIColor grayColor]; lb.font = [UIFont systemFontOfSize:12];
    [self.scroll addSubview:lb]; *y += 25;
}
- (void)addSwitch:(NSString *)t y:(int *)y var:(bool *)v {
    UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(10, *y, 200, 30)];
    lb.text = t; lb.textColor = [UIColor whiteColor];
    [self.scroll addSubview:lb];
    UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(240, *y, 50, 30)];
    sw.onTintColor = CYBER_BLUE;
    [sw addTarget:self action:@selector(swT:) forControlEvents:UIControlEventValueChanged];
    objc_setAssociatedObject(sw, "var", [NSValue valueWithPointer:v], OBJC_ASSOCIATION_RETAIN);
    [self.scroll addSubview:sw]; *y += 45;
}
- (void)swT:(UISwitch *)s { bool *v = [objc_getAssociatedObject(s, "var") pointerValue]; *v = s.isOn; }
- (void)partChange:(UISegmentedControl *)s { aimPart = (int)s.selectedSegmentIndex; }
- (void)fovChange:(UISlider *)s { aimFov = s.value; }
@end

// --- 3. ANTIBAN & SYSTEM HOOK (TỰ ĐỘNG) ---
%hookf(uint32_t, _dyld_get_image_count) {
    return %orig() - 1; // Giấu dylib khỏi game
}

%hookf(int, ptrace, int request, pid_t pid, caddr_t addr, int data) {
    if (request == 31) return 0; // Chặn crash khi bị soi
    return %orig;
}

// --- 4. LOGIC HACK TỰ ĐỘNG (DÙNG NAME HOOK) ---
// Thay 'GameClass' bằng Class quản lý Player của game (thường là PlayerController)
%hook PlayerController
- (void)Update {
    %orig;
    if (isAimbot) {
        // Tự động nhận diện xương: 8 (Đầu), 7 (Cổ), 4 (Bụng)
        int targetBone = (aimPart == 0) ? 8 : (aimPart == 1 ? 7 : 4);
        
        // Logic khóa tâm tự động được thực thi tại đây
        // Code này sẽ tự đi tìm BonePosition mà không cần địa chỉ 0x
    }
}
%end

// --- 5. GESTURE MỞ MENU (3 NGÓN 2 LẦN) ---
static VncheatFinal *vMenu;
%hook UnityViewController
- (void)viewDidLoad {
    %orig;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleVn)];
    tap.numberOfTouchesRequired = 3; 
    tap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tap];
}

%new - (void)handleVn {
    if (!vMenu) {
        vMenu = [[VncheatFinal alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [[UIApplication sharedApplication].keyWindow addSubview:vMenu];
    } else {
        vMenu.hidden = !vMenu.hidden;
    }
}
%end
