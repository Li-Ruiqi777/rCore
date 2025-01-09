    .section .text.entry
    .globl _start
_start:
    la sp, boot_stack_top  # 设置sp指针
    call rust_main         # 跳转到rust_main函数

    .section .bss.stack
    .globl boot_stack_lower_bound

# 分配栈空间
boot_stack_lower_bound:
    .space 4096 * 16
    .globl boot_stack_top
boot_stack_top: