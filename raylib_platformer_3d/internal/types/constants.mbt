///|
/// Window width in pixels.
pub let screen_width : Int = 1024

///|
/// Window height in pixels.
pub let screen_height : Int = 768

// ========== Physics ==========

///|
/// Gravity acceleration for gravity in world units per second squared.
pub let gravity : Float = 25.0

///|
/// Force value for jump force in world units per second.
pub let jump_force : Float = 10.0

///|
/// Speed value for move speed in world units per second.
pub let move_speed : Float = 6.0

///|
/// Physics setting for air control.
pub let air_control : Float = 0.4

///|
/// Speed value for max fall speed in world units per second.
pub let max_fall_speed : Float = 30.0

///|
/// Time value for coyote time in seconds.
pub let coyote_time : Float = 0.1

///|
/// Physics setting for jump buffer.
pub let jump_buffer : Float = 0.1

///|
/// Speed value for wall slide speed in world units per second.
pub let wall_slide_speed : Float = 3.0

///|
/// Force value for wall jump height force in world units per second.
pub let wall_jump_h_force : Float = 7.0

///|
/// Force value for wall jump v force in world units per second.
pub let wall_jump_v_force : Float = 9.0

///|
/// Force value for double jump force in world units per second.
pub let double_jump_force : Float = 8.5

///|
/// Damping factor for ground friction.
pub let ground_friction : Float = 0.85

///|
/// Damping factor for ice friction.
pub let ice_friction : Float = 0.98

///|
/// Damping factor for air friction.
pub let air_friction : Float = 0.92

///|
/// Speed value for dash speed in world units per second.
pub let dash_speed : Float = 14.0

///|
/// Time value for dash duration in seconds.
pub let dash_duration : Float = 0.15

///|
/// Time value for dash cooldown in seconds.
pub let dash_cooldown : Float = 0.6

///|
/// Acceleration value for player accel mult in world units per second squared.
pub let player_accel_mult : Float = 10.0

// ========== Player ==========

///|
/// Size or distance value for player radius in world units.
pub let player_radius : Float = 0.4

///|
/// Size or distance value for player height in world units.
pub let player_height : Float = 0.8

///|
/// Count limit or quantity for player max lives.
pub let player_max_lives : Int = 5

///|
/// Time value for invincible time in seconds.
pub let invincible_time : Float = 1.5

///|
/// Size or distance value for respawn height in world units.
pub let respawn_height : Float = 2.0

///|
/// Coordinate value for death fall y in world units.
pub let death_fall_y : Float = -20.0

// ========== Camera ==========

///|
/// Field-of-view value for camera fovy in degrees.
pub let camera_fovy : Float = 60.0

///|
/// Size or distance value for camera dist in world units.
pub let camera_dist : Float = 8.0

///|
/// Size or distance value for camera height in world units.
pub let camera_height : Float = 4.0

///|
/// Camera setting for camera smooth.
pub let camera_smooth : Float = 8.0

///|
/// Speed value for camera rotate speed in world units per second.
pub let camera_rotate_speed : Float = 90.0

///|
/// Size or distance value for camera min dist in world units.
pub let camera_min_dist : Float = 4.0

///|
/// Size or distance value for camera max dist in world units.
pub let camera_max_dist : Float = 14.0

///|
/// Speed value for camera zoom speed in world units per second.
pub let camera_zoom_speed : Float = 3.0

///|
/// Camera setting for camera shake decay.
pub let camera_shake_decay : Float = 5.0

// ========== Pool sizes ==========

///|
/// Count limit or quantity for max platforms.
pub let max_platforms : Int = 128

///|
/// Count limit or quantity for max collectibles.
pub let max_collectibles : Int = 64

///|
/// Count limit or quantity for max hazards.
pub let max_hazards : Int = 32

///|
/// Count limit or quantity for max particles.
pub let max_particles : Int = 512

///|
/// Count limit or quantity for max checkpoints.
pub let max_checkpoints : Int = 8

///|
/// Count limit or quantity for max enemies.
pub let max_enemies : Int = 32

///|
/// Count limit or quantity for max powerups.
pub let max_powerups : Int = 16

///|
/// Count limit or quantity for max decorations.
pub let max_decorations : Int = 64

