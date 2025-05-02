package dwarf

Data :: struct {
	// raw data
	abbrev:      []byte,
	arranges:    []byte,
	frame:       []byte,
	info:        []byte,
	line:        []byte,
	pubnames:    []byte,
	ranges:      []byte,
	str:         []byte,

	// New sections added in DWARF 5.
	addr:        []byte,
	lineStr:     []byte,
	strOffsets:  []byte,
	rngLists:    []byte,

	// parsed data
	abbrevCache: map[u64]AbbrevTable,
	bigEndian:   bool,
	typeSigs:    map[u64]^TypeUnit,
	unit:        []Unit,
}
