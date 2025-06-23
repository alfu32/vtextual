module geometry

pub struct Size {
pub:
	width  int
	height int
}

pub fn (s Size) add(other Size) Size {
	return Size{
		width:  s.width + other.width
		height: s.height + other.height
	}
}

pub fn (s Size) sub(other Size) Size {
	return Size{
		width:  s.width - other.width
		height: s.height - other.height
	}
}
