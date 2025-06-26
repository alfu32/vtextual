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
	display    CSSDisplay      = .inline
	position   CSSPosition     = .none
	width      CSSDimension    = CSSDimension{
		typ:   .auto
		value: 0
	}
	min_width  CSSDimension    = CSSDimension{
		typ:   .chars
		value: 0
	}
	max_width  CSSDimension    = CSSDimension{
		typ:   .none
		value: 0
	}
	height     CSSDimension    = CSSDimension{
		typ:   .auto
		value: 0
	}
	min_height CSSDimension    = CSSDimension{
		typ:   .chars
		value: 0
	}
	max_height CSSDimension    = CSSDimension{
		typ:   .none
		value: 0
	}
	margin     CSSDimension    = CSSDimension{
		typ:   .chars
		value: 0
	}
	padding    CSSDimension    = CSSDimension{
		typ:   .chars
		value: 0
	}
	border     CSSBorder       = CSSBorder{
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

fn build_dom_node(x xml.Element, parent voidptr) &DomNode {
	mut node := &DomNode{
		tag:             x.name
		attributes:      x.attrs.clone()
		style:           CSSStyle{} // uses all defaults
		event_listeners: map[string][]EventCallback{}
		children:        []&DomNode{}
		parent:          parent
		dirty:           true
	}
	for child in x.children {
		child_node := build_dom_node(child, node)
		node.children << child_node
	}
	return node
}

// convenience constructor
pub fn DOM.parse(xml_frag string) DOM {
	return DOM{
		root: DomNode.parse(xml_frag)
	}
}
