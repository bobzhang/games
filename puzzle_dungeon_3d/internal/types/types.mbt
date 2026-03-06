// Enum types for categorical constants

///|
/// Tile categories used by puzzle logic and world rendering for each grid cell.
pub(all) enum Tile {
  TileEmpty
  TileWall
  TileFloor
  TilePlate
  TileSwitchOff
  TileSwitchOn
  TileExitClosed
  TileExitOpen
  TilePit
  TileIce
  TileTeleportA
  TileTeleportB
  TileCracked
  TileSpikesOff
  TileSpikesOn
  TileConveyorUp
  TileConveyorRight
  TileConveyorDown
  TileConveyorLeft
  TileBridgeOff
  TileBridgeOn
  TileGateClosed
  TileGateOpen
  TileMirrorNe
  TileMirrorNw
  TileMirrorSe
  TileMirrorSw
  TileLaserSourceRight
  TileLaserSourceDown
  TileLaserSourceLeft
  TileLaserSourceUp
  TileLaserTarget
  TileRotatePlatform
} derive(Eq)

///|
/// Entity kinds that can occupy tiles independently from base terrain.
pub(all) enum EntityKind {
  EntityNone
  EntityBlock
  EntityDiamond
  EntityKey
  EntityBomb
} derive(Eq)

///|
/// Cardinal movement and facing directions used by player, conveyors, and lasers.
pub(all) enum Dir {
  DirNone
  DirUp
  DirRight
  DirDown
  DirLeft
} derive(Eq)

///|
/// High-level game states that drive update and UI render dispatch.
pub(all) enum GameState {
  StateMenu
  StatePlaying
  StatePaused
  StateLevelComplete
  StateGameOver
  StateFloorSelect
  StateCampaignComplete
  StateWorldSelect
  StateTutorial
} derive(Eq)

///|
/// The five campaign themes that map floors to mechanics and visual palettes.
pub(all) enum World {
  WorldDungeon
  WorldIce
  WorldLava
  WorldGarden
  WorldVoid
} derive(Eq)

///|
/// Maps a world-selection index to a `World` enum, defaulting to `WorldVoid`.
pub fn int_to_world(i : Int) -> World {
  if i == 0 {
    WorldDungeon
  } else if i == 1 {
    WorldIce
  } else if i == 2 {
    WorldLava
  } else if i == 3 {
    WorldGarden
  } else {
    WorldVoid
  }
}

///|
/// Converts a `World` enum to its stable integer index for save/UI usage.
pub fn world_to_int(w : World) -> Int {
  match w {
    WorldDungeon => 0
    WorldIce => 1
    WorldLava => 2
    WorldGarden => 3
    _ => 4
  }
}

///|
/// Decorative prop categories used to flavor each world theme.
pub(all) enum DecoKind {
  DecoTorch
  DecoCrystal
  DecoMagmaPool
  DecoFlower
  DecoFloatingRock
  DecoPillar
  DecoMushroom
  DecoVine
} derive(Eq)

// Entity on the grid (block, diamond, key, bomb)

///|
/// Movable grid entity state (blocks, collectibles, and keys) with animation data.
pub(all) struct Entity {
  mut active : Bool
  mut kind : EntityKind
  mut gx : Int // grid x
  mut gy : Int // grid y
  mut anim_x : Float // animated world x
  mut anim_y : Float // animated world z (y in grid = z in world)
  mut anim_timer : Float
  mut falling : Bool
  mut fall_timer : Float
  mut on_plate : Bool
}

///|
/// Creates an inactive entity slot used to initialize fixed-size entity pools.
pub fn Entity::inactive() -> Entity {
  {
    active: false,
    kind: EntityNone,
    gx: 0,
    gy: 0,
    anim_x: 0.0,
    anim_y: 0.0,
    anim_timer: 0.0,
    falling: false,
    fall_timer: 0.0,
    on_plate: false,
  }
}

///|
/// Creates an active push-block entity at grid coordinates `(gx, gy)`.
pub fn Entity::new_block(gx : Int, gy : Int) -> Entity {
  {
    active: true,
    kind: EntityBlock,
    gx,
    gy,
    anim_x: Float::from_int(gx),
    anim_y: Float::from_int(gy),
    anim_timer: 0.0,
    falling: false,
    fall_timer: 0.0,
    on_plate: false,
  }
}

///|
/// Creates an active diamond pickup entity at grid coordinates `(gx, gy)`.
pub fn Entity::new_diamond(gx : Int, gy : Int) -> Entity {
  {
    active: true,
    kind: EntityDiamond,
    gx,
    gy,
    anim_x: Float::from_int(gx),
    anim_y: Float::from_int(gy),
    anim_timer: 0.0,
    falling: false,
    fall_timer: 0.0,
    on_plate: false,
  }
}

