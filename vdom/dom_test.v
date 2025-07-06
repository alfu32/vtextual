module vdom

import term

fn test_css_parser() {
	dump(DimensionType.auto)
	mut style := css_style_parse('display:block; width:50%; border:solid #f00;text-background:22;')
	dump(style)
}

fn test_css_dimension_parse() {
	samples := ['auto', 'none', '50%', '2fr', '10']
	dump('--- test_css_dimension_parse ---')
	for s in samples {
		dim := css_dimension_parse(s)
		dump('${s} => typ=${dim.typ}, value=${dim.value}')
	}
	cc := term.bg_hex(1234233, '123')
}

fn test_css_style_parse() {
	input := 'display:block; width:50%; border:dashed #ff0; text-background:t47; text-color:t23; padding:2;'
	dump('--- test_css_style_parse ---')
	dump('Input: "${input}"')
	style := css_style_parse(input)
	dump('display       = ${style.display}')
	dump('width         = typ=${style.width.typ}, value=${style.width.value}')
	dump('border.style  = ${style.border.style}')
	dump('border.color  = ${style.border.color}')
	dump('background    = ${style.text_style.background}')
	dump('color         = ${style.text_style.color}')
	dump('padding       = typ=${style.padding.typ}, value=${style.padding.value}')
}

fn test_rgb() {
	input := 'display:block; width:50%; border:dashed #ffff00; text-background:#ffff00; color:#111111; padding:2;'
	dump('--- test_css_style_parse ---')
	dump('Input: "${input}"')
	style := css_style_parse(input)
	dump(style.text_style.background.red())
	dump(style.text_style.background.green())
	dump(style.text_style.background.blue())
	dump(style.text_style.color.red())
	dump(style.text_style.color.green())
	dump(style.text_style.color.blue())
}

fn test_build_dom_node() {
	xml_src := '<div id="test" style="display:block;width:10;"><span>Hi</span><!--comment--><![CDATA[DATA]]>Some Other Text Node</div>'
	dump('--- test_build_dom_node ---')
	dump('XML Input: ${xml_src}')
	root := dom_node_parse(xml_src)
	dump('root.tag          = ${root.tag}')
	dump('root.attributes   = ${root.attributes}')
	dump('root.style.display= ${root.style.display}')
	dump('root.style.width  = typ=${root.style.width.typ}, value=${root.style.width.value}')
	dump('children count    = ${root.children.len}')
	for child in root.children {
		dump('  child.tag = ${child.tag}, text="${child.text}"')
		dump('  child.children.len = ${child.children.len}"')
		dump('  child.children = ${child.children}"')
	}
	childchild := root.children[0].children[0]
	dump('  child[0].child.tag = ${childchild.tag}, text="${childchild.text}"')
}

fn test_inner_outer_text_html() {
	xml_src := '<div id="greet"><span>Hello</span> World<!--x--></div>'
	root := dom_node_parse(xml_src)
	dump('root.outer_html(): ${root.outer_html()}')
	// prints: <div id="greet"><span>Hello</span> World<!--x--></div>
	dump('root.inner_html(): ${root.inner_html()}')
	// prints: <span>Hello</span> World<!--x-->
	dump('root.inner_text(): ${root.inner_text()}')
	// prints: Hello World
}
