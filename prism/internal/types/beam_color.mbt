///|
pub fn beam_color_black() -> BeamColor {
  { r: false, g: false, b: false, }
}

///|
pub fn beam_color_red() -> BeamColor {
  { r: true, g: false, b: false, }
}

///|
pub fn beam_color_green() -> BeamColor {
  { r: false, g: true, b: false, }
}

///|
pub fn beam_color_blue() -> BeamColor {
  { r: false, g: false, b: true, }
}

///|
pub fn beam_color_yellow() -> BeamColor {
  { r: true, g: true, b: false, }
}

///|
pub fn beam_color_magenta() -> BeamColor {
  { r: true, g: false, b: true, }
}

///|
pub fn beam_color_cyan() -> BeamColor {
  { r: false, g: true, b: true, }
}

///|
pub fn beam_color_white() -> BeamColor {
  { r: true, g: true, b: true, }
}

///|
pub fn beam_color_add(a : BeamColor, b : BeamColor) -> BeamColor {
  { r: a.r || b.r, g: a.g || b.g, b: a.b || b.b, }
}

///|
pub fn beam_color_filter(color : BeamColor, fc : FilterColor) -> BeamColor {
  match fc {
    Red => { r: color.r, g: false, b: false, }
    Green => { r: false, g: color.g, b: false, }
    Blue => { r: false, g: false, b: color.b, }
  }
}

///|
pub fn beam_color_is_black(c : BeamColor) -> Bool {
  !c.r && !c.g && !c.b
}

///|
pub fn beam_color_channel_count(c : BeamColor) -> Int {
  let mut n = 0
  if c.r {
    n += 1
  }
  if c.g {
    n += 1
  }
  if c.b {
    n += 1
  }
  n
}

///|
pub fn beam_color_to_raylib(c : BeamColor) -> @raylib.Color {
  match (c.r, c.g, c.b) {
    (true, false, false) => color_beam_red
    (false, true, false) => color_beam_green
    (false, false, true) => color_beam_blue
    (true, true, false) => color_beam_yellow
    (true, false, true) => color_beam_magenta
    (false, true, true) => color_beam_cyan
    (true, true, true) => color_beam_white
    _ => @raylib.Color::new(40, 40, 40, 255)
  }
}

///|
pub fn beam_color_display_name(c : BeamColor) -> String {
  match (c.r, c.g, c.b) {
    (true, false, false) => "Red"
    (false, true, false) => "Green"
    (false, false, true) => "Blue"
    (true, true, false) => "Yellow"
    (true, false, true) => "Magenta"
    (false, true, true) => "Cyan"
    (true, true, true) => "White"
    _ => "None"
  }
}
