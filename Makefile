# (C)2004-2008 SourceMod Development Team
# Makefile written by David "BAILOPAN" Anderson

SMSDK = ../sourcemod
HL2SDK_ORIG = ../../hl2sdk
HL2SDK_OB = ../../hl2sdk-ob
HL2SDK_CSS = ../../hl2sdk-css
HL2SDK_OB_VALVE = ../../hl2sdk-ob-valve
HL2SDK_L4D = ../../hl2sdk-l4d
HL2SDK_L4D2 = ../../hl2sdk-l4d2
HL2SDK_CSGO = ../hl2sdk-csgo
MMSOURCE17 = ../mmsource

#####################################
### EDIT BELOW FOR OTHER PROJECTS ###
#####################################

PROJECT = cleaner

#Uncomment for Metamod: Source enabled extension
USEMETA = false

OBJECTS = smsdk_ext.cpp extension.cpp CDetour/detours.cpp asm/asm.c

##############################################
### CONFIGURE ANY OTHER FLAGS/OPTIONS HERE ###
##############################################

C_OPT_FLAGS = -DNDEBUG -O3 -funroll-loops -pipe -fno-strict-aliasing
C_DEBUG_FLAGS = -D_DEBUG -DDEBUG -g -ggdb3
C_GCC4_FLAGS = -fvisibility=hidden
CPP_GCC4_FLAGS = -fvisibility-inlines-hidden
CPP = gcc

override ENGSET = false
ifeq "$(ENGINE)" "original"
	HL2SDK = $(HL2SDK_ORIG)
	HL2PUB = $(HL2SDK)/public
	HL2LIB = $(HL2SDK)/linux_sdk
	CFLAGS += -DSOURCE_ENGINE=1
	METAMOD = $(MMSOURCE17)/core-legacy
	INCLUDE += -I$(HL2SDK)/public/dlls -I$(HL2SDK)/game_shared
	GAMEFIX = 1.ep1
	override ENGSET = true
endif
ifeq "$(ENGINE)" "orangebox"
	HL2SDK = $(HL2SDK_OB)
	HL2PUB = $(HL2SDK)/public
	HL2LIB = $(HL2SDK)/lib/linux
	CFLAGS += -DSOURCE_ENGINE=3
	METAMOD = $(MMSOURCE17)/core
	INCLUDE += -I$(HL2SDK)/public/game/server -I$(HL2SDK)/common -I$(HL2SDK)/game/shared -I$(HL2SDK)/public/toolframework
	GAMEFIX = 2.ep2
	override ENGSET = true
endif
ifeq "$(ENGINE)" "orangeboxvalve"
	HL2SDK = $(HL2SDK_OB_VALVE)
	HL2PUB = $(HL2SDK)/public
	HL2LIB = $(HL2SDK)/lib/linux
	CFLAGS += -DSOURCE_ENGINE=6
	METAMOD = $(MMSOURCE17)/core
	INCLUDE += -I$(HL2SDK)/public/game/server -I$(HL2SDK)/common -I$(HL2SDK)/game/shared -I$(HL2SDK)/public/toolframework
	GAMEFIX = 2.ep2v
	override ENGSET = true
endif
ifeq "$(ENGINE)" "css"
	HL2SDK = $(HL2SDK_CSS)
	HL2PUB = $(HL2SDK)/public
	HL2LIB = $(HL2SDK)/lib/linux
	CFLAGS += -DSOURCE_ENGINE=6
	METAMOD = $(MMSOURCE17)/core
	INCLUDE += -I$(HL2SDK)/public/game/server -I$(HL2SDK)/common -I$(HL2SDK)/game/shared -I$(HL2SDK)/public/toolframework
	GAMEFIX = 2.css
	override ENGSET = true
endif
ifeq "$(ENGINE)" "left4dead"
	HL2SDK = $(HL2SDK_L4D)
	HL2PUB = $(HL2SDK)/public
	HL2LIB = $(HL2SDK)/lib/linux
	CFLAGS += -DSOURCE_ENGINE=11
	METAMOD = $(MMSOURCE17)/core
	INCLUDE += -I$(HL2SDK)/public/game/server -I$(HL2SDK)/common -I$(HL2SDK)/game/shared -I$(HL2SDK)/public/toolframework
	GAMEFIX = 2.l4d
	override ENGSET = true
endif
ifeq "$(ENGINE)" "left4dead2"
	HL2SDK = $(HL2SDK_L4D2)
	HL2PUB = $(HL2SDK)/public
	HL2LIB = $(HL2SDK)/lib/linux
	CFLAGS += -DSOURCE_ENGINE=13
	METAMOD = $(MMSOURCE17)/core
	INCLUDE += -I$(HL2SDK)/public/game/server -I$(HL2SDK)/common -I$(HL2SDK)/game/shared -I$(HL2SDK)/public/toolframework
	GAMEFIX = 2.l4d2
	override ENGSET = true
endif
ifeq "$(ENGINE)" "csgo"
	HL2SDK = $(HL2SDK_CSGO)
	HL2PUB = $(HL2SDK)/public
	HL2LIB = $(HL2SDK)/lib/linux
	CFLAGS += -DSOURCE_ENGINE=18
	METAMOD = $(MMSOURCE17)/core
	INCLUDE += -I$(HL2SDK)/public/game/server -I$(HL2SDK)/common -I$(HL2SDK)/game/shared -I$(HL2SDK)/public/toolframework
	GAMEFIX = 2.csgo
	override ENGSET = true
endif

