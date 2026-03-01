///|
/// Width of the game window in pixels.
pub let screen_w : Int = 1720

///|
/// Height of the game window in pixels.
pub let screen_h : Int = 980

///|
/// Target frame rate used by the main loop.
pub let target_fps : Int = 120

///|
/// Left x coordinate of the bowling lane area.
pub let lane_x : Int = 90

///|
/// Top y coordinate of the bowling lane area.
pub let lane_y : Int = 40

///|
/// Width of the bowling lane in pixels.
pub let lane_w : Int = 970

///|
/// Height of the bowling lane in pixels.
pub let lane_h : Int = 900

///|
/// Lane left edge as float for physics calculations.
pub let lane_left : Float = Float::from_int(lane_x)

///|
/// Lane top edge as float for physics calculations.
pub let lane_top : Float = Float::from_int(lane_y)

///|
/// Lane right edge as float for physics calculations.
pub let lane_right : Float = Float::from_int(lane_x + lane_w)

///|
/// Lane bottom edge as float for physics calculations.
pub let lane_bottom : Float = Float::from_int(lane_y + lane_h)

///|
/// Y coordinate of the foul line.
pub let foul_line_y : Float = lane_bottom - 146.0

///|
/// Y coordinate of the pin deck center line.
pub let pin_deck_y : Float = lane_top + 148.0

///|
/// Vertical spacing between pin rows.
pub let pin_row_gap : Float = 44.0

///|
/// Horizontal spacing between pins in a row.
pub let pin_col_gap : Float = 41.0

///|
/// Radius of a single pin in world units.
pub let pin_radius : Float = 13.0

///|
/// Radius of the bowling ball in world units.
pub let ball_radius : Float = 18.0

///|
/// Ball spawn x coordinate before each throw.
pub let ball_start_x : Float = Float::from_int(lane_x + lane_w / 2)

///|
/// Ball spawn y coordinate before each throw.
pub let ball_start_y : Float = lane_bottom - 58.0

///|
/// Minimum aim angle offset in degrees.
pub let aim_min : Float = -36.0

///|
/// Maximum aim angle offset in degrees.
pub let aim_max : Float = 36.0

///|
/// Minimum spin value accepted by input.
pub let spin_min : Float = -1.0

///|
/// Maximum spin value accepted by input.
pub let spin_max : Float = 1.0

///|
/// Maximum number of roll entries stored in score history.
pub let max_rolls : Int = 24

///|
/// Number of pooled spark particles for impact effects.
pub let max_sparks : Int = 1200

///|
/// Left x coordinate of the side panel.
pub let panel_x0 : Int = lane_x + lane_w + 24

///|
/// Width of the side panel.
pub let panel_w : Int = screen_w - panel_x0 - 28

///|
/// Returns the full panel rectangle `(x, y, w, h)`.
pub fn panel_rect() -> (Int, Int, Int, Int) {
  (panel_x0, 20, panel_w, screen_h - 40)
}

///|
/// Returns the title-screen start button rectangle.
pub fn title_start_button() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 240, 600, 480, 116)
}

///|
/// Returns the result-screen retry button rectangle.
pub fn retry_button() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 220, 650, 440, 104)
}

///|
/// Returns the touch rectangle for aiming left.
pub fn touch_aim_left_rect() -> (Int, Int, Int, Int) {
  (72, screen_h - 170, 128, 96)
}

///|
/// Returns the touch rectangle for aiming right.
pub fn touch_aim_right_rect() -> (Int, Int, Int, Int) {
  (216, screen_h - 170, 128, 96)
}

///|
/// Returns the touch rectangle for decreasing spin.
pub fn touch_spin_left_rect() -> (Int, Int, Int, Int) {
  (370, screen_h - 170, 128, 96)
}

///|
/// Returns the touch rectangle for increasing spin.
pub fn touch_spin_right_rect() -> (Int, Int, Int, Int) {
  (514, screen_h - 170, 128, 96)
}

///|
/// Returns the touch rectangle for throw power input.
pub fn touch_power_rect() -> (Int, Int, Int, Int) {
  (screen_w - 316, screen_h - 212, 252, 150)
}
