module vdom

import term

// ─── CSS MODEL ────────────────────────────────────────────────────────────────────

pub enum DimensionType {
	auto
	none
	chars
	percent
	fraction
	undefined
}

pub struct CSSDimension {
pub mut:
	typ   DimensionType
	value i64
}

pub fn (cssd CSSDimension) is_undefined() bool {
	return cssd.typ == .undefined
}

pub fn (cssd CSSDimension) to_string() string {
	return '${cssd.value}${cssd.typ.str()}'
}

pub fn (cssd CSSDimension) str() string {
	return cssd.to_string()
}

// returns a CSSDimension with defaults (auto, 0)
pub fn css_dimension_new() CSSDimension {
	return CSSDimension{
		typ:   .undefined
		value: 0
	}
}

// parse “auto”, “none”, “50%”, “2fr”, or “10” (chars)
pub fn css_dimension_parse(val string) CSSDimension {
	lc := val.trim_space().to_lower()
	if lc == 'auto' {
		return CSSDimension{
			typ:   .auto
			value: 0
		}
	}
	if lc == 'none' {
		return CSSDimension{
			typ:   .none
			value: 0
		}
	}
	if lc.ends_with('%') {
		return CSSDimension{
			typ:   .percent
			value: lc.trim_right('%').i64()
		}
	}
	if lc.ends_with('fr') {
		return CSSDimension{
			typ:   .fraction
			value: lc.trim_right('fr').i64()
		}
	}
	if lc.is_int() {
		return CSSDimension{
			typ:   .chars
			value: lc.i64()
		}
	}
	// otherwise assume chars

	return CSSDimension{
		typ:   .undefined
		value: 0
	}
}

pub enum CSSDisplay {
	inline
	block
	inline_block
	none
	undefined
}

pub enum CSSPosition {
	none
	relative
	absolute
	fixed
	undefined
}

pub enum BoxSizing {
	content_box
	border_box
	undefined
}

pub enum LayoutDirection {
	ltr_ttb // left→right, top→bottom
	rtl_ttb // right→left, top→bottom
	ltr_btt // left→right, bottom→top
	rtl_btt // right→left, bottom→top
}

pub enum BorderStyle {
	none
	default
	dotted
	dashed
	solid
	star
	hash
	double
	double_dash
	rounded
	rounded_dashed
	thick
	literal
	undefined
}

// overflow enum
pub enum CSSOverflow {
	visible
	scroll
	hidden
	undefined
}

pub struct CSSBorder {
pub mut:
	style      BorderStyle
	definition string // = "+=+|+-+|"
	color      CssColor
	background CssColor
}

pub fn css_border_definition(definition string) string {
	// 7bit default
	// +-------+
	// |       |
	// |       |
	// +-------+
	// star
	// *---------*
	// *         *
	// *         *
	// *---------*
	// hash
	// ###########
	// #         #
	// #         #
	// ###########
	// solid
	// ┌─────────┐
	// │         │
	// │         │
	// └─────────┘
	// dashed
	// ┌---------┐
	// |         |
	// |         |
	// └---------┘
	// dotted
	// ,''''''''',
	// :         :
	// :         :
	// '.........'
	// double
	// ╔═════════╗
	// ║         ║
	// ║         ║
	// ╚═════════╝
	// double-dash
	// ╔=========╗
	// ║         ║
	// ║         ║
	// ╚=========╝
	// rounded
	// ╭─────────╮
	// │         │
	// │         │
	// ╰─────────╯
	// rounded-dashed
	// ╭---------╮
	// |         |
	// |         |
	// ╰---------╯
	// thick ▛▜▙▟, ▘▝▖▗ ▌, ▐, █
	// ▛▀▀▀▀▀▀▀▀▀▜
	// ▌         ▐
	// ▌         ▐
	// ▙▄▄▄▄▄▄▄▄▄▟
	styles := {
		'default':        '+-+|+-+|'
		'star':           '*-***-**'
		'hash':           '########'
		'solid':          '┌─┐│└─┘│'
		'dashed':         '┌-┐|└─┘|'
		'dotted':         ",.,:''':"
		'double':         '╔═╗║╚═╝║'
		'double-dash':    '╔=╗║╚=╝║'
		'rounded':        '╭─╮│╰─╯│'
		'rounded-dashed': '╭-╮|╰-╯|'
		'thick':          '▛▀▜▌▙▄▟▐'
	}
	def := definition.to_lower()
	return if def in styles {
		styles[def]
	} else {
		styles['7bit']
	}
}