///|
/// Count limit or quantity for max projectiles.
pub let max_projectiles : Int = 32

// ========== Game states ==========

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
/// Numeric id for level complete.
pub let state_level_complete : Int = 3

///|
/// Numeric id for game over.
pub let state_game_over : Int = 4

///|
/// Numeric id for world select.
pub let state_world_select : Int = 5

///|
/// Numeric id for campaign complete.
pub let state_campaign_complete : Int = 6

///|
/// Numeric id for level select.
pub let state_level_select : Int = 7

///|
/// Numeric id for death anim.
pub let state_death_anim : Int = 8

///|
/// Numeric id for world intro.
pub let state_world_intro : Int = 9

// ========== Platform types ==========

///|
/// Numeric id for static.
pub let plat_static : Int = 0

///|
/// Numeric id for moving x.
pub let plat_moving_x : Int = 1

///|
/// Numeric id for moving y.
pub let plat_moving_y : Int = 2

///|
/// Numeric id for moving z.
pub let plat_moving_z : Int = 3

///|
/// Numeric id for falling.
pub let plat_falling : Int = 4

///|
/// Numeric id for bouncy.
pub let plat_bouncy : Int = 5

///|
/// Numeric id for ice.
pub let plat_ice : Int = 6

///|
/// Numeric id for crumbling.
pub let plat_crumbling : Int = 7

///|
/// Numeric id for rotating.
pub let plat_rotating : Int = 8

///|
/// Numeric id for conveyor left.
pub let plat_conveyor_l : Int = 9

///|
/// Numeric id for conveyor right.
pub let plat_conveyor_r : Int = 10

///|
/// Numeric id for phasing.
pub let plat_phasing : Int = 11

///|
/// Numeric id for size pulse.
pub let plat_size_pulse : Int = 12

// ========== Collectible types ==========

///|
/// Numeric id for gem.
pub let collect_gem : Int = 0

///|
/// Numeric id for star.
pub let collect_star : Int = 1

///|
/// Numeric id for life.
pub let collect_life : Int = 2

///|
/// Numeric id for spring.
pub let collect_spring : Int = 3

///|
/// Numeric id for coin bronze.
pub let collect_coin_bronze : Int = 4

///|
/// Numeric id for coin silver.
pub let collect_coin_silver : Int = 5

///|
/// Numeric id for coin gold.
pub let collect_coin_gold : Int = 6

///|
/// Numeric id for key.
pub let collect_key : Int = 7

// ========== Hazard types ==========

///|
/// Numeric id for spike.
pub let hazard_spike : Int = 0

///|
/// Numeric id for lava.
pub let hazard_lava : Int = 1

///|
/// Numeric id for saw.
pub let hazard_saw : Int = 2

///|
/// Numeric id for laser.
pub let hazard_laser : Int = 3

///|
/// Numeric id for fire jet.
pub let hazard_fire_jet : Int = 4

///|
/// Numeric id for pendulum.
pub let hazard_pendulum : Int = 5

///|
/// Numeric id for crusher.
pub let hazard_crusher : Int = 6

// ========== Enemy types ==========

///|
/// Numeric id for patrol.
pub let enemy_patrol : Int = 0

///|
/// Numeric id for bounce.
pub let enemy_bounce : Int = 1

///|
/// Numeric id for fly circle.
pub let enemy_fly_circle : Int = 2

///|
/// Numeric id for chase.
pub let enemy_chase : Int = 3

///|
/// Numeric id for turret.
pub let enemy_turret : Int = 4

///|
/// Numeric id for ghost.
pub let enemy_ghost : Int = 5

// ========== Power-up types ==========

///|
/// Numeric id for double jump.
pub let powerup_double_jump : Int = 0

///|
/// Numeric id for speed.
pub let powerup_speed : Int = 1

///|
/// Numeric id for shield.
pub let powerup_shield : Int = 2

///|
/// Numeric id for magnet.
pub let powerup_magnet : Int = 3

///|
/// Numeric id for slow fall.
pub let powerup_slow_fall : Int = 4

// ========== Worlds ==========

///|
/// Count limit or quantity for num worlds.
pub let num_worlds : Int = 4

