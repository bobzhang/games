# Puzzle Dungeon 3D

A 3D isometric Sokoban-style puzzle game with 30 floors spread across 5 themed worlds: Stone Dungeon, Frozen Cavern, Magma Fortress, Verdant Garden, and The Void. Players push blocks onto pressure plates, collect diamonds and keys, navigate ice tiles, teleporters, conveyors, cracked floors, switches, laser beam puzzles, and rotating mirror platforms to reach the exit portal on each floor.

The core gameplay is turn-based grid movement on a 12x12 tile grid rendered in 3D with an orthographic camera. Each move advances the game state -- blocks pushed onto pits fill them, cracked floors collapse after being stepped on, switches toggle spikes and bridges, and conveyors move entities each turn. The laser system adds reflection puzzles where laser sources emit beams that bounce off four types of angled mirrors and must reach target tiles. A full undo system (200 moves deep) allows players to rewind mistakes, and a 3-star rating system based on par move counts encourages optimization.

The game features a complete campaign progression with world unlocking (complete 4 levels in a world to unlock the next), floor-select screen, 9 achievements, ambient particle effects tied to world themes (torches in dungeons, crystals in ice, magma pools in lava), smooth animation easing, and a rotatable 3D camera.

## Build and Run

```bash
moon build --target native raylib_puzzle_dungeon_3d/
./_build/native/debug/build/raylib_puzzle_dungeon_3d/raylib_puzzle_dungeon_3d.exe
```

## Controls

- **W/A/S/D or Arrow Keys**: Move player on the grid (turn-based)
- **Z / U**: Undo last move
- **R**: Restart current floor
- **Q**: Rotate camera 90 degrees clockwise
- **E**: Rotate camera 90 degrees counter-clockwise
- **Escape / P**: Pause game
- **M**: Return to main menu (from pause/level complete/game over)
- **L**: Go to floor select (from pause/level complete)
- **Enter / Space**: Confirm menu selection, advance to next floor

## How to Play

Move the player character on a 12x12 grid to solve each floor's puzzle. The exit portal opens when all objectives are met: pressure plates must have blocks on them, all diamonds must be collected, and all laser targets must be hit by reflected beams.

**Block mechanics**: Walk into a block to push it one tile. Two-block push chains are supported (pushing a block into another block pushes both if space allows). Blocks pushed onto pits fill them, creating walkable floor. Blocks on cracked floors cause both to collapse into pits. Blocks on ice slide until hitting an obstacle.

**Special tiles**:
- **Ice**: The player and blocks slide in the direction of movement until hitting something solid
- **Teleporters**: Stepping on portal A warps to portal B, and vice versa
- **Switches**: Toggle all spikes (on/off) and all bridges (raised/lowered) in the level
- **Conveyors**: Push entities one tile in their marked direction each turn
- **Cracked floors**: Collapse into pits after being stepped off
- **Mirrors**: Reflect laser beams at 90 degrees; four orientations (NE, NW, SE, SW)
- **Rotate platforms**: Stepping on one rotates all adjacent mirrors 90 degrees clockwise
- **Gates**: Open when all pressure plates are satisfied

**Scoring**: Each floor has a par move count. Completing at or below par earns 3 stars, within 15 moves above par earns 2 stars, otherwise 1 star. Total stars unlock later worlds.

## Public API Reference

### Package `raylib_puzzle_dungeon_3d`

> Main entry point.

No public types or functions beyond the `main` entry point, which initializes the window, creates a `Game` instance, and runs the game loop dispatching to `@game.update_game` and `@render.draw_world`/`@render.draw_ui`.

### Package `raylib_puzzle_dungeon_3d/internal/types`

> Core type definitions, constants, utility functions, and grid helpers.

#### Enums

