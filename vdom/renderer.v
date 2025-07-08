module vdom

import math
import arrays

pub struct Canvas {
	width  u32
	height u32
}

// ─── RENDERER ───────────────────────────────────────────────────────────────────

pub fn (canvas &Canvas) render(dom &DOM, stylesheet &CssStylesheet) map[string][]&Drawable {
	// initial containing block = entire canvas
	mut drawables := map[string][]&Drawable{}
	drawables['canvas'] = []

	drawables['canvas'] << &Rect{
		typ:          'Rect'
		css:          ''
		x:            0
		y:            0
		width:        int(canvas.width)
		height:       int(canvas.height)
		color_config: CssColorConfig{
			styles:     []
			color:      css_color_parse('#dede33') or {
				CssColor{
					value: 0x123123
					typ:   .rgb
				}
			}
			background: css_color_parse('#232333') or {
				CssColor{
					value: 0x123123
					typ:   .rgb
				}
			}
			typ:        .default
		}
		z_index:      0
	}
	out, bb, cursor := canvas.render_node(dom.root.children[0], stylesheet, BoundingBox{'Canvas', 1, 1, int(canvas.width), int(canvas.height), 0},
		BoundingBox{'SiblingBox0', 1, 1, 0, 0, 0}, mut Point{})
	_ := bb
	for id, dwc in out {
		drawables[id] = dwc
	}
	return drawables
}

