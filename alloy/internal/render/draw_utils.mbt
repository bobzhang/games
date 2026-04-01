///|
fn draw_stars_small(x : Int, y : Int, rating : @types.StarRating) -> Unit {
  let count = @types.star_count(rating)
  for i in 0..<3 {
    let color = if i < count {
      @types.color_star_gold
    } else {
      @types.color_star_empty
    }
    @draw.draw_text("*", x + i * 14, y, 16, color)
  }
}

///|
fn draw_stars_large(x : Int, y : Int, rating : @types.StarRating) -> Unit {
  let count = @types.star_count(rating)
  for i in 0..<3 {
    let color = if i < count {
      @types.color_star_gold
    } else {
      @types.color_star_empty
    }
    @draw.draw_text("*", x + i * 40, y, 44, color)
  }
}

///|
fn sinf(a : Float) -> Float {
  Float::from_double(@math.sin(a.to_double()))
}

///|
fn cosf(a : Float) -> Float {
  Float::from_double(@math.cos(a.to_double()))
}

///|
fn format_float(v : Float, decimals : Int) -> String {
  if decimals <= 0 {
    return v.to_int().to_string()
  }
  let mut mult = 1
  for _i in 0..<decimals {
    mult *= 10
  }
  let scaled = (v * Float::from_int(mult)).to_int()
  let integer_part = scaled / mult
  let frac_part = scaled % mult
  let frac_abs = if frac_part < 0 { -frac_part } else { frac_part }
  integer_part.to_string() + "." + frac_abs.to_string()
}
