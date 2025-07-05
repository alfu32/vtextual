module vdom

import term

struct VTRenderer {
pub mut:
	canvas     Canvas
	document   DOM
	stylesheet CssStylesheet
}

pub fn vt_renderer_init(html string, css string, width u32, height u32) VTRenderer {
	dom := dom_parse(html)
	stylesheet := css_stylesheet_parse(css)
	return VTRenderer{
		canvas:     Canvas{
			width:  width
			height: height
		}
		document:   dom
		stylesheet: stylesheet
	}
}

pub fn (vt VTRenderer) render_debug() {
	print(vt)
	for node_id, drawables in render2(vt.document, vt.stylesheet, vt.canvas) {
		println(node_id)
		for drawable in drawables {
			match drawable {
				Rect {
					println(drawable)
				}
				Horizontal {
					println(drawable)
				}
				Vertical {
					println(drawable)
				}
				Text {
					println(drawable)
				}
			}
		}
	}
}

pub fn (vt VTRenderer) render() {
	term.clear()
	for node_id, drawables in render2(vt.document, vt.stylesheet, vt.canvas) {
		node := vt.document.find_node(node_id)
		_ := node_id
		for drawable in drawables {
			match drawable {
				Rect {
					draw_rect(drawable, node)
				}
				Horizontal {
					draw_horizontal(drawable, node)
				}
				Vertical {
					draw_vertical(drawable, node)
				}
				Text {
					draw_text(drawable, node)
				}
			}
		}
	}
	term.set_cursor_position(x: 0, y: int(vt.canvas.height + 1))
	println(term.reset('\n'))
}

fn draw_rect(r Rect, node ?&DomNode) {
	// // println(r)
	chr := ' '[0] //(rand.u8()%95)+33

	for y in 1 .. r.height - 1 {
		term.set_cursor_position(x: r.x, y: r.y + y)
		fg := term.rgb(r.color_config.fg_red(), r.color_config.fg_green(), r.color_config.fg_blue(), // "${r.x:03}x${y:02}"+
		 chr.ascii_str().repeat(r.width - 2))
		print(term.bg_rgb(r.color_config.bg_red(), r.color_config.bg_green(), r.color_config.bg_blue(),
			fg))
	}
	term.set_cursor_position(x: r.x + r.width - 11, y: r.y + r.height - 1)
	if node != none {
		print(' ${node.tag} ')
	} else {
		print(' undefined ')
	}
}

fn draw_horizontal(h Horizontal, node ?&DomNode) {
	term.set_cursor_position(x: h.x, y: h.y)
	print(h.value)
}

fn draw_vertical(v Vertical, node ?&DomNode) {
	for y in 0 .. v.value.len {
		term.set_cursor_position(x: v.x, y: v.y + y)
		print(v.value[y].ascii_str())
	}
}

fn draw_text(t Text, node ?&DomNode) {
	term.set_cursor_position(x: t.x, y: t.y)
	print(t.value)
}
