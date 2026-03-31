///|
pub let screen_width : Int = 1280

///|
pub let screen_height : Int = 720

///|
pub let target_fps : Int = 60

///|
pub let cell_size : Int = 64

///|
pub let grid_cols : Int = 8

///|
pub let grid_rows : Int = 8

///|
pub let grid_offset_x : Int = 180

///|
pub let grid_offset_y : Int = 80

///|
pub let palette_x : Int = 740

///|
pub let palette_y : Int = 100

///|
pub let swatch_size : Int = 48

///|
pub let color_bg : @raylib.Color = @raylib.Color::new(25, 22, 35, 255)

///|
pub let color_grid_bg : @raylib.Color = @raylib.Color::new(40, 36, 52, 255)

///|
pub let color_grid_line : @raylib.Color = @raylib.Color::new(60, 55, 75, 255)

///|
pub let color_hole : @raylib.Color = @raylib.Color::new(18, 16, 26, 255)

///|
pub let color_hole_border : @raylib.Color = @raylib.Color::new(100, 90, 130, 255)

///|
pub let color_correct_glow : @raylib.Color = @raylib.Color::new(50, 255, 120, 180)

///|
pub let color_wrong_glow : @raylib.Color = @raylib.Color::new(255, 50, 60, 180)

///|
pub let color_hover : @raylib.Color = @raylib.Color::new(255, 255, 255, 60)

///|
pub let color_hud_text : @raylib.Color = @raylib.Color::new(210, 205, 230, 255)

///|
pub let color_hud_dim : @raylib.Color = @raylib.Color::new(140, 135, 160, 200)

///|
pub let color_title_accent : @raylib.Color = @raylib.Color::new(180, 120, 255, 255)

///|
pub let color_star_on : @raylib.Color = @raylib.Color::new(255, 215, 0, 255)

///|
pub let color_star_off : @raylib.Color = @raylib.Color::new(80, 75, 95, 255)

///|
pub let color_selected : @raylib.Color = @raylib.Color::new(255, 255, 255, 255)

///|
pub let color_tier_repair : @raylib.Color = @raylib.Color::new(100, 200, 255, 255)

///|
pub let color_tier_restore : @raylib.Color = @raylib.Color::new(255, 180, 60, 255)

///|
pub let color_tier_master : @raylib.Color = @raylib.Color::new(255, 80, 180, 255)

///|
pub fn tile_color_to_raylib(c : TileColor) -> @raylib.Color {
  match c {
    Red => @raylib.Color::new(220, 50, 50, 255)
    Blue => @raylib.Color::new(50, 120, 220, 255)
    Green => @raylib.Color::new(50, 190, 80, 255)
    Gold => @raylib.Color::new(230, 190, 50, 255)
    Purple => @raylib.Color::new(160, 60, 210, 255)
    White => @raylib.Color::new(230, 225, 240, 255)
  }
}

///|
pub fn tile_color_index(c : TileColor) -> Int {
  match c {
    Red => 0
    Blue => 1
    Green => 2
    Gold => 3
    Purple => 4
    White => 5
  }
}

///|
pub fn index_to_tile_color(i : Int) -> TileColor {
  match i {
    0 => Red
    1 => Blue
    2 => Green
    3 => Gold
    4 => Purple
    _ => White
  }
}

///|
pub fn tile_shape_index(s : TileShape) -> Int {
  match s {
    Square => 0
    Triangle => 1
    Arrow => 2
    Diamond => 3
    Circle => 4
    Cross => 5
  }
}

///|
pub fn index_to_tile_shape(i : Int) -> TileShape {
  match i {
    0 => Square
    1 => Triangle
    2 => Arrow
    3 => Diamond
    4 => Circle
    _ => Cross
  }
}

///|
pub fn orientation_index(o : Orientation) -> Int {
  match o {
    N => 0
    E => 1
    S => 2
    W => 3
  }
}

///|
pub fn index_to_orientation(i : Int) -> Orientation {
  match i % 4 {
    0 => N
    1 => E
    2 => S
    _ => W
  }
}