///|
/// Creates an active key pickup entity at grid coordinates `(gx, gy)`.
pub fn Entity::new_key(gx : Int, gy : Int) -> Entity {
  {
    active: true,
    kind: EntityKey,
    gx,
    gy,
    anim_x: Float::from_int(gx),
    anim_y: Float::from_int(gy),
    anim_timer: 0.0,
    falling: false,
    fall_timer: 0.0,
    on_plate: false,
  }
}

// Particle effect

///|
/// Particle record used by world effects such as teleports, gates, and celebration bursts.
pub(all) struct Particle {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut z : Float
  mut vx : Float
  mut vy : Float
  mut vz : Float
  mut life : Float
  mut max_life : Float
  mut r : Int
  mut g : Int
  mut b : Int
  mut size : Float
}

///|
/// Creates an inactive particle slot for pooled particle allocation.
pub fn Particle::inactive() -> Particle {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    z: 0.0,
    vx: 0.0,
    vy: 0.0,
    vz: 0.0,
    life: 0.0,
    max_life: 1.0,
    r: 255,
    g: 255,
    b: 255,
    size: 0.05,
  }
}

// Laser beam segment for rendering

///|
/// One rendered laser segment between two grid points after mirror tracing.
pub(all) struct LaserSegment {
  mut active : Bool
  mut start_gx : Int
  mut start_gy : Int
  mut end_gx : Int
  mut end_gy : Int
  mut dir : Dir
}

///|
/// Creates an inactive laser segment entry for reusable laser buffers.
pub fn LaserSegment::inactive() -> LaserSegment {
  {
    active: false,
    start_gx: 0,
    start_gy: 0,
    end_gx: 0,
    end_gy: 0,
    dir: DirNone,
  }
}

// Decoration for world ambiance

///|
/// Ambient decoration instance used to enrich otherwise static dungeon spaces.
pub(all) struct Decoration {
  mut active : Bool
  mut kind : DecoKind
  mut x : Float
  mut y : Float
  mut z : Float
  mut scale : Float
  mut phase : Float
}

///|
/// Creates an inactive decoration slot for pooled world props.
pub fn Decoration::inactive() -> Decoration {
  {
    active: false,
    kind: DecoTorch,
    x: 0.0,
    y: 0.0,
    z: 0.0,
    scale: 1.0,
    phase: 0.0,
  }
}

// Undo snapshot

///|
/// Snapshot data captured before a move to support deterministic undo playback.
pub(all) struct UndoState {
  mut player_gx : Int
  mut player_gy : Int
  tiles : FixedArray[Tile]
  entity_gx : FixedArray[Int]
  entity_gy : FixedArray[Int]
  entity_active : FixedArray[Bool]
  entity_kind : FixedArray[EntityKind]
  mut moves : Int
  mut keys_held : Int
  mut diamonds_collected : Int
}

///|
/// Creates a blank undo snapshot with tile/entity arrays sized to puzzle limits.
pub fn UndoState::empty() -> UndoState {
  {
    player_gx: 0,
    player_gy: 0,
    tiles: FixedArray::make(grid_total, TileEmpty),
    entity_gx: FixedArray::make(max_entities, 0),
    entity_gy: FixedArray::make(max_entities, 0),
    entity_active: FixedArray::make(max_entities, false),
    entity_kind: FixedArray::make(max_entities, EntityNone),
    moves: 0,
    keys_held: 0,
    diamonds_collected: 0,
  }
}

// Floor completion info

///|
/// Persistent completion metadata for a single floor.
pub(all) struct FloorInfo {
  mut unlocked : Bool
  mut completed : Bool
  mut best_moves : Int
  mut stars : Int

  fn new() -> FloorInfo
}

///|
/// Creates default floor progress (locked, incomplete, and no stars).
#deprecated
pub fn FloorInfo::new() -> FloorInfo {
  { unlocked: false, completed: false, best_moves: 999, stars: 0 }
}

// Achievement tracking

///|
/// Runtime display state for one achievement badge.
pub(all) struct AchievementInfo {
  mut unlocked : Bool
  mut show_timer : Float

  fn new() -> AchievementInfo
}

///|
/// Creates a locked achievement entry with no active display timer.
#deprecated
pub fn AchievementInfo::new() -> AchievementInfo {
  { unlocked: false, show_timer: 0.0 }
}

// Main Game struct

///|
/// Full mutable game runtime state shared across update, simulation, and rendering.
pub(all) struct Game {
  // State
  mut state : GameState
  mut prev_state : GameState

  // Player
  mut player_gx : Int
  mut player_gy : Int
  mut player_anim_x : Float
  mut player_anim_z : Float
  mut player_anim_timer : Float
  mut player_dir : Dir
  mut player_moving : Bool
  mut player_walk_cycle : Float
  mut player_push_anim : Float

