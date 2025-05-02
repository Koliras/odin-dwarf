package dwarf

Abbrev :: struct {
	tag:      Tag,
	children: bool,
	field:    []Afield,
}

Afield :: struct {
	attr:  Attr,
	fmt:   Format,
	class: Class,
	val:   i64, // for Form.Implicit_Const
}

AbbrevTable :: map[u32]Abbrev

Class :: enum {
	// UNKNOWN represents values of unknown DWARF class.
	UNKNOWN,

	// ADDRESS represents values of type uint64 that are
	// addresses on the target machine.
	ADDRESS,

	// BLOCK represents values of type []byte whose
	// interpretation depends on the attribute.
	BLOCK,

	// CONSTANT represents values of type int64 that are
	// constants. The interpretation of this constant depends on
	// the attribute.
	CONSTANT,

	// EXPR_LOC represents values of type []byte that contain
	// an encoded DWARF expression or location description.
	EXPR_LOC,

	// FLAG represents values of type bool.
	FLAG,

	// LINE_PTR represents values that are an int64 offset
	// into the "line" section.
	LINE_PTR,

	// LOC_LIST_PTR represents values that are an int64 offset
	// into the "loclist" section.
	LOC_LIST_PTR,

	// MAC_PTR represents values that are an int64 offset into
	// the "mac" section.
	MAC_PTR,

	// RANGE_LIST_PTR represents values that are an int64 offset into
	// the "rangelist" section.
	RANGE_LIST_PTR,

	// REFERENCE represents values that are an Offset offset
	// of an Entry in the info section (for use with Reader.Seek).
	// The DWARF specification combines Reference and
	// ReferenceSig into class "reference".
	REFERENCE,

	// REFERENCE_SIG represents values that are a uint64 type
	// signature referencing a type Entry.
	REFERENCE_SIG,

	// STRING represents values that are strings. If the
	// compilation unit specifies the AttrUseUTF8 flag (strongly
	// recommended), the string value will be encoded in UTF-8.
	// Otherwise, the encoding is unspecified.
	STRING,

	// REFERENCE_ALT represents values of type int64 that are
	// an offset into the DWARF "info" section of an alternate
	// object file.
	REFERENCE_ALT,

	// STRING_ALT represents values of type int64 that are an
	// offset into the DWARF string section of an alternate object
	// file.
	STRING_ALT,

	// ADDR_PTR represents values that are an int64 offset
	// into the "addr" section.
	ADDR_PTR,

	// LOC_LIST represents values that are an int64 offset
	// into the "loclists" section.
	LOC_LIST,

	// RNG_LIST represents values that are a uint64 offset
	// from the base of the "rnglists" section.
	RNG_LIST,

	// RNG_LISTS_PTR represents values that are an int64 offset
	// into the "rnglists" section. These are used as the base for
	// RngList values.
	RNG_LISTS_PTR,

	// STR_OFFSETS_PTR represents values that are an int64
	// offset into the "str_offsets" section.
	STR_OFFSETS_PTR,
}
