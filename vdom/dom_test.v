module vdom

fn test_css_parser() {
	println(DimensionType.auto)
	mut style := css_style_parse('display:block; width:50%; border:solid #f00; layout:rtlttb; background:blue;')
	println(style)
}