ifeq ($(ENGINE),$(filter $(ENGINE), css left4dead2 orangeboxvalve))
	LINK_HL2 = $(HL2LIB)/tier1_i486.a $(HL2LIB)/mathlib_i486.a libvstdlib_srv.so libtier0_srv.so
else
	LINK_HL2 = $(HL2LIB)/tier1_i486.a $(HL2LIB)/mathlib_i486.a libvstdlib.so libtier0.so
endif

ifeq "$(ENGINE)" "csgo"
	LINK_HL2 += $(HL2LIB)/interfaces_i486.a
endif

LINK += $(LINK_HL2)

INCLUDE += -I. -I.. -Isdk -I$(HL2PUB) -I$(HL2PUB)/engine -I$(HL2PUB)/mathlib -I$(HL2PUB)/tier0 \
	-I$(HL2PUB)/tier1 -I$(METAMOD) -I$(METAMOD)/sourcehook -I$(SMSDK)/public -I$(SMSDK)/public/extensions \
	-I$(SMSDK)/sourcepawn/include

CFLAGS += -DSE_EPISODEONE=1 -DSE_DARKMESSIAH=2 -DSE_ORANGEBOX=3 -DSE_BLOODYGOODTIME=4 -DSE_EYE=5 \
		-DSE_CSS=6 -DSE_HL2DM=7 -DSE_DODS=8 -DSE_SDK2013=9 -DSE_TF2=10 -DSE_LEFT4DEAD=11 -DSE_NUCLEARDAWN=12 \
		-DSE_LEFT4DEAD2=13 -DSE_ALIENSWARM=14 -DSE_PORTAL2=15 -DSE_BLADE=16 -DSE_INSURGENCY=17 \
		-DSE_CSGO=18 -DSE_DOTA=19

LINK += -m32 -ldl -lm

CFLAGS += -D_LINUX -DPOSIX -Dstricmp=strcasecmp -D_stricmp=strcasecmp -D_strnicmp=strncasecmp -Dstrnicmp=strncasecmp \
	-D_snprintf=snprintf -D_vsnprintf=vsnprintf -D_alloca=alloca -Dstrcmpi=strcasecmp -DCOMPILER_GCC \
	-Wno-switch -Wall -Werror -Wno-uninitialized -Wno-invalid-offsetof -Wno-unused -Wno-unused-result -mfpmath=sse -msse -DSOURCEMOD_BUILD -DHAVE_STDINT_H -m32
CPPFLAGS += -Wno-non-virtual-dtor -fno-exceptions -fno-rtti -fno-threadsafe-statics -std=c++11 

################################################
### DO NOT EDIT BELOW HERE FOR MOST PROJECTS ###
################################################

ifeq "$(DEBUG)" "true"
	BIN_DIR = Debug
	CFLAGS += $(C_DEBUG_FLAGS)
else
	BIN_DIR = Release
	CFLAGS += $(C_OPT_FLAGS)
endif

ifeq "$(USEMETA)" "true"
	BIN_DIR := $(BIN_DIR).$(ENGINE)
endif

OS := $(shell uname -s)
ifeq "$(OS)" "Darwin"
	LINK += -dynamiclib
	BINARY = $(PROJECT).ext.$(GAMEFIX).dylib
else
	LINK += -static-libgcc -shared
	BINARY = $(PROJECT).ext.$(GAMEFIX).so
endif

GCC_VERSION := $(shell $(CPP) -dumpversion >&1 | cut -b1)
ifeq "$(GCC_VERSION)" "4"
	CFLAGS += $(C_GCC4_FLAGS)
	CPPFLAGS += $(CPP_GCC4_FLAGS)
endif

OBJ_LINUX := $(OBJECTS:%.cpp=$(BIN_DIR)/%.o)

$(BIN_DIR)/%.o: %.cpp
	$(CPP) $(INCLUDE) $(CFLAGS) $(CPPFLAGS) -o $@ -c $<

all: check
	ln -sf $(SMSDK)/public/smsdk_ext.cpp
	mkdir -p $(BIN_DIR)/sdk
	mkdir -p $(BIN_DIR)/CDetour
	mkdir -p $(BIN_DIR)/asm
ifeq ($(ENGINE),$(filter $(ENGINE), css left4dead2 orangeboxvalve))
	ln -sf $(HL2LIB)/libvstdlib_srv.so libvstdlib_srv.so;
	ln -sf $(HL2LIB)/libtier0_srv.so libtier0_srv.so;
else
	ln -sf $(HL2LIB)/vstdlib_i486.so vstdlib_i486.so;
	ln -sf $(HL2LIB)/tier0_i486.so tier0_i486.so;
endif
	$(MAKE) -f Makefile extension

check:
	if [ "$(USEMETA)" = "true" ] && [ "$(ENGSET)" = "false" ]; then \
		echo "You must supply ENGINE=left4dead or ENGINE=orangebox or ENGINE=original"; \
		exit 1; \
	fi

extension: check $(OBJ_LINUX)
	$(CPP) $(INCLUDE) $(OBJ_LINUX) $(LINK) -o $(BIN_DIR)/$(BINARY)

debug:
	$(MAKE) -f Makefile all DEBUG=true

default: all

clean: check
	rm -rf $(BIN_DIR)/*.o
	rm -rf $(BIN_DIR)/sdk/*.o
	rm -rf $(BIN_DIR)/CDetour/*.o
	rm -rf $(BIN_DIR)/asm/*.o
	rm -rf $(BIN_DIR)/$(BINARY)
