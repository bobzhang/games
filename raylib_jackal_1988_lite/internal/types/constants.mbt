/// Window width in pixels.
pub let screen_width : Int = 980

/// Window height in pixels.
pub let screen_height : Int = 760

/// Map width in tiles.
pub let map_tiles_w : Int = 26

/// Map height in tiles.
pub let map_tiles_h : Int = 26

/// Size of one map tile in pixels.
pub let tile_size : Int = 24

/// Total map width in pixels.
pub let map_pixel_w : Int = map_tiles_w * tile_size

/// Total map height in pixels.
pub let map_pixel_h : Int = map_tiles_h * tile_size

/// Horizontal screen offset of the map.
pub let map_offset_x : Int = 36

/// Vertical screen offset of the map.
pub let map_offset_y : Int = 50

/// Left x-coordinate of the side panel.
pub let panel_x : Int = map_offset_x + map_pixel_w + 20

/// Width of the side panel.
pub let panel_w : Int = screen_width - panel_x - 24

/// Tank body size in pixels.
pub let tank_size : Float = 20.0

/// Half tank size for collision math.
pub let tank_half : Float = tank_size / 2.0

/// Bullet collision radius.
pub let bullet_radius : Float = 3.0

/// Maximum number of player tanks.
pub let max_players : Int = 2

/// Maximum enemy tank slots.
pub let max_enemies : Int = 42

/// Maximum bullet slots.
pub let max_bullets : Int = 320

/// Maximum particle slots.
pub let max_particles : Int = 960

/// Maximum powerup slots.
pub let max_powerups : Int = 32

/// Maximum hostage slots.
pub let max_hostages : Int = 56

/// Total number of tiles in the map array.
pub let max_tiles : Int = map_tiles_w * map_tiles_h

/// Maximum enemies allowed simultaneously on field.
pub let enemy_on_field_limit : Int = 8

/// Stage intro overlay duration.
pub let stage_intro_time : Float = 1.6

/// Delay before moving from stage clear state.
pub let stage_clear_time : Float = 2.4

/// Delay before leaving game over state.
pub let game_over_delay : Float = 2.8

/// Delay before leaving campaign clear state.
pub let campaign_clear_delay : Float = 3.6

/// Base interval between enemy spawns.
pub let enemy_spawn_period : Float = 0.95

/// Lifetime of spawned powerups.
pub let powerup_life : Float = 11.0

/// Duration of global freeze effect.
pub let freeze_duration : Float = 6.0

/// Duration of base-shield shovel effect.
pub let shovel_duration : Float = 11.0

/// Delay before a destroyed player respawns.
pub let player_respawn_delay : Float = 1.2

/// Spawn invulnerability duration for players.
pub let player_invuln_spawn : Float = 2.0

/// Base player reload delay.
pub let player_reload_base : Float = 0.30

/// Base enemy reload delay.
pub let enemy_reload_base : Float = 0.68

/// Bullet speed for player-fired shots.
pub let bullet_speed_player : Float = 350.0

/// Bullet speed for enemy-fired shots.
pub let bullet_speed_enemy : Float = 290.0

/// Default player tank move speed.
pub let speed_player : Float = 128.0

/// Move speed for basic enemies.
pub let speed_enemy_basic : Float = 78.0

/// Move speed for fast enemies.
pub let speed_enemy_fast : Float = 110.0

/// Move speed for heavy enemies.
pub let speed_enemy_heavy : Float = 66.0

/// Move speed for sniper enemies.
pub let speed_enemy_sniper : Float = 84.0

/// Base tile x-coordinate.
pub let base_tile_x : Int = 12

/// Base tile y-coordinate.
pub let base_tile_y : Int = 24

/// Blink speed for menu selection highlight.
pub let menu_select_blink_speed : Float = 3.0

/// Decay factor for camera shake.
pub let camera_shake_decay : Float = 3.3

/// Maximum camera shake amplitude.
pub let camera_shake_power : Float = 7.5

/// Total number of campaign stages.
pub let level_count : Int = 96

/// Number of unique map pattern templates.
pub let map_pattern_count : Int = 48

/// Radius within which hostages can be rescued.
pub let rescue_pickup_radius : Float = 20.0

/// Score granted per rescued hostage.
pub let rescue_score_each : Int = 120

