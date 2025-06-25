module vdom

// A simple Event struct
pub struct Event {
pub:
	typ     string
	payload voidptr // you can replace with a more specific type if you like
	target  &Node
}

// Signature for listener functions
pub type EventListener = fn (e Event)

// The core DOM node
pub struct Node {
pub mut:
	tag       string
	attrs     map[string]string
	style     map[string]string          // CSS properties
	listeners map[string][]EventListener // event-type → list of callbacks
	children  []&Node
	parent    &Node = unsafe { nil }
	text      string
}

//–– Style API ––

// set a CSS property
pub fn (mut n Node) set_style(prop string, value string) {
	n.style[prop] = value
}

// get a CSS property (empty string if unset)
pub fn (n &Node) get_style(prop string) string {
	return n.style[prop]
}

// remove a CSS property
pub fn (mut n Node) remove_style(prop string) {
	n.style.delete(prop)
}

//–– Event‐listener API ––

// register a listener for event `typ`
pub fn (mut n Node) add_event_listener(typ string, listener EventListener) {
	if typ !in n.listeners {
		n.listeners[typ] = []EventListener{}
	}
	n.listeners[typ] << listener
}

// remove all listeners for event `typ`
// (you can also enhance this to remove only a specific function)
pub fn (mut n Node) remove_event_listeners(typ string) {
	n.listeners.delete(typ)
}

// dispatch an event to this node
pub fn (n &Node) dispatch_event(e Event) {
	if listeners := n.listeners[e.typ] {
		for l in listeners {
			l(e)
		}
	}
}
