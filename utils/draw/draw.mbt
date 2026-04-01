///|
/// Global font state – holds the loaded custom font, or `None` before `init` / after `cleanup`.
let font_state : Ref[@raylib.Font?] = { val: None }

///|
/// Loads a high-quality TTF font for use by all subsequent `draw_text` / `measure_text` calls.
/// Must be called **after** `@raylib.init_window`.
pub fn init_font() -> Unit {
  // Try multiple paths for font loading.
  // On native: CWD is project root, so "utils/draw/resources/..." works.
  // On web (Emscripten): files are embedded at the @-mapped virtual path,
  // but CWD may vary. Try both absolute and relative paths.
  let paths = [
    "utils/draw/resources/anonymous_pro_bold.ttf", "/utils/draw/resources/anonymous_pro_bold.ttf",
    "./utils/draw/resources/anonymous_pro_bold.ttf",
  ]
  for i in 0..<paths.length() {
    let f = @raylib.load_font_ex(paths[i], 48)
    // Check if the font loaded successfully (has valid texture)
    if f.texture().id() > 0U {
      f.texture().set_filter(@raylib.TextureFilterBilinear)
      font_state.val = Some(f)
      return
    }
  }
  // All paths failed - font_state stays None, draw_text will use default raylib font
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
  color : @raylib.Color,
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
      let v = @raylib.measure_text_ex(
        f,
        text,
        Float::from_int(size),
        spacing(size),
      )
      v.x.to_int()
    }
    None => @raylib.measure_text(text, size)
  }
}
