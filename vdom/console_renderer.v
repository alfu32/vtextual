module vdom

//–– Dependencies for ANSI control ––
import term
import strconv
import math

type StringTransform = fn (_ string) string

// A cell now holds its rune plus three layers of formatters:
//  - a BG formatter: wraps text in the right bg-SGR codes
//  - a FG formatter: wraps its input in the right fg-SGR codes
//  - zero or more style formatters (bold, italic, underline…)
pub struct Cell {
pub mut:
	ch         rune
	bg_fmt     StringTransform = term.reset
	fg_fmt     StringTransform = term.reset
	style_fmts []StringTransform // e.g. [col.bold, col.underline]
}

// simple named ↔ hex map; extend as you like
const named_colors = {
	'black':   0x000000
	'red':     0xff0000
	'green':   0x00ff00
	'yellow':  0xffff00
	'blue':    0x0000ff
	'magenta': 0xff00ff
	'cyan':    0x00ffff
	'white':   0xffffff
}

// parse “red”, “#ff8800” or integer hex (0xRRGGBB) into an int or error
fn parse_color(val string) ?i64 {
	s := val.trim_space().to_lower().trim_left('#')
	if v := named_colors[s] {
		return v
	}
	// hex string?
	if s.len == 6 {
		return strconv.parse_int(s, 16, 32) or { return none }
	}
	return none
}

// returns a bg-formatter fn: wraps its input in the correct SGR for a 24-bit BG color
fn bg_formatter(color string) fn (string) string {
	if c := parse_color(color) {
		return fn [c] (msg string) string {
			return term.bg_hex(int(c), msg)
		}
	}
	return term.reset
}

// returns a fg-formatter fn: wraps its input in the correct SGR for a 24-bit FG color
fn fg_formatter(color string) fn (string) string {
	if c := parse_color(color) {
		return fn [c] (msg string) string {
			return term.hex(int(c), msg)
		}
	}
	return term.reset
}

// parse a comma‐separated font‐style list into a slice of term.colors fns
fn style_formatters(val string) []fn (string) string {
	mut fns := []StringTransform{}
	for token in val.split_any(', ') {
		match token {
			'bold' { fns << term.bold }
			'dim' { fns << term.dim }
			'italic' { fns << term.italic }
			'underline' { fns << term.underline }
			'strikethrough' { fns << term.strikethrough }
			'slowblink' { fns << term.slow_blink }
			'rapidblink' { fns << term.rapid_blink }
			'inverse' { fns << term.inverse }
			'hidden' { fns << term.hidden }
			else {}
		}
	}
	return fns
}

struct Canvas {
pub mut:
	width  int
	height int
	cells  [][]Cell
}

// A computed box for each node
struct LayoutBox {
	x      int
	y      int
	width  int
	height int
	node   &Node
}

//–– Entry point ––
pub fn render_console(root &Node, viewport_width int, viewport_height int) {
	// 1) compute layout boxes
	mut layouts := []LayoutBox{}
	compute_layout(root, 0, 0, viewport_width, viewport_height, mut layouts)
	// 2) paint into canvas
	mut cvs := new_canvas(viewport_width, viewport_height, root.get_style('background-color'))
	for lb in layouts {
		paint_box(mut cvs, lb)
	}
	// 3) flush to stdout
	print_canvas(cvs)
}

//–– Canvas helpers ––
fn new_canvas(w int, h int, root_bg string) Canvas {
	mut rows := [][]Cell{len: h}
	root_bg_fmt := bg_formatter(root_bg)
	for y in 0 .. h {
		mut row := []Cell{len: w}
		for x in 0 .. w {
			row[x] = Cell{
				ch:         ` `
				bg_fmt:     root_bg_fmt
				fg_fmt:     term.reset
				style_fmts: []StringTransform{}
			}
		}
		rows[y] = row
	}
	return Canvas{w, h, rows}
}

fn print_canvas(cvs Canvas) {
	for row in cvs.cells {
		mut line := ''
		for cell in row {
			mut s := cell.ch.str()
			// apply formatting layers:
			s = cell.bg_fmt(s)
			s = cell.fg_fmt(s)
			for fn_fmt in cell.style_fmts {
				s = fn_fmt(s)
			}
			line += s
		}
		// reset at end of each line
		line += term.reset('')
		println(line)
	}
}

