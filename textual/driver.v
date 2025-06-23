module textual

// This is a stubbed TerminalDriver that will eventually handle keyboard/mouse input.
pub struct TerminalDriver {
pub mut:
	running bool
}

// Starts the event loop: reads user input and pushes events into the Dispatcher
pub fn (mut d TerminalDriver) start() {
	d.running = true
	for d.running {
		if event := d.read_event() {
			msg := EventMessage{
				event: event
			}
			Dispatcher.push(msg)
		}
	}
}

// Stub: replace this with real terminal input parsing
pub fn (d &TerminalDriver) read_event() ?Event {
	// Simulated event
	return none
}
