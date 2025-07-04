module vdom

import term

fn test_01(){
	html_string ="<box>text</box>"
	css_string ="
		box{
			width:30;
			height:10;
		}
	".trim_indent()
	vt := vt_renderer_init(
		html_string,
		css_string
		120,
		40
	)
	vt.render()
}

fn test_02(){
	sn := "=".repeat(30)
	println(sn)
}

fn test_03(){
	println(term.rgb(7,7,0,"coucou"))
	println(term.rgb(67,67,0,"coucou"))
	println(term.rgb(167,167,0,"coucou"))
	println(term.rgb(255,255,0,"coucou"))
}
