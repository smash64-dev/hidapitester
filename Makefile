#
# Makefile for 'hidapitester'
# 2019 Tod E. Kurt, todbot.com
#

# overide this with something like `HIDAPI_DIR=../hidapi-libusb make`
HIDAPI_DIR ?= ../hidapi
LIB_DIR ?= .libs

# try to do some autodetecting
UNAME ?= $(shell uname -s)
ARCH ?= $(shell uname -m)

ifeq "$(UNAME)" "Darwin"
	OS=macos
endif
ifeq "$(UNAME)" "Windows_NT"
	OS=windows
endif
ifeq "$(OS)" "Windows_NT"
	OS=windows
endif
ifeq "$(UNAME)" "Linux"
	OS=linux
endif

# deal with stupid Windows not having 'cc'
ifeq (default,$(origin CC))
  CC = gcc
endif


#############  Mac
ifeq "$(OS)" "macos"

CFLAGS+=-arch x86_64 -arch arm64
LIBS=-framework IOKit -framework CoreFoundation -framework AppKit
DYNLIBS = -L$(HIDAPI_DIR)/mac/$(LIB_DIR) -lhidapi
OBJS=$(HIDAPI_DIR)/mac/hid.o
EXE=

endif

############# Windows
ifeq "$(OS)" "windows"

LIBS += -lsetupapi -Wl,--enable-auto-import -static-libgcc -static-libstdc++
DYNLIBS = -L$(HIDAPI_DIR)/windows/$(LIB_DIR) -lhidapi
OBJS = $(HIDAPI_DIR)/windows/hid.o
EXE=.exe

endif

############ Linux (hidraw)
ifeq "$(OS)" "linux"

LIBS = `pkg-config libudev --libs`
DYNLIBS = -L$(HIDAPI_DIR)/linux/$(LIB_DIR) -lhidapi-hidraw
OBJS = $(HIDAPI_DIR)/linux/hid.o
EXE=

endif

############ Dynamic (hidraw)
ifeq "$(LINK)" "dynamic"

LIBS += $(DYNLIBS)
OBJS =

endif

############# common

CFLAGS+=-I $(HIDAPI_DIR)/hidapi
OBJS += hidapitester.o

all: hidapitester

$(OBJS): %.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@


hidapitester: $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o hidapitester$(EXE) $(LIBS)

clean:
	rm -f $(OBJS)
	rm -f hidapitester$(EXE)

package: hidapitester$(EXE)
	@echo "Packaging up hidapitester for '$(OS)-$(ARCH)'"
	zip hidapitester-$(OS)-$(ARCH).zip hidapitester$(EXE)
