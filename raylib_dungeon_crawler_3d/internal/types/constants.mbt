// Screen

///|
/// Window width in pixels.
pub let screen_width : Int = 1024

///|
/// Window height in pixels.
pub let screen_height : Int = 768

// Grid dimensions

///|
/// Grid dimension value for grid width in cells.
pub let grid_w : Int = 32

///|
/// Grid dimension value for grid height in cells.
pub let grid_h : Int = 32

///|
/// Grid dimension value for grid total in cells.
pub let grid_total : Int = 1024 // grid_w * grid_h

///|
/// Size or distance value for cell size in world units.
pub let cell_size : Float = 2.0

///|
/// Size or distance value for wall height in world units.
pub let wall_height : Float = 3.0

// Tile types

///|
/// Numeric id for tile wall.
pub let tile_wall : Int = 1

///|
/// Numeric id for tile floor.
pub let tile_floor : Int = 2

///|
/// Numeric id for tile door.
pub let tile_door : Int = 3

///|
/// Numeric id for tile stairs.
pub let tile_stairs : Int = 4

///|
/// Numeric id for tile chest.
pub let tile_chest : Int = 5

///|
/// Numeric id for tile trap.
pub let tile_trap : Int = 6

///|
/// Numeric id for tile shrine.
pub let tile_shrine : Int = 7

///|
/// Numeric id for tile shop.
pub let tile_shop : Int = 8

///|
/// Numeric id for tile locked door.
pub let tile_locked_door : Int = 9

///|
/// Numeric id for tile boss door.
pub let tile_boss_door : Int = 10

///|
/// Numeric id for tile secret door.
pub let tile_secret_door : Int = 11

// Enemy types

///|
/// Numeric id for none.
pub let enemy_none : Int = 0

///|
/// Numeric id for skeleton.
pub let enemy_skeleton : Int = 1

///|
/// Numeric id for archer.
pub let enemy_archer : Int = 2

///|
/// Numeric id for golem.
pub let enemy_golem : Int = 3

///|
/// Numeric id for wraith.
pub let enemy_wraith : Int = 4

///|
/// Numeric id for dragon boss.
pub let enemy_dragon_boss : Int = 5

///|
/// Numeric id for slime.
pub let enemy_slime : Int = 6

///|
/// Numeric id for bat.
pub let enemy_bat : Int = 7

///|
/// Numeric id for spider.
pub let enemy_spider : Int = 8

///|
/// Numeric id for minotaur.
pub let enemy_minotaur : Int = 9

///|
/// Numeric id for lich.
pub let enemy_lich : Int = 10

///|
/// Numeric id for mimic.
pub let enemy_mimic : Int = 11

// Enemy states

///|
/// Numeric id for idle.
pub let ai_idle : Int = 0

///|
/// Numeric id for chase.
pub let ai_chase : Int = 2

///|
/// Numeric id for special.
pub let ai_special : Int = 6

// Loot types

///|
/// Numeric id for none.
pub let loot_none : Int = 0

///|
/// Numeric id for health potion.
pub let loot_health_potion : Int = 1

///|
/// Numeric id for damage boost.
pub let loot_damage_boost : Int = 2

///|
/// Numeric id for armor.
pub let loot_armor : Int = 3

///|
/// Numeric id for mana potion.
pub let loot_mana_potion : Int = 4

///|
/// Numeric id for speed potion.
pub let loot_speed_potion : Int = 5

///|
/// Numeric id for strength potion.
pub let loot_strength_potion : Int = 6

///|
/// Numeric id for gold pile.
pub let loot_gold_pile : Int = 7

///|
/// Numeric id for key.
pub let loot_key : Int = 8

///|
/// Numeric id for boss key.
pub let loot_boss_key : Int = 9

// Weapon types

///|
/// Numeric id for sword.
pub let weapon_sword : Int = 0

///|
/// Numeric id for axe.
pub let weapon_axe : Int = 1

///|
/// Numeric id for mace.
pub let weapon_mace : Int = 2

///|
/// Numeric id for dagger.
pub let weapon_dagger : Int = 3

///|
/// Numeric id for staff.
pub let weapon_staff : Int = 4

///|
/// Numeric id for bow.
pub let weapon_bow : Int = 5

// Armor types

///|
/// Numeric id for none.
pub let armor_none : Int = 0

///|
/// Numeric id for robes.
pub let armor_robes : Int = 1

///|
/// Numeric id for leather.
pub let armor_leather : Int = 2

///|
/// Numeric id for chain.
pub let armor_chain : Int = 3

///|
/// Numeric id for plate.
pub let armor_plate : Int = 4