///|
/// Worlds setting for levels per world.
pub let levels_per_world : Int = 5

///|
/// Count limit or quantity for total levels.
pub let total_levels : Int = 20

// ========== World theme indices ==========

///|
/// Numeric id for forest.
pub let world_forest : Int = 0

///|
/// Numeric id for crystal.
pub let world_crystal : Int = 1

///|
/// Numeric id for lava.
pub let world_lava : Int = 2

///|
/// Numeric id for sky.
pub let world_sky : Int = 3

// ========== Bouncy ==========

///|
/// Force value for bounce force in world units per second.
pub let bounce_force : Float = 15.0

///|
/// Force value for super bounce force in world units per second.
pub let super_bounce_force : Float = 20.0

// ========== Falling platform ==========

///|
/// Time value for fall delay in seconds.
pub let fall_delay : Float = 0.5

///|
/// Speed value for fall speed in world units per second.
pub let fall_speed : Float = 8.0

///|
/// Falling platform setting for fall shake amp.
pub let fall_shake_amp : Float = 0.05

// ========== Crumbling ==========

///|
/// Time value for crumble time in seconds.
pub let crumble_time : Float = 0.8

// ========== Phasing platform ==========

///|
/// Time value for phase on time in seconds.
pub let phase_on_time : Float = 2.0

///|
/// Time value for phase off time in seconds.
pub let phase_off_time : Float = 1.5

// ========== Rotating platform ==========

///|
/// Speed value for rotate speed in world units per second.
pub let rotate_speed : Float = 1.5

// ========== Conveyor ==========

///|
/// Force value for conveyor force in world units per second.
pub let conveyor_force : Float = 3.0

// ========== Score ==========

///|
/// Scoring or progression value for gem score.
pub let gem_score : Int = 10

///|
/// Scoring or progression value for star score.
pub let star_score : Int = 50

///|
/// Scoring or progression value for coin bronze score.
pub let coin_bronze_score : Int = 5

///|
/// Scoring or progression value for coin silver score.
pub let coin_silver_score : Int = 20

///|
/// Scoring or progression value for coin gold score.
pub let coin_gold_score : Int = 100

///|
/// Scoring or progression value for key score.
pub let key_score : Int = 200

///|
/// Scoring or progression value for enemy kill score.
pub let enemy_kill_score : Int = 30

///|
/// Multiplier used for combo base mult.
pub let combo_base_mult : Float = 1.0

///|
/// Score setting for combo increment.
pub let combo_increment : Float = 0.5

///|
/// Time value for combo decay time in seconds.
pub let combo_decay_time : Float = 2.0

///|
/// Score setting for combo max.
pub let combo_max : Float = 5.0

// ========== Enemy parameters ==========

///|
/// Speed value for enemy patrol speed in world units per second.
pub let enemy_patrol_speed : Float = 2.0

///|
/// Speed value for enemy bounce speed in world units per second.
pub let enemy_bounce_speed : Float = 4.0

///|
/// Size or distance value for enemy bounce height in world units.
pub let enemy_bounce_height : Float = 3.0

///|
/// Size or distance value for enemy fly radius in world units.
pub let enemy_fly_radius : Float = 3.0

///|
/// Speed value for enemy fly speed in world units per second.
pub let enemy_fly_speed : Float = 1.5

///|
/// Speed value for enemy chase speed in world units per second.
pub let enemy_chase_speed : Float = 3.5

///|
/// Size or distance value for enemy chase range in world units.
pub let enemy_chase_range : Float = 10.0

///|
/// Size or distance value for enemy turret range in world units.
pub let enemy_turret_range : Float = 12.0

///|
/// Rate value for enemy turret fire rate.
pub let enemy_turret_fire_rate : Float = 2.0

///|
/// Speed value for enemy ghost speed in world units per second.
pub let enemy_ghost_speed : Float = 2.0

///|
/// Size or distance value for enemy ghost fade dist in world units.
pub let enemy_ghost_fade_dist : Float = 6.0

///|
/// Enemy parameters setting for enemy stomp bounce.
pub let enemy_stomp_bounce : Float = 8.0

///|
/// Size or distance value for enemy size in world units.
pub let enemy_size : Float = 0.6

