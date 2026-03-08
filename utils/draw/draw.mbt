///|
/// Global font state – holds the loaded custom font, or `None` before `init` / after `cleanup`.
let font_state : Ref[@raylib.Font?] = { val: None }

///|
/// Loads a high-quality TTF font for use by all subsequent `draw_text` / `measure_text` calls.
/// Must be called **after** `@raylib.init_window`.
pub fn init_font() -> Unit {
  let f = @raylib.load_font_ex("utils/draw/resources/anonymous_pro_bold.ttf", 48)
  @raylib.set_font_texture_filter(f, @raylib.TextureFilterBilinear)
  font_state.val = Some(f)
}

///|
/// Unloads the custom font.  Call **before** `@raylib.close_window`.
pub fn cleanup() -> Unit {
  match font_state.val {
    Some(f) => {
      @raylib.unload_font(f)
      font_state.val = None
    }
    None => ()
  }
}

///|
/// Computes inter-character spacing proportional to font size.
fn spacing(size : Int) -> Float {
  Float::from_int(size) / 10.0
}

///|
/// Drop-in replacement for `@raylib.draw_text` that uses the loaded TTF font.
/// Falls back to the default raylib font if `init` has not been called.
pub fn draw_text(
  text : String,
  x : Int,
  y : Int,
  size : Int,
  color : @raylib.Color
) -> Unit {
  match font_state.val {
    Some(f) =>
      @raylib.draw_text_ex(
        f,
        text,
        @raylib.Vector2::new(Float::from_int(x), Float::from_int(y)),
        Float::from_int(size),
        spacing(size),
        color,
      )
    None => @raylib.draw_text(text, x, y, size, color)
  }
}

///|
/// Drop-in replacement for `@raylib.measure_text` that uses the loaded TTF font.
/// Falls back to the default raylib measurement if `init` has not been called.
pub fn measure_text(text : String, size : Int) -> Int {
  match font_state.val {
    Some(f) => {
      let v = @raylib.measure_text_ex(f, text, Float::from_int(size), spacing(size))
      v.x.to_int()
    }
    None => @raylib.measure_text(text, size)
  }
}