// Spell types

///|
/// Numeric id for none.
pub let spell_none : Int = 0

///|
/// Numeric id for fireball.
pub let spell_fireball : Int = 1

///|
/// Numeric id for ice bolt.
pub let spell_ice_bolt : Int = 2

///|
/// Numeric id for heal.
pub let spell_heal : Int = 3

///|
/// Numeric id for shield.
pub let spell_shield : Int = 4

///|
/// Numeric id for lightning.
pub let spell_lightning : Int = 5

///|
/// Numeric id for teleport.
pub let spell_teleport : Int = 6

// Trap types

///|
/// Numeric id for spike.
pub let trap_spike : Int = 0

///|
/// Numeric id for arrow.
pub let trap_arrow : Int = 1

///|
/// Numeric id for flame.
pub let trap_flame : Int = 2

///|
/// Numeric id for poison.
pub let trap_poison : Int = 3

///|
/// Numeric id for pitfall.
pub let trap_pitfall : Int = 4

// Item rarity

///|
/// Numeric id for common.
pub let rarity_common : Int = 0

///|
/// Numeric id for uncommon.
pub let rarity_uncommon : Int = 1

// Floor themes

///|
/// Numeric id for crypt.
pub let theme_crypt : Int = 0

// Game states

///|
/// Numeric id for menu.
pub let state_menu : Int = 0

///|
/// Numeric id for playing.
pub let state_playing : Int = 1

///|
/// Numeric id for paused.
pub let state_paused : Int = 2

///|
/// Numeric id for game over.
pub let state_game_over : Int = 3

///|
/// Numeric id for level up.
pub let state_level_up : Int = 4

///|
/// Numeric id for floor complete.
pub let state_floor_complete : Int = 5

///|
/// Numeric id for shop.
pub let state_shop : Int = 7

///|
/// Numeric id for shrine.
pub let state_shrine : Int = 8

///|
/// Numeric id for class select.
pub let state_class_select : Int = 11

// Player classes

///|
/// Numeric id for warrior.
pub let class_warrior : Int = 0

///|
/// Numeric id for rogue.
pub let class_rogue : Int = 1

///|
/// Numeric id for mage.
pub let class_mage : Int = 2

// Pools

///|
/// Count limit or quantity for max enemies.
pub let max_enemies : Int = 64

///|
/// Count limit or quantity for max projectiles.
pub let max_projectiles : Int = 128

///|
/// Count limit or quantity for max particles.
pub let max_particles : Int = 256

///|
/// Count limit or quantity for max loot.
pub let max_loot : Int = 32

///|
/// Count limit or quantity for max floors.
pub let max_floors : Int = 10

///|
/// Count limit or quantity for max inventory.
pub let max_inventory : Int = 20

///|
/// Count limit or quantity for max spells.
pub let max_spells : Int = 6

///|
/// Count limit or quantity for max messages.
pub let max_messages : Int = 8

///|
/// Count limit or quantity for max traps.
pub let max_traps : Int = 24

///|
/// Count limit or quantity for max shop items.
pub let max_shop_items : Int = 6

///|
/// Count limit or quantity for max torches.
pub let max_torches : Int = 32

// BSP dungeon generation

///|
/// Size or distance value for min room size in world units.
pub let min_room_size : Int = 4

///|
/// Count limit or quantity for max room size.
pub let max_room_size : Int = 10

///|
/// Count limit or quantity for max rooms.
pub let max_rooms : Int = 12

///|
/// Size or distance value for corridor width in world units.
pub let corridor_width : Int = 1

// Player defaults

///|
/// Speed value for player speed in world units per second.
pub let player_speed : Float = 6.0

///|
/// Multiplier used for player sprint mult.
pub let player_sprint_mult : Float = 1.5

///|
/// Hit-point value for player start hp.
pub let player_start_hp : Int = 100

///|
/// Mana-related value for player start mana.
pub let player_start_mana : Int = 50

///|
/// Player defaults setting for player start atk.
pub let player_start_atk : Int = 10

///|
/// Player defaults setting for player start def.
pub let player_start_def : Int = 5

///|
/// Player defaults setting for player start str.
pub let player_start_str : Int = 8

///|
/// Player defaults setting for player start dex.
pub let player_start_dex : Int = 8

///|
/// Player defaults setting for player start int stat.
pub let player_start_int_stat : Int = 8

///|
/// Size or distance value for player eye height in world units.
pub let player_eye_height : Float = 1.6

// Combat

///|
/// Size or distance value for sword range in world units.
pub let sword_range : Float = 2.5

///|
/// Time value for sword cooldown in seconds.
pub let sword_cooldown : Float = 0.4

