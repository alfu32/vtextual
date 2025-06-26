module vdom

import encoding.xml

// callback type for event listeners
pub type EventCallback = fn (node &DomNode)

// ─── CSS MODEL ────────────────────────────────────────────────────────────────────

pub enum DimensionType {
	auto
	none
	chars
	percent
	fraction
}

pub struct CSSDimension {
pub mut:
	typ   DimensionType
	value f64
}

pub enum CSSDisplay {
	inline
	block
	inline_block
	none
}

pub enum CSSPosition {
	none
	relative
	absolute
	fixed
}

pub enum BoxSizing {
	content_box
	border_box
}

pub enum LayoutDirection {
	ltr_ttb // left→right, top→bottom
	rtl_ttb // right→left, top→bottom
	ltr_btt // left→right, bottom→top
	rtl_btt // right→left, bottom→top
}

pub enum BorderStyle {
	none
	dotted
	dashed
	solid
}

pub struct CSSBorder {
pub mut:
	style BorderStyle
	color string
}

pub struct CSSStyle {
pub mut:
	display    CSSDisplay   = .inline
	position   CSSPosition  = .none
	width      CSSDimension = CSSDimension{
		typ:   .auto
		value: 0
	}
	min_width  CSSDimension = CSSDimension{
		typ:   .chars
		value: 0
	}
	max_width  CSSDimension = CSSDimension{
		typ:   .none
		value: 0
	}
	height     CSSDimension = CSSDimension{
		typ:   .auto
		value: 0
	}
	min_height CSSDimension = CSSDimension{
		typ:   .chars
		value: 0
	}
	max_height CSSDimension = CSSDimension{
		typ:   .none
		value: 0
	}
	margin     CSSDimension = CSSDimension{
		typ:   .chars
		value: 0
	}
	padding    CSSDimension = CSSDimension{
		typ:   .chars
		value: 0
	}
	border     CSSBorder = CSSBorder{
		style: .none
		color: ''
	}
	box_sizing BoxSizing       = .content_box
	layout     LayoutDirection = .ltr_ttb
	background string          = 'none'
	color      string          = 'default'
}

// ─── DOM MODEL ────────────────────────────────────────────────────────────────────

pub struct DomNode {
pub mut:
	tag             string
	attributes      map[string]string
	style           CSSStyle
	event_listeners map[string][]EventCallback
	children        []&DomNode
	parent          voidptr
	dirty           bool
}

// wrapper holding the document root
pub struct DOM {
pub:
	root &DomNode
}

// static-style parser: XML → DomNode tree
pub fn DomNode.parse(xml_frag string) &DomNode {
	doc := xml.parse(xml_frag) or { panic('XML parsing failed: ${err}') }
	return build_dom_node(doc.root, unsafe { nil })
}

// parse a full “key:val;…” declaration string
pub fn CSSStyle.parse(style_str string) CSSStyle {
	mut s := CSSStyle{} // start with defaults
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
		match key {
			'display' {
				match val.to_lower() {
					'inline' { s.display = .inline }
					'block' { s.display = .block }
					'inline-block' { s.display = .inline_block }
					'none' { s.display = .none }
					else {}
				}
			}
			'position' {
				match val.to_lower() {
					'relative' { s.position = .relative }
					'absolute' { s.position = .absolute }
					'fixed' { s.position = .fixed }
					'none' { s.position = .none }
					else {}
				}
			}
			'width' {
				s.width = parse_dimension(val)
			}
			'min-width' {
				s.min_width = parse_dimension(val)
			}
			'max-width' {
				s.max_width = parse_dimension(val)
			}
			'height' {
				s.height = parse_dimension(val)
			}
			'min-height' {
				s.min_height = parse_dimension(val)
			}
			'max-height' {
				s.max_height = parse_dimension(val)
			}
			'margin' {
				s.margin = parse_dimension(val)
			}
			'padding' {
				s.padding = parse_dimension(val)
			}
			'border' {
				parts2 := val.split(' ')
				if parts2.len == 2 {
					match parts2[0].to_lower() {
						'dotted' { s.border.style = .dotted }
						'dashed' { s.border.style = .dashed }
						'solid' { s.border.style = .solid }
						else {}
					}
					s.border.color = parts2[1]
				}
			}
			'box-sizing' {
				match val.to_lower() {
					'border-box' { s.box_sizing = .border_box }
					'content-box' { s.box_sizing = .content_box }
					else {}
				}
			}
			'layout' {
				match val.to_lower() {
					'ltrttb' { s.layout = .ltr_ttb }
					'rtlttb' { s.layout = .rtl_ttb }
					'ltrbtt' { s.layout = .ltr_btt }
					'rtlbtt' { s.layout = .rtl_btt }
					else {}
				}
			}
			'background' {
				s.background = val
			}
			'color' {
				s.color = val
			}
			else {}
		}
	}
	return s
}

// parse_dimension helper to parse “auto”, “none”, “50%”, “2fr”, or “10” (chars)
fn parse_dimension(val string) CSSDimension {
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
		num := lc.trim_suffix('%').f64()
		return CSSDimension{
			typ:   .percent
			value: num
		}
	}
	if lc.ends_with('fr') {
		num := lc.trim_suffix('fr').f64()
		return CSSDimension{
			typ:   .fraction
			value: num
		}
	}
	// otherwise assume chars
	return CSSDimension{
		typ:   .chars
		value: lc.f64()
	}
}

// convenience constructor
pub fn DOM.parse(xml_frag string) DOM {
	return DOM{
		root: DomNode.parse(xml_frag)
	}
}
