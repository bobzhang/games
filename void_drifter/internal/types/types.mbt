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
  mut hp : Int
  mut max_hp : Int
  mut shield : Int
  mut max_shield : Int
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
  mut credits : Int
  mut kills : Int
  mut sectors_cleared : Int
}

///|
pub(all) struct Weapon {
  mut kind : WeaponKind
  mut damage : Int
  mut fire_rate : Float
  mut fire_timer : Float
  mut projectile_speed : Float
  mut spread : Float
  mut projectile_count : Int
  mut range : Float
  mut heat_cost : Float
}

///|
pub(all) struct Projectile {
  mut active : Bool
  mut pos : Vec2
  mut vel : Vec2
  mut damage : Int
  mut lifetime : Float
  mut radius : Float
  mut friendly : Bool
  mut piercing : Bool
  mut homing_strength : Float
  mut chain_count : Int
  mut explosive_radius : Float
  mut freezing : Bool
  mut bounces : Int
  mut weapon_kind : WeaponKind
}

///|
pub(all) struct Enemy {
  mut active : Bool
  mut kind : EnemyKind
  mut pos : Vec2
  mut vel : Vec2
  mut angle : Float
  mut hp : Int
  mut max_hp : Int
  mut damage : Int
  mut speed : Float
  mut fire_timer : Float
  mut fire_rate : Float
  mut radius : Float
  mut frozen_timer : Float
  mut shield : Int
  mut behavior_timer : Float
  mut target_pos : Vec2
  mut score_value : Int
}

///|
pub(all) struct Boss {
  mut active : Bool
  mut kind : BossKind
  mut pos : Vec2
  mut vel : Vec2
  mut hp : Int
  mut max_hp : Int
  mut phase : Int
  mut phase_timer : Float
  mut attack_timer : Float
  mut pattern_index : Int
  mut radius : Float
  mut shield : Int
  mut enraged : Bool
  mut spawn_timer : Float
  mut score_value : Int
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
  mut hp : Int
}

///|
pub(all) struct Hazard {
  mut active : Bool
  mut kind : HazardKind
  mut pos : Vec2
  mut radius : Float
  mut timer : Float
  mut damage : Int
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
  mut x : Int
  mut y : Int
  mut cleared : Bool
  mut connections : Array[Int]
  mut enemy_count : Int
  mut has_shop : Bool
  mut reward_tier : Int
  mut elite : Bool
}

///|
pub(all) struct SectorMap {
  mut nodes : Array[SectorNode]
  mut current : Int
  mut depth : Int
  mut boss_node : Int
}

///|
pub(all) struct ShopItem {
  mut name : String
  mut description : String
  mut cost : Int
  mut purchased : Bool
  mut effect : PickupKind
}

///|
pub(all) struct RunStats {
  mut score : Int
  mut kills : Int
  mut max_combo : Int
  mut combo : Int
  mut sectors_cleared : Int
  mut credits_earned : Int
  mut damage_dealt : Int
  mut damage_taken : Int
  mut shots_fired : Int
  mut shots_hit : Int
  mut time_played : Float
  mut bosses_defeated : Int
  mut mods_collected : Int
}

///|
pub(all) struct MetaProgress {
  mut best_score : Int
  mut highest_kills : Int
  mut total_runs : Int
  mut total_kills : Int
  mut bosses_defeated : Int
  mut sectors_explored : Int
  mut unlocked_weapons : Array[WeaponKind]
  mut unlocked_mods : Array[ModKind]
  mut run_history : Array[RunRecord]
}

///|
pub(all) struct RunRecord {
  mut score : Int
  mut kills : Int
  mut sectors : Int
  mut weapon : WeaponKind
}

///|
pub(all) struct DamageNumber {
  mut active : Bool
  mut pos : Vec2
  mut vel : Vec2
  mut life : Float
  mut value : Int
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
  mut rng : Int
  mut camera_x : Float
  mut camera_y : Float
  mut arena_width : Float
  mut arena_height : Float
  mut current_sector_kind : SectorKind
  mut wave_timer : Float
  mut wave_count : Int
  mut sector_enemies_total : Int
  mut sector_enemies_killed : Int
  mut sector_cleared : Bool
  mut boss_intro_timer : Float
  mut paused : Bool
  mut frame_count : Int
}
