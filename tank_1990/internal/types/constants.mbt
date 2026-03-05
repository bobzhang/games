///|
/// Window width in pixels.
pub let screen_width : Int = 980

///|
/// Window height in pixels.
pub let screen_height : Int = 760

///|
/// Map width in tiles.
pub let map_tiles_w : Int = 26

///|
/// Map height in tiles.
pub let map_tiles_h : Int = 26

///|
/// Tile size in pixels.
pub let tile_size : Int = 24

///|
/// Map width in pixels.
pub let map_pixel_w : Int = map_tiles_w * tile_size

///|
/// Map height in pixels.
pub let map_pixel_h : Int = map_tiles_h * tile_size

///|
/// Horizontal pixel offset of the map from the window edge.
pub let map_offset_x : Int = 36

///|
/// Vertical pixel offset of the map from the window edge.
pub let map_offset_y : Int = 50

///|
/// Horizontal pixel position of the side panel.
pub let panel_x : Int = map_offset_x + map_pixel_w + 20

///|
/// Width of the side panel in pixels.
pub let panel_w : Int = screen_width - panel_x - 24

///|
/// Tank body size in pixels.
pub let tank_size : Float = 20.0

///|
/// Half of the tank body size for centering calculations.
pub let tank_half : Float = tank_size / 2.0

///|
/// Bullet collision radius in pixels.
pub let bullet_radius : Float = 3.0

///|
/// Maximum number of simultaneous players.
pub let max_players : Int = 2

///|
/// Maximum number of enemy tank slots.
pub let max_enemies : Int = 42

///|
/// Maximum number of active bullets.
pub let max_bullets : Int = 320

///|
/// Maximum number of active particles.
pub let max_particles : Int = 960

///|
/// Maximum number of active powerups on the field.
pub let max_powerups : Int = 32

///|
/// Total number of map tile cells.
pub let max_tiles : Int = map_tiles_w * map_tiles_h

///|
/// Maximum enemy tanks allowed on the field simultaneously.
pub let enemy_on_field_limit : Int = 8

///|
/// Duration of the stage introduction overlay in seconds.
pub let stage_intro_time : Float = 1.6

///|
/// Duration of the stage clear overlay in seconds.
pub let stage_clear_time : Float = 2.4

///|
/// Delay before returning to menu after game over in seconds.
pub let game_over_delay : Float = 2.8

///|
/// Delay before returning to menu after completing all stages in seconds.
pub let campaign_clear_delay : Float = 3.6

///|
/// Interval between enemy spawns in seconds.
pub let enemy_spawn_period : Float = 0.95

///|
/// Lifetime of a powerup on the field in seconds.
pub let powerup_life : Float = 11.0

///|
/// Duration of the freeze-all-enemies effect in seconds.
pub let freeze_duration : Float = 6.0

///|
/// Duration of the shovel base-fortification effect in seconds.
pub let shovel_duration : Float = 11.0

///|
/// Delay before a player respawns after destruction in seconds.
pub let player_respawn_delay : Float = 1.2

///|
/// Invulnerability duration after player spawns in seconds.
pub let player_invuln_spawn : Float = 2.0

///|
/// Base reload time between player shots in seconds.
pub let player_reload_base : Float = 0.30

///|
/// Base reload time between enemy shots in seconds.
pub let enemy_reload_base : Float = 0.68

///|
/// Player bullet travel speed in pixels per second.
pub let bullet_speed_player : Float = 350.0

///|
/// Enemy bullet travel speed in pixels per second.
pub let bullet_speed_enemy : Float = 290.0

///|
/// Player tank movement speed in pixels per second.
pub let speed_player : Float = 128.0

///|
/// Basic enemy tank movement speed in pixels per second.
pub let speed_enemy_basic : Float = 78.0

///|
/// Fast enemy tank movement speed in pixels per second.
pub let speed_enemy_fast : Float = 110.0

///|
/// Heavy enemy tank movement speed in pixels per second.
pub let speed_enemy_heavy : Float = 66.0

///|
/// Sniper enemy tank movement speed in pixels per second.
pub let speed_enemy_sniper : Float = 84.0

///|
/// Tile X coordinate of the player base.
pub let base_tile_x : Int = 12

///|
/// Tile Y coordinate of the player base.
pub let base_tile_y : Int = 24

///|
/// Blink speed for menu selection cursor.
pub let menu_select_blink_speed : Float = 3.0

///|
/// Decay rate for camera shake intensity.
pub let camera_shake_decay : Float = 3.3

///|
/// Maximum camera shake intensity.
pub let camera_shake_power : Float = 7.5

///|
/// Total number of campaign levels.
pub let level_count : Int = 96

///|
/// Number of distinct map tile patterns.
pub let map_pattern_count : Int = 48