//–– Layout ––
fn compute_layout(n &Node, origin_x int, origin_y int, parent_w int, parent_h int, mut out []LayoutBox) {
	// parse margin & padding
	marg_top, _, _, marg_left := parse_box_values(n.get_style('margin'), parent_w)
	pad_top, pad_right, pad_bot, pad_left := parse_box_values(n.get_style('padding'),
		parent_w)
	// parse width/height
	w := compute_unit(n.get_style('width'), parent_w)
	h := compute_unit(n.get_style('height'), parent_h)
	// initial position
	mut x := origin_x + marg_left
	mut y := origin_y + marg_top
	// positioning modes
	pos := n.get_style('position')
	if pos == 'absolute' {
		mut v := n.get_style('left')
		if v != '' {
			x = origin_x + compute_unit(v, parent_w)
		}
		v = n.get_style('top')
		if v != '' {
			y = origin_y + compute_unit(v, parent_h)
		}
	} else if pos == 'fixed' {
		// fixed always relative to (0,0) of viewport
		mut v := n.get_style('left')
		if v != '' {
			x = compute_unit(v, parent_w)
		}
		v = n.get_style('top')
		if v != '' {
			y = compute_unit(v, parent_h)
		}
	}
	// include padding inside the box
	content_x := x + pad_left
	content_y := y + pad_top
	content_w := math.max(0, w - pad_left - pad_right)
	content_h := math.max(0, h - pad_top - pad_bot)
	// register this box
	out << LayoutBox{x, y, w, h, unsafe { n }}
	// flow children
	// for simplicity: block & inline-block each start at content_x,y
	for child in n.children {
		compute_layout(child, content_x, content_y, content_w, content_h, mut out)
	}
}

fn paint_text_with_formatters(mut cvs Canvas, txt string, x int, y int, w int, h int,
	fg_fn fn (string) string,
	bg_fn fn (string) string,
	style_fns []fn (string) string,
	ws string) {
	mut cx := x
	mut cy := y
	for r in txt.runes() {
		if cx >= x + w {
			if ws == 'wrap' {
				cx = x
				cy++
				if cy >= y + h {
					break
				}
			} else {
				break
			}
		}
		if cx in 0..cvs.width && cy in 0..cvs.height {
			mut cell := &cvs.cells[cy][cx]
			cell.ch = r
			cell.fg_fmt = fg_fn
			cell.bg_fmt = bg_fn
			cell.style_fmts = style_fns.clone()
		}
		cx++
	}
}

//–– Painting ––
fn paint_box(mut cvs Canvas, lb LayoutBox) {
	n := lb.node
	bg_val := n.get_style('background-color')
	fg_val := n.get_style('color')
	bs_val := n.get_style('border-style')
	// bc_val := n.get_style('border-color')
	fs_val := n.get_style('font-style') // our custom attribute

	bg_fmt := bg_formatter(bg_val)
	fg_fmt := fg_formatter(fg_val)
	style_fns := style_formatters(fs_val)

	// 1) fill background
	for yy in lb.y .. math.min(cvs.height, lb.y + lb.height) {
		for xx in lb.x .. math.min(cvs.width, lb.x + lb.width) {
			cvs.cells[yy][xx].bg_fmt = bg_fmt
		}
	}

	// 2) draw border (uses fg_fmt for the line runes)
	if parse_border_style(bs_val) != .none {
		draw_border(mut cvs, lb.x, lb.y, lb.width, lb.height, parse_border_style(bs_val),
			fg_fmt, bg_fmt) // draw_border will call fg_formatter internally
	}

	// 3) paint text with all three layers
	if n.text.len > 0 {
		paint_text_with_formatters(mut cvs, n.text, lb.x, lb.y, lb.width, lb.height, fg_fmt,
			bg_fmt, style_fns, n.get_style('white-space'))
	}

	// 4) scrollbars etc… (analogous)
}

//–– Unit parsing ––
fn compute_unit(val string, parent int) int {
	if val.ends_with('%') {
		pct := val[..val.len - 1].int()
		return parent * pct / 100
	}
	if val.ends_with('div') {
		d := val[..val.len - 3].int()
		if d > 0 {
			return parent / d
		}
	}
	if val != '' {
		return val.int()
	}
	return parent
}