| Enum | Variants | Description |
|------|----------|-------------|
| `Tile` | `TileEmpty`, `TileWall`, `TileFloor`, `TilePlate`, `TileSwitchOff`, `TileSwitchOn`, `TileExitClosed`, `TileExitOpen`, `TilePit`, `TileIce`, `TileTeleportA`, `TileTeleportB`, `TileCracked`, `TileSpikesOff`, `TileSpikesOn`, `TileConveyorUp/Right/Down/Left`, `TileBridgeOff`, `TileBridgeOn`, `TileGateClosed`, `TileGateOpen`, `TileMirrorNe/Nw/Se/Sw`, `TileLaserSourceRight/Down/Left/Up`, `TileLaserTarget`, `TileRotatePlatform` | All grid tile types (36 variants) |
| `EntityKind` | `EntityNone`, `EntityBlock`, `EntityDiamond`, `EntityKey`, `EntityBomb` | Types of entities that can exist on the grid |
| `Dir` | `DirNone`, `DirUp`, `DirRight`, `DirDown`, `DirLeft` | Cardinal directions |
| `GameState` | `StateMenu`, `StatePlaying`, `StatePaused`, `StateLevelComplete`, `StateGameOver`, `StateFloorSelect`, `StateCampaignComplete`, `StateWorldSelect`, `StateTutorial` | Game FSM states |
| `World` | `WorldDungeon`, `WorldIce`, `WorldLava`, `WorldGarden`, `WorldVoid` | Five themed worlds |
| `DecoKind` | `DecoTorch`, `DecoCrystal`, `DecoMagmaPool`, `DecoFlower`, `DecoFloatingRock`, `DecoPillar`, `DecoMushroom`, `DecoVine` | Decoration types for ambient visuals |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Entity` | `active`, `kind`, `gx`, `gy`, `anim_x`, `anim_y`, `anim_timer`, `falling`, `fall_timer`, `on_plate` | Grid entity (block, diamond, key) with position and animation state |
| `Particle` | `active`, `x`, `y`, `z`, `vx`, `vy`, `vz`, `life`, `max_life`, `r`, `g`, `b`, `size` | 3D particle with velocity, color, and lifetime |
| `LaserSegment` | `active`, `start_gx`, `start_gy`, `end_gx`, `end_gy`, `dir` | A segment of a laser beam path between two grid points |
| `Decoration` | `active`, `kind`, `x`, `y`, `z`, `scale`, `phase` | Ambient decoration placed near walls |
| `UndoState` | `player_gx`, `player_gy`, `tiles`, `entity_gx/gy/active/kind`, `moves`, `keys_held`, `diamonds_collected` | Snapshot of full game state for undo |
| `FloorInfo` | `unlocked`, `completed`, `best_moves`, `stars` | Completion tracking per floor |
| `AchievementInfo` | `unlocked`, `show_timer` | Achievement unlock state |
| `Game` | `state`, `player_gx/gy`, `tiles`, `entities`, `current_floor`, `current_world`, `moves`, `keys_held`, `diamonds_collected`, `laser_segments`, `decorations`, `undo_stack`, `particles`, `floor_info`, `achievements`, `camera_angle`, ... | Main game state container with all subsystems |

#### Constructor Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `Entity::inactive` | `() -> Entity` | Creates an inactive entity |
| `Entity::new_block` | `(Int, Int) -> Entity` | Creates a block entity at grid position |
| `Entity::new_diamond` | `(Int, Int) -> Entity` | Creates a diamond entity at grid position |
| `Entity::new_key` | `(Int, Int) -> Entity` | Creates a key entity at grid position |
| `Particle::inactive` | `() -> Particle` | Creates an inactive particle |
| `LaserSegment::inactive` | `() -> LaserSegment` | Creates an inactive laser segment |
| `Decoration::inactive` | `() -> Decoration` | Creates an inactive decoration |
| `UndoState::empty` | `() -> UndoState` | Creates an empty undo state with pre-allocated arrays |
| `FloorInfo::new` | `() -> FloorInfo` | Creates a new floor info (locked, uncompleted) |
| `AchievementInfo::new` | `() -> AchievementInfo` | Creates a new achievement info (locked) |
| `Game::new` | `() -> Game` | Creates a fully initialized game with all pools allocated |

#### Math Utility Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `absf` | `(Float) -> Float` | Absolute value of a float |
| `absi` | `(Int) -> Int` | Absolute value of an integer |
| `clampf` | `(Float, Float, Float) -> Float` | Clamp float between bounds |
| `clampi` | `(Int, Int, Int) -> Int` | Clamp integer between bounds |
| `mini` / `maxi` | `(Int, Int) -> Int` | Min/max of two integers |
| `minf` / `maxf` | `(Float, Float) -> Float` | Min/max of two floats |
| `lerpf` | `(Float, Float, Float) -> Float` | Linear interpolation |
| `smooth_step` | `(Float) -> Float` | Smooth step easing (3t^2 - 2t^3) |
| `ease_out_bounce` | `(Float) -> Float` | Bounce easing function |
| `ease_out_cubic` | `(Float) -> Float` | Cubic ease-out |
| `ease_in_out_quad` | `(Float) -> Float` | Quadratic ease-in-out |

#### Direction Helpers

| Function | Signature | Description |
|----------|-----------|-------------|
| `dir_dx` / `dir_dy` | `(Dir) -> Int` | Get x/y delta for a direction |
| `opposite_dir` | `(Dir) -> Dir` | Returns the opposite direction |
| `rotate_dir_cw` | `(Dir) -> Dir` | Rotates a direction 90 degrees clockwise |

#### Grid Helpers

| Function | Signature | Description |
|----------|-----------|-------------|
| `in_bounds` | `(Int, Int) -> Bool` | Tests if grid coordinates are within 12x12 bounds |
| `tile_index` | `(Int, Int) -> Int` | Converts grid coords to flat array index |
| `get_tile` / `set_tile` | `(Game, Int, Int) -> Tile` / `(Game, Int, Int, Tile) -> Unit` | Grid tile access |
| `is_walkable` | `(Tile) -> Bool` | Tests if a tile can be walked on |
| `is_pushable_onto` | `(Tile) -> Bool` | Tests if a block can be pushed onto a tile |
| `is_solid_tile` | `(Tile) -> Bool` | Tests if a tile blocks movement |
| `is_conveyor` | `(Tile) -> Bool` | Tests if a tile is a conveyor belt |
| `conveyor_direction` | `(Tile) -> Dir` | Returns the direction of a conveyor tile |
| `is_mirror` / `is_laser_source` | `(Tile) -> Bool` | Tests for mirror/laser source tiles |
| `laser_source_direction` | `(Tile) -> Dir` | Returns the emission direction of a laser source |
| `mirror_reflect` | `(Tile, Dir) -> Dir` | Computes reflected direction off a mirror tile |

#### Entity and Particle Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `entity_at` | `(Game, Int, Int) -> Int` | Finds entity index at grid position (-1 if none) |
| `alloc_entity` | `(Game) -> Int` | Finds first inactive entity slot |
| `alloc_particle` | `(Game) -> Int` | Finds first inactive particle slot |
| `spawn_particles` | `(Game, Float, Float, Float, Int, Int, Int, Int) -> Unit` | Spawns burst particles at world position |
| `spawn_ambient_particles` | `(Game, Float, Float, Float, Int, Int, Int, Int, Float, Float) -> Unit` | Spawns smaller ambient particles |

#### Game Logic Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `count_active_plates` | `(Game) -> Int` | Counts plates with blocks on them |
| `count_plates` | `(Game) -> Int` | Counts total plate tiles |
| `count_diamonds` | `(Game) -> Int` | Counts remaining diamond entities |
| `count_laser_targets` | `(Game) -> Int` | Counts laser target tiles |
| `calculate_laser_paths` | `(Game) -> Unit` | Traces all laser beams from sources through mirrors |
| `resolve_conveyors` | `(Game) -> Unit` | Moves all entities on conveyors one step |
| `ice_slide_entity` | `(Game, Int, Dir) -> Unit` | Slides an entity on ice until stopped |
| `update_gates` | `(Game) -> Unit` | Opens/closes gates based on plate satisfaction |
| `toggle_bridges` | `(Game) -> Unit` | Toggles all bridge tiles between on/off |
| `setup_decorations` | `(Game) -> Unit` | Places random decorations near walls |
| `count_total_stars` | `(Game) -> Int` | Sums stars across all floors |
| `is_world_unlocked` | `(Game, Int) -> Bool` | Checks if a world is accessible |
| `stars_to_unlock_world` | `(Int) -> Int` | Returns star threshold for a world |
| `get_world_for_floor` | `(Int) -> World` | Maps floor number to world |
| `get_tutorial_for_floor` | `(Int) -> String` | Returns tutorial text for a floor |

#### World Theme Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `int_to_world` / `world_to_int` | `(Int) -> World` / `(World) -> Int` | Convert between World enum and integer |
| `get_world_floor_color` | `(World) -> (Int, Int, Int)` | Floor color RGB for a world theme |
| `get_world_wall_color` | `(World) -> (Int, Int, Int)` | Wall color RGB for a world theme |
| `get_world_accent_color` | `(World) -> (Int, Int, Int)` | Accent color RGB for a world theme |
| `get_world_bg_color` | `(World) -> (Int, Int, Int)` | Background color RGB for a world theme |
| `get_world_name` | `(World) -> String` | Human-readable world name |

### Package `raylib_puzzle_dungeon_3d/internal/game`

> Game logic, state machine updates, player movement, stage loading, and undo system.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `update_game` | `(Game, Float) -> Unit` | Main update dispatcher -- routes to state-specific handlers, updates particles/transitions/messages |
| `load_floor` | `(Game, Int) -> Unit` | Loads a floor from level data, parses tile characters, places entities, sets up decorations and lasers |

### Package `raylib_puzzle_dungeon_3d/internal/levels`

> Level data storage for all 30 floors.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `get_floor_data` | `(Int) -> Array[String]` | Returns the tile map string array for a floor (12 rows of characters) |
| `get_par_moves` | `(Int) -> Int` | Returns the par (optimal) move count for a floor |

### Package `raylib_puzzle_dungeon_3d/internal/render`

> 3D world rendering and 2D UI overlay.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_world` | `(Game) -> Unit` | Sets up 3D camera and draws all floor tiles, entities, player, decorations, laser beams, particles, and shadows |
| `draw_ui` | `(Game) -> Unit` | Draws the 2D overlay -- dispatches to menu, HUD, pause, level complete, floor select, world select, or campaign complete screens |

