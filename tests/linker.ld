OUTPUT_ARCH( "riscv" )
ENTRY( _start )

MEMORY {
    ram : ORIGIN = 0x00000000, LENGTH = 0x4000
}

SECTIONS
{
    .text :
    {
        *(.text)
    } > ram

    .rodata :
    {
        *(.rodata)
    } > ram

    .data :
    {
        *(.data)
        *(.sdata)
    } > ram

    .bss :
    {
        *(.bss)
        *(COMMON)
    } > ram
}
