ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:14.0
GO_EASY_ON_ME = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Vncheat
Vncheat_FILES = Tweak.xm
Vncheat_FRAMEWORKS = UIKit Foundation
Vncheat_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-variable

include $(THEOS_MAKE_PATH)/tweak.mk

