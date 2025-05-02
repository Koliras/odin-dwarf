package dwarf

import "core:fmt"
import "core:os"
import "core:slice"

Section_Attribute_Flags :: bit_set[Section_Attribute_Flag;uint]
Section_Attribute_Flag :: enum {
	WRITE            = 1,
	ALLOC            = 2,
	EXECINSTR        = 3,
	MERGE            = 5,
	STRINGS          = 6,
	INFO_LINK        = 7,
	LINK_ORDER       = 8,
	OS_NONCONFORMING = 9,
	GROUP            = 10,
	TLS              = 11,
	MASKOS1          = 21,
	MASKOS2          = 22,
	MASKOS3          = 23,
	MASKOS4          = 24,
	MASKOS5          = 25,
	MASKOS6          = 26,
	MASKOS7          = 27,
	MASKOS8          = 28,
	MASKPROC1        = 29,
	MASKPROC2        = 30,
	MASKPROC3        = 31,
	MASKPROC4        = 32,
}

Section_Type :: enum u32 {
	NULL          = 0,
	PROGBITS      = 1,
	SYMTAB        = 2,
	STRTAB        = 3,
	RELA          = 4,
	HASH          = 5,
	DYNAMIC       = 6,
	NOTE          = 7,
	NOBITS        = 8,
	REL           = 9,
	SHLIB         = 10,
	DYNSYM        = 11,
	INIT_ARRAY    = 14,
	FINI_ARRAY    = 15,
	PREINIT_ARRAY = 16,
	GROUP         = 17,
	SYMTAB_SHNDX  = 18,
	LOOS          = 0x60000000,
	HIOS          = 0x6fffffff,
	LOPROC        = 0x70000000,
	HIPROC        = 0x7fffffff,
	LOUSER        = 0x80000000,
	HIUSER        = 0xffffffff,
}

Elf_Section_Header :: struct {
	name:      u32,
	type:      Section_Type,
	flags:     Section_Attribute_Flags,
	addr:      uintptr,
	offset:    uintptr,
	size:      uintptr,
	link:      u32,
	info:      u32,
	addralign: uintptr,
	entsize:   uintptr,
}

main :: proc() {
	filepath := "./test_program/cloop"
	if len(os.args) > 1 {
		filepath = os.args[1]
	}
	program, file_err := os.open(filepath)
	assert(file_err == nil)
	magic := [4]byte{0x7f, 'E', 'L', 'F'}
	file_start: [16]byte
	amount_read, start_read_err := os.read(program, file_start[:])
	if slice.equal(file_start[:4], magic[:]) {
		fmt.panicf("Not an elf file")
	}
}
