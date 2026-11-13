///|
pub(all) struct Vec2 {
  mut x : Float
  mut y : Float
}

///|
pub(all) struct Body {
  mut id : Int32
  mut active : Bool
  kind : PieceKind
  material : Material
  mut x : Float
  mut y : Float
  mut angle : Float
  mut vx : Float
  mut vy : Float
  mut angular_vel : Float
  width : Float
  height : Float
  mut mass : Float
  mut stress : Float
  mut broken : Bool
  mut grounded : Bool
}

///|
pub(all) struct Joint {
  mut active : Bool
  kind : JointKind
  body_a : Int32
  body_b : Int32
  local_x_a : Float
  local_y_a : Float
  local_x_b : Float
  local_y_b : Float
  mut stress : Float
  mut broken : Bool
  strength : Float
}

///|
pub(all) struct World {
  bodies : Array[Body]
  joints : Array[Joint]
  mut gravity : Float
  ground_y : Float
  mut wind_force : Float
  mut quake_timer : Float
  mut quake_intensity : Float
  mut friction_mult : Float
}

///|
pub(all) struct Level {
  name : String
  description : String
  target_height : Float
  budget : Int32
  test_kinds : Array[TestKind]
  available_pieces : Array[(PieceKind, Material, Int32)]
  world_index : Int32 // which world this level belongs to (0, 1, 2)
}

///|
pub(all) struct Blueprint {
  kind : BlueprintKind
  name : String
  pieces : Array[(PieceKind, Material, Float, Float, Float)]
  // (kind, material, offset_x, offset_y, angle)
  cost : Int32
}

///|
pub(all) struct Particle {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut life : Float
  mut max_life : Float
  mut size : Float
  r : Int32
  g : Int32
  b : Int32
}

///|
pub(all) struct Upgrade {
  kind : UpgradeKind
  name : String
  description : String
  cost : Int32
  mut purchased : Bool
}

///|
pub(all) struct ChallengeState {
  mode : ChallengeMode
  mut time_left : Float
  mut rounds_survived : Int32
  mut target_height : Float
  mut budget_used : Int32
  mut budget_limit : Int32
  mut hazard_round : Int32
  mut hazard_timer : Float
  mut completed : Bool
  mut challenge_score : Int32
}

///|
pub(all) struct DestructionState {
  particles : Array[Particle]
  mut slow_motion : Float
  mut camera_shake : Float
  mut shake_x : Float
  mut shake_y : Float
  mut chain_breaks : Int32
  mut replay_timer : Float
  mut replay_active : Bool
}

///|
pub(all) struct WorldInfo {
  theme : WorldTheme
  name : String
  description : String
  level_start : Int32 // index of first level in this world
  level_end : Int32 // index of last level (inclusive)
  stars_required : Int32 // total stars needed to unlock this world
  bg_r : Int32
  bg_g : Int32
  bg_b : Int32
  accent_r : Int32
  accent_g : Int32
  accent_b : Int32
  // World-specific physics modifiers
  gravity_mult : Float
  wind_mult : Float
  friction_mult : Float
}

///|
pub(all) struct ActiveCombo {
  kind : ComboKind
  body_a_id : Int32
  body_b_id : Int32
  bonus_value : Float
}

///|
pub(all) struct TutorialState {
  mut step : Int32
  mut completed : Bool
  mut highlight_x : Int32
  mut highlight_y : Int32
  mut highlight_w : Int32
  mut highlight_h : Int32
  mut message : String
  mut show_arrow : Bool
  mut arrow_x : Int32
  mut arrow_y : Int32
  mut blink_timer : Float
}

///|
pub(all) struct Statistics {
  mut total_builds : Int32
  mut total_breaks : Int32
  best_heights : Array[Float] // per level
  materials_used : Array[Int32] // [Wood, Stone, Steel] counts
  mut levels_completed : Int32
  mut stars_earned : Int32
  level_stars : Array[Int32] // stars per level
  mut total_pieces_placed : Int32
  mut total_tests_run : Int32
  mut challenges_completed : Int32
}

///|
pub(all) struct ReplayState {
  actions : Array[ReplayAction]
  mut test_height : Float
  mut test_score : Int32
  mut test_passed : Bool
  mut playback_index : Int32
  mut playback_timer : Float
  mut playback_speed : Float
  mut is_recording : Bool
  mut is_playing : Bool
  // Ghost tower: best solution overlay
  ghost_pieces : Array[(PieceKind, Material, Float, Float, Float)]
  mut ghost_visible : Bool
}

///|
pub(all) struct Game {
  mut screen : Screen
  world : World
  mut current_level : Int32
  mut selected_piece : Int32
  mut ghost_x : Float
  mut ghost_y : Float
  mut ghost_angle : Float
  mut score : Int32
  mut total_score : Int32
  mut best_height : Float
  mut test_phase : Int32
  mut test_timer : Float
  mut frame_count : Int32
  mut rng_state : UInt32
  mut message_text : String
  mut message_timer : Float
  inventory : Array[(PieceKind, Material, Int32)]
  mut tower_height : Float
  blueprints : Array[Blueprint]
  mut selected_blueprint : Int32
  custom_blueprints : Array[Blueprint]
  destruction : DestructionState
  upgrades : Array[Upgrade]
  mut challenge_state : ChallengeState?
  mut star_anim_timer : Float
  mut result_stars : Int32
  // Upgrade effect flags
  mut reinforce_wood : Bool
  mut reinforce_stone : Bool
  mut reinforce_steel : Bool
  mut lightweight_wood : Bool
  mut lightweight_stone : Bool
  mut lightweight_steel : Bool
  mut flex_joints : Bool
  mut deep_foundation : Bool
  // Phase 3: new features
  active_combos : Array[ActiveCombo]
  tutorial : TutorialState
  statistics : Statistics
  replay : ReplayState
  sound_queue : Array[SoundEvent]
  mut current_world : Int32
  mut tutorial_shown : Bool
}
