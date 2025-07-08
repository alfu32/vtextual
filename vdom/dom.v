module vdom

import encoding.xml
import strings
import rand
import term.ui as tui
import term

// callback type for event listeners
pub type EventCallback = fn (node &DomNode, e &tui.Event)

// ─── DOM MODEL ────────────────────────────────────────────────────────────────────
@[heap]
pub struct DomNode {
pub mut:
	id             string = rand.uuid_v4()
	tag            string
	attributes     map[string]string
	style          CSSStyle
	event_listener EventCallback = fn (node &DomNode, e &tui.Event) {}
	children       []&DomNode
	parent         &DomNode
	dirty          bool
	text           string
	scroll         Point
}

pub fn (node &DomNode) dispatch_event(e &tui.Event) {
	mut n := node
	n.children[0].text = '${e.typ} ${n.children[0].text}'
	match e.typ {
		.unknown {}
		.mouse_down {}
		.mouse_up {}
		.mouse_move {}
		.mouse_drag {}
		.mouse_scroll {
			match e.direction {
				.unknown {}
				.up { n.scroll.y -= 1 }
				.down { n.scroll.y += 1 }
				.left { n.scroll.x -= 1 }
				.right { n.scroll.x += 1 }
			}
		}
		.key_down {}
		.resized {}
	}
	// n.event_listener(&node,e)
}

// returns a DomNode with all defaults
pub fn dom_node_new() DomNode {
	return DomNode{
		id:             rand.uuid_v4()
		tag:            ''
		attributes:     map[string]string{}
		style:          css_style_new()
		event_listener: fn (node &DomNode, e &tui.Event) {}
		children:       []&DomNode{}
		parent:         unsafe { nil }
		dirty:          false
		text:           ''
	}
}

@[heap]
pub struct DOM {
pub mut:
	width  int
	height int
	root   &DomNode
}

pub fn (node DomNode) query_selector_all(selector string) []string {
	mut found_nodes := []string{}
	selector_type := selector.substr(0, 1)
	selector_value := selector.substr(1, selector.len)
	condition := match selector_type {
		'#' {
			id := (node.attributes['id'] or { '' })
			id == selector_value
		}
		'.' {
			classes := (node.attributes['class'] or { '' })
			selector_value in classes.split(' ')
		}
		else {
			node.tag == selector
		}
	}
	if condition {
		found_nodes << node.id
	}
	// index := "${node.attributes['id'] or {''}} ${node.attributes['class'] or {''}} ${node.tag}"
	// if index.contains(selector_value) || index.contains(selector) {
	// 	dump("$selector_value in  '$index'")
	// 	found_nodes << &node
	// }
	for c in node.children {
		fnn := c.query_selector_all(selector)
		for nn in fnn {
			found_nodes << nn
		}
	}
	return found_nodes
}

pub fn (d DOM) query_selector_all(node_id string) []&DomNode {
	return d.root.query_selector_all(node_id).map(fn [d] (id string) &DomNode {
		return d.find_node(id) or { unsafe { nil } }
	}).filter(it != unsafe { nil })
}

pub fn (node &DomNode) find_node(node_id string) ?&DomNode {
	if node.id == node_id {
		return node
	} else {
		for c in node.children {
			nn := c.find_node(node_id)
			if nn != none {
				return nn
			}
		}
		return none
	}
}

pub fn (d &DOM) find_node(node_id string) ?&DomNode {
	return d.root.find_node(node_id)
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

// dom_parse parse the XML fragment and wrap it in a DOM
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

fn build_dom_node(x xml.XMLNode, parent &DomNode) &DomNode {
	style_str := x.attributes['style'] or { '' }
	mut node := &DomNode{
		tag:            x.name
		attributes:     x.attributes.clone()
		style:          css_style_parse(style_str)
		event_listener: fn (node &DomNode, e &tui.Event) {}
		children:       []&DomNode{}
		parent:         parent
		dirty:          true
		text:           ''
	}
	// recurse into the mixed-content children
	for child in x.children {
		child_dom := match child {
			xml.XMLNode {
				build_dom_node(child, voidptr(node))
			}
			xml.XMLCData {
				&DomNode{
					tag:            '#cdata'
					attributes:     map[string]string{}
					style:          css_style_new()
					event_listener: fn (node &DomNode, e &tui.Event) {}
					children:       []&DomNode{}
					parent:         voidptr(node)
					dirty:          true
					text:           child.text
				}
			}
			xml.XMLComment {
				&DomNode{
					tag:            '#comment'
					attributes:     map[string]string{}
					style:          css_style_new()
					event_listener: fn (node &DomNode, e &tui.Event) {}
					children:       []&DomNode{}
					parent:         voidptr(node)
					dirty:          true
					text:           child.text
				}
			}
			else {
				&DomNode{
					tag:            '#text'
					attributes:     map[string]string{}
					style:          css_style_new()
					event_listener: fn (node &DomNode, e &tui.Event) {}
					children:       []&DomNode{}
					parent:         voidptr(node)
					dirty:          true
					text:           child.str()
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
