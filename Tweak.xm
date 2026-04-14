#import <UIKit/UIKit.h>
#import <substrate.h>
#import <mach-o/dyld.h>
#import <string.h>

// --- DANH SÁCH MỤC TIÊU CẦN GIẤU ---
static const char* hidden_list[] = {
    "Libsqlite3", 
    "EreenTst",
    "CydiaSubstrate",
    "Sideloadly",
    "Shadow" // Thêm Shadow để né các app check dylib
};

// Hàm đếm số lượng mục tiêu trong danh sách
static inline int get_hidden_count() {
    return sizeof(hidden_list) / sizeof(char*);
}

// 1. Hook đếm dylib - Làm "bay màu" file lạ khỏi danh sách đếm của game
%hookf(uint32_t, _dyld_get_image_count) {
    uint32_t original_count = %orig();
    uint32_t hidden_found = 0;
    
    for (uint32_t i = 0; i < original_count; i++) {
        const char* name = _dyld_get_image_name(i);
        if (name) {
            for (int j = 0; j < get_hidden_count(); j++) {
                if (strstr(name, hidden_list[j])) {
                    hidden_found++;
                    break;
                }
            }
        }
    }
    return original_count - hidden_found;
}

// 2. Hook lấy tên dylib - Đổi danh tính file hack thành file hệ thống
%hookf(const char *, _dyld_get_image_name, uint32_t image_index) {
    const char *original_name = %orig(image_index);
    if (original_name) {
        for (int i = 0; i < get_hidden_count(); i++) {
            if (strstr(original_name, hidden_list[i])) {
                // Trả về một framework hệ thống cực kỳ an toàn
                return "/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation";
            }
        }
    }
    return original_name;
}

// 3. Chặn game quét file thủ công (access & stat)
%hookf(int, access, const char *path, int mode) {
    if (path) {
        for (int i = 0; i < get_hidden_count(); i++) {
            if (strstr(path, hidden_list[i])) return -1; // Báo "File không tồn tại"
        }
    }
    return %orig(path, mode);
}

// 4. Chặn lệnh Anti-Debug của game
%hookf(int, ptrace, int request, pid_t pid, caddr_t addr, int data) {
    if (request == 31) return 0; // Chặn PT_DENY_ATTACH
    return %orig(request, pid, addr, data);
}

%ctor {
    // Khởi động hệ thống tàng hình
    NSLog(@"[CoreAnalytics] Shield System Activated!");
}
