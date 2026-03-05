# Tank 1990

## Introduction to the Game

Tank 1990 is a raylib game package in this repository. This README documents its gameplay intent, public API surface, architecture, and a practical refinement plan.

## Build and Run

```bash
moon build --target native tank_1990/
moon run --target native tank_1990/
```

## Controls

- Refer to the in-game UI for the current control mapping.

## How to Play

Start a run, learn enemy and obstacle patterns, and optimize movement plus timing to maximize score and survival.

## Public API Documentation

The API surface below is generated from `pkg.generated.mbti` files to stay aligned with the compiled public interface.

### Package `tonyfettes/raylib-examples/tank_1990/game`
- Source: `internal/game/pkg.generated.mbti`
- Export summary: 1 values, 0 types, 0 type aliases, 0 traits.
```mbti
pub fn update_game(@types.Game, Float) -> Unit
```

### Package `tonyfettes/raylib-examples/tank_1990/levels`
- Source: `internal/levels/pkg.generated.mbti`
- Export summary: 2 values, 0 types, 0 type aliases, 0 traits.
```mbti
pub fn get_stage_profile(Int) -> @types.StageProfile

pub fn level_pattern(Int) -> Array[String]
```

### Package `tonyfettes/raylib-examples/tank_1990/particles`
- Source: `internal/particles/pkg.generated.mbti`
- Export summary: 5 values, 0 types, 0 type aliases, 0 traits.
```mbti
pub fn spawn_explosion(@types.Game, Float, Float, Float) -> Unit

pub fn spawn_particle(@types.Game, Float, Float, Float, Float, Float, Float, @raylib.Color) -> Unit

pub fn spawn_respawn_burst(@types.Game, Float, Float) -> Unit

pub fn spawn_spark_burst(@types.Game, Float, Float, Int) -> Unit

pub fn update_particles(@types.Game, Float) -> Unit
```

### Package `tonyfettes/raylib-examples/tank_1990/render`
- Source: `internal/render/pkg.generated.mbti`
- Export summary: 31 values, 0 types, 0 type aliases, 0 traits.
```mbti
pub fn bullet_texture(Int) -> @tonyfettes/raylib/internal/raylib.Texture?

pub fn draw_text_centered(String, Int, Int, Int, @tonyfettes/raylib.Color) -> Unit

pub fn draw_text_shadow(String, Int, Int, Int, @tonyfettes/raylib.Color) -> Unit

pub fn draw_texture_box_opt(@tonyfettes/raylib/internal/raylib.Texture?, Int, Int, Int, Int, @tonyfettes/raylib.Color) -> Bool

pub fn draw_texture_centered(@tonyfettes/raylib/internal/raylib.Texture, Float, Float, Float, Float, Float, @tonyfettes/raylib.Color) -> Unit

pub fn draw_texture_centered_opt(@tonyfettes/raylib/internal/raylib.Texture?, Float, Float, Float, Float, Float, @tonyfettes/raylib.Color) -> Bool

pub fn draw_ui(@types.Game) -> Unit

pub fn draw_world(@types.Game) -> Unit

pub fn enemy_body_texture(Int) -> @tonyfettes/raylib/internal/raylib.Texture?

pub fn enemy_marker_texture() -> @tonyfettes/raylib/internal/raylib.Texture?

pub fn enemy_turret_texture(Int) -> @tonyfettes/raylib/internal/raylib.Texture?

pub fn explosion_frame(Int) -> @tonyfettes/raylib/internal/raylib.Texture?

pub fn fx_muzzle_texture() -> @tonyfettes/raylib/internal/raylib.Texture?

pub fn fx_smoke_texture() -> @tonyfettes/raylib/internal/raylib.Texture?

pub fn fx_spark_texture() -> @tonyfettes/raylib/internal/raylib.Texture?

pub fn fx_trace_texture() -> @tonyfettes/raylib/internal/raylib.Texture?

pub fn init_assets() -> Unit

pub fn player_body_texture(Int) -> @tonyfettes/raylib/internal/raylib.Texture?

pub fn player_turret_texture(Int, Int) -> @tonyfettes/raylib/internal/raylib.Texture?

pub fn smoke_frame(Int) -> @tonyfettes/raylib/internal/raylib.Texture?

pub fn tile_texture(Int, Int, Int, Int) -> @tonyfettes/raylib/internal/raylib.Texture?

pub fn tracks_texture() -> @tonyfettes/raylib/internal/raylib.Texture?

pub fn ui_font() -> @tonyfettes/raylib/internal/raylib.Font?

pub fn ui_icon_arrow_down_texture() -> @tonyfettes/raylib/internal/raylib.Texture?

pub fn ui_icon_arrow_up_texture() -> @tonyfettes/raylib/internal/raylib.Texture?

pub fn ui_icon_play_texture() -> @tonyfettes/raylib/internal/raylib.Texture?

pub fn ui_menu_button_focus_texture() -> @tonyfettes/raylib/internal/raylib.Texture?

pub fn ui_menu_button_texture() -> @tonyfettes/raylib/internal/raylib.Texture?

pub fn ui_panel_card_texture() -> @tonyfettes/raylib/internal/raylib.Texture?

pub fn ui_panel_line_texture() -> @tonyfettes/raylib/internal/raylib.Texture?

pub fn unload_assets() -> Unit
```

