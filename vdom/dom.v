module vdom

import encoding.xml
import strings
import rand

// callback type for event listeners
pub type EventCallback = fn (node &DomNode)

// ─── DOM MODEL ────────────────────────────────────────────────────────────────────
@[heap]
pub struct DomNode {
pub mut:
	id              string = rand.uuid_v4()
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
		id:              rand.uuid_v4()
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
pub mut:
	width  int
	height int
	root   &DomNode
}

pub fn find_node(parent_node &DomNode, node_id string) ?&DomNode {
	if parent_node.id == node_id {
		return parent_node
	} else {
		for c in parent_node.children {
			nn := find_node(c, node_id)
			if nn != none {
				return nn
			}
		}
		return none
	}
}

pub fn (d DOM) find_node(node_id string) ?&DomNode {
	return find_node(d.root, node_id)
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
	mut root := dom_node_new()
	root.style.width = CSSDimension{
		typ:   .chars
		value: 120
	}
	root.style.height = CSSDimension{
		typ:   .chars
		value: 50
	}
	root.children = [
		dom_node_parse(xml_frag),
	]
	return DOM{
		width:  120
		height: 50
		root:   &root
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
