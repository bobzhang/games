///|
/// Title text shown in window and menus.
pub let game_title : String = "raylib [game] fighter 97 lite"

///|
/// Window width in pixels.
pub let screen_width : Int32 = 1360

///|
/// Window height in pixels.
pub let screen_height : Int32 = 768

///|
/// World y-coordinate of the ground plane.
pub let floor_y : Float = 572.0

///|
/// Left stage boundary for fighter movement.
pub let stage_left_x : Float = 120.0

///|
/// Right stage boundary for fighter movement.
pub let stage_right_x : Float = 1240.0

///|
/// Horizontal center line of the stage.
pub let center_line_x : Float = (stage_left_x + stage_right_x) * 0.5

///|
/// Target simulation frame rate.
pub let fight_fps : Float = 60.0

///|
/// Fixed-step delta time used per simulation frame.
pub let frame_dt : Float = 1.0 / fight_fps

///|
/// Max allowed frame delta for clamping slow frames.
pub let max_frame_dt : Float = 0.05

///|
/// Number of fighter slots in a match.
pub let max_players : Int32 = 2

///|
/// Number of characters in the roster.
pub let roster_count : Int32 = 6

///|
/// Maximum stage particle slots.
pub let max_particles : Int32 = 860

///|
/// Maximum hit spark slots.
pub let max_hit_sparks : Int32 = 360

///|
/// Direction history buffer size for motion parsing.
pub let direction_buffer_size : Int32 = 42

///|
/// Sentinel winner value for no winner yet.
pub let winner_none : Int32 = -1

///|
/// Sentinel winner value for draw result.
pub let winner_draw : Int32 = -2

///|
/// Facing value for left.
pub let facing_left : Int32 = -1

///|
/// Facing value for right.
pub let facing_right : Int32 = 1

///|
/// Motion id for quarter-circle-forward command.
pub let motion_qcf : Int32 = 1

///|
/// Motion id for dragon-punch command.
pub let motion_dp : Int32 = 2

///|
/// Rounds required to win a match.
pub let max_round_wins : Int32 = 2

///|
/// Round timer start value in seconds.
pub let round_time_start : Float = 99.0

///|
/// Duration of intro state in seconds.
pub let intro_duration : Float = 2.6

///|
/// Duration of round-over state in seconds.
pub let round_over_duration : Float = 2.8

///|
/// Duration of match-over state in seconds.
pub let match_over_duration : Float = 6.0

///|
/// Blink speed for title prompts.
pub let title_blink_speed : Float = 2.5

///|
/// Blink speed for select highlights.
pub let select_blink_speed : Float = 4.8

///|
/// Forward walk speed.
pub let move_speed_forward : Float = 220.0

///|
/// Backward walk speed.
pub let move_speed_back : Float = 170.0

///|
/// Horizontal slide speed while crouching.
pub let crouch_slide_speed : Float = 80.0

///|
/// Initial upward jump velocity.
pub let jump_initial_velocity : Float = -700.0

///|
/// Downward acceleration applied while airborne.
pub let gravity_force : Float = 1800.0

///|
/// Forward dash speed.
pub let dash_forward_speed : Float = 520.0

///|
/// Backward dash speed.
pub let dash_back_speed : Float = -430.0

///|
/// Dash duration in frames.
pub let dash_duration_frames : Int32 = 14

///|
/// Visual body width for fighter rendering.
pub let fighter_body_width : Float = 72.0

///|
/// Visual body height for fighter rendering.
pub let fighter_body_height : Float = 134.0

///|
/// Standing hurtbox width.
pub let fighter_stand_hurtbox_w : Float = 56.0

///|
/// Standing hurtbox height.
pub let fighter_stand_hurtbox_h : Float = 124.0

///|
/// Crouching hurtbox width.
pub let fighter_crouch_hurtbox_w : Float = 60.0

///|
/// Crouching hurtbox height.
pub let fighter_crouch_hurtbox_h : Float = 84.0

///|
/// Pushbox radius used for fighter separation.
pub let fighter_push_radius : Float = 46.0

///|
/// Maximum fighter health.
pub let health_max : Int32 = 1000