///|
/// Team identifier for no team affiliation.
pub let team_none : Int = 0

///|
/// Team identifier for player one.
pub let team_player1 : Int = 1

///|
/// Team identifier for player two.
pub let team_player2 : Int = 2

///|
/// Team identifier for all enemies.
pub let team_enemy : Int = 3

///|
/// Direction constant for up.
pub let dir_up : Int = 0

///|
/// Direction constant for right.
pub let dir_right : Int = 1

///|
/// Direction constant for down.
pub let dir_down : Int = 2

///|
/// Direction constant for left.
pub let dir_left : Int = 3

///|
/// Tile type for an empty passable cell.
pub let tile_empty : Int = 0

///|
/// Tile type for a destructible brick wall.
pub let tile_brick : Int = 1

///|
/// Tile type for an indestructible steel wall.
pub let tile_steel : Int = 2

///|
/// Tile type for impassable water.
pub let tile_water : Int = 3

///|
/// Tile type for bush concealment.
pub let tile_bush : Int = 4

///|
/// Tile type for slippery ice terrain.
pub let tile_ice : Int = 5

///|
/// Tile type for the player base structure.
pub let tile_base : Int = 6

///|
/// Game state constant for the main menu.
pub let state_menu : Int = 0

///|
/// Game state constant for the stage introduction screen.
pub let state_stage_intro : Int = 1

///|
/// Game state constant for active gameplay.
pub let state_playing : Int = 2

///|
/// Game state constant for the paused state.
pub let state_paused : Int = 3

///|
/// Game state constant for the stage clear screen.
pub let state_stage_clear : Int = 4

///|
/// Game state constant for the game over screen.
pub let state_game_over : Int = 5

///|
/// Game state constant for the campaign completion screen.
pub let state_campaign_clear : Int = 6

///|
/// Enemy type constant for basic tanks.
pub let enemy_basic : Int = 0

///|
/// Enemy type constant for fast tanks.
pub let enemy_fast : Int = 1

///|
/// Enemy type constant for heavy armored tanks.
pub let enemy_heavy : Int = 2

///|
/// Enemy type constant for sniper tanks.
pub let enemy_sniper : Int = 3

///|
/// Powerup type for temporary shield protection.
pub let powerup_shield : Int = 0

///|
/// Powerup type for weapon upgrade star.
pub let powerup_star : Int = 1

///|
/// Powerup type for grenade that destroys all on-screen enemies.
pub let powerup_grenade : Int = 2

///|
/// Powerup type for clock that freezes all enemies.
pub let powerup_clock : Int = 3

///|
/// Powerup type for shovel that fortifies the base.
pub let powerup_shovel : Int = 4

///|
/// Powerup type for extra life tank.
pub let powerup_tank : Int = 5

///|
/// World X coordinate of the left enemy spawn point.
pub let enemy_spawn_x0 : Float = 2.0 * Float::from_int(tile_size) + tank_half

///|
/// World X coordinate of the center enemy spawn point.
pub let enemy_spawn_x1 : Float = 12.0 * Float::from_int(tile_size) + tank_half

///|
/// World X coordinate of the right enemy spawn point.
pub let enemy_spawn_x2 : Float = 22.0 * Float::from_int(tile_size) + tank_half

///|
/// World Y coordinate of all enemy spawn points.
pub let enemy_spawn_y : Float = 1.5 * Float::from_int(tile_size)

///|
/// World X coordinate of player one's spawn point.
pub let player1_spawn_x : Float = 8.0 * Float::from_int(tile_size) + tank_half

///|
/// World Y coordinate of player one's spawn point.
pub let player1_spawn_y : Float = 24.0 * Float::from_int(tile_size) + tank_half

///|
/// World X coordinate of player two's spawn point.
pub let player2_spawn_x : Float = 16.0 * Float::from_int(tile_size) + tank_half

///|
/// World Y coordinate of player two's spawn point.
pub let player2_spawn_y : Float = 24.0 * Float::from_int(tile_size) + tank_half

///|
/// Number of rows in the enemy icon grid on the side panel.
pub let enemy_icon_rows : Int = 10

///|
/// Number of columns in the enemy icon grid on the side panel.
pub let enemy_icon_cols : Int = 2

///|
/// Number of tiles forming the protective ring around the base.
pub let base_ring_count : Int = 14

///|
/// Tile X coordinates of the base protective ring.
pub let base_ring_x : Array[Int] = [
  11, 12, 13, 14, 11, 14, 11, 14, 11, 12, 13, 14, 12, 13,
]

///|
/// Tile Y coordinates of the base protective ring.
pub let base_ring_y : Array[Int] = [
  22, 22, 22, 22, 23, 23, 24, 24, 25, 25, 25, 25, 24, 24,
]