///|
/// Size or distance value for enemy kill radius in world units.
pub let enemy_kill_radius : Float = 0.7

// ========== Power-up parameters ==========

///|
/// Time value for powerup duration in seconds.
pub let powerup_duration : Float = 8.0

///|
/// Speed value for powerup speed mult in world units per second.
pub let powerup_speed_mult : Float = 1.6

///|
/// Size or distance value for powerup magnet range in world units.
pub let powerup_magnet_range : Float = 5.0

///|
/// Multiplier used for powerup slow fall mult.
pub let powerup_slow_fall_mult : Float = 0.3

///|
/// Speed value for powerup bob speed in world units per second.
pub let powerup_bob_speed : Float = 3.0

///|
/// Speed value for powerup spin speed in world units per second.
pub let powerup_spin_speed : Float = 4.0

// ========== Particle parameters ==========

///|
/// Count limit or quantity for particle jump count.
pub let particle_jump_count : Int = 6

///|
/// Count limit or quantity for particle collect count.
pub let particle_collect_count : Int = 8

///|
/// Count limit or quantity for particle death count.
pub let particle_death_count : Int = 16

///|
/// Count limit or quantity for particle stomp count.
pub let particle_stomp_count : Int = 10

///|
/// Count limit or quantity for particle trail count.
pub let particle_trail_count : Int = 2

///|
/// Count limit or quantity for particle powerup count.
pub let particle_powerup_count : Int = 12

///|
/// Count limit or quantity for particle checkpoint count.
pub let particle_checkpoint_count : Int = 8

///|
/// Count limit or quantity for particle landing count.
pub let particle_landing_count : Int = 4

///|
/// Count limit or quantity for particle wall slide count.
pub let particle_wall_slide_count : Int = 1

///|
/// Count limit or quantity for particle dash count.
pub let particle_dash_count : Int = 6

// ========== Decoration parameters ==========

///|
/// Numeric id for tree.
pub let deco_tree : Int = 0

///|
/// Numeric id for rock.
pub let deco_rock : Int = 1

///|
/// Numeric id for crystal.
pub let deco_crystal : Int = 2

///|
/// Numeric id for mushroom.
pub let deco_mushroom : Int = 3

///|
/// Numeric id for pillar.
pub let deco_pillar : Int = 4

///|
/// Numeric id for stalagmite.
pub let deco_stalagmite : Int = 5

///|
/// Numeric id for lava rock.
pub let deco_lava_rock : Int = 6

///|
/// Numeric id for cloud.
pub let deco_cloud : Int = 7

///|
/// Numeric id for bush.
pub let deco_bush : Int = 8

///|
/// Numeric id for lamp.
pub let deco_lamp : Int = 9

// ========== Projectile types ==========

///|
/// Numeric id for enemy shot.
pub let proj_enemy_shot : Int = 0

///|
/// Numeric id for fire ball.
pub let proj_fire_ball : Int = 1

///|
/// Speed value for proj speed in world units per second.
pub let proj_speed : Float = 8.0

///|
/// Time value for proj lifetime in seconds.
pub let proj_lifetime : Float = 3.0

///|
/// Size or distance value for proj radius in world units.
pub let proj_radius : Float = 0.2

// ========== Level complete stars ==========

///|
/// Time value for star time threshold 1 in seconds.
pub let star_time_threshold_1 : Float = 60.0

///|
/// Time value for star time threshold 2 in seconds.
pub let star_time_threshold_2 : Float = 45.0

///|
/// Time value for star time threshold 3 in seconds.
pub let star_time_threshold_3 : Float = 30.0

///|
/// Scoring or progression value for star no death bonus.
pub let star_no_death_bonus : Int = 100

///|
/// Scoring or progression value for star all gems bonus.
pub let star_all_gems_bonus : Int = 200

// ========== UI animation ==========

///|
/// UI sizing value for ui fade speed in pixels.
pub let ui_fade_speed : Float = 3.0

///|
/// UI sizing value for ui slide speed in pixels.
pub let ui_slide_speed : Float = 5.0

///|
/// UI sizing value for ui blink speed in pixels.
pub let ui_blink_speed : Float = 3.5

