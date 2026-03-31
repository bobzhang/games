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
  }
}
