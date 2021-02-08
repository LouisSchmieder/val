module main

import os
import encoding.binary

struct Archive {
	out     string
	entries []string
	data    []string
}

pub fn create_from_path(path string, out string, recursive bool) Archive {
	entries, data := get_entries_from_path(path, recursive, true, '')
	return create_archive(out, entries, data)
}

pub fn create_from_file(path string) Archive {
	tmp := os.read_file(path) or { '' }
	data := tmp.bytes()
	mut i := 0
	mut entries := []string{}
	mut d := []string{}
	for i < data.len {
		path_len := int(binary.big_endian_u32(data[i..i + 4]))
		i += 4
		entries << data[i..i + path_len].bytestr()
		i += path_len
		data_len := int(binary.big_endian_u32(data[i..i + 4]))
		i += 4
		d << data[i..i + data_len].bytestr()
		i += data_len
	}
	return create_archive(path, entries, d)
}

fn get_entries_from_path(path string, r bool, a bool, upper string) ([]string, []string) {
	mut entries := []string{}
	mut data := []string{}
	files := os.ls(path) or { [''] }
	for f in files {
		if os.is_dir('$path/$f') {
			if r {
				tmp_e, tmp_d := get_entries_from_path('$path/$f', r, false, if upper != '' {
					'$upper/$f'
				} else {
					f
				})
				entries << tmp_e
				data << tmp_d
			}
		} else {
			if a {
				entries << '$f'
				text := os.read_file('$path/$f') or { '' }
				data << text
				continue
			}
			entries << '$upper/$f'
			text := os.read_file('$path/$f') or { '' }
			data << text
		}
	}
	return entries, data
}

fn create_archive(out string, entries []string, data []string) Archive {
	return Archive{
		out: out
		entries: entries
		data: data
	}
}

// Creates an .val file
pub fn (archive Archive) make_file() {
	mut output := []byte{}
	for i, entry in archive.entries {
		mut tmp := []byte{len: 4}
		binary.big_endian_put_u32(mut tmp, u32(entry.len))
		output << tmp
		output << entry.bytes()
		data := archive.data[i]
		binary.big_endian_put_u32(mut tmp, u32(data.len))
		output << tmp
		output << data.bytes()
	}
	os.write_file(archive.out, output.bytestr()) or { panic(err) }
}

// Creates the original folder structure
pub fn (archive Archive) make_orginial(base string) {
	for i, entry in archive.entries {
		mut upper_dirs := entry.split('/')
		upper_dirs = upper_dirs[..upper_dirs.len - 1]
		os.mkdir_all('$base/${upper_dirs.join('/')}') or { panic(err) }
		os.write_file('$base/$entry', archive.data[i]) or { panic(err) }
	}
}
