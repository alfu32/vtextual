// textual/runner.v

module textual

import time

pub struct Dispatcher {
pub mut:
	targets      []&MessageTarget
	global_queue []Message
	timers       []Timer
}

pub fn (mut d Dispatcher) register(target &MessageTarget) {
	d.targets << target
}

pub fn (mut d Dispatcher) queue(msg Message) {
	d.global_queue << msg
}

pub fn (mut d Dispatcher) tick() {
	d.tick_timers()
	d.flush_messages()
}

pub fn (mut d Dispatcher) flush_messages() {
	for mut target in d.targets {
		for msg in d.global_queue {
			if msg.target_id == target.id {
				target.send(msg)
			}
		}
		target.dispatch_all()
	}
	d.global_queue.clear()
}

pub fn (mut d Dispatcher) tick_timers() {
	now := time.now()
	mut keep := []Timer{}
	for mut timer in d.timers {
		if now >= timer.next_tick {
			d.queue(timer.payload)
			if timer.repeat {
				timer.next_tick = now.add(timer.interval)
				keep << timer
			}
		} else {
			keep << timer
		}
	}
	d.timers = keep
}

// In your main loop:
fn run_event_loop(mut dispatcher Dispatcher) {
	for {
		time.sleep(10 * time.millisecond)
		dispatcher.tick()
	}
}
