module style

import style { Color, EdgeInsets }

pub struct Style {
pub:
	color     ?Color
	margin    ?EdgeInsets
	padding   ?EdgeInsets
	bold      bool
	italic    bool
	underline bool
}