## Architecture

### Package Structure

```
raylib_puzzle_dungeon_3d/
├── main.mbt                    — Entry point: window init, game loop
├── moon.pkg                    — Package config with imports
└── internal/
    ├── types/
    │   ├── types.mbt           — Enums, structs, constructors (Tile, Entity, Game, etc.)
    │   ├── constants.mbt       — All game constants (screen, grid, animation, scoring, colors, tutorials, achievements)
    │   └── utils.mbt           — Math utilities, direction helpers, grid helpers, laser path calculation, conveyor/ice/gate logic
    ├── game/
    │   ├── game_update.mbt     — FSM update dispatcher, menu/pause/level-complete handlers
    │   ├── player_system.mbt   — Player movement, push chains, tile effects, ice sliding, mirror rotation
    │   ├── stage.mbt           — Floor loading, tile parsing, undo save/restore, progress reset
    │   └── particles.mbt       — Particle system update with gravity, drag, floor collision
    ├── levels/
    │   └── levels.mbt          — Level data for 30 floors as string arrays, par move counts
    └── render/
        ├── render_world.mbt    — 3D rendering: camera, floor tiles, entities, player, decorations, lasers, shadows
        └── render_ui.mbt       — 2D overlay: menu, HUD, pause, floor select, world select, level complete, achievements
```

