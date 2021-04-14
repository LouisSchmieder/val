module bits

struct Buffer {
mut:
	off byte
	cur byte
pub mut:
	index int
	buf []byte
}

pub fn create_bit_buffer() Buffer {
	return Buffer{
		off: 0
		cur: 0
		buf: []byte{}
	}
}

pub fn from_bytes(bytes []byte) Buffer {
	mut buf := Buffer{
		off: 0
		index: 0
		cur: bytes[0]
		buf: bytes
	}
	return buf
}

pub fn (mut buf Buffer) read_bit() bool {
	mut tmp := buf.cur << buf.off
	tmp >>= 7
	buf.off++
	if buf.off == 8 {
		buf.next()
	}
	return tmp == 0b00000001
}

pub fn (mut buf Buffer) read_byte() byte {
	if buf.off == 0 {
		tmp := buf.cur
		buf.next()
		return tmp
	}
	mut res := byte(0x00)
	mut diff := 8 - buf.off
	buf.cur <<= buf.off
	res |= buf.cur
	buf.next()
	tmp := buf.cur >> diff
	res |= tmp
	buf.off = 8 - diff
	return res
}

pub fn (mut buf Buffer) push_bit(b bool) {
	buf.cur <<= 1
	if b {
		buf.cur |= 0b00000001
	} else {
		buf.cur |= 0b00000000
	}
	buf.off++
	if buf.off == 8 {
		buf.push_cur()
	}
}

pub fn (mut buf Buffer) push_byte(b byte) {
	if buf.off == 0 {
		buf.cur = b
		buf.push_cur()
		return
	}
	diff := 8 - buf.off
	mut tmp := b >> buf.off
	buf.cur <<= diff
	buf.cur |= tmp
	buf.push_cur()
	tmp = b << diff
	tmp >>= diff
	buf.cur |= tmp
	buf.off = 8 - diff
}

fn (mut buf Buffer) push_cur() {
	buf.buf << buf.cur
	buf.cur = 0
	buf.off = 0
}

fn (mut buf Buffer) next() {
	if buf.index + 1 < buf.buf.len {
		buf.index++
		buf.cur = buf.buf[buf.index]
		buf.off = 0
	}
}

pub fn (mut buf Buffer) to_bytes() []byte {
	if buf.off > 0 {
		buf.cur <<= buf.off
		buf.push_cur()
	}
	return buf.buf
}