/// Bonus score granted when rescue goal is met.
pub let rescue_stage_bonus : Int = 300

/// Base rescue target per stage.
pub let rescue_goal_base : Int = 5

/// Team id for no owner.
pub let team_none : Int = 0

/// Team id for player 1.
pub let team_player1 : Int = 1

/// Team id for player 2.
pub let team_player2 : Int = 2

/// Team id for enemies.
pub let team_enemy : Int = 3

/// Direction id for up.
pub let dir_up : Int = 0

/// Direction id for right.
pub let dir_right : Int = 1

/// Direction id for down.
pub let dir_down : Int = 2

/// Direction id for left.
pub let dir_left : Int = 3

/// Tile id for empty space.
pub let tile_empty : Int = 0

/// Tile id for destructible brick.
pub let tile_brick : Int = 1

/// Tile id for steel wall.
pub let tile_steel : Int = 2

/// Tile id for water hazard.
pub let tile_water : Int = 3

/// Tile id for bush cover.
pub let tile_bush : Int = 4

/// Tile id for ice surface.
pub let tile_ice : Int = 5

/// Tile id for base objective.
pub let tile_base : Int = 6

/// Tile id for hostage camp.
pub let tile_camp : Int = 7

/// Menu state id.
pub let state_menu : Int = 0

/// Stage intro state id.
pub let state_stage_intro : Int = 1

/// Active gameplay state id.
pub let state_playing : Int = 2

/// Paused state id.
pub let state_paused : Int = 3

/// Stage clear state id.
pub let state_stage_clear : Int = 4

/// Game over state id.
pub let state_game_over : Int = 5

/// Campaign clear state id.
pub let state_campaign_clear : Int = 6

/// Enemy kind id for basic unit.
pub let enemy_basic : Int = 0

/// Enemy kind id for fast unit.
pub let enemy_fast : Int = 1

/// Enemy kind id for heavy unit.
pub let enemy_heavy : Int = 2

/// Enemy kind id for sniper unit.
pub let enemy_sniper : Int = 3

/// Powerup id for shield.
pub let powerup_shield : Int = 0

/// Powerup id for star.
pub let powerup_star : Int = 1

/// Powerup id for grenade.
pub let powerup_grenade : Int = 2

/// Powerup id for clock.
pub let powerup_clock : Int = 3

/// Powerup id for shovel.
pub let powerup_shovel : Int = 4

/// Powerup id for extra tank life.
pub let powerup_tank : Int = 5

/// Enemy spawn point x for left lane.
pub let enemy_spawn_x0 : Float = 2.0 * Float::from_int(tile_size) + tank_half

/// Enemy spawn point x for center lane.
pub let enemy_spawn_x1 : Float = 12.0 * Float::from_int(tile_size) + tank_half

/// Enemy spawn point x for right lane.
pub let enemy_spawn_x2 : Float = 22.0 * Float::from_int(tile_size) + tank_half

/// Enemy spawn point y-coordinate.
pub let enemy_spawn_y : Float = 1.5 * Float::from_int(tile_size)

/// Player 1 spawn x-coordinate.
pub let player1_spawn_x : Float = 8.0 * Float::from_int(tile_size) + tank_half

/// Player 1 spawn y-coordinate.
pub let player1_spawn_y : Float = 24.0 * Float::from_int(tile_size) + tank_half

/// Player 2 spawn x-coordinate.
pub let player2_spawn_x : Float = 16.0 * Float::from_int(tile_size) + tank_half

/// Player 2 spawn y-coordinate.
pub let player2_spawn_y : Float = 24.0 * Float::from_int(tile_size) + tank_half

/// Number of rows for enemy icon display.
pub let enemy_icon_rows : Int = 10

/// Number of columns for enemy icon display.
pub let enemy_icon_cols : Int = 2

/// Count of tiles surrounding the base ring.
pub let base_ring_count : Int = 14

/// X tile coordinates for protected base ring.
pub let base_ring_x : Array[Int] = [
  11, 12, 13, 14, 11, 14, 11, 14, 11, 12, 13, 14, 12, 13,
]

/// Y tile coordinates for protected base ring.
pub let base_ring_y : Array[Int] = [
  22, 22, 22, 22, 23, 23, 24, 24, 25, 25, 25, 25, 24, 24,
]
