#
#
#
#

HIDAPI_DIR=../hidapi-libusb

# try to do some autodetecting
UNAME := $(shell uname -s)

ifeq "$(UNAME)" "Darwin"
	OS=macosx
endif

ifeq "$(OS)" "Windows_NT"
	OS=windows
endif

ifeq "$(UNAME)" "Linux"
	OS=linux
endif


#############  Mac
ifeq "$(OS)" "macosx"

LIBS=-framework IOKit -framework CoreFoundation
OBJS=$(HIDAPI_DIR)/mac/hid.o 
EXE=

endif

############# Windows
ifeq "$(OS)" "windows"

LIBS += -lsetupapi -Wl,--enable-auto-import -static-libgcc -static-libstdc++
OBJS = $(HIDAPI_DIR)/windows/hid.o
EXE=.exe

endif

############ Linux
ifeq "$(OS)" "linux"

LIBS = 
OBJS = ./hidapi/linux/hid.o
EXE=

endif


############# common

CFLAGS=-I $(HIDAPI_DIR)/hidapi
OBJS += hidapitester.o

all: hidapitester

$(OBJS): %.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@


hidapitester: $(OBJS) 
	$(CC) $(CFLAGS) $(LIBS) $(OBJS) -o hidapitester$(EXE) 

clean:
	rm -f $(OBJS)
	rm -f hidapitester$(EXE)
