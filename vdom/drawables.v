module vdom

import math

// ─── DRAWABLES ───────────────────────────────────────────────────────────────

// pub type Color = string

pub struct Point {
pub mut:
	x i64
	y i64
	z i64
}

pub fn (a Point) add(b Point) Point {
	return Point{
		x: a.x + b.x
		y: a.y + b.y
		z: a.z + b.z
	}
}

pub fn (a Point) box(b Point) BoundingBox {
	x0 := math.min(a.x, b.x)
	y0 := math.min(a.y, b.y)
	x1 := math.max(a.x, b.x)
	y1 := math.max(a.y, b.y)
	return BoundingBox{
		x: x0
		y: y0
		w: x1 - x0
		h: y1 - y0
		z: 0
	}
}

pub struct BoundingBox {
pub mut:
	typ string = 'box'
	x   i64
	y   i64
	w   i64
	h   i64
	z   i64
}

// Box.z = 0
pub fn (bb BoundingBox) translate(p Point) BoundingBox {
	return BoundingBox{
		typ: 'box'
		x:   bb.x + p.x
		y:   bb.y + p.y
		w:   bb.w
		h:   bb.h
		z:   bb.z + 1
	}
}

// Box.z = 0
pub fn (bb BoundingBox) top_left() Point {
	return Point{
		x: bb.x
		y: bb.y
		z: bb.z
	}
}

pub fn (bb BoundingBox) grow(n i64) BoundingBox {
	mut nw := bb.w
	mut nh := bb.h
	mut ny := bb.y
	mut nx := bb.x
	if nw + 2 * n > 0 {
		nw = nw + 2 * n
		nx = nx - n
	}
	if nh + 2 * n > 0 {
		nh = nh + 2 * n
		ny = ny - n
	}
	return BoundingBox{
		typ: 'box'
		x:   nx
		y:   ny
		w:   nw
		h:   nh
		z:   bb.z + 1
	}
}

pub fn (bb BoundingBox) add(c BoundingBox) BoundingBox {
	x0 := math.min(bb.x, c.x)
	y0 := math.min(bb.y, c.y)
	x1 := math.max(bb.x + bb.w, c.x + c.w)
	y1 := math.max(bb.y + bb.w, c.y + bb.h)
	return BoundingBox{
		typ: bb.typ
		x:   x0
		y:   y0
		w:   x1 - x0
		h:   y1 - y0
		z:   bb.z + 1
	}
}

pub fn (bb BoundingBox) str() string {
	return '[${bb.x},${bb.y},${bb.x + bb.w},${bb.y + bb.h}]'
}

@[heap]
pub struct Rect {
	typ          string = 'rect'
	css          string
	x            i64
	y            i64
	width        i64
	height       i64
	color_config CssColorConfig
	z_index      i64
}

@[heap]
pub struct Horizontal {
	typ          string = 'horizontal'
	css          string
	x            i64
	y            i64
	value        string
	color_config CSSBorder
	z_index      i64
}

@[heap]
pub struct Vertical {
	typ          string = 'vertical'
	css          string
	x            i64
	y            i64
	value        string
	color_config CSSBorder
	z_index      i64
}

@[heap]
pub struct Text {
	typ          string = 'text'
	css          string
	x            i64
	y            i64
	value        string
	color_config CssColorConfig
	z_index      i64
}

pub type Drawable = Rect | Horizontal | Vertical | Text

pub fn (d Drawable) get_bounding_box() BoundingBox {
	return match d {
		Rect {
			BoundingBox{
				typ: d.typ
				x:   d.x
				y:   d.y
				w:   d.width
				h:   d.height
				z:   0
			}
		}
		Horizontal {
			BoundingBox{
				typ: d.typ
				x:   d.x
				y:   d.y
				w:   d.value.len
				h:   1
				z:   0
			}
		}
		Vertical {
			BoundingBox{
				typ: d.typ
				x:   d.x
				y:   d.y
				w:   1
				h:   d.value.len
				z:   0
			}
		}
		Text {
			BoundingBox{
				typ: d.typ
				x:   d.x
				y:   d.y
				w:   d.value.len
				h:   1
				z:   0
			}
		}
	}
}
