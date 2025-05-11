package dwarf

import "core:fmt"
import "core:os"
import "core:reflect"
import "core:slice"

MAGIC :: []byte{'\n', 'E', 'L', 'F'}

Parse_Elf_Error :: enum {
	None,
	Incorect_Magic,
	Incorrect_Ident_Class,
	Incorrect_Ident_Data_Format,
	Incorrect_Ident_Version,
	Incorrect_Os_Abi,
}

Elf_Class :: enum u8 {
	Unknown = 0,
	Bit32   = 1,
	Bit64   = 2,
}

Os_Abi :: enum u8 {
	Sys_V        = 0,
	Hpux         = 1,
	Netbsd       = 2,
	Linux        = 3,
	Hurd         = 4,
	Ia32_86_Open = 5,
	Solaris      = 6,
	Aix          = 7,
	Irix         = 8,
	Freebsd      = 9,
	Tru64        = 10,
	Modesto      = 11,
	Openbsd      = 12,
	Openvms      = 13,
	Nsk          = 14,
	Aros         = 15,
	Fenixos      = 16,
	Cloud_Abi    = 17,
	Arm          = 97,
	Standalone   = 255,
}

Elf_Version :: enum u32 {
	None,
	Current,
}

Elf_Data_Format :: enum u8 {
	Unknown,
	Le,
	Be,
}

Ident :: struct {
	raw:         [16]byte,
	class:       Elf_Class,
	version:     Elf_Version,
	data:        Elf_Data_Format,
	os_abi:      Os_Abi,
	abi_version: []byte,
}

Elf_Type :: enum u16 {
	None   = 0,
	Rel    = 1,
	Exec   = 2,
	Dyn    = 3,
	Core   = 4,
	Loos   = 0xfe00,
	Hios   = 0xfeff,
	Loproc = 0xff00,
	Hiproc = 0xffff,
}

Elf_Ehdr :: struct {
	ident:     Ident,
	type:      Elf_Type,
	machine:   Elf_Machine,
	version:   Elf_Version,
	entry:     uintptr,
	phoff:     uintptr,
	shoff:     uintptr,
	flags:     u32,
	ehsize:    u16,
	phentsize: u16,
	phnum:     u16,
	shentsize: u16,
	shnum:     u16,
	shstrndx:  u16,
}

ident_init :: proc(ident: ^Ident, bytes: [16]byte) -> Parse_Elf_Error {
	ident.raw = bytes
	ident.abi_version = ident.raw[8:]
	valid_class, valid_format, valid_version, valid_abi: bool
	class := Elf_Class(bytes[4])
	for val in Elf_Class {
		if class == val {
			valid_class = true
			break
		}
	}
	if !valid_class {
		return .Incorrect_Ident_Class
	}

	format := Elf_Data_Format(bytes[5])
	for val in Elf_Data_Format {
		if format == val {
			valid_format = true
			break
		}
	}
	if !valid_format {
		return .Incorrect_Ident_Data_Format
	}

	version := Elf_Version(bytes[6])
	for val in Elf_Version {
		if version == val {
			valid_version = true
			break
		}
	}
	if !valid_version {
		return .Incorrect_Ident_Version
	}

	abi := Os_Abi(bytes[7])
	for val in Os_Abi {
		if abi == val {
			valid_abi = true
			break
		}
	}
	if !valid_abi {
		return .Incorrect_Os_Abi
	}
	ident.class = class
	ident.data = format
	ident.version = version
	ident.os_abi = abi
	return .None
}

