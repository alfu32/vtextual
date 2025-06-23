module textual

fn test_dispatcher_queueing() {
	mut target := MessageTarget{
		id: 'widget1'
	}

	mut dispatcher := Dispatcher{}
	dispatcher.register(&target)

	dispatcher.queue(Message{
		id:        'test1'
		target_id: 'widget1'
		bubble:    false
		handled:   false
	})

	dispatcher.tick()

	// Ensure inbox was flushed and message was handled
	assert target.inbox.len == 0
}
