module vdom

// ─── DRAWABLES ───────────────────────────────────────────────────────────────

// pub type Color = string

pub struct Rect {
	typ          string = 'rect'
	css          string
	x            int
	y            int
	width        int
	height       int
	color_config CssColorConfig
	z_index      u64
}

pub struct Horizontal {
	typ          string = 'horizontal'
	css          string
	x            int
	y            int
	value        string
	color_config CssColorConfig
	z_index      u64
}

pub struct Vertical {
	typ          string = 'vertical'
	css          string
	x            int
	y            int
	value        string
	color_config CssColorConfig
	z_index      u64
}

pub struct Text {
	typ          string = 'text'
	css          string
	x            int
	y            int
	value        string
	color_config CssColorConfig
	z_index      u64
}

pub type Drawable = Rect | Horizontal | Vertical | Text

struct Rectangle {
	x int
	y int
	w int
	h int
}

pub fn (r Rectangle) str() string {
	return '[${r.x},${r.y},${r.x + r.w},${r.y + r.h}]'
}

pub fn (d Drawable) get_bounding_rect() Rectangle {
	return match d {
		Rect {
			Rectangle{
				x: d.x
				y: d.y
				w: d.width
				h: d.height
			}
		}
		Horizontal {
			Rectangle{
				x: d.x
				y: d.y
				w: d.value.len
				h: 1
			}
		}
		Vertical {
			Rectangle{
				x: d.x
				y: d.y
				w: 1
				h: d.value.len
			}
		}
		Text {
			Rectangle{
				x: d.x
				y: d.y
				w: d.value.len
				h: 1
			}
		}
	}
}
