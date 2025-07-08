module app

import term.ui as tui
import vdom

pub struct App {
pub mut:
	tui      &tui.Context = unsafe { nil }
	renderer vdom.VTRenderer
}

pub fn app_init(html string, stylesheet string) &App {
	mut vt := vdom.vt_renderer_init(html, stylesheet, 160, 40)

	event := fn [mut vt] (e &tui.Event, x voidptr) {
		if e.typ == .key_down && e.code == .escape {
			println(x)
			exit(0)
		}
		vt.dispatch_event(e)
		if e.typ != .mouse_move {
			// mut textbox1 := vt.document.query_selector_all('#textbox1')[0]
			// textbox1.children[0].text = ' ${e} ${textbox1.inner_text()}'
		}
	}

	frame := fn [vt] (x voidptr) {
		mut html_app := unsafe { &App(x) }

		// println(tui.Context(x))
		html_app.renderer.render()
		// html_app.tui.clear()
		// html_app.tui.set_bg_color(r: 63, g: 81, b: 181)
		// html_app.tui.draw_rect(20, 6, 41, 10)
		// html_app.tui.draw_text(24, 8, 'Hello from V!')
		// html_app.tui.set_cursor_position(0, 0)
		//
		// html_app.tui.reset()
		// html_app.tui.flush()
	}

	mut html_app := &App{
		renderer: vt
	}
	html_app.tui = tui.init(
		user_data:   html_app
		event_fn:    event
		frame_fn:    frame
		hide_cursor: true
	)
	return html_app
}
