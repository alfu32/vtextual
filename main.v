module main

import vdom
import time

fn main() {
	st := '
		top:2ch;
		left:2ch;
		width:100ch;
		height:15ch;
		border:solid #228888 #440088;
		position:relative-parent;
		text-background:#CC0000;
		text-color:#222222;
	'.trim_indent()
	dump(st)
	dump(vdom.css_style_parse(st))
	html := '
		<div id="wrap">
			<box id="textbox1">
			    text where there`s enough tokens to get it wrapped around more than on line. this visible chaos so they scramble the controllers, but the russian telegram channels are open to the public. they cannot offer the people solutions they can`t do that.text where there`s enough tokens to get it wrapped around more than on line. this visible chaos so they scramble the controllers, but the russian telegram channels are open to the public. they cannot offer the people solutions they can`t do that.
			</box>
			<box id="textbox2">
				text where there`s enough tokens to get it wrapped around more than on line. this visible chaos so they scramble the controllers, but the russian telegram channels are open to the public. they cannot offer the people solutions they can`t do that.
			</box>
		</div>
	'
	stylesheet := '
		#wrap{
			top:2ch;
			left:2ch;
			width:100ch;
			height:30ch;
			border:solid #ddeedd #440088;
			position:relative-parent;
			text-background:#440088;
			text-color:#222222;
		}
		#textbox1{
			top:10ch;
			left:2ch;
			width:30ch;
			height:8ch;
			border:rounded #331111 #7733AA;
			position:relative-parent;
			text-background:#7733AA;
			text-color:#eeeeee;
		}
		#textbox2{
			top:10ch;
			left:52ch;
			width:24ch;
			height:9ch;
			border:double #aaeeff #00AA99;
			position:relative-sibling;
			text-background:#00AA99;
			text-color:#222222;
		}
	'.trim_indent()
	mut vt := vdom.vt_renderer_init(html, stylesheet, 120, 20)

	mut textbox1 := vt.document.query_selector_all('#textbox1')[0]
	mut root := vt.document.root.children[0]

	lim := $if debug ? {
		1
	} $else {
		100
	}
	for k in 0 .. lim {
		$if debug ? {
			vt.render_debug()
		} $else {
			vt.render()
		}

		textbox1.children[0].text = ' ${k:06x} ${textbox1.inner_text()}'
		textbox1.scroll.y = k % 5
		// root.scroll.y = (2*k) % 10
		time.sleep(444 * time.millisecond)
	}
	// println(textbox1)
	// println(textbox1.children)
}
