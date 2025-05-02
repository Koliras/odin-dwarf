package dwarf

Attr :: enum u32 {
	SIBLING                 = 0x01,
	LOCATION                = 0x02,
	NAME                    = 0x03,
	ORDERING                = 0x09,
	BYTE_SIZE               = 0x0B,
	BIT_OFFSET              = 0x0C,
	BIT_SIZE                = 0x0D,
	STMT_LIST               = 0x10,
	LOWPC                   = 0x11,
	HIGHPC                  = 0x12,
	LANGUAGE                = 0x13,
	DISCR                   = 0x15,
	DISCR_VALUE             = 0x16,
	VISIBILITY              = 0x17,
	IMPORT                  = 0x18,
	STRING_LENGTH           = 0x19,
	COMMON_REF              = 0x1A,
	COMP_DIR                = 0x1B,
	CONST_VALUE             = 0x1C,
	CONTAINING_TYPE         = 0x1D,
	DEFAULT_VALUE           = 0x1E,
	INLINE                  = 0x20,
	IS_OPTIONAL             = 0x21,
	LOWER_BOUND             = 0x22,
	PRODUCER                = 0x25,
	PROTOTYPED              = 0x27,
	RETURN_ADDR             = 0x2A,
	START_SCOPE             = 0x2C,
	STRIDE_SIZE             = 0x2E,
	UPPER_BOUND             = 0x2F,
	ABSTRACT_ORIGIN         = 0x31,
	ACCESSIBILITY           = 0x32,
	ADDR_CLASS              = 0x33,
	ARTIFICIAL              = 0x34,
	BASE_TYPES              = 0x35,
	CALLING                 = 0x36,
	COUNT                   = 0x37,
	DATA_MEMBER_LOC         = 0x38,
	DECL_COLUMN             = 0x39,
	DECL_FILE               = 0x3A,
	DECL_LINE               = 0x3B,
	DECLARATION             = 0x3C,
	DISCR_LIST              = 0x3D,
	ENCODING                = 0x3E,
	EXTERNAL                = 0x3F,
	FRAME_BASE              = 0x40,
	FRIEND                  = 0x41,
	IDENTIFIER_CASE         = 0x42,
	MACRO_INFO              = 0x43,
	NAMELIST_ITEM           = 0x44,
	PRIORITY                = 0x45,
	SEGMENT                 = 0x46,
	SPECIFICATION           = 0x47,
	STATIC_LINK             = 0x48,
	TYPE                    = 0x49,
	USE_LOCATION            = 0x4A,
	VAR_PARAM               = 0x4B,
	VIRTUALITY              = 0x4C,
	VTABLE_ELEM_LOC         = 0x4D,
	// The following are new in DWARF 3.
	ALLOCATED               = 0x4E,
	ASSOCIATED              = 0x4F,
	DATA_LOCATION           = 0x50,
	STRIDE                  = 0x51,
	ENTRYPC                 = 0x52,
	USE_U_T_F8              = 0x53,
	EXTENSION               = 0x54,
	RANGES                  = 0x55,
	TRAMPOLINE              = 0x56,
	CALL_COLUMN             = 0x57,
	CALL_FILE               = 0x58,
	CALL_LINE               = 0x59,
	DESCRIPTION             = 0x5A,
	BINARY_SCALE            = 0x5B,
	DECIMAL_SCALE           = 0x5C,
	SMALL                   = 0x5D,
	DECIMAL_SIGN            = 0x5E,
	DIGIT_COUNT             = 0x5F,
	PICTURE_STRING          = 0x60,
	MUTABLE                 = 0x61,
	THREADS_SCALED          = 0x62,
	EXPLICIT                = 0x63,
	OBJECT_POINTER          = 0x64,
	ENDIANITY               = 0x65,
	ELEMENTAL               = 0x66,
	PURE                    = 0x67,
	RECURSIVE               = 0x68,
	// The following are new in DWARF 4.
	SIGNATURE               = 0x69,
	MAIN_SUBPROGRAM         = 0x6A,
	DATA_BIT_OFFSET         = 0x6B,
	CONST_EXPR              = 0x6C,
	ENUM_CLASS              = 0x6D,
	LINKAGE_NAME            = 0x6E,
	// The following are new in DWARF 5.
	STRING_LENGTH_BIT_SIZE  = 0x6F,
	STRING_LENGTH_BYTE_SIZE = 0x70,
	RANK                    = 0x71,
	STR_OFFSETS_BASE        = 0x72,
	ADDR_BASE               = 0x73,
	RNGLISTS_BASE           = 0x74,
	DWO_NAME                = 0x76,
	REFERENCE               = 0x77,
	RVALUE_REFERENCE        = 0x78,
	MACROS                  = 0x79,
	CALL_ALL_CALLS          = 0x7A,
	CALL_ALL_SOURCE_CALLS   = 0x7B,
	CALL_ALL_TAIL_CALLS     = 0x7C,
	CALL_RETURN_P_C         = 0x7D,
	CALL_VALUE              = 0x7E,
	CALL_ORIGIN             = 0x7F,
	CALL_PARAMETER          = 0x80,
	CALL_P_C                = 0x81,
	CALL_TAIL_CALL          = 0x82,
	CALL_TARGET             = 0x83,
	CALL_TARGET_CLOBBERED   = 0x84,
	CALL_DATA_LOCATION      = 0x85,
	CALL_DATA_VALUE         = 0x86,
	NORETURN                = 0x87,
	ALIGNMENT               = 0x88,
	EXPORT_SYMBOLS          = 0x89,
	DELETED                 = 0x8A,
	DEFAULTED               = 0x8B,
	LOCLISTS_BASE           = 0x8C,
}

