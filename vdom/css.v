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

pub fn (this CSSDimension) accumulate(other CSSDimension) CSSDimension {
	return if other.typ != .undefined { other } else { this }
}

pub fn (this CSSDimension) override(other CSSDimension) CSSDimension {
	return if other.typ != .undefined { other } else { this }
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
	block
	none
	undefined
}

pub fn (cssd CSSDisplay) accumulate(other CSSDisplay) CSSDisplay {
	return if other != .undefined { other } else { cssd }
}

pub fn (cssd CSSDisplay) override(other CSSDisplay) CSSDisplay {
	return if other != .undefined { other } else { cssd }
}

pub enum CSSPosition {
	relative
	undefined
}

pub fn (cssp CSSPosition) accumulate(other CSSPosition) CSSPosition {
	return if other != .undefined { other } else { cssp }
}

pub fn (cssp CSSPosition) override(other CSSPosition) CSSPosition {
	return if other != .undefined { other } else { cssp }
}

pub enum BoxSizing {
	content_box
	border_box
	undefined
}

pub fn (cssp BoxSizing) accumulate(other BoxSizing) BoxSizing {
	return if other != .undefined { other } else { cssp }
}

pub fn (cssp BoxSizing) override(other BoxSizing) BoxSizing {
	return if other != .undefined { other } else { cssp }
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

pub fn (bs BorderStyle) accumulate(other BorderStyle) BorderStyle {
	return if other != .undefined { other } else { bs }
}

pub fn (bs BorderStyle) override(other BorderStyle) BorderStyle {
	return if other != .undefined { other } else { bs }
}

// overflow enum
pub enum CSSOverflow {
	visible
	scroll
	hidden
	undefined
}

pub fn (bs CSSOverflow) accumulate(other CSSOverflow) CSSOverflow {
	return other
}

pub fn (bs CSSOverflow) override(other CSSOverflow) CSSOverflow {
	return other
}

pub struct CSSBorder {
pub mut:
	style      BorderStyle
	definition string // = "+=+|+-+|"
	color      CssColor
	background CssColor
}

pub fn (cssb CSSBorder) accumulate(other CSSBorder) CSSBorder {
	mut new_border := css_border_new()
	new_border.style = cssb.style.accumulate(other.style)
	new_border.definition = if other.style != .undefined {
		other.definition
	} else {
		cssb.definition
	}
	new_border.color = cssb.color.accumulate(other.color)
	new_border.background = cssb.background.accumulate(other.background)
	return new_border
}

pub fn (cssb CSSBorder) override(other CSSBorder) CSSBorder {
	mut new_border := css_border_new()
	new_border.style = cssb.style.override(other.style)
	new_border.definition = if other.style != .undefined {
		other.definition
	} else {
		cssb.definition
	}
	new_border.color = cssb.color.override(other.color)
	new_border.background = cssb.background.override(other.background)
	return new_border
}

pub fn (cssb CSSBorder) to_string() string {
	return '${cssb.style}(${cssb.definition}) ${cssb.color.to_string()} ${cssb.background.to_string()}'
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

pub fn (cssb CSSBorder) str() string {
	return '${if cssb.style == .literal {
		cssb.definition
	} else {
		cssb.style.str()
	}} #${cssb.color.to_u32():06X} #${cssb.background.to_u32():06X}'
}

// css_border_new returns a CSSBorder with defaults (none, "")
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
	display    CSSDisplay     = .undefined
	position   CSSPosition    = .undefined
	top        CSSDimension   = css_dimension_new()
	left       CSSDimension   = css_dimension_new()
	width      CSSDimension   = css_dimension_new()
	height     CSSDimension   = css_dimension_new()
	padding    CSSDimension   = css_dimension_new()
	border     CSSBorder      = css_border_new()
	box_sizing BoxSizing      = .undefined
	text_style CssColorConfig = CssColorConfig{
		styles: []
		fg:     css_color_new()
		bg:     css_color_new()
		typ:    .undefined
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
		width:      this.width
		height:     this.height
		padding:    this.padding
		border:     this.border
		box_sizing: this.box_sizing
		text_style: this.text_style.copy()
		overflow_x: this.overflow_x
		overflow_y: this.overflow_y
	}
}

pub fn (style CSSStyle) get_css_box() Box {
	return Box{
		typ: 'CssBox'
		x:   style.left.value
		y:   style.top.value
		w:   style.width.value
		h:   style.height.value
		z:   0
	}
}

