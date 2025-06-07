package dwarf

import "core:bytes"
import "core:encoding/varint"
import "core:fmt"
import "core:io"
import "core:mem"
import os "core:os/os2"
import "core:reflect"
import "core:slice"
import "core:strings"

MAGIC :: []byte{'\n', 'E', 'L', 'F'}

vari: int = ---
Parse_Elf_Error :: enum {
	None,
	Incorrect_Magic,
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
		return .Incorrect_Magic
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
	defer delete(elf_section_headers_bytes)

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
	ds: Sections
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
		sections_get_from_elf_header(&ds, &header, fd)
		if header.name == ".dynamic" {
			dynamic_header = &header
		}
		strings.builder_reset(&name_builder)
	}
	strings.builder_destroy(&name_builder)
	delete(names_buf)
	// Finish getting elf section headers names
	// Finish getting all elf section headers data

	// Start determining if elf file is pie(position independent executable)
	dynamic_buf := make([]byte, dynamic_header.size)
	os.read_at(fd, dynamic_buf, cast(i64)dynamic_header.offset)
	pie: bool
	for i := 0; i < len(dynamic_buf) / 8; i += 2 {
		off := i * 8
		if off + 16 >= len(dynamic_buf) {
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
	delete(dynamic_buf)
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

Sections :: struct {
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

sections_delete :: proc(ds: ^Sections) {
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

sections_get_from_elf_header :: proc(ds: ^Sections, header: ^Elf_Section_Header, fd: ^os.File) {
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
	offset:  int,
	abbrevs: map[u64]Abbrev,
}

Abbrev :: struct {
	code:         u64,
	tag:          Tag,
	has_children: u8,
	attributes:   [dynamic]Attribute,
}

Attribute :: struct {
	name:               Attribute_Name,
	form:               Attribute_Form,
	implicit_const_val: i64,
}

Attribute_Form :: enum u64 {
	Addr           = 0x01,
	Block2         = 0x03,
	Block4         = 0x04,
	Data2          = 0x05,
	Data4          = 0x06,
	Data8          = 0x07,
	String         = 0x08,
	Block          = 0x09,
	Block1         = 0x0a,
	Data1          = 0x0b,
	Flag           = 0x0c,
	Sdata          = 0x0d,
	Strp           = 0x0e,
	Udata          = 0x0f,
	Ref_Addr       = 0x10,
	Ref1           = 0x11,
	Ref2           = 0x12,
	Ref4           = 0x13,
	Ref8           = 0x14,
	Ref_Udata      = 0x15,
	Indirect       = 0x16,
	Sec_Offset     = 0x17,
	Exprloc        = 0x18,
	Flag_Present   = 0x19,
	Strx           = 0x1a,
	Addrx          = 0x1b,
	Ref_Sup4       = 0x1c,
	Strp_Sup       = 0x1d,
	Data16         = 0x1e,
	Line_Strp      = 0x1f,
	Ref_Sig8       = 0x20,
	Implicit_Const = 0x21,
	Loclistx       = 0x22,
	Rnglistx       = 0x23,
	Ref_Sup8       = 0x24,
	Strx1          = 0x25,
	Strx2          = 0x26,
	Strx3          = 0x27,
	Strx4          = 0x28,
	Addrx1         = 0x29,
	Addrx2         = 0x2a,
	Addrx3         = 0x2b,
	Addrx4         = 0x2c,
}


_decode_uleb_buffer :: #force_inline proc(
	buf: ^bytes.Buffer,
) -> (
	val: u64,
	size: int,
	err: varint.Error,
) {
	val_128: u128
	val_128, size, err = varint.decode_uleb128_buffer(buf.buf[buf.off:])
	val = cast(u64)val_128
	buf.off += size
	return
}

_decode_ileb_buffer :: #force_inline proc(
	buf: ^bytes.Buffer,
) -> (
	val: i64,
	size: int,
	err: varint.Error,
) {
	val_128: i128
	val_128, size, err = varint.decode_ileb128_buffer(buf.buf[buf.off:])
	val = cast(i64)val_128
	buf.off += size
	return
}

abbrev_section_to_abbrev_tables :: proc(abbrev_section: []byte) -> [dynamic]Abbrev_Table {
	buf: bytes.Buffer
	bytes.buffer_init(&buf, abbrev_section)
	defer bytes.buffer_destroy(&buf)
	tables := make([dynamic]Abbrev_Table, 0, 10)

	for !bytes.buffer_is_empty(&buf) {
		table: Abbrev_Table = {
			offset  = buf.off,
			abbrevs = make(map[u64]Abbrev),
		}
		for {
			decl: Abbrev = {
				attributes = make([dynamic]Attribute, 0, 10),
			}
			code_val, code_bytes_read, uleb_code_err := _decode_uleb_buffer(&buf)
			decl.code = code_val
			if decl.code == 0 {
				break // finished this decl
			}
			tag_val, tag_bytes_read, uleb_tag_err := _decode_uleb_buffer(&buf)
			decl.tag = cast(Tag)tag_val
			read_err: io.Error
			decl.has_children, read_err = bytes.buffer_read_byte(&buf)

			for {
				attr: Attribute
				name_val, name_bytes_read, uleb_name_err := _decode_uleb_buffer(&buf)
				attr.name = cast(Attribute_Name)name_val
				form_val, form_bytes_read, uleb_form_err := _decode_uleb_buffer(&buf)
				attr.form = cast(Attribute_Form)form_val

				if attr.form == nil && attr.name == nil {
					break
				}

				if attr.form == .Implicit_Const { 	// DW_FORM_implicit_const
					const_val, const_bytes_read, ileb_const_err := _decode_ileb_buffer(&buf)
					attr.implicit_const_val = const_val
				}

				append(&decl.attributes, attr)
			}

			table.abbrevs[decl.code] = decl
		}
		append(&tables, table)
	}
	return tables
}

// Compilation unit
CU :: struct {
	header:    ^CU_Header,
	dies:      [dynamic]DIE,
	addr_base: u64,
}

CU_Header :: struct {
	length:              uint,
	version:             u16,
	unit_type:           Unit_Header_Type,
	addr_size:           u8,
	debug_abbrev_offset: u64,

	// not part of dwarf but useful
	is_32:               bool,
}

Unit_Header_Type :: enum u8 {
	None          = 0x00, // in case of DWARF version < 5
	Compile       = 0x01,
	Type          = 0x02,
	Partial       = 0x03,
	Skeleton      = 0x04,
	Split_Compile = 0x05,
	Split_Type    = 0x06,
	Lo_User       = 0x80,
	Hi_User       = 0xff,
}

// Debugging information entry
DIE :: struct {
	offset: int,
	depth:  int,
	tag:    Tag,
	forms:  [dynamic]Form,
}

Form :: struct {
	data:  Form_Data,
	class: Form_Class,
}

Form_Data :: union #no_nil {
	u8,
	u16,
	u32,
	u64,
	i64,
	[]byte,
	string,
	uintptr,
}

Form_Class :: enum {
	Address,
	Addrptr,
	Block,
	Constant,
	Exprloc,
	Flag,
	Lineptr,
	Loclist,
	Loclistsptr,
	Macptr,
	Rnglist,
	Rnglistsptr,
	Reference,
	String,
	Stroffsetsptr,
}

compilation_unit_from_bytes :: proc(
	info_section: []byte,
	abbrev_tables: []Abbrev_Table,
	sections: ^Sections,
) -> [dynamic]CU {
	cus := make([dynamic]CU, 0, 10)
	buf: bytes.Buffer
	bytes.buffer_init(&buf, info_section)
	for {
		if bytes.buffer_is_empty(&buf) {
			break
		}
		cu_header := compilation_unit_header_from_buf(&buf)

		abbrev_table := &abbrev_tables[0]
		debug_abbrev_offset := cast(int)cu_header.debug_abbrev_offset
		for &table in abbrev_tables {
			if table.offset == debug_abbrev_offset {
				abbrev_table = &table
				break
			}
		}

		cu := compilation_unit_parse(&buf, &cu_header, sections, abbrev_table)
		append(&cus, cu)
	}
	return cus
}

compilation_unit_header_from_buf :: proc(buf: ^bytes.Buffer) -> (cuh: CU_Header) {
	off := 0

	cuh_bytes: [24]byte
	bytes.buffer_read(buf, cuh_bytes[:])
	len_32 := slice.to_type(cuh_bytes[:4], u32)
	if len_32 != 0xffffffff {
		cuh.is_32 = true
		cuh.length = cast(uint)len_32
		off += 4
	} else {
		len_64 := slice.to_type(cuh_bytes[4:12], u64)
		cuh.length = cast(uint)len_64
		off += 12
	}

	cuh.version = slice.to_type(cuh_bytes[off:off + 2], u16)
	off += 2

	if cuh.version >= 5 {
		// unit_type appeared only in DWARF 5
		cuh.unit_type = slice.to_type(cuh_bytes[off:off + 1], Unit_Header_Type)
		off += 1

		cuh.addr_size = slice.to_type(cuh_bytes[off:off + 1], u8)
		off += 1
		if cuh.is_32 {
			cuh.debug_abbrev_offset = cast(u64)slice.to_type(cuh_bytes[off:off + 4], u32)
			off += 4
		} else {
			cuh.debug_abbrev_offset = slice.to_type(cuh_bytes[off:off + 8], u64)
			off += 8
		}
	} else {
		if cuh.is_32 {
			cuh.debug_abbrev_offset = cast(u64)slice.to_type(cuh_bytes[off:off + 4], u32)
			off += 4
		} else {
			cuh.debug_abbrev_offset = slice.to_type(cuh_bytes[off:off + 8], u64)
			off += 8
		}
		cuh.addr_size = slice.to_type(cuh_bytes[off:off + 1], u8)
		off += 1
	}
	buf.off -= (24 - off) // normalize offset since we could have read more bytes than needed

	return cuh
}

compilation_unit_parse :: proc(
	buf: ^bytes.Buffer,
	cu_header: ^CU_Header,
	sections: ^Sections,
	abbrev: ^Abbrev_Table,
) -> CU {
	dies := make([dynamic]DIE)
	die_tree_depth := 0
	for {
		abbrev_code, _, _ := _decode_uleb_buffer(buf)
		if abbrev_code == 0 {
			if die_tree_depth == 1 {
				break
			}
			die_tree_depth -= 1
			continue
		}

		abbrev := &abbrev.abbrevs[abbrev_code]
		die := DIE {
			offset = buf.off,
			depth  = die_tree_depth,
			tag    = abbrev.tag,
			forms  = make([dynamic]Form),
		}

		addr_base := 0
		for &a in abbrev.attributes {
			if a.name == .Addr_Base {
				break
			}
		}

		for &attr in abbrev.attributes {
			form := choose_form_advance_buf(buf, cu_header, sections, &attr)
			append(&die.forms, form)
		}

		append(&dies, die)
		if abbrev.has_children == 1 {
			die_tree_depth += 1
		}
	}
	return {header = cu_header, dies = dies}
}

choose_form_advance_buf :: proc(
	buf: ^bytes.Buffer,
	cu_header: ^CU_Header,
	sections: ^Sections,
	attr: ^Attribute,
) -> Form {
	form: Form

	switch attr.form {
	// constants
	case .Data1:
		form.data, _ = bytes.buffer_read_byte(buf)
		form.class = .Constant
	case .Data2:
		val := make([]byte, 2)
		bytes.buffer_read(buf, val[:])
		form.data = val
		form.class = .Constant
	case .Data4:
		val := make([]byte, 4)
		bytes.buffer_read(buf, val[:])
		form.data = val
		form.class = .Constant
	case .Data8:
		val := make([]byte, 8)
		bytes.buffer_read(buf, val[:])
		form.data = val
		form.class = .Constant
	case .Data16:
		data_bytes := make([]byte, 16)
		bytes.buffer_read(buf, data_bytes[:])
		form.data = data_bytes
		form.class = .Constant
	case .Sdata:
		form.data, _, _ = _decode_ileb_buffer(buf)
		form.class = .Constant
	case .Udata:
		form.data, _, _ = _decode_uleb_buffer(buf)
		form.class = .Constant
	// implicit const
	case .Implicit_Const:
		form.data = attr.implicit_const_val
		form.class = .Constant
	// address
	case .Addr:
		val: [8]byte
		bytes.buffer_read(buf, val[:])
		form.data = slice.to_type(val[:], uintptr)
		form.class = .Address
	case .Addrx:
		form.data, _, _ = _decode_uleb_buffer(buf)
		form.class = .Address
	case .Addrx1:
		form.data, _ = bytes.buffer_read_byte(buf)
		form.class = .Address
	case .Addrx2:
		val: [2]byte
		bytes.buffer_read(buf, val[:])
		form.data = slice.to_type(val[:], u16)
	case .Addrx3:
		val_bytes: [3]byte
		bytes.buffer_read(buf, val_bytes[:])
		val: u32
		// todo: handle different endiannes
		mem.copy(&val, raw_data(val_bytes[:]), 3)
		form.data = val
	case .Addrx4:
		val: [4]byte
		bytes.buffer_read(buf, val[:])
		form.data = slice.to_type(val[:], u32)
	// references
	case .Ref_Addr:
		form.data = _read_offset(buf, cu_header.is_32)
		form.class = .Reference
	case .Ref1:
		form.data, _ = bytes.buffer_read_byte(buf)
		form.class = .Reference
	case .Ref2:
		val: [2]byte
		bytes.buffer_read(buf, val[:])
		form.data = slice.to_type(val[:], u16)
		form.class = .Reference
	case .Ref4:
		val: [4]byte
		bytes.buffer_read(buf, val[:])
		form.data = slice.to_type(val[:], u32)
		form.class = .Reference
	case .Ref8:
		val: [8]byte
		bytes.buffer_read(buf, val[:])
		form.data = slice.to_type(val[:], u64)
		form.class = .Reference
	case .Ref_Udata:
		form.data, _, _ = _decode_uleb_buffer(buf)
		form.class = .Reference
	// flags
	case .Flag:
		form.data, _ = bytes.buffer_read_byte(buf)
		form.class = .Flag
	case .Flag_Present:
		form.data = []byte{1}
		form.class = .Flag
	case .String:
		form.data = buffer_cstring_to_string(buf)
		form.class = .String
	case .Strp:
		off := _read_offset(buf, cu_header.is_32)
		str_section := sections.str[off:]
		str_buf: bytes.Buffer
		bytes.buffer_init(&str_buf, str_section[:])
		defer bytes.buffer_destroy(&str_buf)
		form.data = buffer_cstring_to_string(&str_buf)
		form.class = .String
	case .Line_Strp:
		off := _read_offset(buf, cu_header.is_32)
		str_section := sections.line_str[off:]
		str_buf: bytes.Buffer
		bytes.buffer_init(&str_buf, str_section[:])
		defer bytes.buffer_destroy(&str_buf)
		form.data = buffer_cstring_to_string(&str_buf)
		form.class = .String
	// dwarf expression
	case .Exprloc:
		length, _, _ := _decode_uleb_buffer(buf)
		expr_buf := make([]byte, length)
		bytes.buffer_read(buf, expr_buf)
		form.data = expr_buf
		form.class = .Exprloc
	// addrptr, lineptr, loclist, macptr, loclistsptr, rnglist, rnglistsptr, stroffsetsptr
	case .Sec_Offset:
		form.data = _read_offset(buf, cu_header.is_32)
		#partial switch attr.name {
		case .Addr_Base:
			form.class = .Addrptr
		case .Stmt_List:
			form.class = .Lineptr
		case .Location,
		     .String_Length,
		     .Return_Addr,
		     .Data_Member_Location,
		     .Frame_Base,
		     .Segment,
		     .Static_Link,
		     .Use_Location,
		     .Vtable_Elem_Location:
			form.class = .Loclist
		case .Loclists_Base:
			form.class = .Loclistsptr
		case .Macro_Info, .Macros:
			form.class = .Macptr
		case .Start_Scope, .Ranges:
			form.class = .Rnglist
		case .Rnglists_Base:
			form.class = .Rnglistsptr
		case .Str_Offsets_Base:
			form.class = .Stroffsetsptr
		}
	// block
	case .Block1:
		length, _ := bytes.buffer_read_byte(buf)
		block_bytes := make([]byte, length)
		bytes.buffer_read(buf, block_bytes)
		form.data = block_bytes
		form.class = .Block
	case .Block2:
		len_bytes: [2]byte
		bytes.buffer_read(buf, len_bytes[:])
		length := slice.to_type(len_bytes[:], u16)
		block_bytes := make([]byte, length)
		bytes.buffer_read(buf, block_bytes)
		form.data = block_bytes
		form.class = .Block
	case .Block4:
		len_bytes: [4]byte
		bytes.buffer_read(buf, len_bytes[:])
		length := slice.to_type(len_bytes[:], u16)
		block_bytes := make([]byte, length)
		bytes.buffer_read(buf, block_bytes)
		form.data = block_bytes
		form.class = .Block
	case .Block:
		length, _, _ := _decode_uleb_buffer(buf)
		block_bytes := make([]byte, length)
		bytes.buffer_read(buf, block_bytes)
		form.data = block_bytes
		form.class = .Block
	// loclist
	case .Loclistx:
		form.data, _, _ = _decode_uleb_buffer(buf)
		form.class = .Loclist
	// rnglist
	case .Rnglistx:
		form.data, _, _ = _decode_uleb_buffer(buf)
		form.class = .Rnglist
	}
	return form
}


_read_offset :: #force_inline proc(buf: ^bytes.Buffer, is_32: bool) -> u64 {
	if is_32 {
		val_bytes: [4]byte
		bytes.buffer_read(buf, val_bytes[:])
		val := slice.to_type(val_bytes[:], u32)
		return cast(u64)val
	}
	val_bytes: [8]byte
	bytes.buffer_read(buf, val_bytes[:])
	val := slice.to_type(val_bytes[:], u64)
	return val
}

buffer_cstring_to_string :: proc(buf: ^bytes.Buffer) -> string {
	str := strings.builder_make_none()
	defer strings.builder_destroy(&str)
	for b, _ := bytes.buffer_read_byte(buf); b != 0; b, _ = bytes.buffer_read_byte(buf) {
		strings.write_byte(&str, b)
	}
	return strings.to_string(str)
}
