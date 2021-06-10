TARGET=test
CC=arm-none-eabi-gcc
CP=arm-none-eabi-objcopy
PWD=$(shell pwd)
WARE=$(patsubst %,-I $(PWD)/ware/%,$(shell ls $(PWD)/ware))
START_SRC=$(shell find . -name startup_stm32f10x_hd.s)
START_OBJ=$(START_SRC:%.s=%.o)
C_SRC=$(shell find . -name '*.c')
C_OBJ=$(C_SRC:%.c=%.o)
CPUFLAGS=-mthumb -mcpu=cortex-m3
INCFLAGS=-I $(PWD)/lib -I $(PWD)/lib/inc $(WARE)
CFLAGS=$(CPUFLAGS) $(INCFLAGS) -D STM32F10X_HD -D USE_STDPERIPH_DRIVER -Wall -g -c -o
LDFLAGS=-T $(PWD)/lib/stm32_flash.ld -Wl,-cref,-u,Reset_Handler -Wl,-Map=$(TARGET).map -Wl,--gc-sections -Wl,--defsym=malloc_getpagesize_P=0x80 -Wl,--start-group -lc -lm -Wl,--end-group -0

$(TARGET).hex:$(TARGET).elf
	$(CP) $^ -Oihex $@
$(TARGET).elf:$(START_OBJ) $(C_OBJ)
	$(CC) $^ $(LDFLAGS) $@
$(START_OBJ):$(START_SRC)
	$(CC) $^ $(CFLAGS) $@
$(C_OBJ):%.o:%.c
	$(CC) $^ $(CFLAGS) $@

.PHONY: hex bin clean flash
hex:
	$(CP) $(TARGET).elf -Oihex $(TARGET).hex
bin:
	$(CP) $(TARGET).elf $(TARGET).bin
flash:
	st-flash --format ihex write $(TARGET).hex
clean:
	rm -f $(shell find . -name '*.o') $(TARGET).*