  // Level
  mut current_floor : Int
  mut current_world : World
  mut moves : Int
  mut keys_held : Int
  mut diamonds_collected : Int
  mut diamonds_total : Int
  mut plates_active : Int
  mut plates_total : Int
  mut exit_open : Bool
  tiles : Array[Tile]
  entities : Array[Entity]
  mut level_timer : Float
  mut used_undo : Bool

  // Laser system
  laser_segments : Array[LaserSegment]
  mut laser_segment_count : Int
  mut laser_targets_hit : Int
  mut laser_targets_total : Int

  // Decorations
  decorations : Array[Decoration]
  mut decoration_count : Int

  // Conveyor / spike timing
  mut spike_timer : Float
  mut spike_phase : Bool
  mut conveyor_moved_this_turn : Bool

  // Gate animation
  mut gate_anim_timer : Float
  mut gate_opening : Bool

  // Undo
  undo_stack : Array[UndoState]
  mut undo_count : Int

  // Particles
  particles : Array[Particle]

  // Floor tracking
  floor_info : Array[FloorInfo]

  // Achievements
  achievements : Array[AchievementInfo]
  mut achievement_display_timer : Float
  mut achievement_display_text : String

  // Camera
  mut camera_angle : Float
  mut camera_target_x : Float
  mut camera_target_z : Float

  // UI
  mut menu_cursor : Int
  mut menu_blink : Float
  mut transition_timer : Float
  mut transition_out : Bool
  mut message_timer : Float
  mut message_text : String
  mut floor_select_cursor : Int
  mut world_select_cursor : Int
  mut tutorial_step : Int
  mut tutorial_timer : Float
  mut tutorial_active : Bool
  mut tutorial_text : String

  // RNG
  mut rng_state : Int
  mut frame_counter : Int

  // Level complete display
  mut complete_timer : Float
  mut complete_stars : Int

  // Stats
  mut total_stars : Int
  mut total_moves : Int
  mut total_undos : Int
  mut levels_completed : Int

  fn new() -> Game
}

///|
/// Constructs a fresh campaign state with initialized pools, default UI cursors,
/// and floor zero unlocked.
#deprecated
pub fn Game::new() -> Game {
  let floor_info : Array[FloorInfo] = []
  for i in 0..<max_floors {
    floor_info.push(FloorInfo())
    ignore(i)
  }
  floor_info[0].unlocked = true
  let achievements : Array[AchievementInfo] = []
  for i in 0..<max_achievements {
    achievements.push(AchievementInfo())
    ignore(i)
  }
  {
    state: StateMenu,
    prev_state: StateMenu,
    player_gx: 1,
    player_gy: 1,
    player_anim_x: 1.0,
    player_anim_z: 1.0,
    player_anim_timer: 0.0,
    player_dir: DirDown,
    player_moving: false,
    player_walk_cycle: 0.0,
    player_push_anim: 0.0,
    current_floor: 0,
    current_world: WorldDungeon,
    moves: 0,
    keys_held: 0,
    diamonds_collected: 0,
    diamonds_total: 0,
    plates_active: 0,
    plates_total: 0,
    exit_open: false,
    tiles: Array::make(grid_total, TileEmpty),
    entities: Array::make(max_entities, Entity::inactive()),
    level_timer: 0.0,
    used_undo: false,
    laser_segments: {
      let arr : Array[LaserSegment] = []
      for i in 0..<max_laser_segments {
        arr.push(LaserSegment::inactive())
        ignore(i)
      }
      arr
    },
    laser_segment_count: 0,
    laser_targets_hit: 0,
    laser_targets_total: 0,
    decorations: {
      let arr : Array[Decoration] = []
      for i in 0..<max_decorations {
        arr.push(Decoration::inactive())
        ignore(i)
      }
      arr
    },
    decoration_count: 0,
    spike_timer: 0.0,
    spike_phase: false,
    conveyor_moved_this_turn: false,
    gate_anim_timer: 0.0,
    gate_opening: false,
    undo_stack: {
      let arr : Array[UndoState] = []
      for i in 0..<max_undo {
        arr.push(UndoState::empty())
        ignore(i)
      }
      arr
    },
    undo_count: 0,
    particles: Array::make(max_particles, Particle::inactive()),
    floor_info,
    achievements,
    achievement_display_timer: 0.0,
    achievement_display_text: "",
    camera_angle: 0.0,
    camera_target_x: 6.0,
    camera_target_z: 6.0,
    menu_cursor: 0,
    menu_blink: 0.0,
    transition_timer: 0.0,
    transition_out: false,
    message_timer: 0.0,
    message_text: "",
    floor_select_cursor: 0,
    world_select_cursor: 0,
    tutorial_step: 0,
    tutorial_timer: 0.0,
    tutorial_active: false,
    tutorial_text: "",
    rng_state: 42,
    frame_counter: 0,
    complete_timer: 0.0,
    complete_stars: 0,
    total_stars: 0,
    total_moves: 0,
    total_undos: 0,
    levels_completed: 0,
  }
}
