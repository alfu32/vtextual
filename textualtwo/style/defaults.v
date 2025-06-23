module style

import style { Color, EdgeInsets, Style }

pub fn default_style() Style {
	return Style{
		color:     Color{
			r: 255
			g: 255
			b: 255
		}
		margin:    EdgeInsets{
			top:    0
			right:  0
			bottom: 0
			left:   0
		}
		padding:   EdgeInsets{
			top:    0
			right:  0
			bottom: 0
			left:   0
		}
		bold:      false
		italic:    false
		underline: false
	}
}