parse_elf :: proc(fd: os.Handle) -> Parse_Elf_Error {
	ident: [16]byte
	_, magic_err := os.read(fd, ident[:])
	assert(magic_err == nil)
	if slice.equal(ident[:4], MAGIC) {
		return .Incorect_Magic
	}

	elf_header: Elf_Ehdr
	ident_init_err := ident_init(&elf_header.ident, ident)
	elf_ehdr_bytes: [48]byte
	_, elf_ehdr_read_err := os.read(fd, elf_ehdr_bytes[:])

	elf_header.type = slice.to_type(elf_ehdr_bytes[:2], Elf_Type)
	elf_header.machine = slice.to_type(elf_ehdr_bytes[2:4], Elf_Machine)
	elf_header.version = slice.to_type(elf_ehdr_bytes[4:8], Elf_Version)
	elf_header.entry = slice.to_type(elf_ehdr_bytes[8:16], uintptr)
	elf_header.phoff = slice.to_type(elf_ehdr_bytes[16:24], uintptr)
	elf_header.shoff = slice.to_type(elf_ehdr_bytes[24:32], uintptr)
	elf_header.flags = slice.to_type(elf_ehdr_bytes[32:36], u32)
	elf_header.ehsize = slice.to_type(elf_ehdr_bytes[36:38], u16)
	elf_header.phentsize = slice.to_type(elf_ehdr_bytes[38:40], u16)
	elf_header.phnum = slice.to_type(elf_ehdr_bytes[40:42], u16)
	elf_header.shentsize = slice.to_type(elf_ehdr_bytes[42:44], u16)
	elf_header.shnum = slice.to_type(elf_ehdr_bytes[44:46], u16)
	elf_header.shstrndx = slice.to_type(elf_ehdr_bytes[46:], u16)
	fmt.printfln("%#v", elf_header)

	elf_section_headers := make([]Elf_Section_Header, elf_header.shnum)
	elf_section_headers_bytes := make([]byte, elf_header.shentsize * elf_header.shnum)

	_, elf_section_read_err := os.read_at(fd, elf_section_headers_bytes, cast(i64)elf_header.shoff)

	for i := 0; i < len(elf_section_headers_bytes) / 64; i += 1 {
		offset := i * 64
		elf_section_headers[i].name = slice.to_type(
			elf_section_headers_bytes[offset:offset + 4],
			u32,
		)
	}
	return .None
}

Section_Header_Type :: enum u32 {
	Null          = 0,
	Progbits      = 1,
	Symtab        = 2,
	Strtab        = 3,
	Rela          = 4,
	Hash          = 5,
	Dynamic       = 6,
	Note          = 7,
	Nobits        = 8,
	Rel           = 9,
	Shlib         = 10,
	Dynsym        = 11,
	Init_Array    = 14,
	Fini_Array    = 15,
	Preinit_Array = 16,
	Group         = 17,
	Symtab_Shndx  = 18,
	Loos          = 0x60000000,
	Hios          = 0x6fffffff,
	Loproc        = 0x70000000,
	Hiproc        = 0x7fffffff,
	Louser        = 0x80000000,
	Hiuser        = 0xffffffff,
}

Section_Attribute_Flags :: bit_set[Section_Attribute_Flag;uint]
Section_Attribute_Flag :: enum uint {
	WRITE            = 0,
	ALLOC            = 1,
	EXECINSTR        = 2,
	MERGE            = 4,
	STRINGS          = 5,
	INFO_LINK        = 6,
	LINK_ORDER       = 7,
	OS_NONCONFORMING = 8,
	GROUP            = 9,
	TLS              = 10,

	// All bits included in this mask are reserved for operating system-specific semantics
	MASKOS1          = 20,
	MASKOS2          = 21,
	MASKOS3          = 22,
	MASKOS4          = 23,
	MASKOS5          = 24,
	MASKOS6          = 25,
	MASKOS7          = 26,
	MASKOS8          = 27,

	// All bits included in this mask are reserved for processor-specific semantics. If meanings are specified, the processor supplement explains them
	MASKPROC1        = 28,
	MASKPROC2        = 29,
	MASKPROC3        = 30,
	MASKPROC4        = 31,
}

Elf_Section_Header :: struct {
	name:      u32,
	type:      Section_Header_Type,
	flags:     Section_Attribute_Flags,
	addr:      uintptr,
	offset:    uintptr,
	size:      uintptr,
	link:      u32,
	info:      u32,
	addralign: uintptr,
	entsize:   uintptr,

	//
	i_name:    string,
}