Format :: enum u32 {
	// value formats
	ADDR           = 0x01,
	DWARF_BLOCK2   = 0x03,
	DWARF_BLOCK4   = 0x04,
	DATA2          = 0x05,
	DATA4          = 0x06,
	DATA8          = 0x07,
	STRING         = 0x08,
	DWARF_BLOCK    = 0x09,
	DWARF_BLOCK1   = 0x0A,
	DATA1          = 0x0B,
	FLAG           = 0x0C,
	SDATA          = 0x0D,
	STRP           = 0x0E,
	UDATA          = 0x0F,
	REF_ADDR       = 0x10,
	REF1           = 0x11,
	REF2           = 0x12,
	REF4           = 0x13,
	REF8           = 0x14,
	REF_UDATA      = 0x15,
	INDIRECT       = 0x16,
	// The following are new in DWARF 4.
	SEC_OFFSET     = 0x17,
	EXPRLOC        = 0x18,
	FLAG_PRESENT   = 0x19,
	REF_SIG8       = 0x20,
	// The following are new in DWARF 5.
	STRX           = 0x1A,
	ADDRX          = 0x1B,
	REF_SUP4       = 0x1C,
	STRP_SUP       = 0x1D,
	DATA16         = 0x1E,
	LINE_STRP      = 0x1F,
	IMPLICIT_CONST = 0x21,
	LOCLISTX       = 0x22,
	RNGLISTX       = 0x23,
	REF_SUP8       = 0x24,
	STRX1          = 0x25,
	STRX2          = 0x26,
	STRX3          = 0x27,
	STRX4          = 0x28,
	ADDRX1         = 0x29,
	ADDRX2         = 0x2A,
	ADDRX3         = 0x2B,
	ADDRX4         = 0x2C,
	// Extensions for multi-file compression (.dwz)
	// http://www.dwarfstd.org/ShowIssue.php?issue=120604.1
	GNU_REF_ALT    = 0x1F20,
	GNU_STRP_ALT   = 0x1F21,
}

