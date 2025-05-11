package dwarf

import "core:os"
import "core:fmt"

// procedure just for testing
main :: proc() {
	fd, open_err := os.open("./test_program/cloop")
	assert(open_err == nil)
	fmt.println(parse_elf(fd))
}

