module vdom

// NOTE: make sure this file is named node_test.v so that `v test` will pick it up.

//–– Basic node creation & tree structure
fn test_node_basic() {
	mut root := &Node{
		tag: 'div'
	}
	mut child := &Node{
		tag:    'span'
		text:   'Hello, v-dom!'
		parent: root
	}
	root.children << child

	// Print what we built
	println('Root node: ${root}')
	println('Child node: ${child}')

	// Assertions
	assert root.tag == 'div'
	assert root.children.len == 1
	assert root.children[0].text == 'Hello, v-dom!'
}

//–– Style API
fn test_style_api() {
	mut n := &Node{
		tag: 'p'
	}

	// set a style, then print
	n.set_style('color', 'blue')
	println('After set_style: ${n}')

	// ensure it's applied
	assert n.get_style('color') == 'blue'

	// remove it, then print again
	n.remove_style('color')
	println('After remove_style: ${n}')

	// ensure it's gone
	assert n.get_style('color') == ''
}

struct Testmod {
pub mut:
	flag bool
}

//–– Event‐listener API
fn test_event_listeners_and_dispatch() {
	mut n := &Node{
		tag: 'button'
	}

	// a flag we can flip inside our listener
	mut obj := &Testmod{false}

	// define a listener closure
	listener := fn [mut obj] (e Event) {
		// print the event that was dispatched
		println('Listener invoked! event: ${e}')
		// mutate our flag
		obj.flag = true
	}

	// register it and show the listener map
	n.add_event_listener('click', listener)
	println('Listeners before dispatch: ${n.listeners}')
	println('Flag before dispatch: ${obj.flag}')
	assert !obj.flag

	// craft and dispatch an event
	evt := Event{
		typ:     'click'
		payload: unsafe { nil }
		target:  n
	}
	n.dispatch_event(evt)

	// print our flag after dispatch
	println('Listeners after dispatch: ${n.listeners}')
	println('Flag after dispatch: ${obj.flag}')

	// assert our listener actually ran
	assert obj.flag
}
