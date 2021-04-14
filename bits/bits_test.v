import bits

fn test_bits() {
	mut buf := bits.create_bit_buffer()
	buf.push_bit(true)
	buf.push_bit(false)
	buf.push_bit(true)
	buf.push_byte(0xF7)
	buf.push_byte(0xF3)
	buf.push_bit(false)
	buf.push_byte(0x57)

	mut test := bits.from_bytes(buf.to_bytes())
	assert test.read_bit() == true
	assert test.read_bit() == false
	assert test.read_bit() == true
	assert test.read_byte() == 0xF7
	assert test.read_byte() == 0xF3
	assert test.read_bit() == false
	assert test.read_byte() == 0x57
}