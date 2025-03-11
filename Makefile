# Define the compiler and flags
CC = arm-none-eabi-gcc
OBJCOPY = arm-none-eabi-objcopy
SIZE = arm-none-eabi-size
CFLAGS = -mcpu=cortex-m3 -mthumb -g -O0

# Define OpenOCD configs
OPENOCD = openocd
OPENOCD_INTERFACE = interface/stlink.cfg
OPENOCD_TARGET = target/stm32f1x.cfg

# Define the source files and include directories
SRCS = src/main.c src/system_stm32f1xx.c src/stm32f1xx_hal_gpio.c src/stm32f1xx_hal_rcc.c src/stm32f1xx_hal.c src/stm32f1xx_hal_cortex.c src/syscalls.c startup_stm32f103xb.s
INCLUDES = -I inc

# Define the output files
OUTPUT = build/output
LDSCRIPT = STM32F103C8Tx_FLASH.ld

# Define the libraries
LIBS = -lc -lm -lnosys

# Define additional flags
LDFLAGS = -specs=nano.specs -specs=nosys.specs

# Define the build targets
all: $(OUTPUT).elf $(OUTPUT).hex $(OUTPUT).bin size

# Define the rule to build the ELF file
$(OUTPUT).elf: $(SRCS)
	$(CC) $(CFLAGS) $(LDFLAGS) -T $(LDSCRIPT) -o $@ $^ $(INCLUDES) -Wl,--start-group $(LIBS) -Wl,--end-group

# Define rules to build HEX and BIN files
$(OUTPUT).hex: $(OUTPUT).elf
	$(OBJCOPY) -O ihex $< $@

$(OUTPUT).bin: $(OUTPUT).elf
	$(OBJCOPY) -O binary $< $@

# Show size information
size: $(OUTPUT).elf
	$(SIZE) $<

# Flash the device
flash:
	$(OPENOCD) -f $(OPENOCD_INTERFACE) -f $(OPENOCD_TARGET) -c "program $(OUTPUT).elf verify reset exit"

# Start OpenOCD debug server
debug-server:
	$(OPENOCD) -f $(OPENOCD_INTERFACE) -f $(OPENOCD_TARGET)

# Reset the device
reset:
	$(OPENOCD) -f $(OPENOCD_INTERFACE) -f $(OPENOCD_TARGET) -c "init" -c "reset" -c "exit"

# Clean target
clean:
	del /Q build\output.elf build\output.hex build\output.bin

.PHONY: all size clean flash debug-server reset
