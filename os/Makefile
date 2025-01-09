# Building
TARGET := riscv64gc-unknown-none-elf
MODE := release
KERNEL_ELF := target/$(TARGET)/$(MODE)/os
KERNEL_BIN := $(KERNEL_ELF).bin
DISASM_TMP := target/$(TARGET)/$(MODE)/asm

# Building mode argument
ifeq ($(MODE), release)
	MODE_ARG := --release
endif

# BOARD
BOARD := qemu
SBI ?= rustsbi
BOOTLOADER := ../bootloader/$(SBI)-$(BOARD).bin

# KERNEL ENTRY
KERNEL_ENTRY_PA := 0x80200000

# Binutils
OBJDUMP := rust-objdump --arch-name=riscv64
OBJCOPY := rust-objcopy --binary-architecture=riscv64

# Disassembly
DISASM ?= -x

build: env $(KERNEL_BIN)

# 检查 RISC-V 目标是否已安装，若未安装则使用rustup添加
env:
	(rustup target list | grep "riscv64gc-unknown-none-elf (installed)") || rustup target add $(TARGET)
	cargo install cargo-binutils
	rustup component add rust-src
	rustup component add llvm-tools-preview

# @的作用：该命令不会被打印出来，只打印执行结果
$(KERNEL_BIN): kernel
	@$(OBJCOPY) $(KERNEL_ELF) --strip-all -O binary $@

kernel:
	@echo Platform: $(BOARD)
	@cp src/linker-$(BOARD).ld src/linker.ld
	@cargo build $(MODE_ARG)
	@rm src/linker.ld

clean:
	@cargo clean

# 对内核ELF文件进行反汇编，并通过less分页查看
disasm: kernel
	@$(OBJDUMP) $(DISASM) $(KERNEL_ELF) | less

# 对内核ELF文件进行反汇编，并通过vim查看
disasm-vim: kernel
	@$(OBJDUMP) $(DISASM) $(KERNEL_ELF) > $(DISASM_TMP)
	@vim $(DISASM_TMP)
	@rm $(DISASM_TMP)

run: run-inner

QEMU_ARGS := -machine virt \
			 -nographic \
			 -bios $(BOOTLOADER) \
			 -device loader,file=$(KERNEL_BIN),addr=$(KERNEL_ENTRY_PA)

QEMU_NAME := qemu-system-riscv64

# 检查 QEMU 版本是否符合要求
qemu-version-check:
	@sh scripts/qemu-ver-check.sh $(QEMU_NAME)

# 先检查 QEMU 版本，再使用指定参数启动 QEMU 加载内核运行
run-inner: qemu-version-check build
	@qemu-system-riscv64 $(QEMU_ARGS)

# 利用tmux创建会话，在一个窗口启动 QEMU 等待 GDB 连接，另一个窗口启动 GDB 连接到 QEMU 进行调试
debug: qemu-version-check build
	@tmux new-session -d \
		"qemu-system-riscv64 $(QEMU_ARGS) -s -S" && \
		tmux split-window -h "riscv64-unknown-elf-gdb -ex 'file $(KERNEL_ELF)' -ex 'set arch riscv:rv64' -ex 'target remote localhost:1234'" && \
		tmux -2 attach-session -d

#启动 QEMU和gdb-server等待客户端连接
gdbserver: qemu-version-check build
	@qemu-system-riscv64 $(QEMU_ARGS) -s -S

# 启动gdb-client连接到QEMU
gdbclient:
	@riscv64-unknown-elf-gdb -ex 'file $(KERNEL_ELF)' -ex 'set arch riscv:rv64' -ex 'target remote localhost:1234'

.PHONY: build env kernel clean disasm disasm-vim run-inner gdbserver gdbclient qemu-version-check
