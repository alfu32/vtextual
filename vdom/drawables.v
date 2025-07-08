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

pub fn (mut a Point) next_z() i64 {
	a.z += 1
	return a.z
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
pub fn (this BoundingBox) translate(p Point) BoundingBox {
	return BoundingBox{
		typ: 'box'
		x:   this.x + p.x
		y:   this.y + p.y
		w:   this.w
		h:   this.h
		z:   this.z + 1
	}
}

// Box.z = 0
pub fn (this BoundingBox) top_left() Point {
	return Point{
		x: this.x
		y: this.y
		z: this.z
	}
}

pub fn (this BoundingBox) grow(n i64) BoundingBox {
	mut nw := this.w
	mut nh := this.h
	mut ny := this.y
	mut nx := this.x
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
		z:   this.z + 1
	}
}

pub fn (this BoundingBox) add(c BoundingBox) BoundingBox {
	x0 := math.min(this.x, c.x)
	y0 := math.min(this.y, c.y)
	x1 := math.max(this.x + this.w, c.x + c.w)
	y1 := math.max(this.y + this.w, c.y + this.h)
	return BoundingBox{
		typ: this.typ
		x:   x0
		y:   y0
		w:   x1 - x0
		h:   y1 - y0
		z:   this.z + 1
	}
}

// contains returns true if the receiver this contains the other box
pub fn (this BoundingBox) contains(other BoundingBox) bool {
	return other.x > this.x && other.y > this.y && (other.x + other.w) < (this.x + this.w)
		&& (other.y + other.h) < (this.y + this.h)
}

// contains returns true if the receiver this contains the other box
pub fn (this BoundingBox) contains_point(p Point) bool {
	return p.x > this.x && p.y > this.y && p.x < (this.x + this.w) && p.y < (this.y + this.h)
}

// intersects returns true if the receiver this intersects the other box
pub fn (this BoundingBox) intersects(other BoundingBox) bool {
	return this.x < (other.x + other.w) && (this.x + this.w) > other.x
		&& this.y < (other.y + other.h) && (this.y + this.h) > other.y
}

//  returns true if the receiver this overlaps the other box
pub fn (this BoundingBox) overlaps(other BoundingBox) bool {
	return this.contains(other) || this.intersects(other) || other.contains(this)
}

// intersects returns the intersection between the receiver the other box
pub fn (this BoundingBox) intersection(c BoundingBox) BoundingBox {
	x1 := math.max(this.x, c.x)
	y1 := math.max(this.y, c.y)
	x2 := math.min(this.x + this.w, c.x + c.w)
	y2 := math.min(this.y + this.h, c.y + c.h)

	if x2 <= x1 || y2 <= y1 {
		return BoundingBox{} // empty box (0 width/height)
	}
	return BoundingBox{
		x: x1
		y: y1
		w: x2 - x1
		h: y2 - y1
		z: math.max(this.z, c.z)
	}
}

pub fn (this BoundingBox) str() string {
	return '[${this.x},${this.y},${this.x + this.w},${this.y + this.h}]'
}

@[heap]
pub struct Rect {
pub mut:
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
pub mut:
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
pub mut:
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
pub mut:
	typ          string = 'text'
	css          string
	x            i64
	y            i64
	value        string
	color_config CssColorConfig
	z_index      i64
}

@[heap]
pub type Drawable = Rect | Horizontal | Vertical | Text

pub fn (d &Drawable) translate(p Point) &Drawable {
	unsafe {
		mut dd := d
		dd.x += p.x
		dd.y += p.y
		return d
	}
}

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
