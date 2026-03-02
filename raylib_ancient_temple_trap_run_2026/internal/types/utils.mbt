///|
/// Return the smaller of two float values.
pub fn minf(a : Float, b : Float) -> Float {
  if a < b {
    a
  } else {
    b
  }
}

///|
/// Return the larger of two float values.
pub fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
  }
}

///|
/// Clamp a float to the inclusive range `[lo, hi]`.
pub fn clampf(v : Float, lo : Float, hi : Float) -> Float {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
/// Return the absolute value of a float.
pub fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
  } else {
    v
  }
}

///|
/// Return the square of a float.
pub fn sq(v : Float) -> Float {
  v * v
}

///|
/// Check whether two axis-aligned rectangles overlap.
pub fn rects_overlap(
  ax : Float,
  ay : Float,
  aw : Float,
  ah : Float,
  bx : Float,
  by : Float,
  bw : Float,
  bh : Float,
) -> Bool {
  ax < bx + bw && ax + aw > bx && ay < by + bh && ay + ah > by
}

///|
/// Check whether a point lies inside an integer rectangle.
pub fn inside_rect(
  px : Float,
  py : Float,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
) -> Bool {
  px >= Float::from_int(x) &&
  px <= Float::from_int(x + w) &&
  py >= Float::from_int(y) &&
  py <= Float::from_int(y + h)
}

///|
/// Return true when pointer/touch is pressing inside a rectangle.
pub fn pointer_on_rect(
  mouse_x : Float,
  mouse_y : Float,
  mouse_hold : Bool,
  touch_count : Int,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
) -> Bool {
  if mouse_hold && inside_rect(mouse_x, mouse_y, x, y, w, h) {
    return true
  }

  for i in 0..<touch_count {
    let p = @raylib.get_touch_position(i)
    if inside_rect(p.x, p.y, x, y, w, h) {
      return true
    }
  }

  false
}

///|
/// Return true when the mouse press occurred inside a rectangle.
pub fn mouse_click_on_rect(
  mouse_x : Float,
  mouse_y : Float,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
) -> Bool {
  @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) &&
  inside_rect(mouse_x, mouse_y, x, y, w, h)
}

///|
/// Compute player rectangle at a candidate center position.
pub fn player_rect_at(
  game : Game,
  px : Float,
  py : Float,
) -> (Float, Float, Float, Float) {
  (
    px - game.player.w * 0.5,
    py - game.player.h * 0.5,
    game.player.w,
    game.player.h,
  )
}

///|
/// Check whether player collider overlaps a rectangle.
pub fn player_hits_rect(
  game : Game,
  x : Float,
  y : Float,
  w : Float,
  h : Float,
) -> Bool {
  let (px, py, pw, ph) = player_rect_at(game, game.player.x, game.player.y)
  rects_overlap(px, py, pw, ph, x, y, w, h)
}

///|
/// Return true while a trap is inside its hot window.
pub fn trap_is_hot(trap : Trap) -> Bool {
  let mut t : Float = trap.timer + trap.phase
  while t >= trap.cycle {
    t = t - trap.cycle
  }
  t < trap.hot_window
}

///|
/// Return true when required relics for exit are collected.
pub fn exit_unlocked(game : Game) -> Bool {
  game.collected_relics >= game.required_relics
}

///|
/// Display name for stage index.
pub fn stage_name(index : Int) -> String {
  match index {
    0 => "Sunken Antechamber"
    1 => "Obsidian Gauntlet"
    _ => "Crown Vault"
  }
}

///|
/// Set banner text and its remaining display duration.
pub fn set_banner(game : Game, text : String, ttl : Float) -> Unit {
  game.banner_text = text
  game.banner_t = ttl
}