### Package `tonyfettes/raylib-examples/tank_1990/score`
- Source: `internal/score/pkg.generated.mbti`
- Export summary: 4 values, 0 types, 0 type aliases, 0 traits.
```mbti
pub fn bump_combo(@types.Game) -> Unit

pub fn combo_multiplier(@types.Game) -> Int

pub fn grant_score(@types.Game, Int, Int) -> Unit

pub fn update_combo(@types.Game, Float) -> Unit
```

### Package `tonyfettes/raylib-examples/tank_1990/types`
- Source: `internal/types/pkg.generated.mbti`
- Export summary: 140 values, 0 types, 0 type aliases, 0 traits.
```mbti
pub fn absf(Float) -> Float

pub let base_ring_count : Int

pub let base_ring_x : Array[Int]

pub let base_ring_y : Array[Int]

pub let base_tile_x : Int

pub let base_tile_y : Int

pub let bullet_radius : Float

pub let bullet_speed_enemy : Float

pub let bullet_speed_player : Float

pub let camera_shake_decay : Float

pub let camera_shake_power : Float

pub let campaign_clear_delay : Float

pub fn clampf(Float, Float, Float) -> Float

pub fn clampi(Int, Int, Int) -> Int

pub fn default_stage_profile() -> StageProfile

pub let dir_down : Int

pub let dir_left : Int

pub let dir_right : Int

pub let dir_up : Int

pub fn dir_vector_x(Int) -> Float

pub fn dir_vector_y(Int) -> Float

pub fn distance_sq(Float, Float, Float, Float) -> Float

pub fn draw_centered_text(String, Int, Int, Int, @raylib.Color) -> Unit

pub fn draw_shadow_text(String, Int, Int, Int, @raylib.Color) -> Unit

pub let enemy_basic : Int

pub fn enemy_color(Int) -> @raylib.Color

pub let enemy_fast : Int

pub let enemy_heavy : Int

pub let enemy_icon_cols : Int

pub let enemy_icon_rows : Int

pub let enemy_on_field_limit : Int

pub let enemy_reload_base : Float

pub fn enemy_score(Int) -> Int

pub let enemy_sniper : Int

pub let enemy_spawn_period : Float

pub let enemy_spawn_x0 : Float

pub let enemy_spawn_x1 : Float

pub let enemy_spawn_x2 : Float

pub let enemy_spawn_y : Float

pub let freeze_duration : Float

pub let game_over_delay : Float

pub fn get_tile(Game, Int, Int) -> Int

pub fn in_tile_bounds(Int, Int) -> Bool

pub fn is_tile_solid_for_bullet(Int) -> Bool

pub fn is_tile_solid_for_tank(Int) -> Bool

pub let level_count : Int

pub let map_offset_x : Int

pub let map_offset_y : Int

pub let map_pattern_count : Int

pub let map_pixel_h : Int

pub let map_pixel_w : Int

pub let map_tiles_h : Int

pub let map_tiles_w : Int

pub let max_bullets : Int

pub let max_enemies : Int

pub let max_particles : Int

pub let max_players : Int

pub let max_powerups : Int

pub let max_tiles : Int

pub let menu_select_blink_speed : Float

pub let panel_w : Int

pub let panel_x : Int

pub let player1_spawn_x : Float

pub let player1_spawn_y : Float

pub let player2_spawn_x : Float

pub let player2_spawn_y : Float

pub let player_invuln_spawn : Float

pub let player_reload_base : Float

pub let player_respawn_delay : Float

pub let powerup_clock : Int

pub fn powerup_color(Int) -> @raylib.Color

pub let powerup_grenade : Int

pub let powerup_life : Float

pub fn powerup_radius(Int) -> Float

pub let powerup_shield : Int

pub let powerup_shovel : Int

pub let powerup_star : Int

pub let powerup_tank : Int

pub fn powerup_text(Int) -> String

pub fn pulse_color(@raylib.Color, Float) -> @raylib.Color

pub fn push_camera_shake(Game, Float) -> Unit

pub fn rand_next(Game) -> Int

pub fn rand_range(Game, Int, Int) -> Int

pub fn rand_rangef(Game, Float, Float) -> Float

pub fn rects_overlap(@raylib.Rectangle, @raylib.Rectangle) -> Bool

pub let screen_height : Int

pub let screen_width : Int

pub fn set_tile(Game, Int, Int, Int, Int) -> Unit

pub fn shake_offsets(Game) -> (Float, Float)

pub let shovel_duration : Float

pub let speed_enemy_basic : Float

pub let speed_enemy_fast : Float

pub let speed_enemy_heavy : Float

pub let speed_enemy_sniper : Float

pub let speed_player : Float

pub let stage_clear_time : Float

pub let stage_intro_time : Float

pub let state_campaign_clear : Int

pub let state_game_over : Int

pub let state_menu : Int

pub let state_paused : Int

pub let state_playing : Int

pub let state_stage_clear : Int

pub let state_stage_intro : Int

pub let tank_half : Float

pub fn tank_rect(Tank) -> @raylib.Rectangle

pub fn tank_rect_at(Float, Float) -> @raylib.Rectangle

pub let tank_size : Float

pub let team_enemy : Int

pub let team_none : Int

pub fn team_of_player(Int) -> Int

pub let team_player1 : Int

pub let team_player2 : Int

pub let tile_base : Int

pub let tile_brick : Int

pub let tile_bush : Int

pub fn tile_center_x(Int) -> Float

pub fn tile_center_y(Int) -> Float

pub let tile_empty : Int

pub let tile_ice : Int

pub fn tile_index(Int, Int) -> Int

pub let tile_size : Int

pub let tile_steel : Int

pub fn tile_to_screen_x(Int, Float) -> Int

pub fn tile_to_screen_y(Int, Float) -> Int

pub let tile_water : Int

pub fn update_camera_shake(Game, Float) -> Unit

pub fn world_to_screen_x(Float, Float) -> Int

pub fn world_to_screen_y(Float, Float) -> Int

pub fn world_x_to_tile(Float) -> Int

pub fn world_y_to_tile(Float) -> Int

pub(all) struct Bullet {
  mut active : Bool
  mut owner_team : Int
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut ttl : Float
  mut damage : Int
  mut power : Int
  mut radius : Float
}
pub fn Bullet::inactive() -> Self

pub(all) struct Game {
  mut state : Int
  mut coop_enabled : Bool
  mut demo_mode : Bool
  mut demo_runs : Int
  mut demo_elapsed : Float
  mut menu_cursor : Int
  mut menu_blink : Float
  mut frame_counter : Int
  mut stage_index : Int
  mut stage_intro_timer : Float
  mut stage_clear_timer : Float
  mut game_over_timer : Float
  mut campaign_clear_timer : Float
  mut pause_blink : Float
  mut profile : StageProfile
  mut freeze_all_timer : Float
  mut shovel_timer : Float
  mut camera_shake : Float
  mut camera_shake_phase : Float
  mut base_alive : Bool
  mut base_flash : Float
  base_tiles_cached : Array[Int]
  mut score_total : Int
  mut high_score : Int
  mut enemies_to_spawn : Int
  mut enemies_spawned : Int
  mut enemies_alive : Int
  mut spawn_timer : Float
  mut kill_combo : Int
  mut combo_timer : Float
  mut rng_state : Int
  map_tiles : Array[Int]
  map_hp : Array[Int]
  players : Array[Tank]
  enemies : Array[Tank]
  bullets : Array[Bullet]
  particles : Array[Particle]
  powerups : Array[Powerup]
  stars : Array[Star]
}
pub fn Game::new() -> Self

pub(all) struct Particle {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut life : Float
  mut max_life : Float
  mut size : Float
  mut spin : Float
  mut rot : Float
  mut fade : Float
  mut color : @raylib.Color
}
pub fn Particle::inactive() -> Self

pub(all) struct Powerup {
  mut active : Bool
  mut kind : Int
  mut x : Float
  mut y : Float
  mut ttl : Float
  mut blink : Float
  mut pulse : Float
}
pub fn Powerup::inactive() -> Self

pub(all) struct StageProfile {
  title : String
  subtitle : String
  enemy_bonus : Int
  spawn_scale : Float
  drop_bonus : Int
  sky_top : @raylib.Color
  sky_bottom : @raylib.Color
  fog_alpha : Float
  ui_accent : @raylib.Color
}
pub fn StageProfile::new(String, String, Int, Float, Int, @raylib.Color, @raylib.Color, Float, @raylib.Color) -> Self

pub(all) struct Star {
  mut x : Float
  mut y : Float
  mut speed : Float
  mut twinkle : Float
}
pub fn Star::new(Float, Float, Float, Float) -> Self

pub(all) struct Tank {
  mut active : Bool
  mut is_player : Bool
  mut player_index : Int
  enemy_kind : Int
  mut x : Float
  mut y : Float
  mut spawn_x : Float
  mut spawn_y : Float
  mut dir : Int
  mut move_speed : Float
  mut hp : Int
  mut max_hp : Int
  mut reload_timer : Float
  mut reload_delay : Float
  mut ai_move_timer : Float
  mut ai_fire_timer : Float
  mut ai_stuck_timer : Float
  mut freeze_timer : Float
  mut shield_timer : Float
  mut invuln_timer : Float
  mut respawn_timer : Float
  mut lives : Int
  mut score : Int
  mut weapon_level : Int
  mut blink_timer : Float
  mut skid_timer : Float
}
pub fn Tank::inactive() -> Self
pub fn Tank::new_enemy(Int, Float, Float) -> Self
pub fn Tank::new_player(Int, Float, Float) -> Self
```

