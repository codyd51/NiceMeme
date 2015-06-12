ARCHS = armv7 arm64
GO_EASY_ON_ME=1
include theos/makefiles/common.mk

TWEAK_NAME = NiceMeme
NiceMeme_FILES = Listener.xm
NiceMeme_LIBRARIES = activator
NiceMeme_FRAMEWORKS = UIKit
NiceMeme_FRAMEWORKS += CoreGraphics
NiceMeme_FRAMEWORKS += QuartzCore

NiceMeme_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
