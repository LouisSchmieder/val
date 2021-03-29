module main

import encoding.binary

struct CompressObject {
	org []byte
mut:
	buffer []byte
	head int
}

pub fn create_compress_object(s string) CompressObject {
	return CompressObject{
		org: s.bytes()
		head: 0
	}
}

pub fn (mut obj CompressObject) compress() {
	for obj.org.len -1 > obj.head {
		mut amount := u64(0)
		mut char := obj.org[obj.head]
		obj.head++
		mut next := obj.org[obj.head]
		for char == next && obj.org.len -1 > obj.head {
			amount++
			obj.head++
			next = obj.org[obj.head]
		}
		obj.buffer << char
		if amount > 0 {
			obj.buffer << smart_number_to_bytes(amount)
		}
	}
}

pub fn (mut obj CompressObject) to_buffer() []byte {
	return obj.buffer
}

fn smart_number_to_bytes(i u64) []byte {
	mut res := []byte{}
	if i <= 256 {
		// byte
		res << byte(1)
		res << byte(i)
	} else if i <= 65535 {
		// u16
		mut buf := []byte{len: 2}
		binary.big_endian_put_u16(mut buf, u16(i))
		res << byte(2)
		res << buf
	} else if i <= 4294967295 {
		// u32
		mut buf := []byte{len: 4}
		binary.big_endian_put_u32(mut buf, u32(i))
		res << byte(4)
		res << buf
	} else {
		// u64
		mut buf := []byte{len: 8}
		binary.big_endian_put_u64(mut buf, i)
		res << byte(8)
		res << buf
	}
	return res
}