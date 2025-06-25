module vdom

// A filled/bordered rectangle
pub struct Rect {
pub:
	x            f32
	y            f32
	width        f32
	height       f32
	border_style BorderStyle
	border_color string
	fill_color   string
}

pub fn (r Rect) is_graphic_primitive() {} // satisfy interface

// A text run
pub struct Text {
pub:
	x          f32
	y          f32
	content    string
	fill_color string
	color      string
}

pub fn (t Text) is_graphic_primitive() {} // satisfy interface

// Now we can return &[GraphicPrimitive]
pub interface GraphicPrimitive {
	is_graphic_primitive() // marker
}

//–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
// Helpers to parse CSS‐like strings
//–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

// "42px" → 42.0; else tries raw f32()
pub fn parse_pixel(s string) f32 {
	if s.ends_with('px') {
		return s.substr(s.len - 2, s.len).f32()
	}
	return s.f32()
}

//–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
// The renderer entrypoint
//–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

pub fn render(root &Node) []GraphicPrimitive {
	mut out := []GraphicPrimitive{}
	// we assume the root’s (0,0) is top-left of the viewport
	layout_node(root, 0.0, 0.0, mut out)
	return out
}

// Recursively layout each node at absolute (offset_x,offset_y)
fn layout_node(n &Node, offset_x f32, offset_y f32, mut acc []GraphicPrimitive) {
	// 1) Compute this node’s box
	mut x := offset_x
	mut y := offset_y

	// handle absolute positioning
	if n.get_style('position') == 'absolute' {
		left := parse_pixel(n.get_style('left'))
		top := parse_pixel(n.get_style('top'))
		x = left
		y = top
	}
	mut v := n.get_style('width')
	w := if v != '' { parse_pixel(v) } else { 0.0 }
	v = n.get_style('height')
	h := if v != '' { parse_pixel(v) } else { 0.0 }

	// 2) Emit a background/border rect if needed
	bg := n.get_style('background-color')
	bs := parse_border_style(n.get_style('border-style'))
	bc := n.get_style('border-color')
	if bg != '' || bs != .none {
		acc << Rect{
			x:            x
			y:            y
			width:        w
			height:       h
			border_style: bs
			border_color: bc
			fill_color:   bg
		}
	}

	// 3) Emit text if this node carries text
	if n.text.len > 0 {
		acc << Text{
			x:          x
			y:          y
			content:    n.text
			fill_color: bg
			color:      n.get_style('color')
		}
	}

	// 4) Recursively layout children.
	//    Here we’re just passing down the same origin.
	//    A real flow/layout engine would bump `offset_y` or respect margins/padding.
	for child in n.children {
		layout_node(child, x, y, mut acc)
	}
}