fn (canvas &Canvas) render_node(node &DomNode, stylesheet &CssStylesheet, parent_box BoundingBox, sibling_box BoundingBox, mut cursor Point) (map[string][]&Drawable, BoundingBox, Point) {
	mut out := map[string][]&Drawable{}
	css_sheet := stylesheet.get_style(node)
	// dump('${node.attributes['id']} ${css_sheet}')
	css := css_sheet.override(node.style)
	border_size := if css.border.style !in [.none, .undefined] { 1 } else { 0 }
	extension_size := if css.border.style !in [.none, .undefined] { 0 } else { 1 }
	// dump('${node.attributes['id']} ${css}')
	// dump('// 3) text node')
	mut css_box := css.get_css_box(parent_box)
	mut bounding_box := match css.position {
		.undefined, .relative_parent {
			BoundingBox{
				typ: 'NodeBoxRelativeParent'
				x:   parent_box.x + css_box.x
				y:   parent_box.y + css_box.y
				w:   css_box.w
				h:   css_box.h
				z:   cursor.next_z()
			}
		}
		.relative_sibling {
			BoundingBox{
				typ: 'NodeBoxRelativeSibling'
				x:   parent_box.x + match css.direction {
					.ltr { sibling_box.x + sibling_box.w }
					.ttb { 0 }
					.undefined { 0 }
				}
				y:   parent_box.y + match css.direction {
					.ltr { 0 }
					.ttb { sibling_box.y + sibling_box.h - 1 }
					.undefined { 0 }
				}
				w:   css_box.w
				h:   css_box.h
				z:   cursor.next_z()
			}
			// BoundingBox{
			// 	typ: 'NodeBoxRelativeSibling'
			// 	x:   parent_box.x + css_box.x
			// 	y:   parent_box.y + css_box.y
			// 	w:   css_box.w
			// 	h:   css_box.h
			// 	z:   cursor.next_z()
			// }
		}
		.absolute {
			BoundingBox{
				typ: 'NodeBoxAbsolute'
				x:   css_box.x
				y:   css_box.y
				w:   css_box.w
				h:   css_box.h
				z:   cursor.next_z()
			}
		}
	}
	mut content_box := BoundingBox{
		typ: 'ChildrenBox'
		x:   parent_box.x + css_box.x - node.scroll.x
		y:   parent_box.y + css_box.y - node.scroll.y
		w:   css_box.w
		h:   css_box.h
		z:   cursor.next_z()
	}
	out[node.id] << &Rect{
		typ:          'Rect'
		css:          node.style.to_string()
		x:            bounding_box.x - extension_size
		y:            bounding_box.y - extension_size
		width:        bounding_box.w + 2 * extension_size
		height:       bounding_box.h + 2 * extension_size
		color_config: css.text_style.copy()
		z_index:      cursor.next_z()
	}
	// last_y := i64(0)
	cursor = bounding_box.top_left()
	if border_size > 0 {
		cursor = cursor.add(x: 1, y: 1)
	}
	mut last_child := dom_node_new()
	mut last_child_css := css_style_new()
	mut last_child_box := BoundingBox{
		typ: 'SiblingBox0'
		x:   border_size
		y:   border_size
		w:   border_size
		h:   border_size
		z:   cursor.next_z()
	}
	for child in node.children {
		mut child_css := stylesheet.get_style(node).override(child.style)
		if child.tag == '#text' {
			if node.inner_text().trim(' \n\r\t') == '' {
				continue
			}
			for line in canvas.split_text_words(node.inner_text(), u64(bounding_box.w - 2)) {
				if line.trim(' \n\r\t') == '' {
					continue
				}
				t := &Text{
					typ:          'Text'
					css:          css.to_string()
					x:            cursor.x
					y:            cursor.y
					value:        line
					color_config: css.text_style.copy()
					z_index:      cursor.next_z()
				}
				// if Drawable(t).get_bounding_box().overlaps(bounding_box) {
				out[node.id] << t
				//}
				cursor.y += 1
				content_box.h += 1
				content_box.w = math.max(bounding_box.h, line.len)
				last_child_box = BoundingBox{
					typ: 'lastChild'
					x:   cursor.x
					y:   cursor.y
					w:   line.len
					h:   1
					z:   cursor.next_z()
				}
			}
		} else if child_css.position == .relative_parent || child_css.position == .undefined {
			//
			dwgs, rb, last_pos := canvas.render_node(child, stylesheet, bounding_box.translate(
				x: -node.scroll.x
				y: -node.scroll.y
				z: 0
			), last_child_box.translate(
				x: -node.scroll.x
				y: -node.scroll.y
				z: 0
			), mut cursor)
			content_box.add(rb)
			for id, dwg in dwgs {
				for d in dwg {
					// if bounding_box.overlaps(d.get_bounding_box()) {
					out[id] << d
					//}
				}
			}
			last_child_box.x = rb.x
			last_child_box.y = rb.y
			last_child_box.w = rb.w
			last_child_box.h = rb.h
		} else if child_css.position == .relative_sibling {
			//
			mut dwgs, rb, last_pos := canvas.render_node(child, stylesheet, bounding_box.translate(
				x: -node.scroll.x
				y: -node.scroll.y
				z: cursor.next_z()
			), last_child_box.translate(
				x: -border_size * 2
				y: -border_size * 2
				z: cursor.next_z()
			), mut cursor)
			content_box.add(rb)
			for id, mut dwg in dwgs {
				mut ord := i64(0)
				for d in dwg {
					// if bounding_box.overlaps(d.get_bounding_box()) {
					// d.y += ord*3
					out[id] << d
					//}
				}
				ord += 1
			}
			last_child_box.x = rb.x
			last_child_box.y = rb.y
			last_child_box.w = rb.w
			last_child_box.h = rb.h
		} else if child.style.position == .absolute {
		}

		match child.style.position {
			.relative_parent {}
			.relative_sibling {}
			.absolute {}
			.undefined {}
		}
		// recurse
	}
	// dump('// 2) borders')
	if border_size > 0 {
		cc := css.border
		runes := cc.definition.runes()
		// ╭─────────╮
		// │         │
		// │         │
		// ╰─────────╯
		tl := runes[0] or { `╭` }
		t := runes[1] or { `─` }
		tr := runes[2] or { `╮` }
		l := runes[3] or { `│` }
		bl := runes[4] or { `╰` }
		bb := runes[5] or { `─` }
		br := runes[6] or { `╯` }
		r := runes[7] or { `│` }
		// top
		out[node.id] << &Horizontal{
			typ:          'HorizontalTop'
			css:          css.border.to_string()
			x:            bounding_box.x
			y:            bounding_box.y
			value:        '${tl}${t.repeat(int(bounding_box.w) - 2)}${tr}'
			color_config: css.border.copy()
			z_index:      cursor.next_z()
		}
		// top box
		out[node.id] << &Horizontal{
			typ:          'HorizontalBottomBoxInfo'
			css:          css.border.to_string()
			x:            bounding_box.x + 2
			y:            bounding_box.y
			value:        '[${css.position}] <${node.tag}> #${node.attributes['id']} .${node.attributes['class']}'
			color_config: css.border.copy()
			z_index:      cursor.next_z()
		}
		// bottom
		out[node.id] << &Horizontal{
			typ:          'HorizontalBottom'
			css:          css.border.to_string()
			x:            bounding_box.x
			y:            bounding_box.y + bounding_box.h - 1
			value:        '${bl}${bb.repeat(int(bounding_box.w) - 2)}${br}'
			color_config: css.border.copy()
			z_index:      cursor.next_z()
		}
		// bottom box
		out[node.id] << &Horizontal{
			typ:          'HorizontalBottomBoxInfo'
			css:          css.border.to_string()
			x:            bounding_box.x + 2
			y:            bounding_box.y + bounding_box.h - 1
			value:        bounding_box.str()
			color_config: css.border.copy()
			z_index:      cursor.next_z()
		}
		// left
		out[node.id] << &Vertical{
			typ:          'VerticalLeft'
			css:          css.border.to_string()
			x:            bounding_box.x
			y:            bounding_box.y + 1
			value:        '${l.repeat(int(bounding_box.h) - 2)}'
			color_config: css.border.copy()
			z_index:      cursor.next_z()
		}
		// right
		out[node.id] << &Vertical{
			typ:          'VerticalRight'
			css:          css.border.to_string()
			x:            bounding_box.x + bounding_box.w - 1
			y:            bounding_box.y + 1
			value:        '${r.repeat(int(bounding_box.h) - 2)}'
			color_config: css.border.copy()
			z_index:      cursor.next_z()
		}
	}
	if content_box.w - 2 * border_size > bounding_box.w {
		bar_w := bounding_box.w * bounding_box.w / content_box.w
		pos_x := node.scroll.x * bounding_box.w / content_box.w
		out[node.id] << &Horizontal{
			typ:          'ScrollBarX'
			css:          css.border.to_string()
			x:            bounding_box.x + node.scroll.x + 1
			y:            bounding_box.y + bounding_box.h - 1
			value:        '█'.repeat(int(bar_w))
			color_config: css.border.copy()
			z_index:      cursor.next_z()
		}
	}
	if content_box.h - 2 * border_size > bounding_box.h {
		bar_h := bounding_box.h * bounding_box.h / content_box.h
		pos_y := node.scroll.y * bounding_box.h / content_box.h
		out[node.id] << &Vertical{
			typ:          'ScrollBarY'
			css:          css.border.to_string()
			x:            bounding_box.x + bounding_box.w - 1
			y:            bounding_box.y + node.scroll.y + 1
			value:        '█'.repeat(int(bar_h))
			color_config: css.border.copy()
			z_index:      cursor.next_z()
		}
	}
	bounding_box.z = cursor.z
	// // out[node.id] = []
	// for d in drawables {
	// 	out[node.id] << d
	// }
	return out, bounding_box, cursor
}

fn identity[T](a T) T {
	return a
}

pub fn (canvas Canvas) split_text(text string, max_width u64) []string {
	mut lines := []string{}
	mut line := []string{}
	for r in text.runes() {
		if line.len >= max_width {
			lines << arrays.join_to_string[string](line, '', identity[string])
			line = []string{}
		}
		line << r.str()
	}
	lines << arrays.join_to_string[string](line, '', identity[string])
	return lines
}

pub fn (canvas Canvas) split_text_words(text string, max_width u64) []string {
	mut lines := []string{}
	mut line := []string{}
	for word in text.split(' ') {
		s := arrays.join_to_string[string](line, ' ', identity[string])
		if (s.len + word.len + 1) >= max_width {
			lines << s
			line = []string{}
		}
		line << word
	}
	lines << arrays.join_to_string[string](line, ' ', identity[string])
	return lines
}