///|
/// Base guard meter maximum.
pub let guard_max : Int32 = 100

///|
/// Super meter maximum.
pub let super_max : Int32 = 100

///|
/// Super meter cost for using super move.
pub let super_cost : Int32 = 100

///|
/// Guard recovery per second.
pub let guard_recover_per_sec : Float = 9.0

///|
/// Meter gain when an attack is blocked.
pub let meter_gain_blocked : Int32 = 4

///|
/// Meter gain when taking a hit.
pub let meter_gain_hit_taken : Int32 = 7

///|
/// Default hitstop frames.
pub let hitstop_default : Int32 = 8

///|
/// Hitstop frames for super attacks.
pub let hitstop_super : Int32 = 14

///|
/// Combo damage scaling step per hit.
pub let combo_decay_step : Float = 0.075

///|
/// Combo timeout window in frames.
pub let combo_timeout_frames : Int32 = 34

///|
/// Damage multiplier for counter hits.
pub let counter_hit_bonus : Float = 1.16

///|
/// Horizontal range for throw attempt.
pub let throw_distance : Float = 68.0

///|
/// Allowed vertical difference for throws.
pub let throw_vertical_tolerance : Float = 44.0

///|
/// Damage dealt by throws.
pub let throw_damage : Int32 = 118

///|
/// Knockdown duration after throw.
pub let throw_knockdown_frames : Int32 = 42

///|
/// Horizontal push applied on successful throw.
pub let throw_push_x : Float = 190.0

///|
/// Vertical launch velocity on successful throw.
pub let throw_launch_y : Float = -200.0

///|
/// Throw tech timing window in frames.
pub let throw_tech_window_frames : Int32 = 8

///|
/// Horizontal push applied during throw tech.
pub let throw_tech_push_x : Float = 136.0

///|
/// Invulnerability frames granted by throw tech.
pub let throw_tech_invuln_frames : Int32 = 6

///|
/// Minimum free corner space required for throws.
pub let throw_corner_space_min : Float = 74.0

///|
/// Escape ratio used when resolving corner throws.
pub let throw_corner_escape_ratio : Float = 0.58

///|
/// Invulnerability frames during wakeup.
pub let wakeup_invuln_frames : Int32 = 10

///|
/// Health regeneration rate in training mode.
pub let training_health_regen_per_sec : Float = 140.0

///|
/// Duration for training info text.
pub let training_info_duration : Float = 1.8

///|
/// Double-tap detection window in seconds.
pub let tap_window : Float = 0.24

///|
/// CPU think interval in seconds.
pub let cpu_think_period : Float = 0.1

///|
/// Base CPU reaction delay.
pub let cpu_reaction_base : Float = 0.12

///|
/// CPU jump decision probability.
pub let cpu_jump_chance : Float = 0.08

///|
/// CPU special-move decision probability.
pub let cpu_special_chance : Float = 0.22

///|
/// CPU super-move decision probability.
pub let cpu_super_chance : Float = 0.18

///|
/// CPU block decision probability.
pub let cpu_block_chance : Float = 0.64

///|
/// Gravity applied to particles.
pub let particle_gravity : Float = 1200.0

///|
/// Friction multiplier applied to particles.
pub let particle_friction : Float = 0.87

///|
/// Camera shake decay speed.
pub let camera_shake_decay : Float = 7.2

///|
/// Maximum camera shake amount.
pub let camera_shake_max : Float = 18.0

///|
/// Default camera zoom.
pub let camera_zoom_base : Float = 1.0

///|
/// Camera zoom when fighters are close.
pub let camera_zoom_close : Float = 1.06

///|
/// Camera zoom when fighters are far apart.
pub let camera_zoom_far : Float = 0.95

///|
/// Number of columns in character select grid.
pub let select_grid_columns : Int32 = 3

///|
/// Width of quote dialog box.
pub let quote_box_w : Int32 = 520

///|
/// Height of quote dialog box.
pub let quote_box_h : Int32 = 76

///|
/// Font size for large titles.
pub let font_title : Int32 = 62

///|
/// Font size for subtitles.
pub let font_subtitle : Int32 = 28
