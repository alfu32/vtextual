module main

import vdom

fn main() {
	st := '
		top:2;
		left:2;
		width:100;
		height:15;
		border:solid #228888 #440088;
		position:relative;
		text-background:#CC0000;
		text-color:#222222;
	'.trim_indent()
	dump(st)
	dump(vdom.css_style_parse(st))
	html := '
		<div id="wrap">
			<box id="textbox1">text where theres enough tokens to get it wraped around more tha on line</box>
			<box id="textbox2">text where theres enough tokens to get it wraped around more tha on line</box>
		</div>
	'
	stylesheet := '
		#wrap{
			top:2;
			left:2;
			width:100;
			height:15;
			border:solid #228888 #440088;
			position:relative;
			text-background:#440088;
			text-color:#222222;
		}
		#textbox1{
			top:2;
			left:2;
			width:10;
			height:7;
			border:solid #338822 #7733AA;
			position:relative;
			text-background:#7733AA;
			text-color:#222222;
		}
		#textbox2{
			top:3;
			left:2;
			width:10;
			height:7;
			border:solid #338822 #00AA99;
			position:relative;
			text-background:#00AA99;
			text-color:#222222;
		}
	'.trim_indent()
	vt := vdom.vt_renderer_init(html, stylesheet, 120, 20)
	// vt.render_debug()
	vt.render()
}
