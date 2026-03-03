///|
/// Width of the game window in pixels.
pub let screen_w : Int = 1440

///|
/// Height of the game window in pixels.
pub let screen_h : Int = 860

///|
/// Target frame rate used by the main loop.
pub let target_fps : Int = 120

///|
/// World layout coordinate for play x.
pub let play_x : Int = 36

///|
/// World layout coordinate for play y.
pub let play_y : Int = 70

///|
/// Gameplay tuning constant for play w.
pub let play_w : Int = 1046

///|
/// Gameplay tuning constant for play h.
pub let play_h : Int = 752

///|
/// World layout coordinate for hud x.
pub let hud_x : Int = play_x + play_w + 18

///|
/// World layout coordinate for hud y.
pub let hud_y : Int = play_y

///|
/// Gameplay tuning constant for hud w.
pub let hud_w : Int = screen_w - hud_x - play_x

///|
/// Gameplay tuning constant for hud h.
pub let hud_h : Int = play_h

///|
/// World layout coordinate for play left.
pub let play_left : Float = Float::from_int(play_x + 12)

///|
/// World layout coordinate for play top.
pub let play_top : Float = Float::from_int(play_y + 12)

///|
/// World layout coordinate for play right.
pub let play_right : Float = Float::from_int(play_x + play_w - 12)

///|
/// World layout coordinate for play bottom.
pub let play_bottom : Float = Float::from_int(play_y + play_h - 12)

///|
/// Gameplay tuning constant for shrine count.
pub let shrine_count : Int = 4

///|
/// Upper bound for max lanterns in gameplay systems.
pub let max_lanterns : Int = 20

///|
/// Upper bound for max gusts in gameplay systems.
pub let max_gusts : Int = 24

///|
/// Upper bound for max sparks in gameplay systems.
pub let max_sparks : Int = 180

///|
/// Upper bound for max thieves in gameplay systems.
pub let max_thieves : Int = 18

///|
/// Spatial tuning constant for patrol radius.
pub let patrol_radius : Float = 18.0

///|
/// Movement or scaling coefficient for patrol accel.
pub let patrol_accel : Float = 980.0

///|
/// Movement or scaling coefficient for patrol drag.
pub let patrol_drag : Float = 4.2

///|
/// Movement or scaling coefficient for patrol max speed.
pub let patrol_max_speed : Float = 322.0

///|
/// Timing constant that controls guard time.
pub let guard_time : Float = 1.20

///|
/// Spatial tuning constant for guard radius.
pub let guard_radius : Float = 112.0

///|
/// Gameplay tuning constant for guard push.
pub let guard_push : Float = 320.0

///|
/// Timing constant that controls calm duration.
pub let calm_duration : Float = 1.80

///|
/// Spatial tuning constant for calm radius.
pub let calm_radius : Float = 128.0

///|
/// Timing constant that controls calm cooldown.
pub let calm_cooldown : Float = 6.20

///|
/// Spatial tuning constant for lantern radius.
pub let lantern_radius : Float = 12.0

///|
/// Survival or damage balancing constant for lantern base drain.
pub let lantern_base_drain : Float = 3.8

///|
/// Movement or scaling coefficient for lantern drag.
pub let lantern_drag : Float = 1.8

///|
/// Survival or damage balancing constant for lantern escort regen.
pub let lantern_escort_regen : Float = 8.2

///|
/// Spatial tuning constant for escort pickup range.
pub let escort_pickup_range : Float = 78.0

///|
/// Gameplay tuning constant for escort pull.
pub let escort_pull : Float = 6.2

///|
/// Spatial tuning constant for delivery radius.
pub let delivery_radius : Float = 34.0

///|
/// Gameplay tuning constant for combo window.
pub let combo_window : Float = 4.2

///|
/// Per-step progression tuning for combo bonus step.
pub let combo_bonus_step : Int = 42

///|
/// Base value before difficulty or progression scaling for delivery score base.
pub let delivery_score_base : Int = 128

///|
/// Progression and scoring constant for score per flame.
pub let score_per_flame : Int = 2

///|
/// Gameplay tuning constant for extinguish limit.
pub let extinguish_limit : Int = 7

///|
/// Gameplay tuning constant for interact stabilize boost.
pub let interact_stabilize_boost : Float = 6.0

///|
/// Gameplay tuning constant for lantern spawn interval.
pub let lantern_spawn_interval : Float = 2.20

///|
/// Minimum or floor value used for lantern spawn floor.
pub let lantern_spawn_floor : Float = 0.86

///|
/// Gameplay tuning constant for gust spawn interval.
pub let gust_spawn_interval : Float = 1.40

///|
/// Minimum or floor value used for gust spawn floor.
pub let gust_spawn_floor : Float = 0.44

///|
/// Gameplay tuning constant for spark spawn interval.
pub let spark_spawn_interval : Float = 0.18

///|
/// Minimum or floor value used for spark spawn floor.
pub let spark_spawn_floor : Float = 0.07

///|
/// Gameplay tuning constant for thief spawn interval.
pub let thief_spawn_interval : Float = 7.20

///|
/// Minimum or floor value used for thief spawn floor.
pub let thief_spawn_floor : Float = 2.50

///|
/// Survival or damage balancing constant for gust drain power.
pub let gust_drain_power : Float = 16.0

///|
/// Survival or damage balancing constant for spark drain power.
pub let spark_drain_power : Float = 26.0

///|
/// Survival or damage balancing constant for thief drain burst.
pub let thief_drain_burst : Float = 32.0

///|
/// Movement or scaling coefficient for thief speed.
pub let thief_speed : Float = 136.0

///|
/// Spatial tuning constant for thief radius.
pub let thief_radius : Float = 14.0

///|
/// Spatial tuning constant for thief contact radius.
pub let thief_contact_radius : Float = thief_radius + lantern_radius + 4.0

///|
/// Gameplay tuning constant for thief steal period.
pub let thief_steal_period : Float = 0.65

///|
/// Gameplay tuning constant for status default t.
pub let status_default_t : Float = 1.30

///|
/// Returns world-space coordinates for gate position.
pub fn gate_position() -> (Float, Float) {
  (Float::from_int(play_x + 110), Float::from_int(play_y + play_h / 2))
}

///|
/// Returns world-space coordinates for shrine position.
pub fn shrine_position(index : Int) -> (Float, Float) {
  match index.clamp(min=0, max=shrine_count - 1) {
    0 => (Float::from_int(play_x + play_w - 140), Float::from_int(play_y + 126))
    1 =>
      (
        Float::from_int(play_x + play_w - 168),
        Float::from_int(play_y + play_h / 2),
      )
    2 =>
      (
        Float::from_int(play_x + play_w - 140),
        Float::from_int(play_y + play_h - 126),
      )
    _ =>
      (
        Float::from_int(play_x + play_w / 2 + 106),
        Float::from_int(play_y + 104),
      )
  }
}
