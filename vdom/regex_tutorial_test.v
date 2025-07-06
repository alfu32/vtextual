module vdom

import regex

interface Any {}

// Helper to dump_value a value with its name
fn dump_value(name string, v Any) {
	println('=== ${name} ===')
	dump(v)
	println('')
}

// test splitting by a simple delimiter
fn test_split_simple() {
	input := 'apple,banana,cherry'
	pattern := r','
	mut re := regex.regex_opt(pattern) or { panic(err) }
	res := re.split(input)
	dump_value('input', input)
	dump_value('pattern', pattern)
	dump_value('result', res)
}

// test splitting with capture groups (keeps delimiters)
fn test_split_with_group() {
	input := 'one;two;three'
	pattern := r'(;)'
	mut re := regex.regex_opt(pattern) or { panic(err) }
	res := re.split(input)
	dump_value('input', &input)
	dump_value('pattern', &pattern)
	dump_value('result', &res)
}

// test splitting with capture groups (keeps delimiters)
fn test_split_with_group2() {
	input := 'a{}b{}c{}'
	pattern := r'([a-z]+\{.*\})'
	mut re := regex.regex_opt(pattern) or { panic(err) }
	res := re.split(input)
	dump_value('input', &input)
	dump_value('pattern', &pattern)
	dump_value('result', &res)
}

// test splitting with capture groups (keeps delimiters)
fn test_split_with_group3() {
	input := 'a{}b{}c{}'
	pattern := r'([a-z]+)\{.*\}'
	mut re := regex.regex_opt(pattern) or { panic(err) }
	res := re.find_all_str(input)
	dump_value('input', &input)
	dump_value('pattern', &pattern)
	dump_value('result', &res)
}

// test splitting with capture groups (keeps delimiters)
fn test_work_parse_css_stylesheet() {
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
			border:solid #4445ff  #4445ff;
			box-sizing:border-box;
			/*20th line*/
		}
		#element-id{
			width:333;
			text-background:#edffaa;
			display:block;
			position:relative;
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
	def_pattern := r'([a-z#.\-]+)\{.*\}'
	mut def_re := regex.regex_opt(def_pattern) or { panic(err) }
	defs := def_re.find_all_str(input)
	// dump_value('input', &input)
	// dump_value('def_pattern', &def_pattern)
	// dump_value('result', &defs)
	rule_pattern := r'\s*[a-z\-]+\s*:\s*.*;\s*'
	mut rule_re := regex.regex_opt(rule_pattern) or { panic(err) }
	selector_pattern := r'^[a-z#.\-]+'
	mut selector_re := regex.regex_opt(selector_pattern) or { panic(err) }
	mut stylesheet := CssStylesheet{}
	for def in defs {
		selector := selector_re.find_all_str(def)

		println('
		definition:
		${def.trim(' ')}
		selector: ${selector[0]}
		'.trim_indent())
		sel := selector[0].trim(' \n\r\t')
		stylesheet.styles[sel] = css_style_new()
		rules := rule_re.find_all_str(def.trim(' \n\r\t'))
		mut rules_text := []string{}
		for rule in rules {
			trimmed := rule.trim(' ;\n\r\t')
			println('   - rule_trimmed: ${trimmed}')
			rules_text << trimmed
		}
		stylesheet.styles[sel] = css_style_parse(rules_text.join(';'))
	}
	dump(stylesheet)
}

// test limiting splits by using a manual loop
fn test_split_max_two() {
	input := 'a-b-c-d'
	pattern := r'-'
	mut re := regex.regex_opt(pattern) or { panic(err) }
	first := re.split(input)
	second := re.split(first[1])
	rest := first[1].all_after('-')
	dump_value('input', &input)
	dump_value('pattern', &pattern)
	dump_value('first split', &first)
	dump_value('second split', &second)
	dump_value('remaining', &rest)
}

// test using special class \d to split on digits
fn test_split_digit_class() {
	input := 'x1y22z333'
	pattern := r'\d+'
	mut re := regex.regex_opt(pattern) or { panic(err) }
	res := re.split(input)
	dump_value('input', &input)
	dump_value('pattern', &pattern)
	dump_value('result', &res)
}

// test splitting empty string boundary cases
fn test_split_empty_boundaries() {
	input := ',start,and,end,'
	pattern := r','
	mut re := regex.regex_opt(pattern) or { panic(err) }
	res := re.split(input)
	dump_value('input', &input)
	dump_value('pattern', &pattern)
	dump_value('result', &res)
}
