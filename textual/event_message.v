// textual/event_message.v

module textual

import time
import rand

pub type EventPayload = KeyEvent | MouseEvent | ResizeEvent | FocusEvent

pub struct EventMessage {
pub:
	id        string
	payload   EventPayload
	timestamp time.Time
}

pub fn new_event_message(payload EventPayload) EventMessage {
	return EventMessage{
		id:        rand.uuid_v4()
		payload:   payload
		timestamp: time.now()
	}
}
