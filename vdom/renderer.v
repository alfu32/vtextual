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
	out, bb := canvas.render_node(dom.root, stylesheet, BoundingBox{'Canvas', 1, 1, int(canvas.width), int(canvas.height), 0},
		0)
	_ := bb
	return out
}

fn (canvas &Canvas) render_node(node &DomNode, stylesheet &CssStylesheet, parent_box BoundingBox, z i64) (map[string][]&Drawable, BoundingBox) {
	mut out := map[string][]&Drawable{}
	mut zz := z
	css_sheet := stylesheet.get_style(node)
	// dump('${node.attributes['id']} ${css_sheet}')
	css := css_sheet.override(node.style)
	// dump('${node.attributes['id']} ${css}')
	// dump('// 3) text node')
	mut css_box := css.get_css_box()
	zz++
	mut bounding_box := BoundingBox{
		typ: 'NodeBox'
		x:   parent_box.x + css_box.x
		y:   parent_box.y + css_box.y
		w:   css_box.w
		h:   css_box.h
		z:   zz
	}
	mut content_box := BoundingBox{
		typ: 'ChildrenBox'
		x:   parent_box.x + css_box.x - node.scroll.x
		y:   parent_box.y + css_box.y - node.scroll.y
		w:   css_box.w
		h:   css_box.h
		z:   zz
	}
	out[node.id] << &Rect{
		typ:          'Rect'
		css:          node.style.to_string()
		x:            bounding_box.x
		y:            bounding_box.y
		width:        bounding_box.w
		height:       bounding_box.h
		color_config: css.text_style.copy()
		z_index:      zz++
	}
	// last_y := i64(0)
	mut cursor := content_box.top_left()
	if css.border.style != .none {
		cursor = cursor.add(x: 1, y: 1)
	}
	for child in node.children {
		zz++
		if child.tag == '#text' {
			zz++
			for line in canvas.split_text_words(node.inner_text(), u64(bounding_box.w - 2)) {
				out[node.id] << &Text{
					typ:          'Text'
					css:          node.style.to_string()
					x:            cursor.x
					y:            cursor.y
					value:        line
					color_config: css.text_style.copy()
					z_index:      zz
				}
				cursor.y += 1
				content_box.h += 1
				content_box.w = math.max(bounding_box.h, line.len)
			}
		} else {
			//
			dwgs, rb := canvas.render_node(child, stylesheet, bounding_box.translate(
				x: -node.scroll.x
				y: -node.scroll.y
				z: zz
			), zz)
			zz = rb.z
			content_box.add(rb)
			for id, dwg in dwgs {
				out[id] = dwg
			}
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
	if css.border.style != .none {
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
		zz++
		out[node.id] << &Horizontal{
			typ:          'HorizontalTop'
			css:          css.border.to_string()
			x:            bounding_box.x
			y:            bounding_box.y
			value:        '${tl}${t.repeat(int(bounding_box.w) - 2)}${tr}'
			color_config: css.border.copy()
			z_index:      zz
		}
		// bottom
		zz++
		out[node.id] << &Horizontal{
			typ:          'HorizontalBottom'
			css:          css.border.to_string()
			x:            bounding_box.x
			y:            bounding_box.y + bounding_box.h - 1
			value:        '${bl}${bb.repeat(int(bounding_box.w) - 2)}${br}'
			color_config: css.border.copy()
			z_index:      zz
		}
		// left
		zz++
		out[node.id] << &Vertical{
			typ:          'VerticalLeft'
			css:          css.border.to_string()
			x:            bounding_box.x
			y:            bounding_box.y + 1
			value:        '${l.repeat(int(bounding_box.h) - 2)}'
			color_config: css.border.copy()
			z_index:      zz
		}
		// right
		zz++
		out[node.id] << &Vertical{
			typ:          'VerticalRight'
			css:          css.border.to_string()
			x:            bounding_box.x + bounding_box.w - 1
			y:            bounding_box.y + 1
			value:        '${r.repeat(int(bounding_box.h) - 2)}'
			color_config: css.border.copy()
			z_index:      zz
		}
	}
	if content_box.w > bounding_box.w {
		bar_w := bounding_box.w * bounding_box.w / content_box.w
		pos_x := node.scroll.x * bounding_box.w / content_box.w
		zz++
		out[node.id] << &Horizontal{
			typ:          'ScrollBarX'
			css:          css.border.to_string()
			x:            bounding_box.x + node.scroll.x + 1
			y:            bounding_box.y + bounding_box.h - 1
			value:        '█'.repeat(int(bar_w))
			color_config: css.border.copy()
			z_index:      zz
		}
	}
	if content_box.h > bounding_box.h {
		bar_h := bounding_box.h * bounding_box.h / content_box.h
		pos_y := node.scroll.y * bounding_box.h / content_box.h
		zz++
		out[node.id] << &Vertical{
			typ:          'ScrollBarY'
			css:          css.border.to_string()
			x:            bounding_box.x + bounding_box.w - 1
			y:            bounding_box.y + node.scroll.y + 1
			value:        '█'.repeat(int(bar_h))
			color_config: css.border.copy()
			z_index:      zz
		}
	}
	bounding_box.z = zz
	// // out[node.id] = []
	// for d in drawables {
	// 	out[node.id] << d
	// }
	return out, bounding_box
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