### Package `tonyfettes/raylib-examples/tank_1990/world`
- Source: `internal/world/pkg.generated.mbti`
- Export summary: 5 values, 0 types, 0 type aliases, 0 traits.
```mbti
pub fn point_in_world(Float, Float) -> Bool

pub fn sight_blocked(@types.Game, Float, Float, Float, Float) -> Bool

pub fn tank_hits_enemies(@types.Game, Float, Float, Int) -> Bool

pub fn tank_hits_players(@types.Game, Float, Float, Int) -> Bool

pub fn tank_hits_world(@types.Game, Float, Float) -> Bool
```

### Package `tonyfettes/raylib-examples/tank_1990`
- Source: `pkg.generated.mbti`
- Export summary: no exported values/types/traits in this package.

## Architecture

This game follows a layered runtime loop: initialize state, update simulation, then render a frame.
- Root package (`main.mbt`): application bootstrap and frame orchestration.
- `internal/game`: gameplay rules, input handling, and state transitions.
- `internal/render`: drawing pipeline and UI presentation.
- `internal/types`: shared types, constants, and utility helpers.
- `internal/levels`: stage layout/profile data and progression setup.
- `internal/world`: world/map simulation and spatial helpers.
- `internal/particles`: particle and transient visual effects.
- `internal/score`: scoring rules and progression bookkeeping.

## Improvement and Refinement Plan

- Keep `warnings = "+missing_doc"` enabled in all package `moon.pkg` files and treat warnings as part of CI quality gates.
- Add deterministic simulation tests for core update logic (fixed seeds and replayable frame steps).
- Introduce render profiling counters (draw calls, frame time buckets) and optimize heavy scenes.
- Split balancing constants into tunable config groups to reduce rebalance risk during gameplay tweaks.
- Move stage/mission definitions to data-driven descriptors for faster content iteration.
