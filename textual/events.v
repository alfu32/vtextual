// textual/events.v

module textual

import time

pub type Event = KeyEvent | MouseEvent | ResizeEvent | FocusEvent

pub struct KeyEvent {
pub:
	timestamp time.Time
	key       string
	ctrl      bool
	alt       bool
	shift     bool
}

pub struct MouseEvent {
pub:
	timestamp time.Time
	x         int
	y         int
	button    string
	action    string // 'down', 'up', 'move'
}

pub struct ResizeEvent {
pub:
	timestamp time.Time
	width     int
	height    int
}

pub struct FocusEvent {
pub:
	timestamp time.Time
	gained    bool
}
