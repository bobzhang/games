///|
/// Window width in pixels.
pub let screen_w : Int = 1500

///|
/// Window height in pixels.
pub let screen_h : Int = 900

///|
/// Fixed update/render target frequency.
pub let target_fps : Int = 120

///|
/// Number of chambers in one full run.
pub let stage_total : Int = 3

///|
/// Left world boundary of the playable chamber.
pub let world_x : Float = 40.0

///|
/// Top world boundary of the playable chamber.
pub let world_y : Float = 70.0

///|
/// Width of the playable chamber region.
pub let world_w : Float = 1020.0

///|
/// Height of the playable chamber region.
pub let world_h : Float = 790.0

///|
/// Player collider width.
pub let player_w : Float = 34.0

///|
/// Player collider height.
pub let player_h : Float = 34.0

///|
/// Movement speed while not dashing.
pub let player_speed_walk : Float = 260.0

///|
/// Movement speed while dashing.
pub let player_speed_dash : Float = 520.0

///|
/// Maximum stamina value.
pub let stamina_max : Float = 100.0

///|
/// Stamina drained per second during dash.
pub let stamina_drain_per_s : Float = 44.0

///|
/// Stamina recovered per second while not dashing.
pub let stamina_recover_per_s : Float = 28.0

///|
/// Minimum stamina required to keep dash active.
pub let dash_min_stamina : Float = 8.0

///|
/// Stamina recovered when collecting a relic.
pub let relic_stamina_bonus : Float = 12.0

///|
/// Trap kind id for spike traps.
pub let trap_kind_spike : Int = 0

///|
/// Trap kind id for dart traps.
pub let trap_kind_dart : Int = 1

///|
/// Hazard kind id for lava zones.
pub let hazard_kind_lava : Int = 0

///|
/// Right-side HUD panel rectangle `(x, y, w, h)`.
pub fn panel_rect() -> (Int, Int, Int, Int) {
  (1080, 20, 390, 860)
}

///|
/// Title-screen start button rectangle.
pub fn title_start_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 210, screen_h / 2 + 130, 420, 88)
}

///|
/// Stage-clear next button rectangle.
pub fn panel_next_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 230, screen_h / 2 + 82, 200, 72)
}

///|
/// Stage-clear retry button rectangle.
pub fn panel_restart_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 + 30, screen_h / 2 + 82, 200, 72)
}

///|
/// In-run restart button rectangle on side panel.
pub fn play_restart_rect() -> (Int, Int, Int, Int) {
  let (px, py, _pw, ph) = panel_rect()
  (px + 84, py + ph - 84, 220, 58)
}

///|
/// Touch control rectangle for left movement.
pub fn touch_left_rect() -> (Int, Int, Int, Int) {
  (86, screen_h - 176, 88, 88)
}

///|
/// Touch control rectangle for right movement.
pub fn touch_right_rect() -> (Int, Int, Int, Int) {
  (268, screen_h - 176, 88, 88)
}

///|
/// Touch control rectangle for upward movement.
pub fn touch_up_rect() -> (Int, Int, Int, Int) {
  (177, screen_h - 266, 88, 88)
}

///|
/// Touch control rectangle for downward movement.
pub fn touch_down_rect() -> (Int, Int, Int, Int) {
  (177, screen_h - 86, 88, 88)
}

///|
/// Touch control rectangle for dash hold input.
pub fn touch_dash_rect() -> (Int, Int, Int, Int) {
  let (px, py, pw, ph) = panel_rect()
  (px + pw - 170, py + ph - 220, 132, 132)
}