pub fn (cssb CSSBorder) to_string() string {
	return '${cssb.style.str()} #${cssb.color.to_u32():06X} #${cssb.background.to_u32():06X}'
}

pub fn (cssb CSSBorder) str() string {
	return '${if cssb.style == .literal {
		cssb.definition
	} else {
		cssb.style.str()
	}} #${cssb.color.to_u32():06X} #${cssb.background.to_u32():06X}'
}

// returns a CSSBorder with defaults (none, "")
pub fn css_border_new() CSSBorder {
	return CSSBorder{
		style:      .undefined
		definition: ''
		color:      css_color_new()
		background: css_color_new()
	}
}

pub struct CSSStyle {
pub mut:
	display    CSSDisplay      = .undefined
	position   CSSPosition     = .undefined
	top        CSSDimension    = css_dimension_new()
	left       CSSDimension    = css_dimension_new()
	right      CSSDimension    = css_dimension_new()
	bottom     CSSDimension    = css_dimension_new()
	width      CSSDimension    = css_dimension_new()
	min_width  CSSDimension    = css_dimension_new()
	max_width  CSSDimension    = css_dimension_new()
	height     CSSDimension    = css_dimension_new()
	min_height CSSDimension    = css_dimension_new()
	max_height CSSDimension    = css_dimension_new()
	margin     CSSDimension    = css_dimension_new()
	padding    CSSDimension    = css_dimension_new()
	border     CSSBorder       = css_border_new()
	box_sizing BoxSizing       = .border_box
	layout     LayoutDirection = .ltr_ttb
	text_style CssColorConfig  = CssColorConfig{
		styles: []
		fg:     css_color_new()
		bg:     css_color_new()
		custom: ''
	}
	overflow_x CSSOverflow = .undefined
	overflow_y CSSOverflow = .undefined
}

pub fn (this CSSStyle) copy() CSSStyle {
	return CSSStyle{
		display:    this.display
		position:   this.position
		top:        this.top
		left:       this.left
		right:      this.right
		bottom:     this.bottom
		width:      this.width
		min_width:  this.min_width
		max_width:  this.max_width
		height:     this.height
		min_height: this.min_height
		max_height: this.max_height
		margin:     this.margin
		padding:    this.padding
		border:     this.border
		box_sizing: this.box_sizing
		layout:     this.layout
		text_style: this.text_style.copy()
		overflow_x: this.overflow_x
		overflow_y: this.overflow_y
	}
}

pub fn (this CSSStyle) accumulate(other CSSStyle) CSSStyle {
	mut default := css_style_new()
	mut new_style := this.copy()
	new_style.display = if other.display != default.display {
		other.display
	} else {
		new_style.display
	}
	new_style.position = if other.position != default.position {
		other.position
	} else {
		new_style.position
	}
	new_style.top = if other.top != default.top { other.top } else { new_style.top }
	new_style.left = if other.left != default.left { other.left } else { new_style.left }
	new_style.right = if other.right != default.right { other.right } else { new_style.right }
	new_style.bottom = if other.bottom != default.bottom { other.bottom } else { new_style.bottom }
	new_style.width = if other.width != default.width { other.width } else { new_style.width }
	new_style.min_width = if other.min_width != default.min_width {
		other.min_width
	} else {
		new_style.min_width
	}
	new_style.max_width = if other.max_width != default.max_width {
		other.max_width
	} else {
		new_style.max_width
	}
	new_style.height = if other.height != default.height { other.height } else { new_style.height }
	new_style.min_height = if other.min_height != default.min_height {
		other.min_height
	} else {
		new_style.min_height
	}
	new_style.max_height = if other.max_height != default.max_height {
		other.max_height
	} else {
		new_style.max_height
	}
	new_style.margin = if other.margin != default.margin { other.margin } else { new_style.margin }
	new_style.padding = if other.padding != default.padding {
		other.padding
	} else {
		new_style.padding
	}
	new_style.border = if other.border != default.border { other.border } else { new_style.border }
	new_style.box_sizing = if other.box_sizing != default.box_sizing {
		other.box_sizing
	} else {
		new_style.box_sizing
	}
	new_style.layout = if other.layout != default.layout { other.layout } else { new_style.layout }
	new_style.text_style = if other.text_style != default.text_style {
		other.text_style
	} else {
		new_style.text_style
	}
	new_style.overflow_x = if other.overflow_x != default.overflow_x {
		other.overflow_x
	} else {
		new_style.overflow_x
	}
	new_style.overflow_y = if other.overflow_y != default.overflow_y {
		other.overflow_y
	} else {
		new_style.overflow_y
	}
	return new_style
}

