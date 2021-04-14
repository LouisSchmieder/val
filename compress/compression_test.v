import compress

fn test_compression() {
	test := 'aaaaadufjjjjjj'
	mut cmp := compress.create_compress_object(test)
	cmp.compress()
	buf := cmp.to_buffer()
	mut decompress := compress.create_decompress_object(buf)
	decompress.decompress()
	str := decompress.to_string()
	assert test == str
}