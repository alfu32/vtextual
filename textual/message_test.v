module textual

fn test_message_bubbling() {
	mut parent := MessageTarget{
		id: 'parent'
	}
	mut child := MessageTarget{
		id:     'child'
		parent: &parent
	}

	mut message := Message{
		id:        'msg1'
		target_id: 'child'
		bubble:    true
		handled:   false
	}

	child.send(message)
	child.dispatch_all()

	assert message.handled == true
}
