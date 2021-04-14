module compress

import encoding.binary
import bits

struct CompressObject {
	org []byte
mut:
	buffer bits.Buffer
	head int
}

pub fn create_compress_object(s string) CompressObject {
	return CompressObject{
		org: s.bytes()
		head: 0
		buffer: bits.create_bit_buffer()
	}
}

pub fn (mut obj CompressObject) compress() {
	for obj.org.len - 1 > obj.head {
		mut amount := u64(1)
		mut char := obj.org[obj.head]
		obj.head++

		for {
			next := obj.org[obj.head]
			if char == next {
				amount++
				if obj.org.len <= obj.head + 1 {
					break
				}
				obj.head++
				continue
			}
			break
		}
		obj.buffer.push_byte(char)
		obj.buffer.push_bit(amount > 1)
		if amount > 1 {
			obj.smart_number_to_bytes(amount)
		}
	}
}

pub fn (mut obj CompressObject) to_buffer() []byte {
	return obj.buffer.to_bytes()
}

fn (mut obj CompressObject) smart_number_to_bytes(i u64) {
	if i <= 256 {
		// byte
		obj.buffer.push_bit(false)
		obj.buffer.push_bit(false)
		obj.buffer.push_byte(byte(i))
	} else if i <= 65535 {
		// u16
		mut buf := []byte{len: 2}
		binary.big_endian_put_u16(mut buf, u16(i))
		obj.buffer.push_bit(true)
		obj.buffer.push_bit(false)
		for b in buf {
			obj.buffer.push_byte(b)
		}
	} else if i <= 4294967295 {
		// u32
		mut buf := []byte{len: 4}
		binary.big_endian_put_u32(mut buf, u32(i))
		obj.buffer.push_bit(false)
		obj.buffer.push_bit(true)
		for b in buf {
			obj.buffer.push_byte(b)
		}
	} else {
		// u64
		mut buf := []byte{len: 8}
		binary.big_endian_put_u64(mut buf, i)
		obj.buffer.push_bit(true)
		obj.buffer.push_bit(true)
		for b in buf {
			obj.buffer.push_byte(b)
		}
	}
}