### Data Flow

1. **Initialization**: `main` creates a `Game` via `Game::new()`, which pre-allocates all entity (64), particle (512), undo (200), laser segment (32), and decoration (48) pools.
2. **State Machine**: `update_game` dispatches to state-specific handlers (`update_menu`, `update_playing`, `update_paused`, etc.). Menu input sets `game.state` to transition between screens.
3. **Turn-based Movement**: In `update_playing`, when the player presses a direction key and is not already moving, `try_move_player` handles the turn -- saves undo, moves player, pushes blocks (with 2-block chain support), processes tile effects (teleport, switch, ice slide, conveyor, cracked floor, mirror rotation), then calls `after_move` to update plates, gates, conveyors, lasers, and exit state.
4. **Level Loading**: `load_floor` parses character-based level data from `@levels.get_floor_data`, maps each character to a (Tile, EntityKind, is_player) tuple, counts objectives, sets up decorations, and calculates initial laser paths.
5. **Rendering**: `draw_world` builds a 3D camera from the player-following target and camera angle, then draws tiles, entities, player, decorations, lasers, particles, and shadows in 3D space. `draw_ui` overlays 2D elements on top.

### Key Design Patterns

- **ECS-like separation**: Types, game logic, levels, and rendering are cleanly separated into internal packages with well-defined public APIs.
- **Full state undo system**: `UndoState` captures the complete grid and entity state using `FixedArray` copies, supporting 200 levels of undo. The undo stack shifts when full to maintain a rolling window.
- **Turn-based with animation**: Movement is discrete (grid-based) but rendered with smooth interpolation using `smooth_step` easing, creating fluid visuals over grid-snapped logic.
- **Character-based level format**: Levels are defined as arrays of strings with single-character tile codes, making them human-readable and easy to edit.
- **World theming system**: Each world has its own floor, wall, accent, and background colors looked up via `get_world_*_color` functions, plus world-specific decoration types.
- **Laser reflection system**: `calculate_laser_paths` traces beams from sources through mirrors with up to 10 bounces, recording segments for rendering and counting target hits for exit conditions.