pub fn (this CSSStyle) override(other CSSStyle) CSSStyle {
	mut default := css_style_new()
	mut new_style := css_style_new()
	new_style.display = other.display
	new_style.position = other.position
	new_style.top = other.top
	new_style.left = other.left
	new_style.right = other.right
	new_style.bottom = other.bottom
	new_style.width = other.width
	new_style.min_width = other.min_width
	new_style.max_width = other.max_width
	new_style.height = other.height
	new_style.min_height = other.min_height
	new_style.max_height = other.max_height
	new_style.layout = other.layout

	new_style.box_sizing = if other.box_sizing != .undefined {
		other.box_sizing
	} else if this.box_sizing != .undefined {
		this.box_sizing
	} else {
		new_style.box_sizing
	}
	new_style.overflow_x = if other.overflow_x != .undefined {
		other.overflow_x
	} else if this.overflow_x != .undefined {
		this.overflow_x
	} else {
		new_style.overflow_x
	}
	new_style.overflow_y = if other.overflow_y != .undefined {
		other.overflow_y
	} else if this.overflow_y != .undefined {
		this.overflow_y
	} else {
		new_style.overflow_x
	}

	new_style.border = if other.border.style != .undefined { other.border } else { this.border }
	new_style.margin = if other.margin.typ != .undefined { other.margin } else { this.margin }
	new_style.padding = if other.padding.typ != .undefined { other.padding } else { this.padding }
	new_style.text_style = if other.text_style != default.text_style {
		other.text_style
	} else {
		this.text_style
	}
	return new_style
}

pub fn (this CSSStyle) to_string() string {
	stl := css_style_new()
	mut txt := []string{}
	if stl.display != this.display {
		txt << 'display:${this.display.str()}'
	}
	if stl.position != this.position {
		txt << 'position:${this.position.str()}'
	}
	if stl.top != this.top {
		txt << 'top:${this.top.to_string()}'
	}
	if stl.left != this.left {
		txt << 'left:${this.left.to_string()}'
	}
	if stl.right != this.right {
		txt << 'right:${this.right.to_string()}'
	}
	if stl.bottom != this.bottom {
		txt << 'bottom:${this.bottom.to_string()}'
	}
	if stl.width != this.width {
		txt << 'width:${this.width.to_string()}'
	}
	if stl.min_width != this.min_width {
		txt << 'min_width:${this.min_width.to_string()}'
	}
	if stl.max_width != this.max_width {
		txt << 'max_width:${this.max_width.to_string()}'
	}
	if stl.height != this.height {
		txt << 'height:${this.height.to_string()}'
	}
	if stl.min_height != this.min_height {
		txt << 'min_height:${this.min_height.to_string()}'
	}
	if stl.max_height != this.max_height {
		txt << 'max_height:${this.max_height.to_string()}'
	}
	if stl.margin != this.margin {
		txt << 'margin:${this.margin.to_string()}'
	}
	if stl.padding != this.padding {
		txt << 'padding:${this.padding.to_string()}'
	}
	if stl.border != this.border {
		txt << 'border:${this.border.to_string()}'
	}
	if stl.box_sizing != this.box_sizing {
		txt << 'box_sizing:${this.box_sizing.str()}'
	}
	if stl.layout != this.layout {
		txt << 'layout:${this.layout.str()}'
	}
	if stl.text_style != this.text_style {
		txt << 'text_style:${this.text_style.to_string()}'
	}
	if stl.overflow_x != this.overflow_x {
		txt << 'overflow_x:${this.overflow_x.str()}'
	}
	if stl.overflow_y != this.overflow_y {
		txt << 'overflow_y:${this.overflow_y.str()}'
	}
	return txt.join(',')
}

