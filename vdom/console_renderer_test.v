module vdom

// NOTE: make sure this file is named console_renderer_test.v
// Run with: v test .

//–– Unit parsing ––
fn test_compute_unit() {
	// unitless
	mut u := compute_unit('10', 100)
	print(u)
	assert u == 10
	// percentage
	u = compute_unit('50%', 80)
	print(u)
	assert u == 40
	// div
	u = compute_unit('4div', 80)
	print(u)
	assert u == 20
	// empty → inherit parent
	u = compute_unit('', 60)
	print(u)
	assert u == 60
}

//–– Basic layout ––
fn test_compute_layout_simple() {
	mut root := &Node{
		tag: 'div'
	}
	root.set_style('width', '10')
	root.set_style('height', '5')

	mut layouts := []LayoutBox{}
	compute_layout(root, 0, 0, 100, 100, mut layouts)
	// we printed for inspection
	println('Layouts (simple): ${layouts}')

	assert layouts.len == 1
	lb := layouts[0]
	assert lb.x == 0
	assert lb.y == 0
	assert lb.width == 10
	assert lb.height == 5
	assert lb.node == root
}

//–– Absolute & Fixed positioning ––
fn test_compute_layout_absolute_and_fixed() {
	mut root := &Node{
		tag: 'div'
	}
	root.set_style('width', '20')
	root.set_style('height', '10')

	mut abs := &Node{
		tag:    'div'
		parent: root
	}
	abs.set_style('position', 'absolute')
	abs.set_style('left', '5')
	abs.set_style('top', '3')
	root.children << abs

	mut fix := &Node{
		tag:    'div'
		parent: root
	}
	fix.set_style('position', 'fixed')
	fix.set_style('left', '2')
	fix.set_style('top', '1')
	root.children << fix

	mut layouts := []LayoutBox{}
	compute_layout(root, 0, 0, 100, 100, mut layouts)
	println('Layouts (abs/fixed): ${layouts}')

	// root, abs, fix
	assert layouts.len == 3
	// abs at (5,3)
	assert layouts[1].node == abs
	assert layouts[1].x == 5
	assert layouts[1].y == 3
	// fix at (2,1)
	assert layouts[2].node == fix
	assert layouts[2].x == 2
	assert layouts[2].y == 1
}

//–– Margin & Padding ––
fn test_compute_layout_with_margin_padding() {
	mut root := &Node{
		tag: 'div'
	}
	root.set_style('width', '10')
	root.set_style('height', '5')
	root.set_style('margin', '1')
	root.set_style('padding', '2')

	mut layouts := []LayoutBox{}
	compute_layout(root, 0, 0, 100, 100, mut layouts)
	println('Layouts (margin/padding): ${layouts}')

	// Origin should be shifted by margin (1,1)
	assert layouts[0].x == 1
	assert layouts[0].y == 1
	// Width/height remain the styled values
	assert layouts[0].width == 10
	assert layouts[0].height == 5
}

//–– Percent & div units in layout ––
fn test_compute_layout_with_percent_and_div() {
	mut root := &Node{
		tag: 'div'
	}
	root.set_style('width', '100')
	root.set_style('height', '50')

	mut child := &Node{
		tag:    'div'
		parent: root
	}
	child.set_style('width', '50%') // 50 of 100
	child.set_style('height', '5div') // 50 / 5 = 10
	root.children << child

	mut layouts := []LayoutBox{}
	compute_layout(root, 0, 0, 100, 100, mut layouts)
	println('Layouts (percent/div): ${layouts}')

	assert layouts.len == 2
	assert layouts[1].width == 50
	assert layouts[1].height == 10
}

//–– Paint background & border ––
fn test_paint_box_background_and_border() {
	mut cvs := new_canvas(25, 25, '')
	mut n := &Node{
		tag: 'div'
	}
	n.set_style('background-color', 'red')
	n.set_style('border-style', 'solid')
	n.set_style('border-color', 'blue')

	// a 3×3 box at (1,1)
	lb := LayoutBox{2, 2, 18, 5, n}
	paint_box(mut cvs, lb)
	println('Canvas after paint_box:')
	for row in cvs.cells {
		println(row.map(it.ch.str()).join(''))
	}

	// top‐left corner should be border
	assert cvs.cells[2][2].ch == `+`
	aa := cvs.cells[2][3].fg_fmt(`─`.str())
	println(aa.str())
	assert aa == '[0m─[0m'
	// interior fill at (2,2)
	bb := cvs.cells[3][2].bg_fmt(`─`.str())
	println(bb.str())
	assert bb == '[48;2;255;0;0m─[49m'
}

//–– Text painting (wrap & nowrap) ––
fn test_paint_text_wrap_and_nowrap() {
	mut cvs_wrap := new_canvas(5, 2, '')
	paint_text(mut cvs_wrap, 'ABCDE', 0, 0, 3, 2, bg_formatter('white'), fg_formatter('black'),
		'wrap')
	println('Canvas wrap:')
	for row in cvs_wrap.cells {
		println(row.map(it.ch.str()).join(''))
	}

	// 'ABC' on first line, 'DE' on second
	assert cvs_wrap.cells[0][0].ch == `A`
	assert cvs_wrap.cells[0][1].ch == `B`
	assert cvs_wrap.cells[0][2].ch == `C`
	assert cvs_wrap.cells[1][0].ch == `D`
	assert cvs_wrap.cells[1][1].ch == `E`

	mut cvs_nowrap := new_canvas(5, 2, '')
	paint_text(mut cvs_nowrap, 'ABCDE', 0, 0, 3, 2, bg_formatter('white'), fg_formatter('black'),
		'nowrap')
	println('Canvas nowrap:')
	for row in cvs_nowrap.cells {
		println(row.map(it.ch.str()).join(''))
	}

	// only 'ABC' should appear; no 'D'
	assert cvs_nowrap.cells[0][0].ch == `A`
	assert cvs_nowrap.cells[0][1].ch == `B`
	assert cvs_nowrap.cells[0][2].ch == `C`
	for row in cvs_nowrap.cells {
		for cell in row {
			assert cell.ch != `D`
		}
	}
}

//–– Overflow scrollbars ––
fn test_overflow_scrollbars() {
	mut cvs := new_canvas(5, 5, '')
	mut n := &Node{
		tag: 'div'
	}
	n.set_style('overflow-x', 'scroll')
	n.set_style('overflow-y', 'scroll')

	// 4×4 box at (0,0)
	lb := LayoutBox{0, 0, 4, 4, n}
	paint_box(mut cvs, lb)
	println('Canvas overflow:')
	for row in cvs.cells {
		println(row.map(it.ch.str()).join(''))
	}

	// horizontal scrollbar at y = 3, x = 0..3 should be '¯'
	for x in 0 .. 4 {
		assert cvs.cells[3][x].ch == `¯`
	}
	// vertical scrollbar at x = 3, y = 0..3 should be '|'
	for y in 0 .. 4 {
		assert cvs.cells[y][3].ch == `|`
	}
}