///|
/// Damage value for sword damage mult.
pub let sword_damage_mult : Float = 1.0

///|
/// Size or distance value for axe range in world units.
pub let axe_range : Float = 2.2

///|
/// Time value for axe cooldown in seconds.
pub let axe_cooldown : Float = 0.7

///|
/// Damage value for axe damage mult.
pub let axe_damage_mult : Float = 1.4

///|
/// Size or distance value for mace range in world units.
pub let mace_range : Float = 2.0

///|
/// Time value for mace cooldown in seconds.
pub let mace_cooldown : Float = 0.6

///|
/// Damage value for mace damage mult.
pub let mace_damage_mult : Float = 1.2

///|
/// Size or distance value for dagger range in world units.
pub let dagger_range : Float = 1.8

///|
/// Time value for dagger cooldown in seconds.
pub let dagger_cooldown : Float = 0.25

///|
/// Damage value for dagger damage mult.
pub let dagger_damage_mult : Float = 0.7

///|
/// Size or distance value for staff range in world units.
pub let staff_range : Float = 2.8

///|
/// Time value for staff cooldown in seconds.
pub let staff_cooldown : Float = 0.5

///|
/// Damage value for staff damage mult.
pub let staff_damage_mult : Float = 0.5

///|
/// Size or distance value for bow range in world units.
pub let bow_range : Float = 15.0

///|
/// Time value for bow cooldown in seconds.
pub let bow_cooldown : Float = 0.8

///|
/// Damage value for bow damage mult.
pub let bow_damage_mult : Float = 0.9

///|
/// Size or distance value for archer range in world units.
pub let archer_range : Float = 12.0

///|
/// Time value for archer shoot cooldown in seconds.
pub let archer_shoot_cooldown : Float = 2.0

///|
/// Speed value for projectile speed in world units per second.
pub let projectile_speed : Float = 8.0

///|
/// Time value for projectile lifetime in seconds.
pub let projectile_lifetime : Float = 3.0

///|
/// Size or distance value for enemy melee range in world units.
pub let enemy_melee_range : Float = 2.0

///|
/// Time value for enemy attack cooldown in seconds.
pub let enemy_attack_cooldown : Float = 1.2

///|
/// Size or distance value for enemy sight range in world units.
pub let enemy_sight_range : Float = 10.0

///|
/// Speed value for enemy move speed in world units per second.
pub let enemy_move_speed : Float = 2.0

///|
/// Speed value for wraith move speed in world units per second.
pub let wraith_move_speed : Float = 4.0

///|
/// Speed value for golem move speed in world units per second.
pub let golem_move_speed : Float = 1.2

///|
/// Speed value for bat move speed in world units per second.
pub let bat_move_speed : Float = 5.0

///|
/// Speed value for slime move speed in world units per second.
pub let slime_move_speed : Float = 1.5

///|
/// Speed value for spider move speed in world units per second.
pub let spider_move_speed : Float = 3.0

///|
/// Speed value for minotaur charge speed in world units per second.
pub let minotaur_charge_speed : Float = 8.0

// Spell costs and values

///|
/// Mana-related value for fireball mana cost.
pub let fireball_mana_cost : Int = 15

///|
/// Damage value for fireball damage.
pub let fireball_damage : Int = 25

///|
/// Size or distance value for fireball radius in world units.
pub let fireball_radius : Float = 2.5

///|
/// Mana-related value for ice bolt mana cost.
pub let ice_bolt_mana_cost : Int = 10

///|
/// Damage value for ice bolt damage.
pub let ice_bolt_damage : Int = 15

///|
/// Time value for ice bolt slow duration in seconds.
pub let ice_bolt_slow_duration : Float = 3.0

///|
/// Mana-related value for heal mana cost.
pub let heal_mana_cost : Int = 20

///|
/// Spell costs and values setting for heal amount.
pub let heal_amount : Int = 40

///|
/// Mana-related value for shield mana cost.
pub let shield_mana_cost : Int = 12

///|
/// Time value for shield duration in seconds.
pub let shield_duration : Float = 8.0

///|
/// Scoring or progression value for shield defense bonus.
pub let shield_defense_bonus : Int = 10

///|
/// Mana-related value for lightning mana cost.
pub let lightning_mana_cost : Int = 25

///|
/// Damage value for lightning damage.
pub let lightning_damage : Int = 35

///|
/// Size or distance value for lightning chain range in world units.
pub let lightning_chain_range : Float = 4.0

///|
/// Mana-related value for teleport mana cost.
pub let teleport_mana_cost : Int = 8

// Trap values

