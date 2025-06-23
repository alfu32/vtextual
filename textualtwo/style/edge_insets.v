module style

pub struct EdgeInsets {
pub:
	top    int
	right  int
	bottom int
	left   int
}

pub fn parse_edge(value string) ?EdgeInsets {
	parts := value.split(' ').map(it.int())
	return match parts.len {
		1 {
			EdgeInsets{
				top:    parts[0]
				right:  parts[0]
				bottom: parts[0]
				left:   parts[0]
			}
		}
		2 {
			EdgeInsets{
				top:    parts[0]
				right:  parts[1]
				bottom: parts[0]
				left:   parts[1]
			}
		}
		4 {
			EdgeInsets{
				top:    parts[0]
				right:  parts[1]
				bottom: parts[2]
				left:   parts[3]
			}
		}
		else {
			none
		}
	}
}
