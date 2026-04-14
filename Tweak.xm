#import <UIKit/UIKit.h>
#import <substrate.h>
#import <mach-o/dyld.h>
#import <string.h>

// --- DANH SÁCH "ĐỐI TƯỢNG" CẦN BẢO VỆ ---
// Đại ca muốn giấu file nào thì điền tên (không cần đuôi .dylib) vào đây
static const char* targets[] = {
    "Libsqlite3", 
    "CoreAnalytics",
    "EreenTst",
    "CydiaSubstrate", // Giấu luôn cả thư viện hỗ trợ cho chắc
    "Sideloadly"
};

// 1. Hook đếm số lượng image (dylib) - Làm game không thấy file lạ
%hookf(uint32_t, _dyld_get_image_count) {
    uint32_t count = %orig();
    uint32_t hidden = 0;
    for (uint32_t i = 0; i < count; i++) {
        const char* name = _dyld_get_image_name(i);
        for (int j = 0; j < 4; j++) {
            if (name && strstr(name, targets[j])) {
                hidden++;
            }
        }
    }
    return count - hidden;
}

// 2. Hook lấy tên image - Đổi tên file hack thành file hệ thống
%hookf(const char *, _dyld_get_image_name, uint32_t index) {
    const char *name = %orig(index);
    if (name) {
        for (int i = 0; i < 4; i++) {
            if (strstr(name, targets[i])) {
                // Đánh lừa game đây là file hệ thống CoreFoundation
                return "/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation";
            }
        }
    }
    return name;
}

// 3. Chặn game quét file trực tiếp (Anti-Directory Scan)
%hookf(int, access, const char *path, int mode) {
    if (path) {
        for (int i = 0; i < 4; i++) {
            if (strstr(path, targets[i])) return -1;
        }
    }
    return %orig(path, mode);
}

// 4. Chặn Anti-Debug (Phòng trường hợp game tự crash khi thấy hack)
%hookf(int, ptrace, int request, pid_t pid, caddr_t addr, int data) {
    if (request == 31) return 0; 
    return %orig;
}

%ctor {
    // Vệ sĩ đã lên đồ
    NSLog(@"[Antiban] Security Guard Active!");
}

