package dwarf

import "core:bytes"
import "core:encoding/varint"
import "core:fmt"
import "core:io"
import os "core:os/os2"
import "core:reflect"
import "core:slice"
import "core:strings"

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

parse_elf :: proc(fd: ^os.File) -> Parse_Elf_Error {
	ident: [16]byte
	_, magic_err := os.read(fd, ident[:])
	assert(magic_err == nil)
	if slice.equal(ident[:4], MAGIC) {
		return .Incorect_Magic
	}

	// Start getting Elf_Ehdr
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
	// End getting Elf_Ehdr

	// Start getting elf section headers
	elf_section_headers := make([]Elf_Section_Header, elf_header.shnum)
	elf_section_headers_bytes := make([]byte, elf_header.shentsize * elf_header.shnum)

	_, elf_section_read_err := os.read_at(fd, elf_section_headers_bytes, cast(i64)elf_header.shoff)

	sections_amount := len(elf_section_headers_bytes) / 64
	for i := 0; i < sections_amount; i += 1 {
		offset := i * 64
		elf_section_headers[i].name_offset = slice.to_type(
			elf_section_headers_bytes[offset:offset + 4],
			u32,
		)
		offset += size_of(u32)
		elf_section_headers[i].type = slice.to_type(
			elf_section_headers_bytes[offset:offset + size_of(Section_Header_Type)],
			Section_Header_Type,
		)
		offset += size_of(Section_Header_Type)
		elf_section_headers[i].flags = slice.to_type(
			elf_section_headers_bytes[offset:offset + size_of(Section_Attribute_Flags)],
			Section_Attribute_Flags,
		)
		offset += size_of(Section_Attribute_Flags)
		elf_section_headers[i].addr = slice.to_type(
			elf_section_headers_bytes[offset:offset + size_of(uintptr)],
			uintptr,
		)
		offset += size_of(uintptr)
		elf_section_headers[i].offset = slice.to_type(
			elf_section_headers_bytes[offset:offset + size_of(uintptr)],
			uintptr,
		)
		offset += size_of(uintptr)
		elf_section_headers[i].size = slice.to_type(
			elf_section_headers_bytes[offset:offset + size_of(uintptr)],
			uintptr,
		)
		offset += size_of(uintptr)
		elf_section_headers[i].link = slice.to_type(
			elf_section_headers_bytes[offset:offset + size_of(u32)],
			u32,
		)
		offset += size_of(u32)
		elf_section_headers[i].info = slice.to_type(
			elf_section_headers_bytes[offset:offset + size_of(u32)],
			u32,
		)
		offset += size_of(u32)
		elf_section_headers[i].addralign = slice.to_type(
			elf_section_headers_bytes[offset:offset + size_of(uintptr)],
			uintptr,
		)
		offset += size_of(uintptr)
		elf_section_headers[i].entsize = slice.to_type(
			elf_section_headers_bytes[offset:offset + size_of(uintptr)],
			uintptr,
		)
	}
	// Finish getting elf section headers basic data

	// Start getting elf section headers names
	names_section := elf_section_headers[elf_header.shstrndx]
	names_buf := make([]byte, names_section.size)
	_, names_section_read_err := os.read_at(fd, names_buf, cast(i64)names_section.offset)
	name_builder := strings.builder_make_len_cap(0, 20)
	ds: Dwarf_Sections
	dynamic_header: ^Elf_Section_Header
	for &header in elf_section_headers {
		for i := header.name_offset;; i += 1 {
			ch := names_buf[i]
			if ch == 0 {
				break
			}
			strings.write_byte(&name_builder, ch)
		}
		header.name = strings.clone_from_bytes(name_builder.buf[:])
		dwarf_sections_get_from_elf_header(&ds, &header, fd)
		if header.name == ".dynamic" {
			dynamic_header = &header
		}
		strings.builder_reset(&name_builder)
	}
	// Finish getting elf section headers names
	// Finish getting all elf section headers data

	// Start determining if elf file is pie(position independent executable)
	dynamic_buf := make([]byte, dynamic_header.size)
	os.read_at(fd, dynamic_buf, cast(i64)dynamic_header.offset)
	pie: bool
	for i := 0; i < len(dynamic_buf) / 8; i += 2 {
		off := i * 8
		if off + 16 > len(dynamic_buf) {
			break
		}

		tag := slice.to_type(dynamic_buf[off:off + 8], uintptr)
		val := slice.to_type(dynamic_buf[off + 8:off + 16], uintptr)

		if tag == 0x6fff_fffb { 	// DT_FLAGS_1
			if val & 0x0800_0000 > 0 { 	// DF_1_PIE
				pie = true
				break
			}
		}
	}
	// Finish determining if elf file is pie

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
	name_offset: u32,
	type:        Section_Header_Type,
	flags:       Section_Attribute_Flags,
	addr:        uintptr,
	offset:      uintptr,
	size:        uintptr,
	link:        u32,
	info:        u32,
	addralign:   uintptr,
	entsize:     uintptr,

	// text name received from dynamic header using `name_offset`
	name:        string,
}

