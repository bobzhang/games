///|
/// Returns full kitchen grid width in pixels.
pub fn kitchen_w() -> Int {
  station_cols * station_tile_w + (station_cols - 1) * station_gap
}

///|
/// Returns full kitchen grid height in pixels.
pub fn kitchen_h() -> Int {
  station_rows * station_tile_h + (station_rows - 1) * station_gap
}

///|
/// Returns pixel X of a station column origin.
pub fn station_x(col : Int) -> Int {
  kitchen_left + col * (station_tile_w + station_gap)
}

///|
/// Returns pixel Y of a station row origin.
pub fn station_y(row : Int) -> Int {
  kitchen_top + row * (station_tile_h + station_gap)
}

///|
/// Returns left X coordinate of the right-side info panel.
pub fn panel_x() -> Int {
  kitchen_left + kitchen_w() + 36
}

///|
/// Returns width of the right-side info panel.
pub fn panel_w() -> Int {
  screen_w - panel_x() - 44
}

///|
/// Maps station grid coordinates to a station id.
pub fn station_at(x : Int, y : Int) -> Int {
  if y == 0 {
    if x == 0 {
      station_broth
    } else if x == 1 {
      station_protein
    } else if x == 2 {
      station_veg
    } else if x == 3 {
      station_spice
    } else {
      station_none
    }
  } else if y == 1 {
    if x == 0 {
      station_prep
    } else if x == 1 {
      station_pot
    } else if x == 2 {
      station_serve
    } else if x == 3 {
      station_rush
    } else {
      station_none
    }
  } else if y == 2 {
    if x == 0 {
      station_trash
    } else if x == 1 {
      station_queue
    } else if x == 2 {
      station_reputation
    } else if x == 3 {
      station_storage
    } else {
      station_none
    }
  } else {
    station_none
  }
}

///|
/// Returns human-readable label for a station id.
pub fn station_name(station : Int) -> String {
  if station == station_broth {
    "Broth Kettle"
  } else if station == station_protein {
    "Protein Crate"
  } else if station == station_veg {
    "Veg Basket"
  } else if station == station_spice {
    "Chili Rack"
  } else if station == station_prep {
    "Prep Board"
  } else if station == station_pot {
    "Hotpot Base"
  } else if station == station_serve {
    "Serve Counter"
  } else if station == station_rush {
    "Rush Bell"
  } else if station == station_trash {
    "Waste Bin"
  } else if station == station_queue {
    "Queue Monitor"
  } else if station == station_reputation {
    "Street Cred"
  } else {
    "Dry Storage"
  }
}

///|
/// Returns display name for a broth kind id.
pub fn broth_name(kind : Int) -> String {
  if kind == 0 {
    "Mala"
  } else if kind == 1 {
    "Tomato"
  } else {
    "Mushroom"
  }
}

///|
/// Returns display name for a protein kind id.
pub fn protein_name(kind : Int) -> String {
  if kind == 0 {
    "Beef"
  } else if kind == 1 {
    "Lamb"
  } else {
    "Tofu"
  }
}

///|
/// Returns display name for a vegetable kind id.
pub fn veg_name(kind : Int) -> String {
  if kind == 0 {
    "Lotus"
  } else if kind == 1 {
    "Spinach"
  } else {
    "Enoki"
  }
}

///|
/// Returns display name for a spice level.
pub fn spice_name(level : Int) -> String {
  if level <= 0 {
    "Mild"
  } else if level == 1 {
    "Bold"
  } else {
    "Inferno"
  }
}

///|
/// Clamps an integer to the inclusive `[lo, hi]` range.
pub fn clampi(v : Int, lo : Int, hi : Int) -> Int {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
/// Clamps a float to the inclusive `[lo, hi]` range.
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
/// Returns the larger of two float values.
pub fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
  }
}

///|
/// Returns the smaller of two float values.
pub fn minf(a : Float, b : Float) -> Float {
  if a < b {
    a
  } else {
    b
  }
}

///|
/// Sets the HUD message text and resets its remaining lifetime.
pub fn set_message(game : Game, text : String) -> Unit {
  game.msg = text
  game.msg_t = msg_ttl
}
