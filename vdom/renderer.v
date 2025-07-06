module vdom

import math

pub struct Canvas {
	width  u32
	height u32
}

// ─── RENDERER ───────────────────────────────────────────────────────────────────

pub fn render(dom DOM, canvas Canvas, stylesheet CssStylesheet) map[string][]Drawable {
	mut out := map[string][]Drawable{}
	// initial containing block = entire canvas
	render_node(dom.root, stylesheet, BoundingBox{'Canvas', 0, 0, int(canvas.width), int(canvas.height), 0}, mut
		out, 0)
	return out
}

fn render_node(node &DomNode, stylesheet CssStylesheet, parent_box BoundingBox, mut out map[string][]Drawable, z i64) BoundingBox {
	mut zz := z
	css_sheet := stylesheet.get_style(node)
	dump('${node.attributes['id']} ${css_sheet}')
	css := css_sheet.override(node.style)
	dump('${node.attributes['id']} ${css}')
	// dump('// 3) text node')
	mut css_box := css.get_css_box()
	zz++
	mut b := BoundingBox{
		typ: 'NodeBox'
		x:   parent_box.x + css_box.x
		y:   parent_box.y + css_box.y
		w:   css_box.w
		h:   css_box.h
		z:   zz
	}
	out[node.id] = []
	out[node.id] << Rect{
		typ:          'Rect'
		css:          node.style.to_string()
		x:            b.x
		y:            b.y
		width:        b.w
		height:       b.h
		color_config: css.text_style
		z_index:      zz++
	}
	// dump('// 2) borders')
	if node.style.border.style != .none {
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
		out[node.id] << Horizontal{'HorizontalTop', node.style.to_string(), b.x, b.y, '${tl}${t.repeat(int(b.w) - 2)}${tr}', cc, zz}
		// bottom
		zz++
		out[node.id] << Horizontal{'HorizontalBottom', node.style.to_string(), b.x, b.y + b.h - 1, '${bl}${bb.repeat(int(b.w) - 2)}${br}', cc, zz}
		// left
		zz++
		out[node.id] << Vertical{'VerticalLeft', node.style.to_string(), b.x, b.y + 1, '${l.repeat(int(b.h) - 2)}', cc, zz}
		// right
		zz++
		out[node.id] << Vertical{'VerticalRight', node.style.to_string(), b.x + b.w - 1, b.y + 1, '${r.repeat(int(b.h) - 2)}', cc, zz}
	}
	// last_y := i64(0)
	for child in node.children {
		zz++
		if child.tag == '#text' {
			zz++
			out[node.id] << Text{
				typ:          'Text'
				css:          node.style.to_string()
				x:            parent_box.x + 1
				y:            parent_box.y + 1
				value:        node.inner_text()
				color_config: css.text_style
				z_index:      zz
			}
			b.h += 1
			b.w = math.max(b.h, node.text.len)
		} else {
			rb := render_node(child, stylesheet, b, mut out, zz)
			zz = rb.z
		}
		// recurse
	}
	b.z = zz
	return b
}
