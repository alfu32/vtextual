module vdom

//–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
// Graphic primitive definitions
//–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

pub enum BorderStyle {
	none
	solid
	dashed
	dotted
}

fn parse_border_style(s string) BorderStyle {
	return match s {
		'solid' { .solid }
		'dashed' { .dashed }
		'dotted' { .dotted }
		else { .none }
	}
}
