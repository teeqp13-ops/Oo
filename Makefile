export ARCHS = arm64 arm64e
export TARGET = iphone:clang:latest:14.0

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = BYANOTweak

BYANOTweak_FILES = Tweak.x BYANOMenuViewController.m
BYANOTweak_FRAMEWORKS = UIKit Foundation CoreGraphics
BYANOTweak_LDFLAGS = -L./ -lBYANO

include $(THEOS_MAKE_PATH)/tweak.mk
