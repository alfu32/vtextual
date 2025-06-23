module style

pub enum HorizontalAlign {
	left
	center
	right
	justify
}

pub enum VerticalAlign {
	top
	middle
	bottom
}

pub fn parse_horizontal_align(value string) ?HorizontalAlign {
	return match value.to_lower() {
		'left' { .left }
		'center' { .center }
		'right' { .right }
		'justify' { .justify }
		else { none }
	}
}

pub fn parse_vertical_align(value string) ?VerticalAlign {
	return match value.to_lower() {
		'top' { .top }
		'middle' { .middle }
		'bottom' { .bottom }
		else { none }
	}
}
