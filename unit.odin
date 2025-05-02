package dwarf

Unit :: struct {
	base:   u32,
	off:    u32,
	data:   []byte,
	atable: AbbrevTable,
	asize:  int,
	vers:   int,
	utype:  u8, // DWARF 5 unit type
	is64:   bool, // True for 64-bit DWARF format
}
