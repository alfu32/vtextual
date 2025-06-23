module textual

pub type Callback = fn ()

pub interface StringRepr {
	str() string
}
