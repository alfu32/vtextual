module main

import vdom
import time
import app

fn main() {
	html := '
		<vt-box id="wrap">
			<vt-box id="textbox1">
			    START text where there`s enough tokens to get it wrapped around more than on line. this visible chaos so they scramble the controllers, but the russian telegram channels are open to the public. they cannot offer the people solutions they can`t do that.text where there`s enough tokens to get it wrapped around more than on line. this visible chaos so they scramble the controllers, but the russian telegram channels are open to the public. they cannot offer the people solutions they can`t do that. END
			</vt-box>
			<vt-list id="list">
				<vt-list-item>top=0ch</vt-list-item>
				<vt-list-item>left=0ch</vt-list-item>
				<vt-list-item>width=100%</vt-list-item>
				<vt-list-item>height=3ch</vt-list-item>
				<vt-list-item>border=solid #ddeedd #440088</vt-list-item>
				<vt-list-item>position=relative-sibling</vt-list-item>
				<vt-list-item>text-background=#440088</vt-list-item>
				<vt-list-item>text-color=#222222</vt-list-item>
			</vt-list>
			<vt-box id="textbox2">
				START text where there`s enough tokens to get it wrapped around more than on line. this visible chaos so they scramble the controllers, but the russian telegram channels are open to the public. they cannot offer the people solutions they can`t do that. END
			</vt-box>
		</vt-box>
	'
	stylesheet := '
		#wrap{
			top:0ch;
			left:0ch;
			width:100%;
			height:100%;
			border:solid #ddeedd #440088;
			position:relative-parent;
			text-background:#440088;
			text-color:#ddeedd;
		}
		#textbox1{
			top:0%;
			left:0ch;
			width:30%;
			height:100%;
			border:rounded #dec5ea #aa3396;
			position:relative-parent;
			text-background:#aa3396;
			text-color:#dec5ea;
		}
		#list{
			top:0ch;
			left:60%;
			width:40%;
			height:100%;
			border:solid #fffee7 #2338ff;
			position:relative-parent;
			direction:ttb;
			text-background:#2338ff;
			text-color:#fffee7;
		}
		vt-list-item{
			top:3ch;
			left:0ch;
			width:100%;
			height:1ch;
			border:none #2e2e2e #ffd500;
			position:relative-sibling;
			direction:ttb;
			text-background:#ffd500;
			text-color:#2e2e2e;
		}
		#textbox2{
			top:0ch;
			left:30%;
			width:30%;
			height:100%;
			border:double #aaeeff #00AA99;
			position:relative-parent;
			text-background:#00AA99;
			text-color:#222222;
		}
	'.trim_indent()
	mut a := app.app_init(html, stylesheet)
	a.tui.run()!
}

fn main0() {
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
		<vt-box id="wrap">
			<vt-box id="textbox1">
			    START text where there`s enough tokens to get it wrapped around more than on line. this visible chaos so they scramble the controllers, but the russian telegram channels are open to the public. they cannot offer the people solutions they can`t do that.text where there`s enough tokens to get it wrapped around more than on line. this visible chaos so they scramble the controllers, but the russian telegram channels are open to the public. they cannot offer the people solutions they can`t do that. END
			</vt-box>
			<vt-list id="list">
				<vt-list-item>top=0ch</vt-list-item>
				<vt-list-item>left=0ch</vt-list-item>
				<vt-list-item>width=100%</vt-list-item>
				<vt-list-item>height=3ch</vt-list-item>
				<vt-list-item>border=solid #ddeedd #440088</vt-list-item>
				<vt-list-item>position=relative-sibling</vt-list-item>
				<vt-list-item>text-background=#440088</vt-list-item>
				<vt-list-item>text-color=#222222</vt-list-item>
			</vt-list>
			<vt-box id="textbox2">
				START text where there`s enough tokens to get it wrapped around more than on line. this visible chaos so they scramble the controllers, but the russian telegram channels are open to the public. they cannot offer the people solutions they can`t do that. END
			</vt-box>
		</vt-box>
	'
	stylesheet := '
		#wrap{
			top:0ch;
			left:0ch;
			width:100%;
			height:100%;
			border:solid #ddeedd #440088;
			position:relative-parent;
			text-background:#440088;
			text-color:#ddeedd;
		}
		#textbox1{
			top:0%;
			left:0ch;
			width:30%;
			height:100%;
			border:rounded #dec5ea #aa3396;
			position:relative-parent;
			text-background:#aa3396;
			text-color:#dec5ea;
		}
		#list{
			top:0ch;
			left:60%;
			width:40%;
			height:100%;
			border:solid #fffee7 #2338ff;
			position:relative-parent;
			direction:ttb;
			text-background:#2338ff;
			text-color:#fffee7;
		}
		vt-list-item{
			top:3ch;
			left:0ch;
			width:100%;
			height:1ch;
			border:none #2e2e2e #ffd500;
			position:relative-sibling;
			direction:ttb;
			text-background:#ffd500;
			text-color:#2e2e2e;
		}
		#textbox2{
			top:0ch;
			left:30%;
			width:30%;
			height:100%;
			border:double #aaeeff #00AA99;
			position:relative-parent;
			text-background:#00AA99;
			text-color:#222222;
		}
	'.trim_indent()
	mut vt := vdom.vt_renderer_init(html, stylesheet, 160, 40)

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

		// textbox1.children[0].text = ' ${k:06x} ${textbox1.inner_text()}'
		textbox1.scroll.y = k % 5
		// root.scroll.y = (2*k) % 10
		time.sleep(444 * time.millisecond)
	}
	// println(textbox1)
	// println(textbox1.children)
}
