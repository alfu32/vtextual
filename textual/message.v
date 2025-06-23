module textual

import rand

// textual/message.v

pub struct Message {
pub:
	id     string
	bubble bool
pub mut:
	handled   bool
	target_id string
}

pub fn new_message(target_id string, bubble bool) Message {
	return Message{
		id:        rand.uuid_v4()
		bubble:    bubble
		handled:   false
		target_id: target_id
	}
}

pub struct MessageTarget {
pub:
	id string
pub mut:
	parent &MessageTarget = unsafe { nil }
	inbox  []&Message
}

pub fn (target &MessageTarget) handle(msg Message) {
	// Placeholder — override in concrete widget
	println('Message ${msg.id} delivered to ${target.id}')
}

pub fn (mut target MessageTarget) send(msg &Message) {
	target.inbox << msg
}

pub fn (mut target MessageTarget) dispatch_all() {
	// mut _ := []Message{}
	for mut msg in target.inbox {
		// print(*msg)
		target.handle(*msg)
		if msg.bubble && isnil(target.parent) == false {
			target.parent.send(msg)
		}
		msg.handled = true
		// print(msg)
	}
	target.inbox.clear()
}
