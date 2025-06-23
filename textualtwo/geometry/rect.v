module geometry

import geometry { Point }

pub struct Rect {
pub:
	x      int
	y      int
	width  int
	height int
}

pub fn (r Rect) contains(p Point) bool {
	return p.x >= r.x && p.x < r.x + r.width && p.y >= r.y && p.y < r.y + r.height
}