Tag :: enum u32 {
	ARRAY_TYPE               = 0x01,
	CLASS_TYPE               = 0x02,
	ENTRY_POINT              = 0x03,
	ENUMERATION_TYPE         = 0x04,
	FORMAL_PARAMETER         = 0x05,
	IMPORTED_DECLARATION     = 0x08,
	LABEL                    = 0x0A,
	LEX_DWARF_BLOCK          = 0x0B,
	MEMBER                   = 0x0D,
	POINTER_TYPE             = 0x0F,
	REFERENCE_TYPE           = 0x10,
	COMPILE_UNIT             = 0x11,
	STRING_TYPE              = 0x12,
	STRUCT_TYPE              = 0x13,
	SUBROUTINE_TYPE          = 0x15,
	TYPEDEF                  = 0x16,
	UNION_TYPE               = 0x17,
	UNSPECIFIED_PARAMETERS   = 0x18,
	VARIANT                  = 0x19,
	COMMON_DWARF_BLOCK       = 0x1A,
	COMMON_INCLUSION         = 0x1B,
	INHERITANCE              = 0x1C,
	INLINED_SUBROUTINE       = 0x1D,
	MODULE                   = 0x1E,
	PTR_TO_MEMBER_TYPE       = 0x1F,
	SET_TYPE                 = 0x20,
	SUBRANGE_TYPE            = 0x21,
	WITH_STMT                = 0x22,
	ACCESS_DECLARATION       = 0x23,
	BASE_TYPE                = 0x24,
	CATCH_DWARF_BLOCK        = 0x25,
	CONST_TYPE               = 0x26,
	CONSTANT                 = 0x27,
	ENUMERATOR               = 0x28,
	FILE_TYPE                = 0x29,
	FRIEND                   = 0x2A,
	NAMELIST                 = 0x2B,
	NAMELIST_ITEM            = 0x2C,
	PACKED_TYPE              = 0x2D,
	SUBPROGRAM               = 0x2E,
	TEMPLATE_TYPE_PARAMETER  = 0x2F,
	TEMPLATE_VALUE_PARAMETER = 0x30,
	THROWN_TYPE              = 0x31,
	TRY_DWARF_BLOCK          = 0x32,
	VARIANT_PART             = 0x33,
	VARIABLE                 = 0x34,
	VOLATILE_TYPE            = 0x35,
	// The following are new in DWARF 3.
	DWARF_PROCEDURE          = 0x36,
	RESTRICT_TYPE            = 0x37,
	INTERFACE_TYPE           = 0x38,
	NAMESPACE                = 0x39,
	IMPORTED_MODULE          = 0x3A,
	UNSPECIFIED_TYPE         = 0x3B,
	PARTIAL_UNIT             = 0x3C,
	IMPORTED_UNIT            = 0x3D,
	MUTABLE_TYPE             = 0x3E, // Later removed from DWARF.
	CONDITION                = 0x3F,
	SHARED_TYPE              = 0x40,
	// The following are new in DWARF 4.
	TYPE_UNIT                = 0x41,
	RVALUE_REFERENCE_TYPE    = 0x42,
	TEMPLATE_ALIAS           = 0x43,
	// The following are new in DWARF 5.
	COARRAY_TYPE             = 0x44,
	GENERIC_SUBRANGE         = 0x45,
	DYNAMIC_TYPE             = 0x46,
	ATOMIC_TYPE              = 0x47,
	CALL_SITE                = 0x48,
	CALL_SITE_PARAMETER      = 0x49,
	SKELETON_UNIT            = 0x4A,
	IMMUTABLE_TYPE           = 0x4B,
}

Op :: enum u8 {
	ADDR               = 0x03, /* 1 op, const addr */
	DEREF              = 0x06,
	CONST_1U           = 0x08, /* 1 op, 1 byte const */
	CONST_1S           = 0x09, /*	" signed */
	CONST_2U           = 0x0A, /* 1 op, 2 byte const  */
	CONST_2S           = 0x0B, /*	" signed */
	CONST_4U           = 0x0C, /* 1 op, 4 byte const */
	CONST_4S           = 0x0D, /*	" signed */
	CONST_8U           = 0x0E, /* 1 op, 8 byte const */
	CONST_8S           = 0x0F, /*	" signed */
	CONSTU             = 0x10, /* 1 op, LEB128 const */
	CONSTS             = 0x11, /*	" signed */
	DUP                = 0x12,
	DROP               = 0x13,
	OVER               = 0x14,
	PICK               = 0x15, /* 1 op, 1 byte stack index */
	SWAP               = 0x16,
	ROT                = 0x17,
	XDEREF             = 0x18,
	ABS                = 0x19,
	AND                = 0x1A,
	DIV                = 0x1B,
	MINUS              = 0x1C,
	MOD                = 0x1D,
	MUL                = 0x1E,
	NEG                = 0x1F,
	NOT                = 0x20,
	OR                 = 0x21,
	PLUS               = 0x22,
	PLUS_UCONST        = 0x23, /* 1 op, ULEB128 addend */
	SHL                = 0x24,
	SHR                = 0x25,
	SHRA               = 0x26,
	XOR                = 0x27,
	SKIP               = 0x2F, /* 1 op, signed 2-byte constant */
	BRA                = 0x28, /* 1 op, signed 2-byte constant */
	EQ                 = 0x29,
	GE                 = 0x2A,
	GT                 = 0x2B,
	LE                 = 0x2C,
	LT                 = 0x2D,
	NE                 = 0x2E,
	LIT0               = 0x30,
	/* LitN = Lit0 + N for N = 0..31 */
	REG0               = 0x50,
	/* RegN = Reg0 + N for N = 0..31 */
	BREG0              = 0x70, /* 1 op, signed LEB128 constant */
	/* BregN = Breg0 + N for N = 0..31 */
	REGX               = 0x90, /* 1 op, ULEB128 register */
	FBREG              = 0x91, /* 1 op, SLEB128 offset */
	BREGX              = 0x92, /* 2 op, ULEB128 reg; SLEB128 off */
	PIECE              = 0x93, /* 1 op, ULEB128 size of piece */
	DEREF_SIZE         = 0x94, /* 1-byte size of data retrieved */
	XDEREF_SIZE        = 0x95, /* 1-byte size of data retrieved */
	NOP                = 0x96,
	// The following are new in DWARF 3.
	PUSH_OBJ_ADDR      = 0x97,
	CALL_2             = 0x98, /* 2-byte offset of DIE */
	CALL_4             = 0x99, /* 4-byte offset of DIE */
	CALL_REF           = 0x9A, /* 4- or 8- byte offset of DIE */
	FORM_T_L_S_ADDRESS = 0x9B,
	CALL_FRAME_C_F_A   = 0x9C,
	BIT_PIECE          = 0x9D,
	// The following are new in DWARF 4.
	IMPLICIT_VALUE     = 0x9E,
	STACK_VALUE        = 0x9F,
	// The following a new in DWARF 5.
	IMPLICIT_POINTER   = 0xA0,
	ADDRX              = 0xA1,
	CONSTX             = 0xA2,
	ENTRY_VALUE        = 0xA3,
	CONST_TYPE         = 0xA4,
	REGVAL_TYPE        = 0xA5,
	DEREF_TYPE         = 0xA6,
	XDEREF_TYPE        = 0xA7,
	CONVERT            = 0xA8,
	REINTERPRET        = 0xA9,
	/* 0xE0-0xFF reserved for user-specific */
}

