module main

import encoding.binary

struct DecompressObject {
	org []byte
mut:
	buffer []byte
	head int
}

pub fn create_decompress_object(buffer []byte) DecompressObject {
	eprintln(buffer)
	return DecompressObject{
		org: buffer
		head: 0
	}
}

pub fn (mut obj DecompressObject) decompress() {
	for obj.org.len -1 > obj.head {
		mut char := obj.next()
		mut len := obj.next()
		if len > 4 {
			obj.head--
			obj.buffer << char
			continue
		}
		mut bytes := obj.org[obj.head..obj.head+len]
		obj.head += len
		mut repeat := smart_bytes_to_number(len, bytes)
		for _ in 0..repeat {
			obj.buffer << char
		}
	}
}

fn (mut obj DecompressObject) next() byte {
	b := obj.org[obj.head]
	obj.head++
	return b
}

pub fn (mut obj DecompressObject) to_string() string {
	return string(obj.buffer)
}

pub fn smart_bytes_to_number(len byte, buf []byte) u64 {
	if len == 1 {
		return u64(buf[0])
	} else if len == 2 {
		return u64(binary.big_endian_u16(buf))
	} else if len == 4 {
		return u64(binary.big_endian_u32(buf))
	} else if len == 8 {
		return u64(binary.big_endian_u64(buf))
	}
	return u64(0)
} 