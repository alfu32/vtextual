module vdom

import regex

struct CssRule {
pub mut:
	selector string
	style    CSSStyle
}

pub type CssSelector = string

pub struct CssStylesheet {
pub mut:
	styles map[CssSelector]CSSStyle
}

fn css_stylesheet_parse_old(input string) CssStylesheet {
	mut rules := CssStylesheet{
		styles: map[CssSelector]CSSStyle{}
	}
	// mut rule_re := regex.regex_opt(r'(?s)([#.]?\w+)\s*\{(.*?)\}') or { panic(err) }
	mut rule_re := regex.regex_opt(r'([#.]?\w+ ?)\s*\{(.* ?)\}') or { panic(err) }
	mut prop_re := regex.regex_opt(r'\s*(\w[\w-]*)\s*:\s*([^;]+);?') or { panic(err) }

	mut start := 0
	for {
		mut style := css_style_new()
		a, b := rule_re.match_string(input[start..])
		if a == -1 {
			break
		}

		// capture groups: full match, selector, body
		selector := rule_re.get_group_by_id(input[start..], 1).trim(' ')
		body := rule_re.get_group_by_id(input[start..], 2).trim(' ')

		mut inner_start := 0
		for {
			st, end := prop_re.match_string(body[inner_start..])
			if st == -1 {
				break
			}
			key := prop_re.get_group_by_id(body[inner_start..], 1).trim(' ')
			val := prop_re.get_group_by_id(body[inner_start..], 2).trim(' ')
			style.set(key, val)
			inner_start = end
		}

		rules.styles[selector] = style

		start = b
	}

	return rules
}

fn css_stylesheet_parse(raw_definition string) CssStylesheet {
	input := raw_definition.trim_indent()
	// def_pattern := r'([0-9A-Za-z#.\-]+)\{.*\}'

	def_pattern := r'([0-9A-Za-z#.:\-]+\s*,*\s*)+\{.*\}'
	mut def_re := regex.regex_opt(def_pattern) or { panic(err) }
	defs := def_re.find_all_str(input)
	// dump_value('input', &input)
	// dump_value('def_pattern', &def_pattern)
	// dump_value('result', &defs)
	rule_pattern := r'\s*[a-z\-]+\s*:\s*.*;\s*'
	mut rule_re := regex.regex_opt(rule_pattern) or { panic(err) }
	selectors_pattern := r'^([0-9A-Za-z#.:\-]+\s*,*\s*)+'
	mut selector_re := regex.regex_opt(selectors_pattern) or { panic(err) }
	mut stylesheet := CssStylesheet{}
	for def in defs {
		selectors := selector_re.find_all_str(def)

		// println("
		// definition:
		// ${def.trim(" ")}
		// selectors: ${selectors[0]}
		// ".trim_indent())
		rules_defs := rule_re.find_all_str(def.trim(' \n\r\t'))
		mut rules_clean_text := []string{}
		for rule in rules_defs {
			trimmed := rule.trim(' ;\n\r\t')
			// println("   - rule_trimmed: $trimmed")
			rules_clean_text << trimmed
		}
		rules := css_style_parse(rules_clean_text.join(';'))
		for sel in selectors[0].trim(' \n\r\t').split(',') {
			selector := sel.trim(' ')
			stylesheet.styles[selector] = rules
		}
	}
	return stylesheet
}

pub fn (s CssStylesheet) get_style(node &DomNode) CSSStyle {
	undef := 'undefined-${node.id}'
	id := node.attributes['id'] or { undef }
	class_name := node.attributes['class'] or { undef }
	tag_name := node.tag
	mut css := css_style_new()
	// dump(tag_name)
	class_selector := '.${class_name}'
	// dump(class_selector)
	id_selector := '#${id}'
	// dump(id_selector)
	if s.styles.keys().contains(tag_name) {
		// dump(tag_name)
		css = css.accumulate(s.styles[tag_name])
	}
	if s.styles.keys().contains(class_selector) {
		// dump(class_selector)
		css = css.accumulate(s.styles[class_selector])
	}
	if s.styles.keys().contains(id_selector) {
		// dump(id_selector)
		css = css.accumulate(s.styles[id_selector])
	}
	// dump(css)
	return css
}
