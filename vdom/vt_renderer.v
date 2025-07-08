module vdom

import term
import term.ui as tui

pub struct VTRenderer {
pub mut:
	canvas     Canvas
	document   &DOM
	stylesheet &CssStylesheet
	events     []&tui.Event
}

pub fn vt_renderer_init(html string, css string, width u32, height u32) VTRenderer {
	dom := dom_parse(html)
	stylesheet := css_stylesheet_parse(css)
	return VTRenderer{
		canvas:     Canvas{
			width:  width
			height: height
		}
		document:   &dom
		stylesheet: &stylesheet
	}
}

pub fn (vt VTRenderer) render_debug() {
	println(vt)
	for node_id, drawables in vt.canvas.render(vt.document, vt.stylesheet) {
		println(node_id)
		for drawable in drawables {
			match drawable {
				Rect {
					println(drawable.color_config.apply('${drawable}'))
				}
				Horizontal {
					println(drawable.color_config.apply('${drawable}'))
				}
				Vertical {
					println(drawable.color_config.apply('${drawable}'))
				}
				Text {
					println(drawable.color_config.apply('${drawable}'))
				}
			}
		}
	}
}

pub fn (mut vt VTRenderer) render() ? {
	term.set_cursor_position(x: 0, y: 0)
	for node_id, drawables in vt.canvas.render(vt.document, vt.stylesheet) {
		mut node := vt.document.find_node(node_id)
		// if node != none {
		_ := node_id
		mut has_event := vt.events.len > 0
		mut raise_event := false
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
			if !raise_event {
				if has_event {
					mut event := vt.events[0]
					raise_event = drawable.get_bounding_box().contains_point(x: event.x, y: event.y)
				}
			}
		}
		if raise_event {
			if has_event {
				mut event := vt.events[0]
				node?.dispatch_event(event)
				vt.events.delete(0)
			}
		}
		// }
	}
	term.set_cursor_position(x: 0, y: int(vt.canvas.height + 1))
	println(term.reset('\n'))
}

pub fn (mut vt VTRenderer) dispatch_event(e &tui.Event) {
	vt.events << e
}

fn draw_rect(r Rect, node ?&DomNode) {
	// // println(r)

	for y in 1 .. int(r.height) {
		term.set_cursor_position(x: int(r.x), y: int(r.y) + y)
		tx := ` `.repeat(int(r.width - 1)) // "${r.x:03}x${y:02}"+
		print(r.color_config.apply(tx))
	}
	// term.set_cursor_position(x: int(r.x + r.width) - 11, y: int(r.y + r.height) - 1)
	// if node != none {
	// 	print(' ${node.tag} ')
	// } else {
	// 	print(' undefined ')
	// }
}

fn draw_horizontal(h Horizontal, node ?&DomNode) {
	term.set_cursor_position(x: int(h.x), y: int(h.y))
	print(h.color_config.apply(h.value))
}

fn draw_vertical(v Vertical, node ?&DomNode) {
	runes := v.value.runes()
	mut y := 0
	for r in runes {
		term.set_cursor_position(x: int(v.x), y: int(v.y) + y)
		print(v.color_config.apply(r.str()))
		y += 1
	}
}

fn draw_text(t Text, node ?&DomNode) {
	term.set_cursor_position(x: int(t.x), y: int(t.y))
	print(t.color_config.apply(t.value))
}
