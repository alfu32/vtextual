module vdom

fn test_renderer() {
	// build your tree, set styles…
	mut root := &Node{
		tag: 'div'
	}
	root.set_style('width', '200px')
	root.set_style('height', '100px')
	root.set_style('background-color', 'lightgrey')

	mut btn := &Node{
		tag:    'button'
		parent: root
		text:   'Click me'
	}
	btn.set_style('position', 'absolute')
	btn.set_style('left', '20px')
	btn.set_style('top', '40px')
	btn.set_style('border-style', 'solid')
	btn.set_style('border-color', 'black')
	btn.set_style('width', '80px')
	btn.set_style('height', '30px')
	root.children << btn

	primes := render(root)
	println(primes) // you’ll see two Rects + one Text in a flat list
}
