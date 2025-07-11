module vdom

import regex

struct TestCases {
pub:
	text_01 string = '
	#id{width:10}
	.class{width:20}
	tag{width:30}
	tag, #some-id, .some-class, some-tag:hover {width:30}
	'.trim_indent()
}

fn test_regex() {
	mut rule_re := regex.regex_opt(r'([#.]?\w+ ?)\s*\{(.* ?)\}') or { panic(err) }
	dump(rule_re)
	dump(TestCases{}.text_01)
}

fn test_regex_1() {
	input := TestCases{}.text_01.trim_indent()
	def_pattern := r'([0-9A-Za-z#.:\-]+\s*,*\s*)+\{.*\}'
	mut def_re := regex.regex_opt(def_pattern) or { panic(err) }
	defs := def_re.find_all_str(input)
	dump(def_re)
	dump(TestCases{}.text_01)
	dump(defs)
}

fn test_stylesheet_parsing_empty() {
	css_stylesheet := css_stylesheet_parse('')
	dump(css_stylesheet)
}

fn test_stylesheet_parsing_simple_defs() {
	css_stylesheet := css_stylesheet_parse('
	#id{
		width:10;
	}
	.class{
		width:20;
	}
	tag{
		width:30;
	}
    '.trim_indent())
	dump(css_stylesheet)
}

fn test_stylesheet_parsing_full_defs() {
	input := '
		.element-class{
			width:333;
			text-background:#edffaa;
			display:block;
			position:absolute;
			top:12;
			left:14%;
			right:11fr;
			bottom:222;
			width:234%;
			min-width:234%;
			max-width:234%;
			height:234%;
			min-height:234%;
			max-height:234%;
			padding:3;
			border:[*]I[*]I #4445ff  #4445ff;
			box-sizing:border-box;
			/*20th line*/
		}
		#element-id{
			width:333;
			text-background:#edffaa;
			display:block;
			position:relative-parent;
			top:12;
			left:14%;
			right:11fr;
			bottom:222;
			width:234%;
			min-width:234%;
			max-width:234%;
			height:234%;
			min-height:234%;
			max-height:234%;
			padding:3;
			border:thick #4445ff  #4445ff;
			box-sizing:border-box;
			/*20th line*/
		}
		tag-name{
			width:333;
			text-background:#edffaa;
			display:block;
			position:fixed;
			top:12;
			left:14%;
			right:11fr;
			bottom:222;
			width:234%;
			min-width:234%;
			max-width:234%;
			height:234%;
			min-height:234%;
			max-height:234%;
			padding:3;
			border:solid #4445ff  #4445ff;
			box-sizing:border-box;
			overflow-x:auto;
			overflow-y:scroll;
			/*20th line*/
		}
    '.trim_indent()
	css_stylesheet := css_stylesheet_parse(input.trim_indent())
	dump(css_stylesheet)
}
