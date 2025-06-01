package dwarf

Dwarf_Tag :: enum u64 {
	Padding                    = 0x00,
	Array_Type                  = 0x01,
	Class_Type                  = 0x02,
	Entry_Point                 = 0x03,
	Enumeration_Type            = 0x04,
	Formal_Parameter            = 0x05,
	Imported_Declaration        = 0x08,
	Label                       = 0x0a,
	Lexical_Block               = 0x0b,
	Member                      = 0x0d,
	Pointer_Type                = 0x0f,
	Reference_Type              = 0x10,
	Compile_Unit                = 0x11,
	String_Type                 = 0x12,
	Structure_Type              = 0x13,
	Subroutine                  = 0x14,
	Subroutine_Type             = 0x15,
	Typedef                     = 0x16,
	Union_Type                  = 0x17,
	Unspecified_Parameters      = 0x18,
	Variant                     = 0x19,
	Common_Block                = 0x1a,
	Common_Inclusion            = 0x1b,
	Inheritance                 = 0x1c,
	Inlined_Subroutine          = 0x1d,
	Module                      = 0x1e,
	Ptr_To_Member_Type          = 0x1f,
	Set_Type                    = 0x20,
	Subrange_Type               = 0x21,
	With_Stmt                   = 0x22,
	Access_Declaration          = 0x23,
	Base_Type                   = 0x24,
	Catch_Block                 = 0x25,
	Const_Type                  = 0x26,
	Constant                    = 0x27,
	Enumerator                  = 0x28,
	File_Type                   = 0x29,
	Friend                      = 0x2a,
	Namelist                    = 0x2b,
	Namelist_Item               = 0x2c,
	Packed_Type                 = 0x2d,
	Subprogram                  = 0x2e,
	Template_Type_Param         = 0x2f,
	Template_Value_Param        = 0x30,
	Thrown_Type                 = 0x31,
	Try_Block                   = 0x32,
	Variant_Part                = 0x33,
	Variable                    = 0x34,
	Volatile_Type               = 0x35,

	// DWARF 3
	Dwarf_Procedure             = 0x36,
	Restrict_Type               = 0x37,
	Interface_Type              = 0x38,
	Namespace                   = 0x39,
	Imported_Module             = 0x3a,
	Unspecified_Type            = 0x3b,
	Partial_Unit                = 0x3c,
	Imported_Unit               = 0x3d,
	Condition                   = 0x3f,
	Shared_Type                 = 0x40,

	// DWARF 4
	Type_Unit                   = 0x41,
	Rvalue_Reference_Type       = 0x42,
	Template_Alias              = 0x43,

	// DWARF 5
	Coarray_Type                = 0x44,
	Generic_Subrange            = 0x45,
	Dynamic_Type                = 0x46,
	Atomic_Type                 = 0x47,
	Call_Site                   = 0x48,
	Call_Site_Parameter         = 0x49,
	Skeleton_Unit               = 0x4a,
	Immutable_Type              = 0x4b,
	Lo_User                     = 0x4080,
	Hi_User                     = 0xffff,

	// SGI/MIPS Extensions.
	MIPS_Loop                   = 0x4081,

	// HP extensions.  See: ftp://ftp.hp.com/pub/lang/tools/WDB/wdb-4.0.tar.gz .
	HP_Array_Descriptor         = 0x4090,
	HP_Bliss_Field              = 0x4091,
	HP_Bliss_Field_Set          = 0x4092,

	// GNU extensions.
	Format_Label                = 0x4101, // For FORTRAN 77 and Fortran 90.
	Function_Template           = 0x4102, // For C++.
	Class_Template              = 0x4103, //For C++.
	GNU_BINCL                   = 0x4104,
	GNU_EINCL                   = 0x4105,

	// Template template parameter.
	// See http://gcc.gnu.org/wiki/TemplateParmsDwarf .
	GNU_Template_Template_Param = 0x4106,

	// Template parameter pack extension = specified at
	// http://wiki.dwarfstd.org/index.php?title=C%2B%2B0x:_Variadic_Templates
	// The values of these two TAGS are in the DW_TAG_GNU_* space until the tags
	// are properly part of DWARF 5.
	GNU_Template_Parameter_Pack = 0x4107,
	GNU_Formal_Parameter_Pack   = 0x4108,
	// The GNU call site extension = specified at
	// http://www.dwarfstd.org/ShowIssue.php?issue=100909.2&type=open .
	// The values of these two TAGS are in the DW_TAG_GNU_* space until the tags
	// are properly part of DWARF 5.
	GNU_Call_Site               = 0x4109,
	GNU_Call_Site_Parameter     = 0x410a,
	// Extensions for UPC.  See: http://dwarfstd.org/doc/DWARF4.pdf.
	Upc_Shared_Type             = 0x8765,
	Upc_Strict_Type             = 0x8766,
	Upc_Relaxed_Type            = 0x8767,
	// PGI (STMicroelectronics; extensions.  No documentation available.
	PGI_Kanji_Type              = 0xA000,
	PGI_Interface_Block         = 0xA020,

	// ZIG extensions.
	ZIG_Padding                 = 0xfdb1,
}

