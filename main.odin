package dwarf

import "core:fmt"
import os "core:os/os2"

// procedure just for testing
main :: proc() {
	fd, open_err := os.open("./test_program/cloop")
	assert(open_err == nil)
	fmt.println(parse_elf(&fd.stream))
}