Dwarf_Sections :: struct {
	abbrev:      []byte,
	line:        []byte,
	info:        []byte,
	addr:        []byte,
	aranges:     []byte,
	frame:       []byte,
	eh_frame:    []byte,
	line_str:    []byte,
	loc:         []byte,
	loclists:    []byte,
	names:       []byte,
	macinfo:     []byte,
	macro:       []byte,
	pubnames:    []byte,
	pubtypes:    []byte,
	ranges:      []byte,
	rnglists:    []byte,
	str:         []byte,
	str_offsets: []byte,
	types:       []byte,
}

dwarf_sections_delete :: proc(ds: ^Dwarf_Sections) {
	delete(ds.abbrev)
	delete(ds.line)
	delete(ds.info)
	delete(ds.addr)
	delete(ds.aranges)
	delete(ds.frame)
	delete(ds.eh_frame)
	delete(ds.line_str)
	delete(ds.loc)
	delete(ds.loclists)
	delete(ds.names)
	delete(ds.macinfo)
	delete(ds.macro)
	delete(ds.pubnames)
	delete(ds.pubtypes)
	delete(ds.ranges)
	delete(ds.rnglists)
	delete(ds.str)
	delete(ds.str_offsets)
	delete(ds.types)
}

dwarf_sections_get_from_elf_header :: proc(
	ds: ^Dwarf_Sections,
	header: ^Elf_Section_Header,
	fd: ^os.File,
) {
	buf := make([]byte, header.size)
	os.read_at(fd, buf, cast(i64)header.offset)

	switch header.name {
	case ".debug_abbrev":
		ds.abbrev = buf
	case ".debug_line":
		ds.line = buf
	case ".debug_info":
		ds.info = buf
	case ".debug_addr":
		ds.addr = buf
	case ".debug_aranges":
		ds.aranges = buf
	case ".debug_frame":
		ds.frame = buf
	case ".eh_frame":
		ds.eh_frame = buf
	case ".debug_line_str":
		ds.line_str = buf
	case ".debug_loc":
		ds.loc = buf
	case ".debug_loclists":
		ds.loclists = buf
	case ".debug_names":
		ds.names = buf
	case ".debug_macinfo":
		ds.macinfo = buf
	case ".debug_macro":
		ds.macro = buf
	case ".debug_pubnames":
		ds.pubnames = buf
	case ".debug_pubtypes":
		ds.pubtypes = buf
	case ".debug_ranges":
		ds.ranges = buf
	case ".debug_rnglists":
		ds.rnglists = buf
	case ".debug_str":
		ds.str = buf
	case ".debug_str_offsets":
		ds.str_offsets = buf
	case ".debug_types":
		ds.types = buf
	}
}

Abbrev_Table :: struct {
	offset: int,
	decls:  map[u64]Abbrev_Decl,
}

Abbrev_Decl :: struct {
	code:         u64,
	tag:          u64,
	has_children: u8,
	attributes:   [dynamic]Abbrev_Attribute,
}

Abbrev_Attribute :: struct {
	name:               u64,
	form:               u64,
	implicit_const_val: i64,
}


_decode_uleb_buffer :: #force_inline proc(
	buf: ^bytes.Buffer,
) -> (
	val: u128,
	size: int,
	err: varint.Error,
) {
	val, size, err = varint.decode_uleb128_buffer(buf.buf[buf.off:])
	buf.off += size
	return
}

_decode_ileb_buffer :: #force_inline proc(
	buf: ^bytes.Buffer,
) -> (
	val: i128,
	size: int,
	err: varint.Error,
) {
	val, size, err = varint.decode_ileb128_buffer(buf.buf[buf.off:])
	buf.off += size
	return
}

abbrev_section_to_abbrev_tables :: proc(abbrev_section: []byte) -> [dynamic]Abbrev_Table {
	buf: bytes.Buffer
	bytes.buffer_init(&buf, abbrev_section)
	tables := make([dynamic]Abbrev_Table, 0, 10)

	for !bytes.buffer_is_empty(&buf) {
		table: Abbrev_Table = {
			offset = buf.off,
			decls  = make(map[u64]Abbrev_Decl),
		}
		for {
			decl: Abbrev_Decl = {
				attributes = make([dynamic]Abbrev_Attribute, 0, 10),
			}
			code_val, code_bytes_read, uleb_code_err := _decode_uleb_buffer(&buf)
			decl.code = cast(u64)code_val
			if decl.code == 0 {
				break // finished this decl
			}
			tag_val, tag_bytes_read, uleb_tag_err := _decode_uleb_buffer(&buf)
			decl.tag = cast(u64)tag_val
			read_err: io.Error
			decl.has_children, read_err = bytes.buffer_read_byte(&buf)

			for {
				attr: Abbrev_Attribute
				name_val, name_bytes_read, uleb_name_err := _decode_uleb_buffer(&buf)
				attr.name = cast(u64)name_val
				form_val, form_bytes_read, uleb_form_err := _decode_uleb_buffer(&buf)
				attr.form = cast(u64)form_val

				if attr.form | attr.name == 0 {
					break
				}

				if attr.form == 0x21 { 	// DW_FORM_implicit_const
					const_val, const_bytes_read, ileb_const_err := _decode_ileb_buffer(&buf)
					attr.implicit_const_val = cast(i64)const_val
				}

				append(&decl.attributes, attr)
			}

			table.decls[decl.code] = decl
		}
		append(&tables, table)
	}
	return tables
}