## Improvement & Refinement Plan

1. **Add bomb entity functionality**: `EntityBomb` is defined in `EntityKind` but never used in `parse_tile_char` or any game logic. Implementing bombs that can destroy walls or blocks within a radius when pushed onto spikes or triggered by lasers would add a new puzzle dimension.

2. **Implement the Tutorial state**: `StateTutorial` exists in `GameState` but `update_game` never dispatches to it. Currently tutorials are handled via `tutorial_active` flag inside `StatePlaying`. A dedicated tutorial state with step-by-step guided prompts would improve onboarding.

3. **Add remaining decoration types**: `DecoPillar`, `DecoMushroom`, and `DecoVine` are defined in `DecoKind` but `setup_decorations` only places `DecoTorch`, `DecoCrystal`, `DecoMagmaPool`, `DecoFlower`, and `DecoFloatingRock`. Adding the remaining types (especially `DecoVine` for Garden world) would enrich visual variety.

4. **Improve push chain limit**: The current implementation supports exactly 2-block push chains. Generalizing this to N-block chains (or explicitly communicating the 2-block limit to the player) would make the push mechanics more predictable and potentially enable more complex puzzles.

5. **Add speed run achievement tracking**: `achievement_speed_run` (index 7) is defined but never checked in `check_achievements`. Adding a timer-based check (e.g., completing a floor in under 30 seconds) would leverage the existing `level_timer` field.

6. **Optimize undo state memory**: Each `UndoState` stores a full copy of all 144 tiles and all 64 entity states. With 200 undo slots, this uses significant memory. A delta-based undo system that only records changed tiles and entities would be more efficient.

7. **Add keyboard shortcuts for floor select**: The floor select screen uses only arrow keys and Enter. Adding number keys for quick-jumping to specific floors or worlds would improve navigation for experienced players.
