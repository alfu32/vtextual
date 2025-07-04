module vdom

// ─── DRAWABLES ───────────────────────────────────────────────────────────────

// pub type Color = string

pub struct Box {
pub mut:
	typ string = 'box'
	x   int
	y   int
	w   int
	h   int
	z   u64
}

pub fn (b Box) grow(n int) Box {
	mut nw := b.w
	mut nh := b.h
	mut ny := b.y
	mut nx := b.x
	if nw + 2 * n > 0 {
		nw = nw + 2 * n
		nx = nx - n
	}
	if nh + 2 * n > 0 {
		nh = nh + 2 * n
		ny = ny - n
	}
	return Box{
		typ: 'box'
		x:   nx
		y:   ny
		w:   nw
		h:   nh
		z:   b.z + 1
	}
}

pub fn (b Box) below() Box {
	return Box{
		typ: 'box'
		x:   b.x
		y:   b.y + b.h
		w:   b.w
		h:   b.h
		z:   b.z + 1
	}
}

pub fn (b Box) right() Box {
	return Box{
		typ: 'box'
		x:   b.x + b.w
		y:   b.y
		w:   b.w
		h:   b.h
		z:   b.z + 1
	}
}

pub struct Rect {
	typ          string = 'rect'
	css          string
	x            int
	y            int
	width        int
	height       int
	color_config CssColorConfig
	z_index      u64
}

pub struct Horizontal {
	typ          string = 'horizontal'
	css          string
	x            int
	y            int
	value        string
	color_config CssColorConfig
	z_index      u64
}

pub struct Vertical {
	typ          string = 'vertical'
	css          string
	x            int
	y            int
	value        string
	color_config CssColorConfig
	z_index      u64
}

pub struct Text {
	typ          string = 'text'
	css          string
	x            int
	y            int
	value        string
	color_config CssColorConfig
	z_index      u64
}

pub type Drawable = Rect | Horizontal | Vertical | Text

struct Rectangle {
	x int
	y int
	w int
	h int
}

pub fn (r Rectangle) str() string {
	return '[${r.x},${r.y},${r.x + r.w},${r.y + r.h}]'
}

pub fn (d Drawable) get_bounding_rect() Rectangle {
	return match d {
		Rect {
			Rectangle{
				x: d.x
				y: d.y
				w: d.width
				h: d.height
			}
		}
		Horizontal {
			Rectangle{
				x: d.x
				y: d.y
				w: d.value.len
				h: 1
			}
		}
		Vertical {
			Rectangle{
				x: d.x
				y: d.y
				w: 1
				h: d.value.len
			}
		}
		Text {
			Rectangle{
				x: d.x
				y: d.y
				w: d.value.len
				h: 1
			}
		}
	}
}