Encoding :: enum u8 {
	ADDRESS         = 0x01,
	BOOLEAN         = 0x02,
	COMPLEX_FLOAT   = 0x03,
	FLOAT           = 0x04,
	SIGNED          = 0x05,
	SIGNED_CHAR     = 0x06,
	UNSIGNED        = 0x07,
	UNSIGNED_CHAR   = 0x08,
	// The following are new in DWARF 3.
	IMAGINARY_FLOAT = 0x09,
	PACKED_DECIMAL  = 0x0A,
	NUMERIC_STRING  = 0x0B,
	EDITED          = 0x0C,
	SIGNED_FIXED    = 0x0D,
	UNSIGNED_FIXED  = 0x0E,
	DECIMAL_FLOAT   = 0x0F,
	// The following are new in DWARF 4.
	UTF             = 0x10,
	// The following are new in DWARF 5.
	UCS             = 0x11,
	ASCII           = 0x12,
}

// Statement program standard opcode encodings.
Lns :: enum u8 {
	COPY               = 1,
	ADVANCE_P_C        = 2,
	ADVANCE_LINE       = 3,
	SET_FILE           = 4,
	SET_COLUMN         = 5,
	NEGATE_STMT        = 6,
	SET_BASIC_BLOCK    = 7,
	CONST_ADD_P_C      = 8,
	FIXED_ADVANCE_P_C  = 9,
	// DWARF 3
	SET_PROLOGUE_END   = 10,
	SET_EPILOGUE_BEGIN = 11,
	SET_ISA            = 12,
}

// Statement program extended opcode encodings.
Lne :: enum u8 {
	END_SEQUENCE      = 1,
	SET_ADDRESS       = 2,
	DEFINE_FILE       = 3,
	// DWARF 4
	SET_DISCRIMINATOR = 4,
}

// Line table directory and file name entry formats.
// These are new in DWARF 5.
Lnct :: enum u8 {
	PATH           = 0x01,
	DIRECTORYINDEX = 0x02,
	TIMESTAMP      = 0x03,
	SIZE           = 0x04,
	MD5            = 0x05,
}

// Location list entry codes.
// These are new in DWARF 5.
Location_List_Entry :: enum u8 {
	END_OF_LIST      = 0x00,
	BASE_ADDRESSX    = 0x01,
	STARTX_ENDX      = 0x02,
	STARTX_LENGTH    = 0x03,
	OFFSET_PAIR      = 0x04,
	DEFAULT_LOCATION = 0x05,
	BASE_ADDRESS     = 0x06,
	START_END        = 0x07,
	START_LENGTH     = 0x08,
}

// Unit header unit type encodings.
// These are new in DWARF 5.
Unit_Header :: enum u8 {
	COMPILE       = 0x01,
	TYPE          = 0x02,
	PARTIAL       = 0x03,
	SKELETON      = 0x04,
	SPLIT_COMPILE = 0x05,
	SPLIT_TYPE    = 0x06,
}

// Opcodes for DWARFv5 debug_rnglists section.
Rle :: enum u8 {
	END_OF_LIST   = 0x0,
	BASE_ADDRESSX = 0x1,
	STARTX_ENDX   = 0x2,
	STARTX_LENGTH = 0x3,
	OFFSET_PAIR   = 0x4,
	BASE_ADDRESS  = 0x5,
	START_END     = 0x6,
	START_LENGTH  = 0x7,
}
