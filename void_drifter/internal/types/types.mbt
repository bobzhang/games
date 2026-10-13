///|
pub(all) struct Vec2 {
  mut x : Float
  mut y : Float
} derive(Eq, Debug)

///|
pub extend Vec2 with Eq::{not_equal, equal}

///|
pub extend Vec2 with Debug::{to_repr}

///|
pub(all) struct Ship {
  mut pos : Vec2
  mut vel : Vec2
  mut angle : Float
  mut hp : Int32
  mut max_hp : Int32
  mut shield : Int32
  mut max_shield : Int32
  mut shield_regen_timer : Float
  mut heat : Float
  mut max_heat : Float
  mut heat_decay : Float
  mut dash_cooldown : Float
  mut dash_timer : Float
  mut invincible_timer : Float
  mut speed : Float
  mut drag : Float
  mut boost_mult : Float
  weapon : Weapon
  mut secondary : Weapon?
  mut primary_mod : ModKind?
  mut utility_mod : UtilityMod?
  mut credits : Int32
  mut kills : Int32
  mut sectors_cleared : Int32
}

///|
pub(all) struct Weapon {
  mut kind : WeaponKind
  mut damage : Int32
  mut fire_rate : Float
  mut fire_timer : Float
  mut projectile_speed : Float
  mut spread : Float
  mut projectile_count : Int32
  mut range : Float
  mut heat_cost : Float
}

///|
pub(all) struct Projectile {
  mut active : Bool
  mut pos : Vec2
  mut vel : Vec2
  mut damage : Int32
  mut lifetime : Float
  mut radius : Float
  mut friendly : Bool
  mut piercing : Bool
  mut homing_strength : Float
  mut chain_count : Int32
  mut explosive_radius : Float
  mut freezing : Bool
  mut bounces : Int32
  mut weapon_kind : WeaponKind
}

///|
pub(all) struct Enemy {
  mut active : Bool
  mut kind : EnemyKind
  mut pos : Vec2
  mut vel : Vec2
  mut angle : Float
  mut hp : Int32
  mut max_hp : Int32
  mut damage : Int32
  mut speed : Float
  mut fire_timer : Float
  mut fire_rate : Float
  mut radius : Float
  mut frozen_timer : Float
  mut shield : Int32
  mut behavior_timer : Float
  mut target_pos : Vec2
  mut score_value : Int32
}

///|
pub(all) struct Boss {
  mut active : Bool
  mut kind : BossKind
  mut pos : Vec2
  mut vel : Vec2
  mut hp : Int32
  mut max_hp : Int32
  mut phase : Int32
  mut phase_timer : Float
  mut attack_timer : Float
  mut pattern_index : Int32
  mut radius : Float
  mut shield : Int32
  mut enraged : Bool
  mut spawn_timer : Float
  mut score_value : Int32
}

///|
pub(all) struct Particle {
  mut active : Bool
  mut pos : Vec2
  mut vel : Vec2
  mut life : Float
  mut max_life : Float
  mut size : Float
  mut color : @raylib.Color
  mut shrink : Bool
}

///|
pub(all) struct Asteroid {
  mut active : Bool
  mut pos : Vec2
  mut vel : Vec2
  mut radius : Float
  mut angle : Float
  mut spin : Float
  mut hp : Int32
}

///|
pub(all) struct Hazard {
  mut active : Bool
  mut kind : HazardKind
  mut pos : Vec2
  mut radius : Float
  mut timer : Float
  mut damage : Int32
}

///|
pub(all) struct Pickup {
  mut active : Bool
  mut kind : PickupKind
  mut pos : Vec2
  mut radius : Float
  mut lifetime : Float
  mut pulse_timer : Float
}

///|
pub(all) struct SectorNode {
  mut kind : SectorKind
  mut x : Int32
  mut y : Int32
  mut cleared : Bool
  mut connections : Array[Int32]
  mut enemy_count : Int32
  mut has_shop : Bool
  mut reward_tier : Int32
  mut elite : Bool
}

///|
pub(all) struct SectorMap {
  mut nodes : Array[SectorNode]
  mut current : Int32
  mut depth : Int32
  mut boss_node : Int32
}

///|
pub(all) struct ShopItem {
  mut name : String
  mut description : String
  mut cost : Int32
  mut purchased : Bool
  mut effect : PickupKind
}

///|
pub(all) struct RunStats {
  mut score : Int32
  mut kills : Int32
  mut max_combo : Int32
  mut combo : Int32
  mut sectors_cleared : Int32
  mut credits_earned : Int32
  mut damage_dealt : Int32
  mut damage_taken : Int32
  mut shots_fired : Int32
  mut shots_hit : Int32
  mut time_played : Float
  mut bosses_defeated : Int32
  mut mods_collected : Int32
}

///|
pub(all) struct MetaProgress {
  mut best_score : Int32
  mut highest_kills : Int32
  mut total_runs : Int32
  mut total_kills : Int32
  mut bosses_defeated : Int32
  mut sectors_explored : Int32
  mut unlocked_weapons : Array[WeaponKind]
  mut unlocked_mods : Array[ModKind]
  mut run_history : Array[RunRecord]
}

///|
pub(all) struct RunRecord {
  mut score : Int32
  mut kills : Int32
  mut sectors : Int32
  mut weapon : WeaponKind
}

///|
pub(all) struct DamageNumber {
  mut active : Bool
  mut pos : Vec2
  mut vel : Vec2
  mut life : Float
  mut value : Int32
  mut color : @raylib.Color
}

///|
pub(all) struct ScreenShake {
  mut intensity : Float
  mut decay : Float
  mut offset_x : Float
  mut offset_y : Float
}

///|
pub(all) struct Game {
  mut screen : Screen
  ship : Ship
  mut projectiles : Array[Projectile]
  mut enemies : Array[Enemy]
  mut boss : Boss?
  mut particles : Array[Particle]
  mut asteroids : Array[Asteroid]
  mut hazards : Array[Hazard]
  mut pickups : Array[Pickup]
  mut damage_numbers : Array[DamageNumber]
  mut sector_map : SectorMap?
  mut shop_items : Array[ShopItem]
  stats : RunStats
  meta : MetaProgress
  shake : ScreenShake
  mut sound_queue : Array[SoundEvent]
  mut message : String
  mut message_timer : Float
  mut rng : Int32
  mut camera_x : Float
  mut camera_y : Float
  mut arena_width : Float
  mut arena_height : Float
  mut current_sector_kind : SectorKind
  mut wave_timer : Float
  mut wave_count : Int32
  mut sector_enemies_total : Int32
  mut sector_enemies_killed : Int32
  mut sector_cleared : Bool
  mut boss_intro_timer : Float
  mut paused : Bool
  mut frame_count : Int32
}
