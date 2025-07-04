module main

import vdom

fn main() {
	vt := vdom.vt_renderer_init('<div class="wrap"><box id="textbox">text</box></div>',
		'
			.wrap{
				border:solid #228888;
				background:#CC0000;
				height:100%;
				color:#222222;
			}
			#textbox{
				border:solid #338822;
				left:30;
				top:4;
				width:30;
				height:10;
				position:absolute;
				background:#FFFF00;
				color:#222222;
			}
		',
		120, 20)
	print(vt)
	vt.render()
}