pub fn (this CSSStyle) str() string {
	return '{${this.to_string()}}'
}

enum CssColorType {
	undefined
	rgb
}

struct CssColor {
pub mut:
	value u32
	typ   CssColorType = .undefined
}

fn css_color_new() CssColor {
	return CssColor{}
}

fn css_color_parse_u32(value u32) CssColor {
	return CssColor{
		value: value
		typ:   .rgb
	}
}

fn (c CssColor) to_u32() u32 {
	return c.value
}

struct CssColorConfig {
pub mut:
	styles []term.TextStyle = []
	fg     CssColor         = css_color_new()
	bg     CssColor         = css_color_new()
	custom string
}

pub fn (cc CssColorConfig) copy() CssColorConfig {
	return CssColorConfig{
		styles: cc.styles
		fg:     cc.fg
		bg:     cc.bg
		custom: cc.custom
	}
}

pub fn (cc CssColorConfig) bg_red() u8 {
	return u8((cc.bg.value & 0xFF0000) >> 16)
}

pub fn (cc CssColorConfig) bg_green() u8 {
	return u8((cc.bg.value & 0xFF00) >> 8)
}

pub fn (cc CssColorConfig) bg_blue() u8 {
	return u8((cc.bg.value & 0xFF))
}

pub fn (cc CssColorConfig) fg_red() u8 {
	return u8((cc.fg.value & 0xFF0000) >> 16)
}

pub fn (cc CssColorConfig) fg_green() u8 {
	return u8((cc.fg.value & 0xFF00) >> 8)
}

pub fn (cc CssColorConfig) fg_blue() u8 {
	return u8((cc.fg.value & 0xFF))
}

pub fn (ccc CssColorConfig) to_string() string {
	return 'decoration:${ccc.styles};fg:#${ccc.fg.value:06X};bg:#${ccc.bg.value:06X}'
}

pub fn (ccc CssColorConfig) str() string {
	return '{styles:[${ccc.styles}],fg:0x${ccc.fg.value:06X},bg:0x${ccc.bg.value:06X}}'
}

pub fn css_color_parse(text string) !CssColor {
	named_colors := {
		'black':   u32(0x000000)
		'red':     0xdd0000
		'green':   0x00dd00
		'yellow':  0xeeee00
		'blue':    0x0000dd
		'magenta': 0xdd00dd
		'cyan':    0x00dddd
		'white':   0xeeeeee
	}

	tt := text.trim(' ')

	return if tt in named_colors {
		CssColor{
			value: named_colors[tt]
			typ:   .rgb
		}
	} else {
		// dump(tt[0].ascii_str())
		match tt[0].ascii_str() {
			'#' {
				a := tt.substr(1, tt.len)
				// dump("parse a ${a}")
				b := a.parse_int(16, 32)!
				// dump("parse b ${b}")
				CssColor{
					typ:   .rgb
					value: u32(b)
				}
			}
			else {
				panic('invalid color definition ${text}')
			}
		}
	}
}

// returns a CSSStyle initialized with all defaults
pub fn css_style_new() CSSStyle {
	return CSSStyle{}
}