///|
/// Damage value for spike damage.
pub let spike_damage : Int = 15

///|
/// Damage value for arrow trap damage.
pub let arrow_trap_damage : Int = 20

///|
/// Damage value for flame damage.
pub let flame_damage : Int = 25

///|
/// Damage value for poison damage per sec.
pub let poison_damage_per_sec : Int = 5

///|
/// Time value for poison duration in seconds.
pub let poison_duration : Float = 5.0

///|
/// Damage value for pitfall damage.
pub let pitfall_damage : Int = 30

///|
/// Time value for trap cooldown in seconds.
pub let trap_cooldown : Float = 3.0

// XP and leveling

///|
/// Scoring or progression value for xp per skeleton.
pub let xp_per_skeleton : Int = 20

///|
/// Scoring or progression value for xp per archer.
pub let xp_per_archer : Int = 30

///|
/// Scoring or progression value for xp per golem.
pub let xp_per_golem : Int = 50

///|
/// Scoring or progression value for xp per wraith.
pub let xp_per_wraith : Int = 40

///|
/// Scoring or progression value for xp per dragon.
pub let xp_per_dragon : Int = 200

///|
/// Scoring or progression value for xp per slime.
pub let xp_per_slime : Int = 10

///|
/// Scoring or progression value for xp per bat.
pub let xp_per_bat : Int = 15

///|
/// Scoring or progression value for xp per spider.
pub let xp_per_spider : Int = 25

///|
/// Scoring or progression value for xp per minotaur.
pub let xp_per_minotaur : Int = 60

///|
/// Scoring or progression value for xp per lich.
pub let xp_per_lich : Int = 80

///|
/// Scoring or progression value for xp per mimic.
pub let xp_per_mimic : Int = 45

///|
/// Scoring or progression value for xp per level.
pub let xp_per_level : Int = 100

///|
/// Hit-point value for hp per level.
pub let hp_per_level : Int = 15

///|
/// Mana-related value for mana per level.
pub let mana_per_level : Int = 8

///|
/// XP and leveling setting for atk per level.
pub let atk_per_level : Int = 3

///|
/// XP and leveling setting for def per level.
pub let def_per_level : Int = 2

// Loot values

///|
/// Hit-point value for health potion heal.
pub let health_potion_heal : Int = 40

///|
/// Mana-related value for mana potion restore.
pub let mana_potion_restore : Int = 30

///|
/// Damage value for damage boost amount.
pub let damage_boost_amount : Int = 5

///|
/// Numeric id for boost amount.
pub let armor_boost_amount : Int = 3

///|
/// Time value for speed potion duration in seconds.
pub let speed_potion_duration : Float = 10.0

///|
/// Time value for strength potion duration in seconds.
pub let strength_potion_duration : Float = 10.0

///|
/// Scoring or progression value for strength potion bonus.
pub let strength_potion_bonus : Int = 8

///|
/// Loot values setting for gold pile min.
pub let gold_pile_min : Int = 10

///|
/// Loot values setting for gold pile max.
pub let gold_pile_max : Int = 50

// Armor defense values

///|
/// Armor defense values setting for robes defense.
pub let robes_defense : Int = 2

///|
/// Armor defense values setting for leather defense.
pub let leather_defense : Int = 5

///|
/// Armor defense values setting for chain defense.
pub let chain_defense : Int = 8

///|
/// Armor defense values setting for plate defense.
pub let plate_defense : Int = 12

// Shop prices

// Shrine buffs

///|
/// Shrine buffs setting for shrine options.
pub let shrine_options : Int = 3

// Minimap

///|
/// UI sizing value for minimap size in pixels.
pub let minimap_size : Int = 160

///|
/// UI sizing value for minimap x in pixels.
pub let minimap_x : Int = 854 // screen_width - minimap_size - 10

///|
/// UI sizing value for minimap y in pixels.
pub let minimap_y : Int = 10

///|
/// UI sizing value for minimap cell in pixels.
pub let minimap_cell : Int = 5

// UI

///|
/// UI sizing value for menu blink speed in pixels.
pub let menu_blink_speed : Float = 3.5

// Sword swing animation

///|
/// Time value for swing duration in seconds.
pub let swing_duration : Float = 0.3

// Camera

///|
/// Field-of-view value for camera fovy in degrees.
pub let camera_fovy : Float = 60.0

// Pi constant

///|
/// Mathematical constant pi in radians.
pub let pi : Float = 3.14159265

// Mana regen

///|
/// Mana-related value for mana regen rate.
pub let mana_regen_rate : Float = 1.5

// Boss intro duration

// Inventory UI
