///|
pub(all) struct Entity {
  mut id : Int
  mut active : Bool
  kind : EntityKind
  mut x : Int
  mut y : Int
  mut falling : Bool
  mut slide_timer : Float
  mut from_x : Int
  mut from_y : Int
}

///|
pub(all) struct LevelSnapshot {
  gravity : GravityDir
  moves : Int
  gems_collected : Int
  keys_collected : Int
  entity_states : Array[(Int, Bool, Int, Int)]
  tile_states : Array[TileKind]
}

///|
pub(all) struct Level {
  width : Int
  height : Int
  tiles : Array[TileKind]
  entities : Array[Entity]
  mut gravity : GravityDir
  mut moves : Int
  mut gems_collected : Int
  mut gems_total : Int
  mut keys_collected : Int
  par_moves : Int
  world : Int
  level_num : Int
  name : String
  mut completed : Bool
  mut player_dead : Bool
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
  mut r : Int
  mut g : Int
  mut b : Int
  mut kind : Int
}

///|
pub(all) struct ReplayFrame {
  direction : GravityDir
  move_type : Int
  dx : Int
  dy : Int
}

///|
pub(all) struct GhostState {
  mut active : Bool
  mut frame_index : Int
  mut ghost_x : Int
  mut ghost_y : Int
  mut ghost_timer : Float
  mut replay_frames : Array[ReplayFrame]
  mut best_moves : Int
}

///|
pub(all) struct HintState {
  mut hints_remaining : Array[Int]
  mut hint_active : Bool
  mut hint_dir : GravityDir
  mut hint_timer : Float
}

///|
pub(all) struct EditorState {
  mut active : Bool
  mut cursor_x : Int
  mut cursor_y : Int
  mut selected_tile : Int
  mut selected_entity : Int
  mut mode : Int
  mut grid_w : Int
  mut grid_h : Int
  mut tiles : Array[TileKind]
  mut entities : Array[Entity]
  mut test_playing : Bool
  mut gravity : GravityDir
}

///|
pub(all) struct AmbientState {
  mut particles : Array[Particle]
  mut spawn_timer : Float
}

///|
pub(all) struct Achievement {
  kind : AchievementKind
  name : String
  description : String
  mut unlocked : Bool
}

///|
pub(all) struct AchievementState {
  achievements : Array[Achievement]
  mut toast_queue : Array[Int]
  mut toast_timer : Float
  mut current_toast : Int
}

///|
pub(all) struct SaveData {
  star_ratings : Array[Array[Int]]
  best_moves : Array[Array[Int]]
  mut achievements_unlocked : Array[Bool]
  mut total_play_time : Float
  levels_unlocked : Array[Int]
}

///|
pub(all) struct GameStats {
  mut total_moves : Int
  mut total_gravity_rotations : Int
  mut total_levels_completed : Int
  mut total_stars_earned : Int
  mut total_time_played : Float
  mut total_deaths : Int
  mut total_undos : Int
  mut total_gems_collected : Int
  mut total_keys_collected : Int
  mut best_streak : Int
  mut current_streak : Int
  mut levels_with_3_stars : Int
  mut total_ice_slides : Int
  mut hint_uses : Int
}

///|
pub(all) struct Game {
  mut screen : Screen
  mut level : Level?
  mut current_world : Int
  mut current_level : Int
  mut undo_stack : Array[LevelSnapshot]
  mut frame_count : Int
  mut rng_state : UInt
  mut anim_timer : Float
  mut gravity_anim_timer : Float
  mut gravity_anim_from : GravityDir
  mut message_text : String
  mut message_timer : Float
  mut total_stars : Int
  mut level_stars : Array[Int]
  levels_unlocked : Array[Int]
  mut settling : Bool
  mut settle_timer : Float
  particles : Array[Particle]
  ghost : GhostState
  hints : HintState
  editor : EditorState
  ambient : AmbientState
  mut move_history : Array[ReplayFrame]
  mut speedrun_timer : Float
  mut speedrun_active : Bool
  mut gravity_rot_angle : Float
  mut gravity_rot_target : Float
  mut bounce_timers : Array[Float]
  mut lava_timer : Float
  mut wind_timer : Float
  mut wind_beat : Int
  achievement_state : AchievementState
  save_data : SaveData
  stats : GameStats
  mut accessibility : AccessibilityMode
  mut used_undo_this_level : Bool
  mut used_hint_this_level : Bool
}

///|
pub fn Entity::new(
  id : Int,
  kind : EntityKind,
  x : Int,
  y : Int
) -> Entity {
  {
    id,
    active: true,
    kind,
    x,
    y,
    falling: false,
    slide_timer: 0.0,
    from_x: x,
    from_y: y,
  }
}

///|
pub fn Entity::clone(self : Entity) -> Entity {
  {
    id: self.id,
    active: self.active,
    kind: self.kind,
    x: self.x,
    y: self.y,
    falling: self.falling,
    slide_timer: self.slide_timer,
    from_x: self.from_x,
    from_y: self.from_y,
  }
}

///|
pub fn Particle::new(
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  life : Float,
  size : Float,
  r : Int,
  g : Int,
  b : Int,
  kind : Int
) -> Particle {
  { x, y, vx, vy, life, max_life: life, size, r, g, b, kind }
}

///|
pub fn GhostState::new() -> GhostState {
  {
    active: false,
    frame_index: 0,
    ghost_x: 0,
    ghost_y: 0,
    ghost_timer: 0.0,
    replay_frames: [],
    best_moves: 999,
  }
}

