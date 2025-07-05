module vdom

import strings

pub struct Canvas {
	width  u32
	height u32
}

// ─── RENDERER ───────────────────────────────────────────────────────────────────

pub fn render(dom DOM, canvas Canvas, stylesheet CssStylesheet) map[string][]Drawable {
	mut out := map[string][]Drawable{}
	// initial containing block = entire canvas
	render_node(dom.root, stylesheet, Box{'Canvas', 0, 0, int(canvas.width), int(canvas.height)}, mut
		out, 0)
	return out
}

fn render_node(node &DomNode, stylesheet CssStylesheet,
	parent_box Box,
	mut out map[string][]Drawable, z u64) {
	mut zz := z
	css := stylesheet.apply_to_node(node).override(node.style)
	if node.tag == '#text' {
		out[node.id] << Text{
			typ:          'Text'
			css:          node.style.to_string()
			x:            parent_box.x + 1
			y:            parent_box.y + 1
			value:        node.text
			color_config: css.text_style
			z_index:      xx++
		}
		return
	}
	// dump('// 3) text node')
	css_box := css.get_css_box()
	b := Box{
		typ: 'NodeBox'
		x:   parent_box.x + css_box.x
		y:   parent_box.y + css_box.y
		w:   css_box.w
		h:   css_box.h
		z:   zz++
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
		bc := (node.style.text_style)
		cc := node.style.border
		tl, t, tr, l, bl, bb, br, r := cc.definition.runes()
		// top
		out[node.id] << Horizontal{'HorizontalTop', node.style.to_string(), b.x, b.y, '${tl}${t.repeat(b.w - 2)}${tr}', cc, zz++}
		// bottom
		out[node.id] << Horizontal{'HorizontalBottom', node.style.to_string(), b.x + b.w - 1, b.y, '${bl}${bb.repeat(b.w - 2)}${br}', cc, zz++}
		// left
		out[node.id] << Horizontal{'HorizontalLeft', node.style.to_string(), b.x, b.y + 1, '${l.repeat(b.h - 2)}', cc, zz++}
		// right
		out[node.id] << Horizontal{'HorizontalRight', node.style.to_string(), x, y, '${r.repeat(b.w - 2)}', cc, zz++}
	}
	for child in node.children {
		// recurse
		render_node(child, stylesheet, b, mut out, zz++)
	}
}