// parse_box_values – Box shorthand parsing ––
fn parse_box_values(val string, parent int) (int, int, int, int) {
	if val == '' {
		return 0, 0, 0, 0
	}
	parts := val.split_any(' ,')
	nums := parts.map(it.int())
	match nums.len {
		1 { return nums[0], nums[0], nums[0], nums[0] }
		2 { return nums[0], nums[1], nums[0], nums[1] }
		3 { return nums[0], nums[1], nums[2], nums[1] }
		4 { return nums[0], nums[1], nums[2], nums[3] }
		else { return 0, 0, 0, 0 }
	}
}

fn draw_border(mut cvs Canvas, x int, y int, w int, h int, st BorderStyle, fg_fmt StringTransform, bg_fmt StringTransform) {
	// choose characters
	mut cch := ` `
	mut hch := ` `
	mut vch := ` `
	match st {
		.solid {
			cch = `+`
			hch = `─`
			vch = `│`
		}
		.dashed {
			cch = `.`
			hch = `-`
			vch = `|`
		}
		.dotted {
			cch = ` `
			hch = `.`
			vch = `:`
		}
		else {}
	}
	// top/bottom
	for xx in x .. x + w {
		if y >= 0 && y < cvs.height {
			cvs.cells[y][xx].ch = hch
			cvs.cells[y][xx].fg_fmt = fg_fmt
			cvs.cells[y][xx].bg_fmt = bg_fmt
		}
		if y + h - 1 >= 0 && y + h - 1 < cvs.height {
			cvs.cells[y + h - 1][xx].ch = hch
			cvs.cells[y + h - 1][xx].fg_fmt = fg_fmt
			cvs.cells[y + h - 1][xx].bg_fmt = bg_fmt
		}
	}
	// left/right
	for yy in y .. y + h {
		if x >= 0 && x < cvs.width {
			cvs.cells[yy][x].ch = vch
			cvs.cells[yy][x].fg_fmt = fg_fmt
			cvs.cells[yy][x].bg_fmt = bg_fmt
		}
		if x + w - 1 >= 0 && x + w - 1 < cvs.width {
			cvs.cells[yy][x + w - 1].ch = vch
			cvs.cells[yy][x + w - 1].fg_fmt = fg_fmt
			cvs.cells[yy][x + w - 1].bg_fmt = bg_fmt
		}
	}
	cvs.cells[y][x].ch = cch
	cvs.cells[y][x + w - 1].ch = cch
	cvs.cells[y + h - 1][x].ch = cch
	cvs.cells[y + h - 1][x + w - 1].ch = cch
}

//–– Text painting ––
fn paint_text(mut cvs Canvas, txt string, x int, y int, w int, h int, fg_fmt StringTransform, bg_fmt StringTransform, ws string) {
	mut col := txt.runes()
	mut cx := x
	mut cy := y
	for r in col {
		if cx >= x + w {
			if ws == 'wrap' {
				cx = x
				cy++
				if cy >= y + h {
					break
				}
			} else {
				break
			}
		}
		if cx >= 0 && cx < cvs.width && cy >= 0 && cy < cvs.height {
			cvs.cells[cy][cx].ch = r
			cvs.cells[cy][cx].fg_fmt = fg_fmt
			cvs.cells[cy][cx].bg_fmt = bg_fmt
		}
		cx++
	}
}

//–– Scrollbar markers ––
fn draw_h_scrollbar(mut cvs Canvas, x int, y int, w int) {
	for xx in x .. x + w {
		if y >= 0 && y < cvs.height {
			cvs.cells[y][xx].ch = `¯`
			cvs.cells[y][xx].fg_fmt = fg_formatter('black')
			cvs.cells[y][xx].fg_fmt = bg_formatter('white')
		}
	}
}

fn draw_v_scrollbar(mut cvs Canvas, x int, y int, h int) {
	for yy in y .. y + h {
		if x >= 0 && x < cvs.width {
			cvs.cells[yy][x].ch = `|`
			cvs.cells[yy][x].fg_fmt = fg_formatter('black')
			cvs.cells[yy][x].fg_fmt = bg_formatter('white')
		}
	}
}
