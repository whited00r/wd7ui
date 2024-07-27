THEOS_DEVICE_IP = 192.168.1.18

GO_EASY_ON_ME = 1

include theos/makefiles/common.mk

TWEAK_NAME = WD7UI
WD7UI_FILES = Tweak.xm UICustomSwitch.m UIImage+StackBlur.m
WD7UI_FRAMEWORKS = UIKit CoreGraphics Foundation QuartzCore

include $(THEOS_MAKE_PATH)/tweak.mk
