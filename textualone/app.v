module textual

pub interface AppLifecycle {
	on_mount(mut self)
	on_event(mut self Message, mut msg Message)
	on_tick(mut self)
}

pub struct App {
pub mut:
	root    Widget
	timers  []AppTimer
	mounted bool
}

// Call during app startup to mount root and register timers
pub fn (mut app App) mount() {
	if !app.mounted {
		app.mounted = true
		app.on_mount()
	}
}

// Base hook – should be overridden by user
pub fn (mut app App) on_mount() {
	// User-defined: setup layout, register timers
}

// Dispatch event messages here (keyboard, resize, mouse, etc.)
pub fn (mut app App) on_event(msg Message) {
	// Pass to root or propagate manually
}

// Called on every interval tick
pub fn (mut app App) on_tick() {
	// Let timers run
	for mut timer in app.timers {
		timer.tick()
	}
}
