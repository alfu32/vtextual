module vdom

import encoding.xml
import strings

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

// returns a CSSDimension with defaults (auto, 0)
pub fn css_dimension_new() CSSDimension {
	return CSSDimension{
		typ:   .auto
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
			value: lc.trim_right('%').f64()
		}
	}
	if lc.ends_with('fr') {
		return CSSDimension{
			typ:   .fraction
			value: lc.trim_right('fr').f64()
		}
	}
	// otherwise assume chars
	return CSSDimension{
		typ:   .chars
		value: lc.f64()
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

// returns a CSSBorder with defaults (none, "")
pub fn css_border_new() CSSBorder {
	return CSSBorder{
		style: .none
		color: ''
	}
}

pub struct CSSStyle {
pub mut:
	display    CSSDisplay   = .inline
	position   CSSPosition  = .none
	width      CSSDimension = css_dimension_new()
	min_width  CSSDimension = CSSDimension{
		typ:   .chars
		value: 0
	}
	max_width  CSSDimension = CSSDimension{
		typ:   .none
		value: 0
	}
	height     CSSDimension = css_dimension_new()
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
	border     CSSBorder       = css_border_new()
	box_sizing BoxSizing       = .content_box
	layout     LayoutDirection = .ltr_ttb
	background string          = 'none'
	color      string          = 'default'
}

// returns a CSSStyle initialized with all defaults
pub fn css_style_new() CSSStyle {
	return CSSStyle{}
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
				s.width = css_dimension_parse(val)
			}
			'min-width' {
				s.min_width = css_dimension_parse(val)
			}
			'max-width' {
				s.max_width = css_dimension_parse(val)
			}
			'height' {
				s.height = css_dimension_parse(val)
			}
			'min-height' {
				s.min_height = css_dimension_parse(val)
			}
			'max-height' {
				s.max_height = css_dimension_parse(val)
			}
			'margin' {
				s.margin = css_dimension_parse(val)
			}
			'padding' {
				s.padding = css_dimension_parse(val)
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
	text            string
}

// returns a DomNode with all defaults
pub fn dom_node_new() DomNode {
	return DomNode{
		tag:             ''
		attributes:      map[string]string{}
		style:           css_style_new()
		event_listeners: map[string][]EventCallback{}
		children:        []&DomNode{}
		parent:          unsafe { nil }
		dirty:           false
		text:            ''
	}
}

pub struct DOM {
pub:
	root &DomNode
}

// returns a DOM with a nil root
pub fn dom_new() DOM {
	return DOM{
		root: unsafe { nil }
	}
}

// parse an XML fragment into a DomNode tree
pub fn dom_node_parse(xml_frag string) &DomNode {
	doc := xml.XMLDocument.from_string(xml_frag) or { panic('XML parsing failed: ${err}') }
	return build_dom_node(doc.root, unsafe { nil })
}

// parse the XML fragment and wrap it in a DOM
pub fn dom_parse(xml_frag string) DOM {
	return DOM{
		root: dom_node_parse(xml_frag)
	}
}

fn build_dom_node(x xml.XMLNode, parent voidptr) &DomNode {
	style_str := x.attributes['style'] or { '' }
	mut node := &DomNode{
		tag:             x.name
		attributes:      x.attributes.clone()
		style:           css_style_parse(style_str)
		event_listeners: map[string][]EventCallback{}
		children:        []&DomNode{}
		parent:          parent
		dirty:           true
		text:            ''
	}
	// recurse into the mixed-content children
	for child in x.children {
		child_dom := match child {
			xml.XMLNode {
				build_dom_node(child, voidptr(node))
			}
			xml.XMLCData {
				&DomNode{
					tag:             '#cdata'
					attributes:      map[string]string{}
					style:           css_style_new()
					event_listeners: map[string][]EventCallback{}
					children:        []&DomNode{}
					parent:          voidptr(node)
					dirty:           true
					text:            child.text
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
					text:            child.text
				}
			}
			else {
				&DomNode{
					tag:             '#text'
					attributes:      map[string]string{}
					style:           css_style_new()
					event_listeners: map[string][]EventCallback{}
					children:        []&DomNode{}
					parent:          voidptr(node)
					dirty:           true
					text:            child.str()
						.replace("xml.XMLNodeContents('", '')
						.replace("')", '')
				}
			}
		}
		node.children << child_dom
	}
	return node
}

// ─── DomNode HTML/Text Serializers ───────────────────────────────────────────────

pub fn (node &DomNode) inner_text() string {
	mut sb := strings.new_builder(32)
	for child in node.children {
		// text nodes carry their content in .text; element nodes recurse
		if child.tag == '#text' {
			sb.write_string(child.text)
		} else {
			sb.write_string(child.inner_text())
		}
	}
	return sb.str()
}

pub fn (node &DomNode) inner_html() string {
	mut sb := strings.new_builder(64)
	for child in node.children {
		sb.write_string(child.outer_html())
	}
	return sb.str()
}

pub fn (node &DomNode) outer_html() string {
	// text node
	if node.tag == '#text' {
		return node.text
	}
	// comment node
	if node.tag == '#comment' {
		return '<!--${node.text}-->'
	}
	// element node
	// serialize attributes
	mut attrs := strings.new_builder(32)
	for key, val in node.attributes {
		attrs.write_string(' ')
		attrs.write_string(key)
		attrs.write_string('="')
		attrs.write_string(val)
		attrs.write_string('"')
	}
	// opening tag + children + closing tag
	return '<${node.tag}${attrs.str()}>' + node.inner_html() + '</${node.tag}>'
}
