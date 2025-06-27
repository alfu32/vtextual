module vdom

fn test_css_parser() {
	println(DimensionType.auto)
	mut style := css_style_parse('display:block; width:50%; border:solid #f00; layout:rtlttb; background:blue;')
	println(style)
}

fn test_css_dimension_parse() {
	samples := ['auto', 'none', '50%', '2fr', '10']
	println('--- test_css_dimension_parse ---')
	for s in samples {
		dim := css_dimension_parse(s)
		println('${s} => typ=${dim.typ}, value=${dim.value}')
	}
}

fn test_css_style_parse() {
	input := 'display:block; width:50%; border:dashed #ff0; layout:RTLBTT; background:blue; color:#123456; padding:2; margin:1fr;'
	println('--- test_css_style_parse ---')
	println('Input: "${input}"')
	style := css_style_parse(input)
	println('display       = ${style.display}')
	println('width         = typ=${style.width.typ}, value=${style.width.value}')
	println('border.style  = ${style.border.style}')
	println('border.color  = ${style.border.color}')
	println('layout        = ${style.layout}')
	println('background    = ${style.background}')
	println('color         = ${style.color}')
	println('padding       = typ=${style.padding.typ}, value=${style.padding.value}')
	println('margin        = typ=${style.margin.typ}, value=${style.margin.value}')
}

fn test_build_dom_node() {
	xml_src := '<div id="test" style="display:block;width:10;"><span>Hi</span><!--comment--><![CDATA[DATA]]>Some Other Text Node</div>'
	println('--- test_build_dom_node ---')
	println('XML Input: ${xml_src}')
	root := dom_node_parse(xml_src)
	println('root.tag          = ${root.tag}')
	println('root.attributes   = ${root.attributes}')
	println('root.style.display= ${root.style.display}')
	println('root.style.width  = typ=${root.style.width.typ}, value=${root.style.width.value}')
	println('children count    = ${root.children.len}')
	for child in root.children {
		println('  child.tag = ${child.tag}, text="${child.text}"')
		println('  child.children.len = ${child.children.len}"')
		println('  child.children = ${child.children}"')
	}
	childchild := root.children[0].children[0]
	println('  child[0].child.tag = ${childchild.tag}, text="${childchild.text}"')
}

fn test_inner_outer_text_html() {
	xml_src := '<div id="greet"><span>Hello</span> World<!--x--></div>'
	root := dom_node_parse(xml_src)
	println(root.outer_html())
	// prints: <div id="greet"><span>Hello</span> World<!--x--></div>
	println(root.inner_html())
	// prints: <span>Hello</span> World<!--x-->
	println(root.inner_text())
	// prints: Hello World
}
