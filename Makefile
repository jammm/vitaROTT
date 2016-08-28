#TARGET = rott
TARGET = rott-sw
HOMEBREW_C_SRCS := $(wildcard src/*.c)
HOMEBREW_CPP_SRCS := $(wildcard src/*.cpp)
HOMEBREW_OBJS = $(patsubst src/%,bin/%,$(HOMEBREW_C_SRCS:.c=.o)) $(patsubst src/%,bin/%,$(HOMEBREW_CPP_SRCS:.cpp=.o))

PREFIX = arm-vita-eabi
CC = $(PREFIX)-gcc
CCP = $(PREFIX)-g++
CFLAGS = -Wall -fno-exceptions -Ofast -DPSP2 -mcpu=cortex-a9 -mthumb -mfpu=neon
CPPFLAGS = $(CFLAGS)
#CFLAGS = $(DEFAULT_CFLAGS) $(MORE_CFLAGS)  -G0 -Wall -fno-exceptions  -fsingle-precision-constant -mno-check-zero-division  -funsafe-math-optimizations -fpeel-loops -ffast-math  -fno-exceptions
#CXXFLAGS = $(DEFAULT_CFLAGS) $(MORE_CFLAGS) -fno-exceptions
#MORE_CFLAGS =  -O3

all: $(TITLE)

TEST_OUTPUT = bin/*.S out/$(TITLE).elf out/$(TITLE).velf bin/*.o lib/*.a lib/*.o lib/*.S # lib/Makefile
LIBS = -lSceTouch_stub -lSceDisplay_stub -lSceGxm_stub -lSceCtrl_stub -lSceRtc_stub -lScePower_stub -lSceSysmodule_stub -lSceCommonDialog_stub
#LIBS =   -lSDL_mixer -lvorbisidec $(shell $(SDL_CONFIG) --libs)   -lpsppower -lpspaudiolib -lpspaudio -lpsputility

debug: CFLAGS += -DDEBUG

debugnet: CFLAGS += -DUSE_DEBUGNET
debugnet: LIBS := -ldebugnet -lSceNet_stub -lSceNetCtl_stub $(LIBS)
debugnet: all

.PHONY: $(TITLE)
$(TITLE): out/$(TITLE).elf
	vita-elf-create out/$(TITLE).elf out/$(TITLE).velf
	vita-make-fself out/$(TITLE).velf out/eboot.bin
	
out/$(TITLE).elf: $(HOMEBREW_OBJS)
	mkdir -p out
	$(CC) -Wl,-q $(LDFLAGS) $(HOMEBREW_OBJS) -lvita2d -lm $(LIBS) -o $@
	
bin/%.o: src/%.c
	mkdir -p bin
	$(CC) $(CFLAGS) -c $< -o $@

bin/%.o: src/%.cpp
	mkdir -p bin
	$(CCP) $(CFLAGS) -c $< -o $@


#INCDIR = /usr/local/pspdev/psp/include/libtimidity
#DEFAULT_CFLAGS = $(shell $(SDL_CONFIG) --cflags) -DUSE_SDL=1    -DPLATFORM_UNIX   -DSHAREWARE=0
#DEFAULT_CFLAGS = $(shell $(SDL_CONFIG) --cflags) -DUSE_SDL=1    -DPLATFORM_UNIX   -DSHAREWARE=1
#EXTRA_TARGETS = EBOOT.PBP
#include $(PSPSDK)/lib/build.mak

clean:
	rm -f $(ALL_OBJS:.o=.d) $(TARGETS) $(TEST_OUTPUT)

rebuild: clean
rebuild: all