///|
/// UI sizing value for ui score fly speed in pixels.
pub let ui_score_fly_speed : Float = 2.0

///|
/// UI sizing value for hud height in pixels.
pub let hud_height : Int = 36

///|
/// UI sizing value for hud combo bar width in pixels.
pub let hud_combo_bar_width : Int = 120

///|
/// UI sizing value for hud combo bar height in pixels.
pub let hud_combo_bar_height : Int = 12

///|
/// UI sizing value for minimap size in pixels.
pub let minimap_size : Int = 140

///|
/// UI sizing value for minimap margin in pixels.
pub let minimap_margin : Int = 10

// ========== World intro ==========

///|
/// Time value for world intro duration in seconds.
pub let world_intro_duration : Float = 2.5

///|
/// World intro setting for world intro fade.
pub let world_intro_fade : Float = 0.8

// ========== Death animation ==========

///|
/// Time value for death anim time in seconds.
pub let death_anim_time : Float = 1.0

///|
/// Size or distance value for death bounce height in world units.
pub let death_bounce_height : Float = 5.0

// ========== Checkpoint ==========

///|
/// Size or distance value for checkpoint activate range in world units.
pub let checkpoint_activate_range : Float = 1.5

///|
/// Size or distance value for checkpoint flag height in world units.
pub let checkpoint_flag_height : Float = 1.5

// ========== Level select grid ==========

///|
/// UI sizing value for level grid cols in pixels.
pub let level_grid_cols : Int = 5

///|
/// UI sizing value for level card width in pixels.
pub let level_card_w : Int = 140

///|
/// UI sizing value for level card height in pixels.
pub let level_card_h : Int = 100

///|
/// UI sizing value for level card gap in pixels.
pub let level_card_gap : Int = 20

// ========== Shadow ==========

///|
/// Size or distance value for shadow size base in world units.
pub let shadow_size_base : Float = 0.5

///|
/// Size or distance value for shadow max height in world units.
pub let shadow_max_height : Float = 20.0

///|
/// Alpha/transparency value for shadow min alpha in 0-255 range.
pub let shadow_min_alpha : Int = 20

///|
/// Alpha/transparency value for shadow max alpha in 0-255 range.
pub let shadow_max_alpha : Int = 80

// ========== Math constants ==========

///|
/// Mathematical constant pi in radians.
pub let pi : Float = 3.14159265

///|
/// Full-turn angle constant in radians.
pub let two_pi : Float = 6.28318530

///|
/// Multiplier to convert degrees to radians.
pub let deg2rad : Float = 0.01745329

///|
/// Multiplier to convert radians to degrees.
pub let rad2deg : Float = 57.2957795

// ========== Forest world colors ==========

///|
/// Red channel (0-255) for forest plat color.
pub let forest_plat_r : Int = 80

///|
/// Green channel (0-255) for forest plat color.
pub let forest_plat_g : Int = 160

///|
/// Blue channel (0-255) for forest plat color.
pub let forest_plat_b : Int = 60

///|
/// Red channel (0-255) for forest bg color.
pub let forest_bg_r : Int = 100

///|
/// Green channel (0-255) for forest bg color.
pub let forest_bg_g : Int = 180

///|
/// Blue channel (0-255) for forest bg color.
pub let forest_bg_b : Int = 255

///|
/// Red channel (0-255) for forest fog color.
pub let forest_fog_r : Int = 140

///|
/// Green channel (0-255) for forest fog color.
pub let forest_fog_g : Int = 200

///|
/// Blue channel (0-255) for forest fog color.
pub let forest_fog_b : Int = 255

///|
/// Red channel (0-255) for forest tree color.
pub let forest_tree_r : Int = 60

///|
/// Green channel (0-255) for forest tree color.
pub let forest_tree_g : Int = 130

///|
/// Blue channel (0-255) for forest tree color.
pub let forest_tree_b : Int = 40

///|
/// Red channel (0-255) for forest trunk color.
pub let forest_trunk_r : Int = 100

///|
/// Green channel (0-255) for forest trunk color.
pub let forest_trunk_g : Int = 70

///|
/// Blue channel (0-255) for forest trunk color.
pub let forest_trunk_b : Int = 40

