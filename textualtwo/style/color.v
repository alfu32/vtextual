module style

pub struct Color {
pub:
    r u8
    g u8
    b u8
    a u8 = 255
}

pub fn parse_color(hex string) ?Color {
    if hex.len != 7 || !hex.starts_with('#') {
        return none
    }
    r := u8(hex[1..3], 16) or { return none }
    g := u8(hex[3..5], 16) or { return none }
    b := u8(hex[5..7], 16) or { return none }
    return Color{r: r, g: g, b: b}
}
