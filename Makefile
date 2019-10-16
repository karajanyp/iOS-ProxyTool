ARCHS=arm64 armv7 armv7s

TARGET=iphone::7.1

ADDITIONAL_OBJCFLAGS = -fobjc-arc

THEOS_DEVICE_IP=192.168.1.108

include theos/makefiles/common.mk

TOOL_NAME = proxytool

proxytool_FILES = main.mm WiFiProxy.m

proxytool_FRAMEWORKS = Foundation SystemConfiguration

proxytool_LDFLAGS = -undefined dynamic_lookup

include $(THEOS_MAKE_PATH)/tool.mk

before-package::
	ldid -S./Ent.plist $(THEOS_STAGING_DIR)/usr/bin/$(TOOL_NAME);
