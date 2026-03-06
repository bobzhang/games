# Tank 1990

A classic top-down tank battle game inspired by the NES title *Battle City*. Command your tank across 96 procedurally themed stages, destroy waves of enemy tanks, collect power-ups, and protect your base from destruction. Supports single-player and local two-player co-op.

The battlefield is a 26x26 tile grid containing brick walls (destructible), steel walls (only destroyed by high-power shots), water (impassable), bushes (provide cover), and ice (causes sliding). Enemy tanks spawn from three points at the top of the map and advance toward your base at the bottom. A stage is cleared once every enemy in the wave has been destroyed. Lose all lives or let the base fall and it is game over.

## Build and Run

```bash
moon build --target native tank_1990/
moon run --target native tank_1990/
```

## Controls

### Menu

| Key | Action |
|-----|--------|
| Up / Down (or W / S) | Navigate menu options |
| Enter / Space | Select menu option |
| C | Toggle co-op mode |
| D | Start demo (AI plays) |

### In-Game -- Player 1

| Key | Action |
|-----|--------|
| Arrow keys | Move tank (Up / Down / Left / Right) |
| Right Shift or Enter | Fire |
| P | Pause / unpause |
| Escape | Exit demo back to menu |

### In-Game -- Player 2 (co-op)

| Key | Action |
|-----|--------|
| W / A / S / D | Move tank |
| Space | Fire |

## How to Play

1. **Start a game** -- from the main menu choose "Play" (single-player) or enable co-op first with C, then select "Play". You can also press D to watch an AI demo.
2. **Defend the base** -- the eagle icon at the bottom-center of the map is your base. If an enemy bullet hits it, the game ends immediately regardless of remaining lives.
3. **Destroy all enemies** -- each stage has a fixed wave of enemies shown by the icon grid on the side panel. Enemies spawn from the top of the map up to 8 at a time. Clear them all to advance.
4. **Collect power-ups** -- destroying certain enemies drops a random power-up:
   - **Shield** -- temporary invulnerability (8 s).
   - **Star** -- upgrades your weapon level (faster reload, more damage, up to level 3 which can break steel walls).
   - **Grenade** -- instantly destroys every enemy currently on the field.
   - **Clock** -- freezes all enemies for 6 s.
   - **Shovel** -- fortifies the base ring with steel walls for 11 s.
   - **Tank** -- grants one extra life.
5. **Watch your lives** -- you respawn after a short delay if you have lives remaining. Each death drops your weapon level by one.
6. **Score** -- points are awarded per enemy kill (varies by enemy type) and per power-up collected (120 pts). Rapid kills build a combo multiplier for bonus points.

### Enemy Types

| Type | Speed | Notes |
|------|-------|-------|
| Basic | Slow | Standard tank, easiest to handle |
| Fast | High | Quick but fragile |
| Heavy | Very slow | Takes more hits to destroy |
| Sniper | Medium | More accurate AI targeting |

### Tile Types

| Tile | Effect |
|------|--------|
| Brick | Blocks movement and bullets; destructible |
| Steel | Blocks movement and bullets; requires weapon level 3 to destroy |
| Water | Impassable to tanks; bullets fly over |
| Bush | Tanks and bullets pass through; provides visual cover |
| Ice | Tanks slide on it after releasing movement keys |

## Public API Reference

The API surface below is generated from `pkg.generated.mbti` files.

### Package `tank_1990/game`

Single entry point that advances one frame of simulation.

```moonbit
pub fn update_game(@types.Game, Float) -> Unit
```

### Package `tank_1990/levels`

Stage layout data and difficulty profiles for the 96-stage campaign.

```moonbit
pub fn get_stage_profile(Int) -> @types.StageProfile
pub fn level_pattern(Int) -> Array[String]
```

### Package `tank_1990/particles`

Spawn and update visual effects (explosions, sparks, smoke).

```moonbit
pub fn spawn_explosion(@types.Game, Float, Float, Float) -> Unit
pub fn spawn_particle(@types.Game, Float, Float, Float, Float, Float, Float, @raylib.Color) -> Unit
pub fn spawn_respawn_burst(@types.Game, Float, Float) -> Unit
pub fn spawn_spark_burst(@types.Game, Float, Float, Int) -> Unit
pub fn update_particles(@types.Game, Float) -> Unit
```

### Package `tank_1990/render`

Drawing functions for the world, UI, and all texture assets.

```moonbit
pub fn draw_ui(@types.Game) -> Unit
pub fn draw_world(@types.Game) -> Unit
pub fn init_assets() -> Unit
pub fn unload_assets() -> Unit
```

<details>
<summary>31 exported values total -- click to expand full list</summary>

