package main

import "w4"

import "core:strconv"
import "core:runtime"
import "core:strings"
import "core:fmt"
import "core:mem"

smiley := [8]u8{
	0b11000011,
	0b10000001,
	0b00100100,
	0b00100100,
	0b00000000,
	0b00100100,
	0b10011001,
	0b11000011,
}

contxt: runtime.Context

HEAP_START :: 1024 * 32
HEAP_END   :: 1024 * 64
heap_top := rawptr(uintptr(HEAP_START))

allocate :: proc(
	_: rawptr, mode: runtime.Allocator_Mode, 
	size, _: int, old_memory: rawptr, old_size: int, 
	location := #caller_location) -> ([]byte, runtime.Allocator_Error) {
	
	if mode == .Alloc {
		if int(uintptr(heap_top)) + size > HEAP_END {
			return nil, .Out_Of_Memory
		}
		ret := mem.byte_slice(heap_top, size)
		heap_top = rawptr(uintptr(heap_top) + uintptr(size))
		return ret, .None
	}
	if mode == .Free {
		return nil, .Mode_Not_Implemented
	}
	if mode == .Free_All {
		heap_top = rawptr(uintptr(HEAP_START))
		return nil, .None
	}
	if mode == .Resize {
		if old_size >= size {
			return mem.byte_slice(old_memory, size), .None
		}
		if int(uintptr(heap_top)) + size > HEAP_END {
			return nil, .Out_Of_Memory
		}
		ret := mem.byte_slice(heap_top, size)
		heap_top = rawptr(uintptr(heap_top) + uintptr(size))
		runtime.copy(ret, mem.byte_slice(old_memory, old_size), )

		return ret, .None
	}
	return nil, .None
}

trace_int :: proc(val: int) {
	data: [5]byte
	strconv.itoa(data[:], val)
	w4.trace(strings.string_from_ptr(&data[0], 5))
}

@export
start :: proc "c" () {

	contxt.allocator.procedure = allocate
	context = contxt

	w4.PALETTE[0] = 0x442d6e
	w4.PALETTE[1] = 0xd075b7
	w4.PALETTE[2] = 0xf0d063
	w4.PALETTE[3] = 0xffffff

}

@export
update :: proc "c" () {
	context = contxt
	w4.PALETTE[0] = PALLETES[cycle]

	
	w4.DRAW_COLORS^ = 0
	w4.text("Hello from Odin!", 10, 10)

	w4.DRAW_COLORS^ = 2
	if .A in w4.GAMEPAD1^ {
		w4.DRAW_COLORS^ = 3
	}
	
	w4.blit(&smiley[0], 76, 76, 8, 8)
	w4.text("Press X to blink", 16, 90)
}