pub fn (this CSSStyle) accumulate(other CSSStyle) CSSStyle {
	mut new_style := this.copy()
	new_style.display = this.display.accumulate(other.display)
	new_style.position = this.position.accumulate(other.position)
	new_style.top = this.top.accumulate(other.top)
	new_style.left = this.left.accumulate(other.left)
	new_style.width = this.width.accumulate(other.width)
	new_style.height = this.height.accumulate(other.height)
	new_style.padding = this.padding.accumulate(other.padding)
	new_style.border = this.border.accumulate(other.border)
	new_style.box_sizing = this.box_sizing.accumulate(other.box_sizing)
	new_style.text_style = this.text_style.accumulate(other.text_style)
	new_style.overflow_x = this.overflow_x.accumulate(other.overflow_x)
	new_style.overflow_y = this.overflow_y.accumulate(other.overflow_y)
	return new_style
}

pub fn (this CSSStyle) override(other CSSStyle) CSSStyle {
	mut new_style := css_style_new()
	new_style.display = this.display.override(other.display)
	new_style.position = this.position.override(other.position)
	new_style.top = this.top.override(other.top)
	new_style.left = this.left.override(other.left)
	new_style.width = this.width.override(other.width)
	new_style.height = this.height.override(other.height)
	new_style.padding = this.padding.override(other.padding)
	new_style.border = this.border.override(other.border)
	new_style.box_sizing = this.box_sizing.override(other.box_sizing)
	new_style.text_style = this.text_style.override(other.text_style)
	new_style.overflow_x = this.overflow_x.override(other.overflow_x)
	new_style.overflow_y = this.overflow_y.override(other.overflow_y)
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
	if stl.width != this.width {
		txt << 'width:${this.width.to_string()}'
	}
	if stl.height != this.height {
		txt << 'height:${this.height.to_string()}'
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

fn (c CssColor) accumulate(other CssColor) CssColor {
	mut new_color := css_color_new()
	new_color.typ = if other.typ != .undefined { other.typ } else { c.typ }
	new_color.value = if other.typ != .undefined { other.value } else { c.value }
	return new_color
}

fn (c CssColor) override(other CssColor) CssColor {
	mut new_color := css_color_new()
	new_color.typ = if other.typ != .undefined { other.typ } else { c.typ }
	new_color.value = if other.typ != .undefined { other.value } else { c.value }
	return new_color
}

fn (c CssColor) to_u32() u32 {
	return c.value
}

fn (c CssColor) to_string() string {
	return '#${c.value:06X}'
}

enum CssColorConfigType {
	default
	undefined
}

struct CssColorConfig {
pub mut:
	styles []term.TextStyle   = []
	fg     CssColor           = css_color_new()
	bg     CssColor           = css_color_new()
	typ    CssColorConfigType = .undefined
}

pub fn (cc CssColorConfig) copy() CssColorConfig {
	return CssColorConfig{
		styles: cc.styles
		fg:     cc.fg
		bg:     cc.bg
		typ:    cc.typ
	}
}

pub fn (this CssColorConfig) accumulate(other CssColorConfig) CssColorConfig {
	mut new_ccc := CssColorConfig{}
	new_ccc.typ = if other.typ != .undefined { other.typ } else { this.typ }
	new_ccc.fg = if other.typ != .undefined { this.fg.accumulate(other.fg) } else { this.fg }
	new_ccc.bg = if other.typ != .undefined { this.fg.accumulate(other.bg) } else { this.bg }
	new_ccc.styles = if other.styles.len != 0 { other.styles } else { this.styles }
	return new_ccc
}

pub fn (this CssColorConfig) override(other CssColorConfig) CssColorConfig {
	mut new_ccc := CssColorConfig{}
	new_ccc.typ = if other.typ != .undefined { other.typ } else { this.typ }
	new_ccc.fg = if other.typ != .undefined { this.fg.accumulate(other.fg) } else { this.fg }
	new_ccc.bg = if other.typ != .undefined { this.fg.accumulate(other.bg) } else { this.bg }
	new_ccc.styles = if other.styles.len != 0 { other.styles } else { this.styles }
	return new_ccc
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
				'block' { this.display = .block }
				'none' { this.display = .none }
				else {}
			}
		}
		'position' {
			match val.to_lower() {
				'relative' { this.position = .relative }
				else { this.position = .undefined }
			}
		}
		'top' {
			this.top = css_dimension_parse(val)
		}
		'left' {
			this.left = css_dimension_parse(val)
		}
		'width' {
			this.width = css_dimension_parse(val)
		}
		'height' {
			this.height = css_dimension_parse(val)
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
			// dump(this.border)
			// dump(this.border.definition)
		}
		'box-sizing' {
			match val.to_lower() {
				'border-box' { this.box_sizing = .border_box }
				'content-box' { this.box_sizing = .content_box }
				else { this.box_sizing = .undefined }
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
