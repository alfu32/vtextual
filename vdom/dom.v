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

pub fn css_dimension_new() CSSDimension {
	return CSSDimension{
		typ:   .auto
		value: 0.0
	}
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

// explicit constructor with all your defaults
pub fn css_style_new() CSSStyle {
	return CSSStyle{
		display:    .inline
		position:   .none
		width:      CSSDimension{
			typ:   .auto
			value: 0
		}
		min_width:  CSSDimension{
			typ:   .chars
			value: 0
		}
		max_width:  CSSDimension{
			typ:   .none
			value: 0
		}
		height:     CSSDimension{
			typ:   .auto
			value: 0
		}
		min_height: CSSDimension{
			typ:   .chars
			value: 0
		}
		max_height: CSSDimension{
			typ:   .none
			value: 0
		}
		margin:     CSSDimension{
			typ:   .chars
			value: 0
		}
		padding:    CSSDimension{
			typ:   .chars
			value: 0
		}
		border:     CSSBorder{
			style: .none
			color: ''
		}
		box_sizing: .content_box
		layout:     .ltr_ttb
		background: 'none'
		color:      'default'
	}
}

// ─── DOM MODEL ────────────────────────────────────────────────────────────────────

@[heap]
pub struct DomNode {
pub mut:
	tag             string
	text            string
	attributes      map[string]string
	style           CSSStyle
	event_listeners map[string][]EventCallback
	children        []&DomNode
	parent          &DomNode
	dirty           bool
}

pub fn dom_node_new() DomNode {
	return DomNode{
		tag:             ''
		text:            ''
		attributes:      {}
		style:           css_style_new()
		event_listeners: {}
		children:        []
		parent:          unsafe { nil }
		dirty:           true
	}
}

// wrapper holding the document root
pub struct DOM {
pub:
	root &DomNode
}

pub fn dom_new() DOM {
	return DOM{
		root: unsafe { nil }
	}
}

// static-style parser: XML → DomNode tree
pub fn dom_node_from_string(xml_frag string) &DomNode {
	doc := xml.XMLDocument.from_string(xml_frag) or { panic('XML parsing failed: ${err}') }
	return build_dom_node(doc.root, unsafe { nil })
}

// parse a full “key:val;…” declaration string
pub fn css_style_from_string(style_str string) CSSStyle {
	mut s := css_style_new() // start with defaults
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
		num := lc.trim_right('%').f64()
		return CSSDimension{
			typ:   .percent
			value: num
		}
	}
	if lc.ends_with('fr') {
		num := lc.trim_right('fr').f64()
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

fn build_dom_node1(x xml.XMLNodeContents, parent &DomNode) &DomNode {
	mut node := dom_node_new()
	return &node
}

// // build_dom_node helper: recurse xml.Element → DomNode
fn build_dom_node(x xml.XMLNode, parent voidptr) &DomNode {
	// create the element node, initializing style from any inline “style” attr
	style_str := x.attributes['style'] or { '' }
	mut node := &DomNode{
		tag:             x.name
		attributes:      x.attributes.clone()
		style:           css_style_from_string(style_str)
		event_listeners: map[string][]EventCallback{}
		children:        []&DomNode{}
		parent:          parent
		dirty:           true
	}
	// recurse into the mixed-content children
	for child in x.children {
		child_dom := match child {
			xml.XMLNode {
				build_dom_node(child, voidptr(node))
			}
			xml.XMLCData {
				&DomNode{
					tag:             '#text'
					attributes:      map[string]string{}
					style:           css_style_new() // no inline on text
					event_listeners: map[string][]EventCallback{}
					children:        []&DomNode{}
					parent:          voidptr(node)
					dirty:           true
				}
			}
			xml.XMLComment {
				&DomNode{
					tag:             '#comment'
					attributes:      map[string]string{}
					style:           css_style_new()
					event_listeners: map[string][]EventCallback{}
					children:        []&DomNode{}
					parent:          voidptr(node)
					dirty:           true
				}
			}
			else {
				// any other variant
				&DomNode{
					tag:             '#error'
					attributes:      map[string]string{}
					style:           css_style_new()
					event_listeners: map[string][]EventCallback{}
					children:        []&DomNode{}
					parent:          voidptr(node)
					dirty:           true
				}
			}
		}
		node.children << child_dom
	}
	return node
}

// convenience constructor
pub fn dom_from_string(xml_frag string) DOM {
	return DOM{
		root: dom_node_from_string(xml_frag)
	}
}
