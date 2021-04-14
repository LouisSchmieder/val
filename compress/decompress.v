module compress

import encoding.binary
import bits

struct DecompressObject {
mut:
	org bits.Buffer
	buffer []byte
}

pub fn create_decompress_object(buffer []byte) DecompressObject {
	return DecompressObject{
		org: bits.from_bytes(buffer)
		buffer: []byte{}
	}
}

pub fn (mut obj DecompressObject) decompress() {
	for obj.org.index + 1 < obj.org.buf.len {
		mut char := obj.org.read_byte()
		mut s := obj.org.read_bit()
		if s {
			mut len := obj.len()

			mut bytes := []byte{}
			for _ in 0..len {
				bytes << obj.org.read_byte()
			}
			mut repeat := smart_bytes_to_number(len, bytes)
			for _ in 0..repeat {
				obj.buffer << char
			}
		} else {
			obj.buffer << char
		}
		
	}
}

pub fn (mut obj DecompressObject) len() byte {
	a := obj.org.read_bit()
	b := obj.org.read_bit()
	if !a && !b {
		return 1
	} else if a && !b {
		return 2
	} else if !a && b {
		return 4
	} else if a && b {
		return 8
	}
	return 0
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