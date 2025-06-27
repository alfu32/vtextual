module vdom

import strings

pub struct Canvas {
	width  u32
	height u32
}

// ─── RENDERER ───────────────────────────────────────────────────────────────────

pub fn render(dom DOM, canvas Canvas) []Drawable {
	mut out := []Drawable{}
	// initial containing block = entire canvas
	render_node(dom.root, 0, 0, int(canvas.width), int(canvas.height), mut out, 0, 0,
		0, int(canvas.width), int(canvas.height))
	return out
}

fn render_node(node &DomNode,
	x int, y int, w int, h int,
	mut out []Drawable, z u64,
	cb_x int, cb_y int, cb_w int, cb_h int) {
	// 1) background
	if node.style.text_style.bg != 0 {
		out << Rect{'Rect', node.style.to_string(), x, y, w, h, node.style.text_style, z}
	}
	println('// 2) borders')
	if node.style.border.style != .none {
		bc := (node.style.text_style)
		// top
		out << Horizontal{'Horizontal', node.style.to_string(), x, y, strings.repeat('─'[0],
			w), bc, z + 1}
		// bottom
		out << Horizontal{'Horizontal', node.style.to_string(), x, y + h - 1, strings.repeat('─'[0],
			w), bc, z + 1}
		// left & right
		for dy in 0 .. h {
			out << Vertical{'Vertical', node.style.to_string(), x, y + dy, '│', bc, z + 1}
			out << Vertical{'Vertical', node.style.to_string(), x + w - 1, y + dy, '│', bc, z + 1}
		}
	}
	println('// 3) text node')
	if node.tag == '#text' {
		out << Text{'Text', node.style.to_string(), x, y, node.text, (node.style.text_style), z + 2}
		return
	}

	// 4) lay out children
	mut flow_x := x
	mut flow_y := y
	for child in node.children {
		// size
		cw := compute_width(child, w)
		ch := compute_height(child, h)

		// positioning
		mut cx := flow_x
		mut cy := flow_y

		if child.style.position == .absolute {
			// use containing block
			origin_x, origin_y, origin_w, origin_h := cb_x, cb_y, cb_w, cb_h
			// horizontal
			if child.style.left.typ != .auto {
				cx = origin_x + int(child.style.left.value)
			} else if child.style.right.typ != .auto {
				cx = origin_x + origin_w - cw - int(child.style.right.value)
			} else {
				cx = origin_x
			}
			// vertical
			if child.style.top.typ != .auto {
				cy = origin_y + int(child.style.top.value)
			} else if child.style.bottom.typ != .auto {
				cy = origin_y + origin_h - ch - int(child.style.bottom.value)
			} else {
				cy = origin_y
			}
		} else {
			// static or relative in flow
			if child.style.position == .relative {
				if child.style.left.typ != .auto {
					cx += int(child.style.left.value)
				}
				if child.style.top.typ != .auto {
					cy += int(child.style.top.value)
				}
			}
		}

		// overflow clipping
		if node.style.overflow_x == .hidden {
			if cx < x || cx + cw > x + w {
				continue
			}
		}
		if node.style.overflow_y == .hidden {
			if cy < y || cy + ch > y + h {
				continue
			}
		}

		// determine new containing block
		mut ncb_x, mut ncb_y, mut ncb_w, mut ncb_h := cb_x, cb_y, cb_w, cb_h
		if child.style.position == .relative {
			ncb_x, ncb_y, ncb_w, ncb_h = cx, cy, cw, ch
		}

		// recurse
		render_node(child, cx, cy, cw, ch, mut out, z + 1, ncb_x, ncb_y, ncb_w, ncb_h)

		// advance flow for non-absolute
		if child.style.position != .absolute {
			flow_x += cw
			if flow_x >= x + w {
				flow_x = x
				flow_y += ch
			}
		}
	}
}

// compute_width/compute_height unchanged…

fn compute_width(node &DomNode, parent_w int) int {
	d := node.style.width
	return match d.typ {
		.chars {
			int(d.value)
		}
		.percent {
			int(parent_w * d.value / 100)
		}
		else {
			if node.style.display == .block {
				parent_w
			} else if node.tag == '#text' {
				node.text.len
			} else {
				parent_w
			}
		}
	}
}

fn compute_height(node &DomNode, parent_h int) int {
	d := node.style.height
	return match d.typ {
		.chars {
			int(d.value)
		}
		.percent {
			int(parent_h * d.value / 100)
		}
		else {
			if node.style.display == .block {
				// sum of child heights
				mut sum := 0
				for c in node.children {
					sum += compute_height(c, parent_h)
				}
				return if sum > 0 { sum } else { 1 }
			} else if node.tag == '#text' {
				1
			} else {
				1
			}
		}
	}
}
