// textual/geometry_test.v
module textual

fn test_offset_arithmetic() {
	a := Offset{3, 5}
	b := Offset{1, 2}
	assert (a + b) == Offset{4, 7}
	assert (a - b) == Offset{2, 3}
}

fn test_size_arithmetic() {
	s1 := Size{10, 20}
	s2 := Size{3, 4}
	assert (s1 + s2) == Size{13, 24}
	assert (s1 - s2) == Size{7, 16}
}

fn test_size_shrink() {
	s := Size{20, 30}
	sp := Spacing{
		top:    2
		right:  3
		bottom: 4
		left:   1
	}
	shrunk := s.shrink(sp)
	assert shrunk.width == 16
	assert shrunk.height == 24
}

fn test_region_contains() {
	r := Region{10, 10, 20, 10}
	assert r.contains(15, 15)
	assert !r.contains(9, 10)
	assert !r.contains(30, 10)
}

fn test_clamp_function() {
	assert clamp(5, 0, 10) == 5
	assert clamp(-1, 0, 10) == 0
	assert clamp(20, 0, 10) == 10
}

fn test_offset_ops() {
	offset_a := Offset{3, 4}
	offset_b := Offset{1, 2}
	println('Offset A: ' + offset_a.str())
	println('Offset B: ' + offset_b.str())

	add := offset_a + offset_b
	println('A + B = ' + add.str())
	assert add.eq(Offset{4, 6})

	sub := offset_a - offset_b
	println('A - B = ' + sub.str())
	assert sub.eq(Offset{2, 2})

	scaled := offset_a.scale(2)
	println('A scaled by 2: ' + scaled.str())
	assert scaled.eq(Offset{6, 8})

	distance := offset_a.distance_to(offset_b)
	println('Distance from A to B: ${distance}')
	assert int(distance) == 2
}

fn test_offset_lerp() {
	a := Offset{0, 0}
	b := Offset{10, 20}
	mid := a.lerp(b, 0.5)
	println('Lerp(0.5) between ' + a.str() + ' and ' + b.str() + ' = ' + mid.str())
	assert mid.eq(Offset{5, 10})
}

fn test_size_ops() {
	size_a := Size{10, 20}
	size_b := Size{3, 4}
	added := size_a + size_b
	println('Size A: ' + size_a.str())
	println('Size B: ' + size_b.str())
	println('A + B = ' + added.str())
	assert added.eq(Size{13, 24})

	shrunk := size_a.shrink(Spacing{1, 2, 3, 4})
	println('Shrunk Size: ' + shrunk.str())
	assert shrunk.eq(Size{4, 16})
}

fn test_size_lerp() {
	a := Size{0, 0}
	b := Size{10, 20}
	mid := a.lerp(b, 0.5)
	println('Lerp(0.5) between ' + a.str() + ' and ' + b.str() + ' = ' + mid.str())
	assert mid.eq(Size{5, 10})
}

fn test_spacing_helpers() {
	all := spacing_all(3)
	println('Spacing all(3): ' + all.str())
	assert all.eq(Spacing{3, 3, 3, 3})

	h := spacing_horizontal(2)
	println('Spacing horizontal(2): ' + h.str())
	assert h.eq(Spacing{0, 2, 0, 2})

	v := spacing_vertical(1)
	println('Spacing vertical(1): ' + v.str())
	assert v.eq(Spacing{1, 0, 1, 0})

	sym := spacing_symmetric(2, 4)
	println('Spacing symmetric(2,4): ' + sym.str())
	assert sym.eq(Spacing{2, 4, 2, 4})
}

fn test_region_ops() {
	r := Region{10, 10, 5, 5}
	println('Region: ' + r.str())

	assert r.contains(12, 12)
	assert !r.contains(5, 5)
	assert !r.contains(20, 20)
	println('Contains tests passed.')
}

fn test_percent_conversion() {
	px := percent_to_pixels(200, 25)
	println('25% of 200 = ${px} px')
	assert px == 50

	percent := pixels_to_percent(200, 50)
	println('50 px of 200 = ${percent}%')
	assert int(percent) == 25
}

fn test_foffset_and_fsize() {
	fo := FOffset{1.5, 2.5}
	scaled := fo.scale(2.0)
	println('FOffset scaled: ' + scaled.str())
	assert scaled == FOffset{3.0, 5.0}

	lerped := fo.lerp(FOffset{3.5, 6.5}, 0.5)
	println('FOffset lerped: ' + lerped.str())
	assert int(lerped.x) == 2 && int(lerped.y) == 4

	dist := fo.distance_to(FOffset{4.5, 6.5})
	println('FOffset distance: ${dist}')
	assert int(dist) == 5

	fs := FSize{10.0, 20.0}
	fs2 := FSize{20.0, 40.0}
	lerp_fs := fs.lerp(fs2, 0.5)
	println('FSize lerped: ' + lerp_fs.str())
	assert int(lerp_fs.width) == 15 && int(lerp_fs.height) == 30
}
