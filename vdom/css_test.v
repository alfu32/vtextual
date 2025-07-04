module vdom

fn test_css_style_overwrite() {
	style1 := css_style_parse('width:30;background:#304050;position:absolute')
	style2 := css_style_parse('width:40')
	style3 := style1.accumulate(style2)
	style4 := style2.accumulate(style1)
	dump('${style1.width} <- ${style2.width} = ${style3.width}')
	dump('${style2.width} <- ${style1.width} = ${style4.width}')
	assert style3.width.value == 40
	assert style4.width.value == 30
	dump('${style1.text_style.bg.to_u32():06X} <- ${style2.text_style.bg.to_u32():06X} = ${style3.text_style.bg.to_u32():06X}')
	dump('${style2.text_style.bg.to_u32():06X} <- ${style1.text_style.bg.to_u32():06X} = ${style4.text_style.bg.to_u32():06X}')
	assert style3.text_style.bg == css_color_parse_u32(0x304050)
	assert style4.text_style.bg == css_color_parse_u32(0x304050)
	dump('${style1.position} <- ${style2.position} = ${style3.position}')
	dump('${style2.position} <- ${style1.position} = ${style4.position}')
}

fn test_css_style_override() {
	style1 := css_style_parse('width:30;height:90;background:#304050;position:absolute')
	style2 := css_style_parse('width:40')
	style3 := style1.override(style2)
	style4 := style2.override(style1)
	dump('${style1.width} <- ${style2.width} = ${style3.width}')
	dump('${style2.width} <- ${style1.width} = ${style4.width}')
	assert style3.width.value == 40
	assert style4.width.value == 30
	dump('${style1.height} <- ${style2.height} = ${style3.height}')
	dump('${style2.height} <- ${style1.height} = ${style4.height}')
	assert style3.height.value == 0
	assert style4.height.value == 90
	dump('${style1.text_style.bg.to_u32():06X} <- ${style2.text_style.bg.to_u32():06X} = ${style3.text_style.bg.to_u32():06X}')
	dump('${style2.text_style.bg.to_u32():06X} <- ${style1.text_style.bg.to_u32():06X} = ${style4.text_style.bg.to_u32():06X}')
	assert style3.text_style.bg == css_color_parse_u32(0x304050)
	assert style4.text_style.bg == css_color_parse_u32(0x304050)
	dump('${style1.position} <- ${style2.position} = ${style3.position}')
	dump('${style2.position} <- ${style1.position} = ${style4.position}')
}

fn test_parsei64() {
	mut a := '32'.i64()
	dump(a)
	a = '0x32'.i64()
	dump(a)
	a = '0b32'.i64()
	dump(a)
	a = 'abbrtsdfe'.i64()
	dump(a)
	dump('abbrtsdfe'.is_int())
	dump('32'.is_int())
	dump('32d'.is_int())
	dump('0x32F'.is_int())
	dump('0x32F'.is_hex())
}

fn test_ascii() {
	for k in (32) .. (255) {
		ch := u8(k)
		println('${k:03} - [ ${ch.ascii_str()} ]')
	}
}
