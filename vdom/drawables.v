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