```moonbit
pub fn bullet_texture(Int) -> @raylib.Texture?
pub fn draw_text_centered(String, Int, Int, Int, @raylib.Color) -> Unit
pub fn draw_text_shadow(String, Int, Int, Int, @raylib.Color) -> Unit
pub fn draw_texture_box_opt(@raylib.Texture?, Int, Int, Int, Int, @raylib.Color) -> Bool
pub fn draw_texture_centered(@raylib.Texture, Float, Float, Float, Float, Float, @raylib.Color) -> Unit
pub fn draw_texture_centered_opt(@raylib.Texture?, Float, Float, Float, Float, Float, @raylib.Color) -> Bool
pub fn enemy_body_texture(Int) -> @raylib.Texture?
pub fn enemy_marker_texture() -> @raylib.Texture?
pub fn enemy_turret_texture(Int) -> @raylib.Texture?
pub fn explosion_frame(Int) -> @raylib.Texture?
pub fn fx_muzzle_texture() -> @raylib.Texture?
pub fn fx_smoke_texture() -> @raylib.Texture?
pub fn fx_spark_texture() -> @raylib.Texture?
pub fn fx_trace_texture() -> @raylib.Texture?
pub fn player_body_texture(Int) -> @raylib.Texture?
pub fn player_turret_texture(Int, Int) -> @raylib.Texture?
pub fn smoke_frame(Int) -> @raylib.Texture?
pub fn tile_texture(Int, Int, Int, Int) -> @raylib.Texture?
pub fn tracks_texture() -> @raylib.Texture?
pub fn ui_font() -> @raylib.Font?
pub fn ui_icon_arrow_down_texture() -> @raylib.Texture?
pub fn ui_icon_arrow_up_texture() -> @raylib.Texture?
pub fn ui_icon_play_texture() -> @raylib.Texture?
pub fn ui_menu_button_focus_texture() -> @raylib.Texture?
pub fn ui_menu_button_texture() -> @raylib.Texture?
pub fn ui_panel_card_texture() -> @raylib.Texture?
pub fn ui_panel_line_texture() -> @raylib.Texture?
```
</details>

### Package `tank_1990/score`

Scoring, combo tracking, and score grants.

```moonbit
pub fn bump_combo(@types.Game) -> Unit
pub fn combo_multiplier(@types.Game) -> Int
pub fn grant_score(@types.Game, Int, Int) -> Unit
pub fn update_combo(@types.Game, Float) -> Unit
```

### Package `tank_1990/types`

Core data structures, constants, enums, and utility functions shared across all packages.

**Key enums:**

| Enum | Variants |
|------|----------|
| `Team` | `None`, `Player1`, `Player2`, `Enemy` |
| `Dir` | `Up`, `Right`, `Down`, `Left` |
| `Tile` | `Empty`, `Brick`, `Steel`, `Water`, `Bush`, `Ice`, `Base` |
| `GameState` | `Menu`, `StageIntro`, `Playing`, `Paused`, `StageClear`, `GameOver`, `CampaignClear` |
| `EnemyKind` | `Basic`, `Fast`, `Heavy`, `Sniper` |
| `PowerupKind` | `Shield`, `Star`, `Grenade`, `Clock`, `Shovel`, `Tank` |

**Key structs:** `Game` (master state), `Tank` (player/enemy), `Bullet`, `Particle`, `Powerup`, `Star`, `StageProfile`.

<details>
<summary>140 exported values -- click to expand full list</summary>

```moonbit
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
```
</details>

### Package `tank_1990/world`

Spatial queries: bounds checking, line-of-sight, and tank-vs-world/tank collision.

```moonbit
pub fn point_in_world(Float, Float) -> Bool
pub fn sight_blocked(@types.Game, Float, Float, Float, Float) -> Bool
pub fn tank_hits_enemies(@types.Game, Float, Float, Int) -> Bool
pub fn tank_hits_players(@types.Game, Float, Float, Int) -> Bool
pub fn tank_hits_world(@types.Game, Float, Float) -> Bool
```

## Architecture

```
tank_1990/
  main.mbt                  -- window init, 60 fps game loop
  internal/
    types/                   -- Game struct, Tank, Bullet, Particle, enums, constants, math helpers
    game/                    -- game state machine, player input, enemy AI, bullet physics, power-ups, stage loading
    render/                  -- draw world tiles, tanks, bullets, particles, UI panels, asset loading
    levels/                  -- 96 stage tile patterns and per-stage difficulty profiles
    world/                   -- tile-grid collision, bounds checks, line-of-sight queries
    particles/               -- explosion / spark / smoke spawn and lifetime update
    score/                   -- score grants, combo multiplier tracking
```

**Data flow each frame:**

1. `main.mbt` calls `@game.update_game(game, dt)` to advance simulation.
2. `update_game` dispatches to the handler for the current `GameState` (menu, playing, paused, etc.).
3. During `Playing`, subsystems run in order: camera shake, combo decay, global effects (freeze/shovel timers), player input, enemy spawn, enemy AI, bullet physics, power-up collision, player respawn, particles.
4. `main.mbt` then calls `@render.draw_world(game)` and `@render.draw_ui(game)` to render the frame.

**Key patterns:**
- **Object pools** -- tanks, bullets, particles, and power-ups use fixed-size arrays with an `active` flag. No heap allocation during gameplay.
- **Sub-step collision** -- bullets advance in 2 sub-steps per frame for robust collision with narrow walls.
- **State machine** -- the `GameState` enum drives a simple top-level match that routes each frame to the right update logic.

## Improvement and Refinement Plan

- Add deterministic simulation tests for core update logic (fixed seeds and replayable frame steps).
- Introduce render profiling counters (draw calls, frame time buckets) and optimize heavy scenes.
- Split balancing constants into tunable config groups to reduce rebalance risk during gameplay tweaks.
- Move stage/mission definitions to data-driven descriptors for faster content iteration.
- Add sound effects and background music using raylib audio API.
- Implement a high-score persistence system (save/load to file).
- Add visual feedback for combo multiplier (floating score text, screen flash).