// ========== Crystal world colors ==========

///|
/// Red channel (0-255) for crystal plat color.
pub let crystal_plat_r : Int = 80

///|
/// Green channel (0-255) for crystal plat color.
pub let crystal_plat_g : Int = 120

///|
/// Blue channel (0-255) for crystal plat color.
pub let crystal_plat_b : Int = 180

///|
/// Red channel (0-255) for crystal bg color.
pub let crystal_bg_r : Int = 20

///|
/// Green channel (0-255) for crystal bg color.
pub let crystal_bg_g : Int = 30

///|
/// Blue channel (0-255) for crystal bg color.
pub let crystal_bg_b : Int = 60

///|
/// Red channel (0-255) for crystal glow color.
pub let crystal_glow_r : Int = 100

///|
/// Green channel (0-255) for crystal glow color.
pub let crystal_glow_g : Int = 150

///|
/// Blue channel (0-255) for crystal glow color.
pub let crystal_glow_b : Int = 255

///|
/// Red channel (0-255) for crystal ice color.
pub let crystal_ice_r : Int = 150

///|
/// Green channel (0-255) for crystal ice color.
pub let crystal_ice_g : Int = 210

///|
/// Blue channel (0-255) for crystal ice color.
pub let crystal_ice_b : Int = 240

// ========== Lava world colors ==========

///|
/// Red channel (0-255) for lava plat color.
pub let lava_plat_r : Int = 160

///|
/// Green channel (0-255) for lava plat color.
pub let lava_plat_g : Int = 80

///|
/// Blue channel (0-255) for lava plat color.
pub let lava_plat_b : Int = 40

///|
/// Red channel (0-255) for lava bg color.
pub let lava_bg_r : Int = 60

///|
/// Green channel (0-255) for lava bg color.
pub let lava_bg_g : Int = 20

///|
/// Blue channel (0-255) for lava bg color.
pub let lava_bg_b : Int = 10

///|
/// Red channel (0-255) for lava glow color.
pub let lava_glow_r : Int = 255

///|
/// Green channel (0-255) for lava glow color.
pub let lava_glow_g : Int = 100

///|
/// Blue channel (0-255) for lava glow color.
pub let lava_glow_b : Int = 20

///|
/// Red channel (0-255) for lava rock color.
pub let lava_rock_r : Int = 80

///|
/// Green channel (0-255) for lava rock color.
pub let lava_rock_g : Int = 50

///|
/// Blue channel (0-255) for lava rock color.
pub let lava_rock_b : Int = 30

// ========== Sky world colors ==========

///|
/// Red channel (0-255) for sky plat color.
pub let sky_plat_r : Int = 140

///|
/// Green channel (0-255) for sky plat color.
pub let sky_plat_g : Int = 140

///|
/// Blue channel (0-255) for sky plat color.
pub let sky_plat_b : Int = 160

///|
/// Red channel (0-255) for sky bg color.
pub let sky_bg_r : Int = 180

///|
/// Green channel (0-255) for sky bg color.
pub let sky_bg_g : Int = 200

///|
/// Blue channel (0-255) for sky bg color.
pub let sky_bg_b : Int = 240

///|
/// Red channel (0-255) for sky cloud color.
pub let sky_cloud_r : Int = 240

///|
/// Green channel (0-255) for sky cloud color.
pub let sky_cloud_g : Int = 245

///|
/// Blue channel (0-255) for sky cloud color.
pub let sky_cloud_b : Int = 255

///|
/// Red channel (0-255) for sky pillar color.
pub let sky_pillar_r : Int = 200

///|
/// Green channel (0-255) for sky pillar color.
pub let sky_pillar_g : Int = 195

///|
/// Blue channel (0-255) for sky pillar color.
pub let sky_pillar_b : Int = 210

// ========== Player colors ==========

///|
/// Red channel (0-255) for player body color.
pub let player_body_r : Int = 60

///|
/// Green channel (0-255) for player body color.
pub let player_body_g : Int = 140

///|
/// Blue channel (0-255) for player body color.
pub let player_body_b : Int = 220

///|
/// Red channel (0-255) for player head color.
pub let player_head_r : Int = 80

