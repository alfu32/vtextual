module textual

import time
import rand

pub struct Timer {
pub:
	id        string
	interval  time.Duration
	repeat    bool
	target_id string
	payload   Message
pub mut:
	next_tick time.Time
}

pub fn new_timer(interval time.Duration, repeat bool, target_id string, payload Message) Timer {
	return Timer{
		id:        rand.uuid_v4()
		interval:  interval
		repeat:    repeat
		next_tick: time.now().add(interval)
		target_id: target_id
		payload:   payload
	}
}

pub struct AppTimer {
pub mut:
	interval_ms int
	elapsed_ms  int
	last_tick   i64
	callback    fn ()
}

// Called every loop iteration to check if enough time passed
pub fn (mut t AppTimer) tick() {
	now := time.now().unix_time_milli()
	if now - t.last_tick >= t.interval_ms {
		t.callback()
		t.last_tick = now
	}
}
