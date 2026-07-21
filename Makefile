export ARCHS := arm64 arm64e
export TARGET := iphone:clang:latest:14.0
THEOS_PACKAGE_SCHEME ?= rootless

INSTALL_TARGET_PROCESSES := SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME := BYANOTweak

BYANOTweak_FILES := Tweak.x BYANOMenuViewController.m
BYANOTweak_FRAMEWORKS := UIKit Foundation CoreGraphics
BYANOTweak_CFLAGS := -fobjc-arc -Wall -Wextra -Wno-error -Wno-unused-parameter -Wno-deprecated-declarations
BYANOTweak_LDFLAGS := -Wl,-dead_strip

include $(THEOS_MAKE_PATH)/tweak.mk
