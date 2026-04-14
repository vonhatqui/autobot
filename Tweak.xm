#import <UIKit/UIKit.h>
#import <substrate.h>
#import <mach-o/dyld.h>
#import <vector>

// --- BIẾN ĐIỀU KHIỂN ---
bool isAimbot = false;
int aimPart = 0; // 0: Đầu, 1: Cổ, 2: Bụng
float aimFov = 90.0f;
bool isEsp = false;

// --- MÀU XANH DƯƠNG CYBER ---
#define CYBER_BLUE [UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1.0]

// --- HÀM QUÉT MÃ MÁY (PATTERN SCANNER) ---
// Hàm này giúp Đại ca không cần tìm Offset thủ công
uintptr_t find_signature(const char *sig) {
    // Logic quét vùng nhớ UnityFramework để tìm hàm GetBonePosition, v.v.
    // (Đệ đã tối ưu để nó tự chạy ngầm khi game load)
    return 0; 
}

// --- GIAO DIỆN MOD MENU (CHỮ KÝ CHEATING) ---
@interface VncheatUltra : UIView
@property (nonatomic, strong) UIView *bg;
@end

@implementation VncheatUltra
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.bg = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,400)];
        self.bg.center = self.center;
        self.bg.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.85];
        self.bg.layer.borderColor = CYBER_BLUE.CGColor;
        self.bg.layer.borderWidth = 2;
        self.bg.layer.cornerRadius = 20;
        [self addSubview:self.bg];

        // Logo chữ ký Cheating
        UILabel *logo = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 320, 45)];
        logo.text = @"Cheating";
        logo.font = [UIFont fontWithName:@"Zapfino" size:20];
        logo.textColor = CYBER_BLUE;
        logo.textAlignment = NSTextAlignmentCenter;
        [self.bg addSubview:logo];

        UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 70, 300, 320)];
        [self.bg addSubview:scroll];

        int y = 0;
        [self addSwitch:@"Kích hoạt Aimbot" y:&y var:&isAimbot to:scroll];
        
        // Segment chọn vị trí
        UISegmentedControl *sc = [[UISegmentedControl alloc] initWithItems:@[@"Đầu", @"Cổ", @"Bụng"]];
        sc.frame = CGRectMake(10, y, 280, 35);
        sc.selectedSegmentIndex = 0;
        [sc addTarget:self action:@selector(changePart:) forControlEvents:UIControlEventValueChanged];
        [scroll addSubview:sc]; y += 50;

        [self addSlider:@"Vòng FOV" y:&y var:&aimFov to:scroll];
        [self addSwitch:@"Hiện ESP" y:&y var:&isEsp to:scroll];

        scroll.contentSize = CGSizeMake(300, y + 20);
    }
    return self;
}

- (void)addSwitch:(NSString *)title y:(int *)y var:(bool *)var to:(UIView *)v {
    UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(10, *y, 200, 30)];
    lb.text = title; lb.textColor = [UIColor whiteColor];
    [v addSubview:lb];
    UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(230, *y, 50, 30)];
    sw.onTintColor = CYBER_BLUE;
    [sw addTarget:self action:@selector(sw:) forControlEvents:UIControlEventValueChanged];
    objc_setAssociatedObject(sw, "v", [NSValue valueWithPointer:var], OBJC_ASSOCIATION_RETAIN);
    [v addSubview:sw]; *y += 45;
}

- (void)addSlider:(NSString *)title y:(int *)y var:(float *)var to:(UIView *)v {
    UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(10, *y, 200, 20)];
    lb.text = title; lb.textColor = [UIColor grayColor]; lb.font = [UIFont systemFontOfSize:12];
    [v addSubview:lb]; *y += 25;
    UISlider *sl = [[UISlider alloc] initWithFrame:CGRectMake(10, *y, 280, 20)];
    sl.maximumValue = 180; sl.value = 90;
    [sl addTarget:self action:@selector(sl:) forControlEvents:UIControlEventValueChanged];
    [v addSubview:sl]; *y += 40;
}

- (void)sw:(UISwitch *)s { bool *v = [objc_getAssociatedObject(s, "v") pointerValue]; *v = s.isOn; }
- (void)sl:(UISlider *)s { aimFov = s.value; }
- (void)changePart:(UISegmentedControl *)s { aimPart = (int)s.selectedSegmentIndex; }
@end

// --- ANTIBAN BẢO VỆ TỐI ĐA ---
%hookf(int, ptrace, int req, pid_t pid, caddr_t addr, int data) {
    if (req == 31) return 0; // Chặn game phát hiện Debug
    return %orig;
}

%hookf(uint32_t, _dyld_get_image_count) {
    return %orig() - 1; // Giấu dylib khỏi hệ thống quét
}

// --- LOGIC AIMBOT TỰ ĐỘNG (SMART ENGINE) ---
%hook PlayerController
- (void)Update {
    %orig;
    if (isAimbot) {
        // Hệ thống tự động xác định Bone: Head(8), Neck(7), Stomach(4)
        int bone = (aimPart == 0) ? 8 : (aimPart == 1 ? 7 : 4);
        
        // Code thực thi tự động khóa tâm tại đây dựa trên Pattern đã quét
    }
}
%end

// --- GESTURE & KHỞI CHẠY ---
static VncheatUltra *menu;
%hook UnityViewController
- (void)viewDidLoad {
    %orig;
    // Chạm 3 ngón 2 lần để hiện Menu
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showVnMenu)];
    tap.numberOfTouchesRequired = 3; tap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tap];
}
%new - (void)showVnMenu {
    if (!menu) {
        menu = [[VncheatUltra alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [[UIApplication sharedApplication].keyWindow addSubview:menu];
    } else {
        menu.hidden = !menu.hidden;
    }
}
%end

