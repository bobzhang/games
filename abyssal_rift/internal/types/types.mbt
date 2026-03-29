///|
pub(all) struct Player {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut facing_x : Float
  mut facing_y : Float
  mut hp : Int
  mut max_hp : Int
  mut shield : Float
  mut max_shield : Float
  mut shield_regen_timer : Float
  mut invuln_timer : Float
  mut dash_cooldown : Float
  mut dash_timer : Float
  mut dash_dx : Float
  mut dash_dy : Float
  mut weapon : WeaponKind
  mut attack_state : AttackState
  mut combo_count : Int
  mut combo_timer : Float
  mut speed : Float
  mut damage_mult : Float
  mut crit_chance : Float
  mut defense : Int
  mut gold : Int
  mut dead : Bool
  mut attack_buffered : Bool
  passives : Array[PassiveKind]
}

///|
pub fn Player::new() -> Player {
  {
    x: 0.0, y: 0.0,
    vx: 0.0, vy: 0.0,
    facing_x: 1.0, facing_y: 0.0,
    hp: 100, max_hp: 100,
    shield: 30.0, max_shield: 30.0,
    shield_regen_timer: 0.0,
    invuln_timer: 0.0,
    dash_cooldown: 0.0, dash_timer: 0.0,
    dash_dx: 0.0, dash_dy: 0.0,
    weapon: Sword,
    attack_state: Idle,
    combo_count: 0, combo_timer: 0.0,
    speed: 1.0, damage_mult: 1.0,
    crit_chance: 0.05, defense: 0,
    gold: 0,
    dead: false,
    attack_buffered: false,
    passives: [],
  }
}

///|
pub(all) struct Enemy {
  mut active : Bool
  mut kind : EnemyKind
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut hp : Int
  mut max_hp : Int
  mut state : EnemyState
  mut facing_x : Float
  mut facing_y : Float
  mut patrol_x : Float
  mut patrol_y : Float
  mut attack_cooldown : Float
  mut anim_timer : Float
  mut anim_frame : Int
  mut flash_timer : Float
  mut knockback_timer : Float
  mut phase : Float
  mut room_id : Int
}

///|
pub(all) struct Projectile {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut damage : Int
  mut is_player : Bool
  mut is_crit : Bool
  mut piercing : Bool
  mut homing : Bool
  mut lifetime : Float
  mut radius : Float
}

///|
pub(all) struct Item {
  mut active : Bool
  mut kind : ItemKind
  mut x : Float
  mut y : Float
  mut bob_timer : Float
}

///|
pub(all) struct Particle {
  mut active : Bool
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
}

///|
pub(all) struct DamageNumber {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vy : Float
  mut life : Float
  mut value : Int
  mut is_crit : Bool
}

///|
pub(all) struct Hitbox {
  x : Float
  y : Float
  radius : Float
  damage : Int
  knockback : Float
  is_crit : Bool
}

///|
pub(all) struct Camera {
  mut x : Float
  mut y : Float
  mut target_x : Float
  mut target_y : Float
  mut shake_intensity : Float
  mut shake_timer : Float
  mut shake_decay : Float
  mut offset_x : Float
  mut offset_y : Float
}

///|
pub fn Camera::new() -> Camera {
  { x: 0.0, y: 0.0, target_x: 0.0, target_y: 0.0,
    shake_intensity: 0.0, shake_timer: 0.0, shake_decay: 0.0,
    offset_x: 0.0, offset_y: 0.0 }
}

///|
pub(all) struct Room {
  x : Int
  y : Int
  w : Int
  h : Int
  kind : RoomKind
  mut state : RoomState
  tiles : Array[Int]
  mut enemies_remaining : Int
  connections : Array[Direction]
  mut visited : Bool
}

///|
pub(all) struct Floor {
  rooms : Array[Room]
  mut current_room : Int
  floor_num : Int
}

///|
pub(all) struct Game {
  mut state : GameState
  player : Player
  camera : Camera
  enemies : Array[Enemy]
  projectiles : Array[Projectile]
  items : Array[Item]
  particles : Array[Particle]
  damage_numbers : Array[DamageNumber]
  events : Array[GameEvent]
  mut floor : Floor?
  mut floor_num : Int
  mut frame_count : Int
  mut hit_pause_timer : Float
  mut room_clear_timer : Float
  mut rng_state : UInt
  mut stairs_active : Bool
  mut stairs_x : Float
  mut stairs_y : Float
  mut enemies_killed : Int
  mut rooms_cleared : Int
  mut floor_rooms_cleared : Int
}

///|
pub fn Game::new() -> Game {
  let enemies : Array[Enemy] = Array::make(
    128,
    { active: false, kind: Skeleton, x: 0.0, y: 0.0,
      vx: 0.0, vy: 0.0, hp: 0, max_hp: 0,
      state: Idle, facing_x: 1.0, facing_y: 0.0,
      patrol_x: 0.0, patrol_y: 0.0, attack_cooldown: 0.0,
      anim_timer: 0.0, anim_frame: 0, flash_timer: 0.0,
      knockback_timer: 0.0, phase: 0.0, room_id: -1 },
  )
  let projectiles : Array[Projectile] = Array::make(
    256,
    { active: false, x: 0.0, y: 0.0, vx: 0.0, vy: 0.0,
      damage: 0, is_player: false, is_crit: false,
      piercing: false, homing: false, lifetime: 0.0, radius: 4.0 },
  )
  let items : Array[Item] = Array::make(
    64,
    { active: false, kind: Gold(0), x: 0.0, y: 0.0, bob_timer: 0.0 },
  )
  let particles : Array[Particle] = Array::make(
    600,
    { active: false, x: 0.0, y: 0.0, vx: 0.0, vy: 0.0,
      life: 0.0, max_life: 0.0, size: 0.0, r: 255, g: 255, b: 255 },
  )
  let damage_numbers : Array[DamageNumber] = Array::make(
    32,
    { active: false, x: 0.0, y: 0.0, vy: 0.0,
      life: 0.0, value: 0, is_crit: false },
  )
  {
    state: Title,
    player: Player::new(),
    camera: Camera::new(),
    enemies,
    projectiles,
    items,
    particles,
    damage_numbers,
    events: [],
    floor: None,
    floor_num: 0,
    frame_count: 0,
    hit_pause_timer: 0.0,
    room_clear_timer: 0.0,
    rng_state: 12345,
    stairs_active: false,
    stairs_x: 0.0,
    stairs_y: 0.0,
    enemies_killed: 0,
    rooms_cleared: 0,
    floor_rooms_cleared: 0,
  }
}