///|
pub fn HintState::new() -> HintState {
  { hints_remaining: [3, 3, 3, 3, 3], hint_active: false, hint_dir: Down, hint_timer: 0.0 }
}

///|
pub fn EditorState::new() -> EditorState {
  {
    active: false,
    cursor_x: 0,
    cursor_y: 0,
    selected_tile: 0,
    selected_entity: 0,
    mode: 0,
    grid_w: 10,
    grid_h: 8,
    tiles: Array::make(10 * 8, Empty),
    entities: [],
    test_playing: false,
    gravity: Down,
  }
}

///|
pub fn AmbientState::new() -> AmbientState {
  { particles: [], spawn_timer: 0.0 }
}

///|
pub fn AchievementState::new() -> AchievementState {
  let achievements = init_achievements()
  {
    achievements,
    toast_queue: [],
    toast_timer: 0.0,
    current_toast: -1,
  }
}

///|
fn init_achievements() -> Array[Achievement] {
  [
    { kind: FirstStep, name: "First Steps", description: "Complete your first level", unlocked: false },
    { kind: WorldMaster(0), name: "Stone Master", description: "Earn all stars in Stone Ruins", unlocked: false },
    { kind: WorldMaster(1), name: "Crystal Master", description: "Earn all stars in Crystal Caverns", unlocked: false },
    { kind: WorldMaster(2), name: "Void Master", description: "Earn all stars in Void Expanse", unlocked: false },
    { kind: WorldMaster(3), name: "Magma Master", description: "Earn all stars in Magma Depths", unlocked: false },
    { kind: WorldMaster(4), name: "Sky Master", description: "Earn all stars in Sky Citadel", unlocked: false },
    { kind: Speedster, name: "Speedster", description: "Complete any level in under 10 moves", unlocked: false },
    { kind: Perfectionist, name: "Perfectionist", description: "Earn 3 stars on 10 different levels", unlocked: false },
    { kind: NoHints, name: "No Hints Needed", description: "Complete a world without using hints", unlocked: false },
    { kind: GemCollector, name: "Gem Collector", description: "Collect 20 gems total", unlocked: false },
    { kind: KeyMaster, name: "Key Master", description: "Collect 10 keys total", unlocked: false },
    { kind: Minimalist, name: "Minimalist", description: "Complete a level at exactly par", unlocked: false },
    { kind: Explorer, name: "Explorer", description: "Use the level editor", unlocked: false },
    { kind: GhostRacer, name: "Ghost Racer", description: "Beat your ghost replay", unlocked: false },
    { kind: UndoFree, name: "Undo Free", description: "Complete a level without using undo", unlocked: false },
    { kind: AllWorlds, name: "World Traveler", description: "Unlock all 5 worlds", unlocked: false },
    { kind: GravitySpinner, name: "Gravity Spinner", description: "Rotate gravity 50 times total", unlocked: false },
    { kind: IceSlider, name: "Ice Slider", description: "Slide on ice 20 times total", unlocked: false },
    { kind: Completionist, name: "Completionist", description: "Earn all 3 stars on all 50 levels", unlocked: false },
  ]
}

///|
pub fn SaveData::new() -> SaveData {
  let star_ratings : Array[Array[Int]] = []
  let best_moves : Array[Array[Int]] = []
  for _w in 0..<num_worlds {
    let stars_row : Array[Int] = Array::make(levels_per_world, 0)
    let moves_row : Array[Int] = Array::make(levels_per_world, 999)
    star_ratings.push(stars_row)
    best_moves.push(moves_row)
  }
  {
    star_ratings,
    best_moves,
    achievements_unlocked: Array::make(19, false),
    total_play_time: 0.0,
    levels_unlocked: [10, 0, 0, 0, 0],
  }
}

///|
pub fn GameStats::new() -> GameStats {
  {
    total_moves: 0,
    total_gravity_rotations: 0,
    total_levels_completed: 0,
    total_stars_earned: 0,
    total_time_played: 0.0,
    total_deaths: 0,
    total_undos: 0,
    total_gems_collected: 0,
    total_keys_collected: 0,
    best_streak: 0,
    current_streak: 0,
    levels_with_3_stars: 0,
    total_ice_slides: 0,
    hint_uses: 0,
  }
}

///|
pub fn Game::new() -> Game {
  {
    screen: Title,
    level: None,
    current_world: 0,
    current_level: 0,
    undo_stack: [],
    frame_count: 0,
    rng_state: 0x13572468U,
    anim_timer: 0.0,
    gravity_anim_timer: 0.0,
    gravity_anim_from: Down,
    message_text: "",
    message_timer: 0.0,
    total_stars: 0,
    level_stars: Array::make(total_levels, 0),
    levels_unlocked: [10, 0, 0, 0, 0],
    settling: false,
    settle_timer: 0.0,
    particles: [],
    ghost: GhostState::new(),
    hints: HintState::new(),
    editor: EditorState::new(),
    ambient: AmbientState::new(),
    move_history: [],
    speedrun_timer: 0.0,
    speedrun_active: false,
    gravity_rot_angle: 0.0,
    gravity_rot_target: 0.0,
    bounce_timers: Array::make(64, 0.0),
    lava_timer: 0.0,
    wind_timer: 0.0,
    wind_beat: 0,
    achievement_state: AchievementState::new(),
    save_data: SaveData::new(),
    stats: GameStats::new(),
    accessibility: Normal,
    used_undo_this_level: false,
    used_hint_this_level: false,
  }
}