///|
/// Green channel (0-255) for player head color.
pub let player_head_g : Int = 170

///|
/// Blue channel (0-255) for player head color.
pub let player_head_b : Int = 250

///|
/// Red channel (0-255) for player eye color.
pub let player_eye_r : Int = 255

///|
/// Green channel (0-255) for player eye color.
pub let player_eye_g : Int = 255

///|
/// Blue channel (0-255) for player eye color.
pub let player_eye_b : Int = 255

///|
/// Red channel (0-255) for player arm color.
pub let player_arm_r : Int = 50

///|
/// Green channel (0-255) for player arm color.
pub let player_arm_g : Int = 120

///|
/// Blue channel (0-255) for player arm color.
pub let player_arm_b : Int = 200

///|
/// Red channel (0-255) for player leg color.
pub let player_leg_r : Int = 40

///|
/// Green channel (0-255) for player leg color.
pub let player_leg_g : Int = 100

///|
/// Blue channel (0-255) for player leg color.
pub let player_leg_b : Int = 180

///|
/// Red channel (0-255) for player shield color.
pub let player_shield_r : Int = 100

///|
/// Green channel (0-255) for player shield color.
pub let player_shield_g : Int = 200

///|
/// Blue channel (0-255) for player shield color.
pub let player_shield_b : Int = 255

///|
/// Alpha channel (0-255) for player shield.
pub let player_shield_a : Int = 80

// ========== Gem colors ==========

///|
/// Red channel (0-255) for gem color.
pub let gem_r : Int = 0

///|
/// Green channel (0-255) for gem color.
pub let gem_g : Int = 255

///|
/// Blue channel (0-255) for gem color.
pub let gem_b : Int = 100

///|
/// Red channel (0-255) for star color.
pub let star_r : Int = 255

///|
/// Green channel (0-255) for star color.
pub let star_g : Int = 255

///|
/// Blue channel (0-255) for star color.
pub let star_b : Int = 0

///|
/// Red channel (0-255) for coin bronze color.
pub let coin_bronze_r : Int = 180

///|
/// Green channel (0-255) for coin bronze color.
pub let coin_bronze_g : Int = 130

///|
/// Blue channel (0-255) for coin bronze color.
pub let coin_bronze_b : Int = 70

///|
/// Red channel (0-255) for coin silver color.
pub let coin_silver_r : Int = 200

///|
/// Green channel (0-255) for coin silver color.
pub let coin_silver_g : Int = 200

///|
/// Blue channel (0-255) for coin silver color.
pub let coin_silver_b : Int = 210

///|
/// Red channel (0-255) for coin gold color.
pub let coin_gold_r : Int = 255

///|
/// Green channel (0-255) for coin gold color.
pub let coin_gold_g : Int = 215

///|
/// Blue channel (0-255) for coin gold color.
pub let coin_gold_b : Int = 0

///|
/// Red channel (0-255) for key color.
pub let key_r : Int = 255

///|
/// Green channel (0-255) for key color.
pub let key_g : Int = 200

///|
/// Blue channel (0-255) for key color.
pub let key_b : Int = 50

// ========== Goal colors ==========

///|
/// Red channel (0-255) for goal inner color.
pub let goal_inner_r : Int = 255

///|
/// Green channel (0-255) for goal inner color.
pub let goal_inner_g : Int = 215

///|
/// Blue channel (0-255) for goal inner color.
pub let goal_inner_b : Int = 0

///|
/// Red channel (0-255) for goal outer color.
pub let goal_outer_r : Int = 255

///|
/// Green channel (0-255) for goal outer color.
pub let goal_outer_g : Int = 255

///|
/// Blue channel (0-255) for goal outer color.
pub let goal_outer_b : Int = 100

// ========== Enemy colors ==========

///|
/// Red channel (0-255) for enemy patrol color.
pub let enemy_patrol_r : Int = 200

///|
/// Green channel (0-255) for enemy patrol color.
pub let enemy_patrol_g : Int = 60

///|
/// Blue channel (0-255) for enemy patrol color.
pub let enemy_patrol_b : Int = 60

///|
/// Red channel (0-255) for enemy bounce color.
pub let enemy_bounce_r : Int = 180

