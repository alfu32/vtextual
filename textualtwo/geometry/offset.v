module geometry

pub struct Offset {
pub:
	dx int
	dy int
}

pub fn (o Offset) add(other Offset) Offset {
	return Offset{
		dx: o.dx + other.dx
		dy: o.dy + other.dy
	}
}