pub fn (mut this CSSStyle) set(key string, val string) {
	match key {
		'display' {
			match val.to_lower() {
				'inline' { this.display = .inline }
				'block' { this.display = .block }
				'inline-block' { this.display = .inline_block }
				'none' { this.display = .none }
				else {}
			}
		}
		'position' {
			match val.to_lower() {
				'relative' { this.position = .relative }
				'absolute' { this.position = .absolute }
				'fixed' { this.position = .fixed }
				'none' { this.position = .none }
				else { this.position = .undefined }
			}
		}
		'top' {
			this.top = css_dimension_parse(val)
		}
		'left' {
			this.left = css_dimension_parse(val)
		}
		'right' {
			this.right = css_dimension_parse(val)
		}
		'bottom' {
			this.bottom = css_dimension_parse(val)
		}
		'width' {
			this.width = css_dimension_parse(val)
		}
		'min-width' {
			this.min_width = css_dimension_parse(val)
		}
		'max-width' {
			this.max_width = css_dimension_parse(val)
		}
		'height' {
			this.height = css_dimension_parse(val)
		}
		'min-height' {
			this.min_height = css_dimension_parse(val)
		}
		'max-height' {
			this.max_height = css_dimension_parse(val)
		}
		'margin' {
			this.margin = css_dimension_parse(val)
		}
		'padding' {
			this.padding = css_dimension_parse(val)
		}
		'border' {
			parts2 := val.split(' ')
			if parts2.len >= 1 {
				def := parts2[0]
				this.border.definition = css_border_definition(def)
				match def.to_lower() {
					'default' {
						this.border.style = .default
					}
					'star' {
						this.border.style = .star
					}
					'hash' {
						this.border.style = .hash
					}
					'solid' {
						this.border.style = .solid
					}
					'dashed' {
						this.border.style = .dashed
					}
					'dotted' {
						this.border.style = .dotted
					}
					'double' {
						this.border.style = .double
					}
					'double-dash' {
						this.border.style = .double_dash
					}
					'rounded' {
						this.border.style = .rounded
					}
					'rounded-dashed' {
						this.border.style = .rounded_dashed
					}
					'thick' {
						this.border.style = .thick
					}
					else {
						this.border.style = .literal
						match def.len {
							4 {
								this.border.definition = '${def}${def}'
							}
							8 {
								this.border.definition = def
							}
							else {
								this.border.definition = '+=+|+-+|'
							}
						}
					}
				}
			}
			if parts2.len >= 2 {
				this.border.color = css_color_parse(parts2[1]) or { css_color_new() }
			}
			if parts2.len >= 3 {
				this.border.color = css_color_parse(parts2[1]) or { css_color_new() }
			}
		}
		'box-sizing' {
			match val.to_lower() {
				'border-box' { this.box_sizing = .border_box }
				'content-box' { this.box_sizing = .content_box }
				else { this.box_sizing = .undefined }
			}
		}
		'layout' {
			match val.to_lower() {
				'ltrttb' { this.layout = .ltr_ttb }
				'rtlttb' { this.layout = .rtl_ttb }
				'ltrbtt' { this.layout = .ltr_btt }
				'rtlbtt' { this.layout = .rtl_btt }
				else { this.layout = .ltr_ttb }
			}
		}
		'background' {
			// dump("background ${val}")
			this.text_style.bg = css_color_parse(val) or { css_color_new() }
			// dump("background ${s.text_style.bg:06x}")
		}
		'color' {
			// dump("color ${val}")
			this.text_style.fg = css_color_parse(val) or { css_color_new() }
			// dump("color ${s.text_style.fg:06x}")
		}
		'text-decoration' {
			this.text_style.styles = []
			for tex in val.split(',') {
				match tex.trim(' ').to_lower() {
					'bold' { this.text_style.styles << .bold }
					'dim' { this.text_style.styles << .dim }
					'italic' { this.text_style.styles << .italic }
					'underline' { this.text_style.styles << .underline }
					'blink' { this.text_style.styles << .blink }
					'reverse' { this.text_style.styles << .reverse }
					else {}
				}
			}
		}
		'overflow-x' {
			match val {
				'scroll' { this.overflow_x = .scroll }
				'hidden' { this.overflow_x = .hidden }
				else { this.overflow_x = .undefined }
			}
		}
		'overflow-y' {
			match val {
				'scroll' { this.overflow_x = .scroll }
				'hidden' { this.overflow_x = .hidden }
				else { this.overflow_x = .undefined }
			}
		}
		else {}
	}
}

// parse a full “key:val;…” declaration string into CSSStyle
pub fn css_style_parse(style_str string) CSSStyle {
	mut s := css_style_new()
	for decl in style_str.split(';') {
		trimmed := decl.trim_space()
		if trimmed == '' {
			continue
		}
		parts := trimmed.split(':')
		if parts.len != 2 {
			continue
		}
		key := parts[0].trim_space().to_lower()
		val := parts[1].trim_space()
		s.set(key, val)
	}
	return s
}