///|
/// Green channel (0-255) for enemy bounce color.
pub let enemy_bounce_g : Int = 100

///|
/// Blue channel (0-255) for enemy bounce color.
pub let enemy_bounce_b : Int = 200

///|
/// Red channel (0-255) for enemy fly color.
pub let enemy_fly_r : Int = 200

///|
/// Green channel (0-255) for enemy fly color.
pub let enemy_fly_g : Int = 150

///|
/// Blue channel (0-255) for enemy fly color.
pub let enemy_fly_b : Int = 50

///|
/// Red channel (0-255) for enemy chase color.
pub let enemy_chase_r : Int = 220

///|
/// Green channel (0-255) for enemy chase color.
pub let enemy_chase_g : Int = 50

///|
/// Blue channel (0-255) for enemy chase color.
pub let enemy_chase_b : Int = 50

///|
/// Red channel (0-255) for enemy turret color.
pub let enemy_turret_r : Int = 120

///|
/// Green channel (0-255) for enemy turret color.
pub let enemy_turret_g : Int = 120

///|
/// Blue channel (0-255) for enemy turret color.
pub let enemy_turret_b : Int = 130

///|
/// Red channel (0-255) for enemy ghost color.
pub let enemy_ghost_r : Int = 160

///|
/// Green channel (0-255) for enemy ghost color.
pub let enemy_ghost_g : Int = 180

///|
/// Blue channel (0-255) for enemy ghost color.
pub let enemy_ghost_b : Int = 220

// ========== Hazard colors ==========

///|
/// Red channel (0-255) for spike color.
pub let spike_r : Int = 200

///|
/// Green channel (0-255) for spike color.
pub let spike_g : Int = 200

///|
/// Blue channel (0-255) for spike color.
pub let spike_b : Int = 200

///|
/// Red channel (0-255) for saw color.
pub let saw_r : Int = 180

///|
/// Green channel (0-255) for saw color.
pub let saw_g : Int = 180

///|
/// Blue channel (0-255) for saw color.
pub let saw_b : Int = 180

///|
/// Red channel (0-255) for laser color.
pub let laser_r : Int = 255

///|
/// Green channel (0-255) for laser color.
pub let laser_g : Int = 50

///|
/// Blue channel (0-255) for laser color.
pub let laser_b : Int = 50

///|
/// Red channel (0-255) for fire jet color.
pub let fire_jet_r : Int = 255

///|
/// Green channel (0-255) for fire jet color.
pub let fire_jet_g : Int = 150

///|
/// Blue channel (0-255) for fire jet color.
pub let fire_jet_b : Int = 30

// ========== Power-up colors ==========

///|
/// Red channel (0-255) for pu double jump color.
pub let pu_double_jump_r : Int = 100

///|
/// Green channel (0-255) for pu double jump color.
pub let pu_double_jump_g : Int = 200

///|
/// Blue channel (0-255) for pu double jump color.
pub let pu_double_jump_b : Int = 255

///|
/// Red channel (0-255) for pu speed color.
pub let pu_speed_r : Int = 255

///|
/// Green channel (0-255) for pu speed color.
pub let pu_speed_g : Int = 200

///|
/// Blue channel (0-255) for pu speed color.
pub let pu_speed_b : Int = 50

///|
/// Red channel (0-255) for pu shield color.
pub let pu_shield_r : Int = 100

///|
/// Green channel (0-255) for pu shield color.
pub let pu_shield_g : Int = 255

///|
/// Blue channel (0-255) for pu shield color.
pub let pu_shield_b : Int = 200

///|
/// Red channel (0-255) for pu magnet color.
pub let pu_magnet_r : Int = 200

///|
/// Green channel (0-255) for pu magnet color.
pub let pu_magnet_g : Int = 100

///|
/// Blue channel (0-255) for pu magnet color.
pub let pu_magnet_b : Int = 255

///|
/// Red channel (0-255) for pu slow fall color.
pub let pu_slow_fall_r : Int = 200

///|
/// Green channel (0-255) for pu slow fall color.
pub let pu_slow_fall_g : Int = 255

///|
/// Blue channel (0-255) for pu slow fall color.
pub let pu_slow_fall_b : Int = 200
