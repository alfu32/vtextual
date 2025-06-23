module geometry

pub struct Point {
pub:
	x int
	y int
}

pub fn (p Point) add(other Point) Point {
	return Point{
		x: p.x + other.x
		y: p.y + other.y
	}
}
