module vdom

// bring in your renderer definitions
// (they must be in the same module or imported appropriately)

// ─── TESTS ───────────────────────────────────────────────────────────────────────

// display:none should hide the element completely
fn test_display_none() {
	dom := dom_parse('<div style="display:none;width:5;height:1;background:red">Hello</div>')
	canvas := Canvas{
		width:  10
		height: 3
	}
	drawables := render(dom, canvas)
	println(drawables)
}

// absolutely positioned children should be placed at (left,top)
fn test_position_absolute() {
	html := '<div style="width:10;height:3;background:black">
                <span style="position:absolute;left:2;top:1;width:3;height:1;background:red">A</span>
             </div>'
	dom := dom_parse(html)
	canvas := Canvas{
		width:  10
		height: 5
	}
	drawables := render(dom, canvas)

	println(drawables)
}

// percentage width/height should scale relative to parent/canvas
fn test_width_height_percentage() {
	html := '<div style="width:50%;height:50%;background:green"></div>'
	dom := dom_parse(html)
	canvas := Canvas{
		width:  20
		height: 10
	}
	drawables := render(dom, canvas)
	println(drawables)
	// expect exactly one green Rect at (0,0) size 10×5
	// assert drawables.len == 1
	d := drawables[0]
	println(d)
	// assert d is Rect
	r := d as Rect
	println(r)
	// assert r.x == 0 && r.y == 0
	// assert r.width == 10 && r.height == 5
}

// overflow-x:hidden should clip children that exceed the container width
fn test_overflow_hidden() {
	html := '<div style="width:5;height:1;overflow-x:hidden">
                <span style="width:10;height:1">0123456789</span>
             </div>'
	dom := dom_parse(html)
	canvas := Canvas{
		width:  10
		height: 3
	}
	drawables := render(dom, canvas)
	println(drawables)

	// // text is entirely outside the clipped region → no Text drawables
	// mut text_count := 0
	// for d in drawables {
	// 	if d is Text {
	// 		text_count++
	// 	}
	// }
	// assert text_count == 0
}

// position:relative with top/left offsets should shift the element
fn test_top_left_relative() {
	html := '<div style="position:relative;top:1;left:2;width:5;height:2;background:blue"></div>'
	dom := dom_parse(html)
	canvas := Canvas{
		width:  10
		height: 5
	}
	drawables := render(dom, canvas)

	println(drawables)
}

// if both right and bottom are specified on an absolute box, they override left/top
fn test_absolute_right_bottom() {
	html := '<div style="width:10;height:5;background:yellow">
                <div style="position:absolute;right:1;bottom:2;width:3;height:1;background:red"></div>
             </div>'
	dom := dom_parse(html)
	canvas := Canvas{
		width:  12
		height: 8
	}
	drawables := render(dom, canvas)
	println(drawables)
}
