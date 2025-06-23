// textual/geometry.v
module textual

import math

pub struct Offset {
pub mut:
	x int
	y int
}

pub fn (a Offset) + (b Offset) Offset {
	return Offset{a.x + b.x, a.y + b.y}
}

pub fn (a Offset) - (b Offset) Offset {
	return Offset{a.x - b.x, a.y - b.y}
}

pub fn (a Offset) eq(b Offset) bool {
	return a.x == b.x && a.y == b.y
}

pub fn (o Offset) scale(factor int) Offset {
	return Offset{o.x * factor, o.y * factor}
}

pub fn (a Offset) distance_to(b Offset) f64 {
	dx := a.x - b.x
	dy := a.y - b.y
	return math.sqrt(f32((dx * dx + dy * dy)))
}

pub fn (o Offset) str() string {
	return 'Offset(x: ${o.x}, y: ${o.y})'
}

pub fn (a Offset) lerp(b Offset, t f32) Offset {
	return Offset{
		x: lerp_int(a.x, b.x, t)
		y: lerp_int(a.y, b.y, t)
	}
}

pub struct Size {
pub mut:
	width  int
	height int
}

pub fn (a Size) + (b Size) Size {
	return Size{a.width + b.width, a.height + b.height}
}

pub fn (a Size) - (b Size) Size {
	return Size{a.width - b.width, a.height - b.height}
}

pub fn (s Size) shrink(spacing Spacing) Size {
	return Size{
		width:  s.width - (spacing.left + spacing.right)
		height: s.height - (spacing.top + spacing.bottom)
	}
}

pub fn (a Size) eq(b Size) bool {
	return a.width == b.width && a.height == b.height
}

pub fn (s Size) str() string {
	return 'Size(width: ${s.width}, height: ${s.height})'
}

pub fn (a Size) lerp(b Size, t f32) Size {
	return Size{
		width:  lerp_int(a.width, b.width, t)
		height: lerp_int(a.height, b.height, t)
	}
}

pub struct Spacing {
pub mut:
	top    int
	right  int
	bottom int
	left   int
}

pub fn (a Spacing) eq(b Spacing) bool {
	return a.top == b.top && a.right == b.right && a.bottom == b.bottom && a.left == b.left
}

pub fn (s Spacing) str() string {
	return 'Spacing(t: ${s.top}, r: ${s.right}, b: ${s.bottom}, l: ${s.left})'
}

pub struct Region {
pub mut:
	x      int
	y      int
	width  int
	height int
}

pub fn (a Region) eq(b Region) bool {
	return a.x == b.x && a.y == b.y && a.width == b.width && a.height == b.height
}

pub fn (r Region) contains(px int, py int) bool {
	return px >= r.x && px < r.x + r.width && py >= r.y && py < r.y + r.height
}

pub fn (r Region) str() string {
	return 'Region(x: ${r.x}, y: ${r.y}, w: ${r.width}, h: ${r.height})'
}

pub fn percent_to_pixels(parent int, percent f32) int {
	return int(f32(parent) * percent / 100.0)
}

pub fn pixels_to_percent(parent int, px int) f32 {
	if parent == 0 {
		return 0
	}
	return (f32(px) / f32(parent)) * 100.0
}

pub fn lerp_int(a int, b int, t f32) int {
	return int(f32(a) + (f32(b - a)) * t)
}

pub fn clamp[T](value T, min T, max T) T {
	return if value < min {
		min
	} else if value > max {
		max
	} else {
		value
	}
}

pub fn spacing_all(v int) Spacing {
	return Spacing{v, v, v, v}
}

pub fn spacing_vertical(v int) Spacing {
	return Spacing{v, 0, v, 0}
}

pub fn spacing_horizontal(v int) Spacing {
	return Spacing{0, v, 0, v}
}

pub fn spacing_symmetric(vertical int, horizontal int) Spacing {
	return Spacing{
		top:    vertical
		bottom: vertical
		left:   horizontal
		right:  horizontal
	}
}

pub fn lerp_f32(a f32, b f32, t f32) f32 {
	return a + (b - a) * t
}

pub struct FOffset {
pub mut:
	x f32
	y f32
}

pub fn (o FOffset) scale(factor f32) FOffset {
	return FOffset{o.x * factor, o.y * factor}
}

pub fn (o FOffset) str() string {
	return 'FOffset(x: ${o.x}, y: ${o.y})'
}

pub fn (a FOffset) lerp(b FOffset, t f32) FOffset {
	return FOffset{
		x: lerp_f32(a.x, b.x, t)
		y: lerp_f32(a.y, b.y, t)
	}
}

pub fn (a FOffset) distance_to(b FOffset) f64 {
	dx := a.x - b.x
	dy := a.y - b.y
	return math.sqrt(dx * dx + dy * dy)
}

pub struct FSize {
pub mut:
	width  f32
	height f32
}

pub fn (s FSize) str() string {
	return 'FSize(width: ${s.width}, height: ${s.height})'
}

pub fn (a FSize) lerp(b FSize, t f32) FSize {
	return FSize{
		width:  lerp_f32(a.width, b.width, t)
		height: lerp_f32(a.height, b.height, t)
	}
}

pub struct FRegion {
pub mut:
	x      f32
	y      f32
	width  f32
	height f32
}

pub fn (r FRegion) str() string {
	return 'FRegion(x: ${r.x}, y: ${r.y}, w: ${r.width}, h: ${r.height})'
}
