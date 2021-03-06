module main

import os

fn main() {
	args := os.args[1..]

	if args.len == 0 {
		print_help()
		return
	}

	mut rec := false
	mut path := ''
	mut out := ''
	mut extr := false
	mut compress := false

	for i := 0; i < args.len; i++ {
		arg := args[i]
		match arg {
			'-r' {
				rec = true
			}
			'-e' {
				extr = true
			}
			'-c' {
				compress = true
			}
			'-p' {
				path = args[i + 1]
				i++
			}
			'-o' {
				out = args[i + 1]
				i++
			}
			else {
				eprintln('Unkown flag `$arg`')
				print_help()
				return
			}
		}
	}
	if extr {
		arch := create_from_file(path, compress)
		arch.make_orginial(out)
	} else {
		arch := create_from_path(path, out, rec, compress)
		arch.make_file()
	}
}

fn print_help() {
	eprintln('Usage:')
	eprintln('val [(-r)/-e] -c -p <input path depends on action> -o <output path depends on action>')
	eprintln('  -c      Compression enabled (Optional)')
	eprintln('  -r      Activates recursion for archiving (Optional)')
	eprintln('  -e      If set action is set to extraction, if not set action is archiving')
}
