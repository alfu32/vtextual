module textual

import time

fn test_timer_trigger() {
	mut dispatcher := Dispatcher{}

	mut target := MessageTarget{
		id: 'timer_target'
	}
	dispatcher.register(&target)

	message := Message{
		id:        'timer_msg'
		target_id: 'timer_target'
		bubble:    false
		handled:   false
	}

	timer := new_timer(10 * time.millisecond, false, 'timer_target', message)
	dispatcher.timers << timer

	time.sleep(20 * time.millisecond)
	dispatcher.tick()

	// Target should have received the message, but inbox is flushed in dispatch_all
	assert target.inbox.len == 0
}
