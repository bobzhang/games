# Voxel World 3D

A first-person Minecraft-inspired voxel sandbox game built with MoonBit and raylib. The player explores a procedurally generated 128x64x128 block world spanning 6 distinct biomes, mining blocks, crafting items, fighting mobs, and surviving a full day/night cycle. The world is divided into an 8x8 grid of 16x64x16 chunks, each generated with multi-octave noise for terrain, caves, and ore distribution.

The core gameplay loop centers on exploration and survival. The player starts at the world center on the surface and must gather resources by mining blocks (hold left-click), place blocks to build (right-click), manage a 36-slot inventory, and craft items from 16 recipes. Health depletes from hostile mob attacks, fall damage, cactus contact, drowning, and starvation. Hunger drains over time (faster when sprinting) and must be replenished by killing passive animals. A 120-second day/night cycle governs sky color, lighting, and mob spawning: passive animals (pigs, cows, chickens) spawn during the day, while hostile mobs (zombies, skeletons, spiders) spawn at night with increased aggression range.

The procedural world generation uses fractal noise functions to create terrain height maps, biome determination via temperature and moisture noise, and 3D cave noise for underground cavern systems. Each biome (Plains, Forest, Desert, Mountains, Tundra, Swamp) has distinct surface blocks, tree density, vegetation, and mob spawn weights. The game features 24 block types including ores (iron, gold, diamond) distributed by depth, decorative blocks (flowers, tall grass, torches), transparent blocks (water, glass, leaves), and gravity-affected blocks (sand, gravel). The rendering system uses chunk-based culling, face visibility checks, distance fog, height-based shading, torch glow effects, and per-entity 3D models with walking animations.

## Build and Run

```bash
moon build --target native voxel_world_3d/
./_build/native/debug/build/voxel_world_3d/voxel_world_3d.exe
```

## Controls

- **W / A / S / D**: Move forward / left / backward / right
- **Mouse movement**: Look around (yaw and pitch, pitch clamped to +/-1.4 radians)
- **Space**: Jump (on ground) / Swim up (underwater)
- **Left Shift**: Sprint (requires hunger > 2, drains hunger faster)
- **Left Mouse Button (hold)**: Mine targeted block (progress bar shown below crosshair)
- **F**: Alternative mine key
- **Right Mouse Button**: Place block from selected hotbar slot at targeted face
- **G**: Alternative place key
- **1-9**: Select hotbar slot directly
- **Mouse Scroll Wheel**: Cycle through hotbar slots
- **E**: Open/close inventory screen
- **C**: Open/close crafting screen
- **W / S or Up / Down** (in crafting): Navigate recipe list
- **Enter / Space** (in crafting): Craft selected recipe
- **T**: Cycle equipped tool forward
- **R**: Cycle equipped tool backward
- **Escape**: Pause game (from playing) / Resume (from pause) / Close inventory/crafting
- **P**: Resume from pause
- **Q**: Quit to main menu (from pause or game over)
- **F3**: Toggle debug information overlay
- **Enter / Space** (game over): Respawn at world center
- **Enter / Space** (main menu): Start new game

## How to Play

The game begins on a title screen showing features and controls. Press Enter/Space to generate the world and start playing. The cursor is captured for first-person mouse look.

**Exploration**: Move with WASD through a procedurally generated world with 6 biomes. Biome type is shown in the top-right corner with a colored indicator. A compass at the top center shows cardinal directions relative to your facing. The F3 key toggles a debug overlay showing position, chunk, facing direction, biome, velocity, grounded state, equipped tool, targeted block, entity count, stats, and time of day.

**Mining**: Target a block by looking at it (white wireframe highlight appears, with a face highlight on the targeted side). Hold left-click or F to mine. Mining progress is shown as a bar below the crosshair. Mining time depends on block hardness and equipped tool: the correct tool class (pickaxe for stone/ores, axe for wood/planks/leaves, shovel for dirt/sand/gravel/snow/clay) mines faster, and higher tool tiers (wood < stone < iron) further reduce time. Bedrock cannot be mined. Some ores require minimum tool tiers: iron ore needs stone pickaxe or better, gold and diamond ore need iron pickaxe.

**Placing**: Right-click or G to place the block from the currently selected hotbar slot on the targeted block face. Cannot place inside the player's collision volume. The placed block is consumed from inventory.

**Inventory**: Press E to open the inventory screen showing a 9x4 grid (36 slots). The top row is the hotbar. Select slots with 1-9 keys. Items stack up to 64 per slot. Close with E or Escape.

**Crafting**: Press C to open the crafting screen showing all 16 recipes. Navigate with W/S, craft with Enter/Space. Recipes include Wood to Planks (1:4), Cobblestone to Brick (4:1), Sand to Glass (4:1), Clay to Bricks (4:2), Planks+Wood to Torches (1+1:4), and many more. Craftable recipes are shown in green, unavailable ones in red.

**Combat**: Left-click targets entities within reach distance using a dot-product aiming test. Weapon damage depends on the equipped tool: hand deals 1, wooden sword 4, stone sword 5, iron sword 7, axes deal 3-5. Hitting an entity applies knockback and triggers AI response (hostile mobs chase, passive mobs flee). Hostile mobs deal damage on contact: zombies deal 3, skeletons 2, spiders 2, with knockback on the player. A 0.4-second attack cooldown prevents spam-clicking.

**Survival**: Health (20 max) regenerates slowly when hunger is above 16. Hunger (20 max) drains over time at 0.005/sec (0.015 when sprinting). At hunger 0, the player takes 1 damage every 4 seconds. Fall damage triggers above 3.5 blocks of fall distance, dealing (distance - 3.5) * 2 damage. Underwater, air (10 max) depletes by 1 per second; at 0 air, the player takes 2 damage per second. Cactus blocks deal 1 damage every 30 frames on contact. After death, the player can respawn at the world center with full health/hunger and a 3-second invulnerability period.

**Day/Night Cycle**: A full cycle takes 120 seconds. The sky transitions through dawn (dark blue to orange), morning (orange to bright blue), daytime (bright blue), dusk (blue to orange to dark), and night (dark blue). Night is defined as time > 60% or < 10% of the cycle. During night, blocks without nearby torches are significantly dimmed. Torches provide warm light in a 5-block Manhattan distance radius and have visible glow sphere effects.

**Block Physics**: Sand and gravel are gravity-affected blocks that fall one step per 0.2 seconds when the block below is not solid. Physics are checked within a 16-block radius of the player.

## Public API Reference

### Package `voxel_world_3d`

> Main entry point.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `main` | `() -> Unit` | Entry point: creates MSAA-enabled window, instantiates Game, runs update/render loop at 60 FPS |

### Package `voxel_world_3d/internal/types`

> Core type definitions, constants, noise functions, and world utilities.

#### Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `screen_width` | `Int` | `1280` | Screen width |
| `screen_height` | `Int` | `720` | Screen height |
| `chunk_x` | `Int` | `16` | Chunk width in blocks |
| `chunk_y` | `Int` | `64` | Chunk height in blocks |
| `chunk_z` | `Int` | `16` | Chunk depth in blocks |
| `world_chunks_x` | `Int` | `8` | World width in chunks |
| `world_chunks_z` | `Int` | `8` | World depth in chunks |
| `render_distance` | `Int` | `3` | Chunk render distance |
| `water_level` | `Int` | `18` | Sea level height |
| `block_air..block_clay` | `Int` | `0..23` | 24 block type constants |
| `block_count` | `Int` | `24` | Total block types |
| `biome_plains..biome_swamp` | `Int` | `0..5` | 6 biome type constants |
| `biome_count` | `Int` | `6` | Total biome types |
| `tool_hand..tool_iron_sword` | `Int` | `0..12` | 13 tool type constants |
| `tool_count` | `Int` | `13` | Total tool types |
| `entity_pig..entity_spider` | `Int` | `1..6` | 6 entity type constants |
| `entity_max` | `Int` | `32` | Maximum concurrent entities |
| `ai_idle..ai_attack` | `Int` | `0..4` | 5 AI state constants |
| `state_menu..state_game_over` | `Int` | `0..5` | 6 game state constants |
| `inventory_slots` | `Int` | `36` | Total inventory slots |
| `inventory_cols` | `Int` | `9` | Inventory grid columns |
| `inventory_rows` | `Int` | `4` | Inventory grid rows |
| `hotbar_slots` | `Int` | `9` | Hotbar slot count |
| `max_stack_size` | `Int` | `64` | Maximum item stack size |
| `player_speed` | `Float` | `5.0` | Base movement speed |
| `player_sprint_mult` | `Float` | `1.6` | Sprint speed multiplier |
| `player_jump_force` | `Float` | `7.5` | Jump velocity |
| `player_height` | `Float` | `1.7` | Player collision height |
| `player_eye_height` | `Float` | `1.5` | Camera eye offset from feet |
| `player_radius` | `Float` | `0.3` | Player collision radius |
| `player_mouse_sensitivity` | `Float` | `0.003` | Mouse look sensitivity |
| `player_max_health` | `Int` | `20` | Maximum health points |
| `player_max_hunger` | `Int` | `20` | Maximum hunger points |
| `player_max_air` | `Int` | `10` | Maximum air (breath) |
| `gravity` | `Float` | `18.0` | Gravity acceleration |
| `terminal_velocity` | `Float` | `30.0` | Maximum fall speed |
| `day_length` | `Float` | `120.0` | Full day/night cycle duration in seconds |
| `reach_distance` | `Float` | `5.5` | Block targeting range |
| `ray_step` | `Float` | `0.05` | Raycasting step size |
| `particle_max` | `Int` | `64` | Maximum concurrent particles |
| `particle_gravity` | `Float` | `10.0` | Particle fall acceleration |
| `camera_fovy` | `Float` | `65.0` | Camera field of view |
| `fog_start_distance` | `Float` | `30.0` | Fog fade start distance |
| `fog_end_distance` | `Float` | `55.0` | Fog fade end distance |
| `fall_damage_threshold` | `Float` | `3.5` | Minimum fall distance for damage |
| `fall_damage_multiplier` | `Float` | `2.0` | Damage per excess fall block |
| `hunger_drain_rate` | `Float` | `0.005` | Base hunger drain per second |
| `hunger_sprint_drain` | `Float` | `0.015` | Sprint hunger drain per second |
| `hunger_heal_threshold` | `Int` | `16` | Minimum hunger for health regen |
| `hunger_starve_threshold` | `Int` | `0` | Hunger level that triggers starvation |
| `starve_damage_interval` | `Float` | `4.0` | Seconds between starvation damage |
| `respawn_invulnerability` | `Float` | `3.0` | Invulnerability after respawn |
| `entity_speed_passive` | `Float` | `2.0` | Passive mob movement speed |
| `entity_speed_hostile` | `Float` | `3.5` | Hostile mob movement speed |
| `entity_spawn_radius` | `Float` | `30.0` | Mob spawn distance from player |
| `entity_despawn_radius` | `Float` | `50.0` | Mob despawn distance from player |
| `entity_attack_range` | `Float` | `1.8` | Hostile mob attack distance |
| `zombie_damage` | `Int` | `3` | Zombie attack damage |
| `skeleton_damage` | `Int` | `2` | Skeleton attack damage |
| `spider_damage` | `Int` | `2` | Spider attack damage |
| `torch_light_level` | `Int` | `14` | Torch light intensity |
| `gravity_block_interval` | `Float` | `0.2` | Sand/gravel fall check interval |
| `dawn_end..late_dusk_end` | `Float` | various | Day phase thresholds (0..1 range) |
| `pi`, `two_pi` | `Float` | `3.14159..` | Math constants |

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Chunk` | `blocks: FixedArray[Int]` | 16x64x16 voxel grid; stores block types in a flat array indexed as `(y * chunk_z + z) * chunk_x + x` |
| `ItemSlot` | `item_id`, `count` | Single inventory slot with block type and stack count |
| `Inventory` | `slots: Array[ItemSlot]`, `selected` | 36-slot inventory with hotbar selection and `add_item` method |
| `Player` | `x/y/z`, `vx/vy/vz`, `yaw/pitch`, `health`, `hunger`, `air`, `mining_*`, `equipped_tool`, `inventory`, `sprint`, `on_ground`, `underwater`, ... | Full player state: position, physics, look direction, survival stats, mining state, tool, movement flags |
| `BlockHit` | `hit`, `bx/by/bz`, `nx/ny/nz`, `distance` | Raycasting result: targeted block position, face normal, and distance |
| `Entity` | `active`, `kind`, `x/y/z`, `vx/vy/vz`, `health`, `ai_state`, `target_x/z`, `yaw`, `on_ground`, `damage_flash`, `anim_timer`, `attack_cooldown` | Mob entity with position, physics, AI state machine, health, and animation |
| `Particle` | `active`, `x/y/z`, `vx/vy/vz`, `color_r/g/b`, `size`, `lifetime`, `max_lifetime` | Visual particle with physics and fade-out |
| `CraftingRecipe` | `input1_id/count`, `input2_id/count`, `output_id/count`, `name` | Crafting recipe with up to 2 inputs and 1 output |
| `BiomeParams` | `id`, `name`, `height_base/amplitude`, `tree_density`, `surface/sub_surface_block`, `has_snow`, `has_cactus`, `water_color_r/g/b` | Biome terrain generation parameters |
| `Game` | `chunks`, `player`, `target`, `entities`, `particles`, `state`, `day_timer`, `day_count`, `sky_r/g/b`, `sun_angle`, `is_night`, `cam_pos_*`, `cam_target_*`, `blocks_broken/placed`, `mobs_killed`, `distance_walked`, `crafting_selection`, `show_debug`, ... | Main game state container |

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `Chunk::new` | `() -> Chunk` | Creates a chunk with all blocks set to air |
| `Chunk::get_block` | `(Chunk, Int, Int, Int) -> Int` | Gets block type at local (x, y, z) |
| `Chunk::set_block` | `(Chunk, Int, Int, Int, Int) -> Unit` | Sets block type at local (x, y, z) |
| `ItemSlot::new` | `(Int, Int) -> ItemSlot` | Creates an inventory slot with item ID and count |
| `Inventory::new` | `() -> Inventory` | Creates a 36-slot empty inventory |
| `Inventory::add_item` | `(Inventory, Int, Int) -> Int` | Adds items to inventory, stacking with existing; returns leftover count |
| `Player::new` | `() -> Player` | Creates a player with default stats and empty inventory |
| `BlockHit::new` | `() -> BlockHit` | Creates an empty block hit result |
| `Entity::new` | `() -> Entity` | Creates an inactive entity |
| `Particle::new` | `() -> Particle` | Creates an inactive particle |
| `CraftingRecipe::new` | `(Int, Int, Int, Int, Int, Int, String) -> CraftingRecipe` | Creates a crafting recipe (input1_id, input1_count, input2_id, input2_count, output_id, output_count, name) |
| `BiomeParams::new` | `() -> BiomeParams` | Creates default biome parameters (plains) |
| `Game::new` | `() -> Game` | Creates a new game: allocates 64 chunks and generates terrain for all of them |
| `mini` | `(Int, Int) -> Int` | Returns minimum of two integers |
| `maxi` | `(Int, Int) -> Int` | Returns maximum of two integers |
| `clampi` | `(Int, Int, Int) -> Int` | Clamps integer to [min, max] |
| `clampf` | `(Float, Float, Float) -> Float` | Clamps float to [min, max] |
| `absf` | `(Float) -> Float` | Absolute value of float |
| `floorf` | `(Float) -> Int` | Floor of float as integer |
| `lerpi` | `(Int, Int, Float) -> Int` | Linear interpolation between two integers |
| `noise2d` | `(Float, Float) -> Float` | Simple hash-based 2D noise |
| `value_noise_2d` | `(Float, Float) -> Float` | Smooth 2D value noise with interpolation |
| `fractal_noise_2d` | `(Float, Float, Int, Float) -> Float` | Multi-octave fractal 2D noise |
| `noise3d` | `(Float, Float, Float) -> Float` | Simple hash-based 3D noise |
| `cave_noise_3d` | `(Float, Float, Float) -> Float` | 3D noise tuned for cave generation |
| `terrain_noise` | `(Float, Float) -> Float` | Multi-scale terrain height noise |
| `biome_noise` | `(Float, Float) -> Float` | Low-frequency biome boundary noise |
| `temperature_noise` | `(Float, Float) -> Float` | Temperature noise for biome determination |
| `moisture_noise` | `(Float, Float) -> Float` | Moisture noise for biome determination |
| `get_biome_at` | `(Int, Int) -> Int` | Determines biome type from temperature/moisture noise |
| `terrain_height_at` | `(Int, Int) -> Int` | Computes terrain height from biome params and noise |
| `generate_terrain_chunk` | `(Chunk, Int, Int) -> Unit` | Generates a full chunk: terrain, caves, ores, trees, vegetation |
| `get_world_block` | `(Game, Int, Int, Int) -> Int` | Gets block at world coordinates (with bounds checking) |
| `set_world_block` | `(Game, Int, Int, Int, Int) -> Unit` | Sets block at world coordinates (with bounds checking) |
| `is_solid` | `(Int) -> Bool` | Tests if a block type is solid (not air, water, or decoration) |
| `is_transparent` | `(Int) -> Bool` | Tests if a block type is transparent (air, water, glass, leaves, decorations) |
| `is_decoration` | `(Int) -> Bool` | Tests if a block type is a decoration (flowers, tall grass, torch, cactus) |
| `is_gravity_block` | `(Int) -> Bool` | Tests if a block is affected by gravity (sand, gravel) |
| `is_face_visible` | `(Game, Int, Int, Int) -> Bool` | Tests if adjacent block is transparent (face should be rendered) |
| `is_hostile` | `(Int) -> Bool` | Tests if an entity kind is hostile |
| `block_name` | `(Int) -> String` | Returns display name for a block type |
| `tool_name` | `(Int) -> String` | Returns display name for a tool type |
| `entity_name` | `(Int) -> String` | Returns display name for an entity kind |
| `biome_name` | `(Int) -> String` | Returns display name for a biome type |
| `facing_direction` | `(Float) -> String` | Converts yaw angle to cardinal direction string |
| `get_mining_time` | `(Int, Int) -> Float` | Calculates mining time for a block with a given tool |
| `get_block_drop` | `(Int) -> Int` | Returns the item dropped when a block is mined |
| `get_entity_max_health` | `(Int) -> Int` | Returns max health for an entity kind |
| `rand_next` | `(Game) -> Int` | LCG pseudo-random number generator |
| `rand_float` | `(Game) -> Float` | Returns random float in [0, 1) |
| `spawn_particle` | `(Game, Float, Float, Float, Float, Float, Float, Int, Int, Int, Float, Float) -> Unit` | Spawns a particle with position, velocity, color, size, lifetime |
| `spawn_break_particles` | `(Game, Int, Int, Int, Int, Int, Int) -> Unit` | Spawns block-break particles at a grid position |
| `show_message` | `(Game, String, Float) -> Unit` | Shows a HUD message for a duration |
| `distance_xz` | `(Float, Float, Float, Float) -> Float` | Horizontal distance between two points |
| `distance3d` | `(Float, Float, Float, Float, Float, Float) -> Float` | 3D Euclidean distance |

### Package `voxel_world_3d/internal/game`

> Game logic: player movement, block interaction, combat, entity AI, crafting, world simulation.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `update_game` | `(Game, Float) -> Unit` | Main update dispatcher: routes to menu/playing/paused/inventory/crafting/game_over handlers |
| `update_player` | `(Game, Float) -> Unit` | Player movement, physics, collision detection, sprint, jump, swim, cactus damage |
| `update_camera_fps` | `(Game) -> Unit` | Updates first-person camera position and look target with head bob and sway |
| `update_block_target` | `(Game) -> Unit` | DDA ray march from camera to find the targeted block and hit face normal |
| `handle_block_interaction` | `(Game, Float) -> Unit` | Mining (hold LMB: progress accumulates, block breaks at 100%) and placing (RMB: consumes from inventory) |
| `handle_block_selection` | `(Game) -> Unit` | Hotbar slot selection via number keys 1-9 and mouse wheel cycling |
| `damage_player` | `(Game, Int) -> Unit` | Deals damage to player (respects invulnerability timer, triggers game over at 0 HP) |
| `update_day_night` | `(Game, Float) -> Unit` | Day/night cycle: advances timer, updates sky color through 6 phases, sets is_night flag |
| `update_message` | `(Game, Float) -> Unit` | Decrements HUD message timer |
| `update_entity_spawning` | `(Game, Float) -> Unit` | Periodically spawns entities near the player based on biome and time of day |
| `update_entities` | `(Game, Float) -> Unit` | Updates all active entities: AI state machine, physics, despawn at range |
| `get_tool_max_durability` | `(Int) -> Int` | Returns max durability for a tool tier (60/132/250 for wood/stone/iron) |
| `get_tool_tier` | `(Int) -> Int` | Returns tool tier (0=hand, 1=wood, 2=stone, 3=iron) |
| `is_pickaxe` | `(Int) -> Bool` | Tests if a tool is a pickaxe type |
| `is_axe` | `(Int) -> Bool` | Tests if a tool is an axe type |
| `is_shovel` | `(Int) -> Bool` | Tests if a tool is a shovel type |
| `is_sword` | `(Int) -> Bool` | Tests if a tool is a sword type |
| `get_best_tool_class_for_block` | `(Int) -> Int` | Returns the ideal tool class for a block (0=any, 1=pickaxe, 2=axe, 3=shovel) |
| `is_correct_tool_for_block` | `(Int, Int) -> Bool` | Tests if the given tool matches the block's preferred tool class |
| `get_tool_effectiveness` | `(Int, Int) -> Float` | Returns mining speed multiplier (0.15-1.0) based on tool match and tier |
| `count_item_in_inventory` | `(Game, Int) -> Int` | Counts total amount of an item across all inventory slots |
| `can_craft_recipe` | `(Game, CraftingRecipe) -> Bool` | Tests if player has materials for a recipe |
| `remove_item_from_inventory` | `(Game, Int, Int) -> Bool` | Removes items from inventory across multiple slots |
| `execute_craft` | `(Game, CraftingRecipe) -> Bool` | Consumes recipe inputs and produces outputs |
| `cycle_tool_forward` | `(Game) -> Unit` | Cycles to next equipped tool with message |
| `cycle_tool_backward` | `(Game) -> Unit` | Cycles to previous equipped tool with message |
| `handle_tool_input` | `(Game) -> Unit` | Handles T/R keys for tool cycling |
| `get_smelting_result` | `(Int) -> Int` | Returns smelting output for an input block (0 if not smeltable) |
| `get_smelting_time` | `(Int) -> Float` | Returns smelting duration in seconds |
| `is_smeltable` | `(Int) -> Bool` | Tests if a block can be smelted |
| `find_first_craftable` | `(Game) -> Int` | Finds index of first craftable recipe (-1 if none) |
| `count_craftable_recipes` | `(Game) -> Int` | Counts recipes currently craftable |
| `can_mine_with_tool` | `(Int, Int) -> Bool` | Tests tool tier requirement for mining specific ores |
| `get_bonus_drop_chance` | `(Int, Int) -> Float` | Returns bonus drop probability for correct high-tier tools |
| `check_workbench_interaction` | `(Game) -> Bool` | Tests if player is targeting a planks block (acts as workbench) |
| `get_recipe_category` | `(CraftingRecipe) -> Int` | Returns recipe category (0=blocks, 1=tools, 2=materials, 3=decorations) |
| `recipe_category_name` | `(Int) -> String` | Returns category display name |
| `pick_wander_target` | `(Game, Entity) -> Unit` | Sets a random wander target within 12 blocks |
| `calculate_flee_target` | `(Game, Entity) -> Unit` | Sets flee target 15 blocks away from player |
| `pathfind_toward_target` | `(Game, Entity, Float, Float) -> Unit` | Moves entity toward target with wall avoidance and jump attempts |
| `get_mob_drop_id` | `(Int) -> Int` | Returns item ID dropped by a mob kind |
| `get_mob_drop_count` | `(Int) -> Int` | Returns number of items dropped by a mob kind |
| `handle_mob_death` | `(Game, Entity) -> Unit` | Processes mob death: particles, drops, hunger restore for passive mobs |
| `check_entity_player_collision` | `(Game, Entity) -> Bool` | Tests entity-player AABB overlap |
| `resolve_entity_player_collision` | `(Game, Entity) -> Unit` | Pushes entity away from player |
| `get_max_entity_count` | `(Bool) -> Int` | Returns max active entities (16 day, 24 night) |
| `get_spawn_weight` | `(Int, Int) -> Int` | Returns spawn weight for an entity kind in a biome |
| `resolve_entity_entity_collisions` | `(Game) -> Unit` | Pushes overlapping entities apart |
| `update_hostile_aggression` | `(Game, Entity) -> Unit` | Updates hostile mob aggro based on distance and time of day |
| `entity_can_see_player` | `(Game, Entity) -> Bool` | Line-of-sight check via 8-step raycast |
| `update_herd_behavior` | `(Game, Entity) -> Unit` | Passive mobs wander toward nearest same-kind entity |
| `update_spider_climb` | `(Game, Entity) -> Unit` | Spiders jump 8 velocity when hitting a wall |
| `update_skeleton_behavior` | `(Game, Entity) -> Unit` | Skeletons back away when closer than 5 blocks during chase |

### Package `voxel_world_3d/internal/levels`

> Block colors, biome parameters, crafting recipes, mob spawn tables, structure templates.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `block_color_r` | `(Int) -> Int` | Red component of a block's top-face color |
| `block_color_g` | `(Int) -> Int` | Green component of a block's top-face color |
| `block_color_b` | `(Int) -> Int` | Blue component of a block's top-face color |
| `block_side_color_r/g/b` | `(Int) -> Int` | Darkened (4/5) side-face color components |
| `block_bottom_color_r/g/b` | `(Int) -> Int` | Further darkened (3/5) bottom-face color components |
| `block_alpha` | `(Int) -> Int` | Block alpha (water=160, glass=120, leaves=230, else 255) |
| `biome_tree_density` | `(Int) -> Float` | Tree spawn density per biome |
| `biome_grass_density` | `(Int) -> Float` | Tall grass spawn density per biome |
| `fog_color_r/g/b` | `(Bool) -> Int` | Fog color by night flag |
| `get_crafting_recipes` | `() -> Array[CraftingRecipe]` | Returns all 16 crafting recipes |
| `get_spawn_type_for_biome` | `(Int, Bool, Int) -> Int` | Returns mob type for biome/time/RNG (0=no spawn) |
| `ore_vein_size` | `(Int) -> Int` | Base vein size for an ore type |
| `ore_chance_at_depth` | `(Int, Int) -> Float` | Ore spawn probability at a given depth |
| `ore_vein_max_at_depth` | `(Int, Int) -> Int` | Maximum ore vein size at a given depth |
| `structure_house_width/depth/height` | `() -> Int` | House template dimensions (7x7x5) |
| `structure_house_block` | `(Int, Int, Int) -> Int` | Block type at relative position in house template |
| `structure_large_tree_height` | `() -> Int` | Large tree height (7) |
| `structure_large_tree_canopy_radius` | `() -> Int` | Large tree canopy radius (3) |
| `structure_large_tree_block` | `(Int, Int, Int) -> Int` | Block at relative position in large tree template |
| `structure_ruin_width/depth/height` | `() -> Int` | Ruin template dimensions (5x5x3) |
| `structure_ruin_block` | `(Int, Int, Int) -> Int` | Block at relative position in ruin template |
| `structure_tower_width/height` | `() -> Int` | Tower template dimensions (3x3x8) |
| `structure_tower_block` | `(Int, Int, Int) -> Int` | Block at relative position in tower template |
| `get_biome_params` | `(Int) -> BiomeParams` | Returns terrain generation parameters for a biome |
| `biome_spawn_rate` | `(Int) -> Float` | Spawn rate modifier per biome |
| `night_spawn_multiplier` | `() -> Float` | Night spawn rate multiplier (1.8) |
| `get_night_hostile_pool` | `(Int, Int) -> Int` | Biome-specific hostile mob selection at night |
| `get_weapon_damage` | `(Int) -> Int` | Weapon damage per tool (1-7) |
| `block_light_level` | `(Int) -> Int` | Light level emitted by a block (torch=14, else 0) |
| `block_hardness` | `(Int) -> Int` | Block resistance value (bedrock=999, stone=5, dirt=1, glass=0) |

### Package `voxel_world_3d/internal/render`

> 3D world rendering and 2D UI drawing.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_world` | `(Game) -> Unit` | Main 3D rendering: builds camera, draws sky/chunks/highlight/mining/entities/particles/decorations/torch glow/water/tool |
| `draw_ui` | `(Game) -> Unit` | Main 2D rendering: dispatches to menu/HUD/crosshair/health/air/debug/inventory/crafting/game over/biome/compass/tool durability/event log |

## Architecture

### Package Structure

```
voxel_world_3d/
+-- main.mbt                         -- Entry point: MSAA window, game loop
+-- moon.pkg                         -- Root package config
+-- internal/
    +-- types/
    |   +-- types.mbt                -- All structs: Chunk, ItemSlot, Inventory, Player, BlockHit, Entity, Particle, CraftingRecipe, BiomeParams, Game
    |   +-- constants.mbt            -- All constants: block/biome/tool/entity/AI/state IDs, physics, survival, rendering, day/night phases
    |   +-- utils.mbt                -- Math, noise functions, terrain generation, world block get/set, property checks, name lookups, RNG, particles
    +-- game/
    |   +-- game_update.mbt          -- Main update dispatcher, state handlers (menu/play/pause/inventory/crafting/game_over), respawn, new game, hunger, combat, player stats, fall damage, block physics, particles, distance tracking
    |   +-- player_system.mbt        -- Player movement, mouse look, sprint, jump, swim, AABB collision, camera follow with head bob
    |   +-- block_system.mbt         -- DDA raycasting for block targeting, mining with progress, block placing with collision check, hotbar selection
    |   +-- crafting_system.mbt      -- Tool durability tiers, tool classification, mining effectiveness, recipe matching, inventory item counting/removal, crafting execution, smelting, tool cycling, workbench interaction
    |   +-- entity_system.mbt        -- Entity AI: wander, flee, chase, attack, pathfinding with wall avoidance, mob drops, player/entity collisions, spawning logic, aggression, line of sight, herding, spider climbing, skeleton ranged behavior
    |   +-- world_system.mbt         -- Day/night sky cycle, entity spawning at terrain surface, entity AI state machine, entity physics, messages
    +-- levels/
    |   +-- levels.mbt               -- Block colors (top/side/bottom/alpha), biome parameters, crafting recipes, mob spawn tables, ore distribution, structure templates (house/tree/ruin/tower), weapon damage, block light/hardness
    +-- render/
        +-- render_world.mbt         -- 3D rendering: camera, sky objects (sun/moon/stars), chunk-based block rendering with face visibility culling, distance fog, height shading, torch proximity lighting, overhang shadows, decorations (flowers/grass/torches), block/face highlights, mining progress overlay, entity models (pig/cow/chicken/zombie/skeleton/spider), particles, torch glow spheres, water surface waves, first-person tool rendering
        +-- render_ui.mbt            -- 2D rendering: main menu with features/controls, HUD (selected block, FPS, day/time, hotbar), crosshair, health/hunger bars, air bar, mining progress bar, debug overlay, pause screen with stats, inventory grid, crafting recipe list, game over screen, biome indicator, compass, tool durability bar, event log
```

### Data Flow

1. **World Generation** (`utils.mbt`): `Game::new` allocates 64 chunks and calls `generate_terrain_chunk` for each. Terrain height is computed via `terrain_height_at` which combines `terrain_noise` (fractal noise) with per-biome base height and amplitude from `get_biome_params`. Biome is determined by `get_biome_at` using temperature and moisture noise. Below terrain height: dirt/sand/stone fill with cave carving via `cave_noise_3d`. Ores are placed probabilistically by depth. Surface decorations (trees, flowers, tall grass, cacti) and water fill complete each chunk.

2. **Input / State Machine** (`game_update.mbt`): `update_game` dispatches to per-state handlers. Playing state runs 14 subsystems per frame: player movement, camera, block targeting, block interaction, block selection, day/night, messages, entities, particles, hunger, block physics, entity spawning, combat, and player stats.

3. **Player Physics** (`player_system.mbt`): `update_player` reads mouse delta for yaw/pitch rotation, WASD keys for horizontal movement relative to facing direction, processes sprint/jump/swim. AABB collision detection checks all blocks overlapping the player's bounding box (radius 0.3, height 1.7) for each axis independently, preventing interpenetration.

4. **Block Interaction** (`block_system.mbt`): `update_block_target` performs a DDA ray march from the camera along the look direction, testing each voxel for solidity. `handle_block_interaction` accumulates mining progress per frame based on block hardness and tool effectiveness. On completion, the block is replaced with air, drops are added to inventory, and break particles spawn.

5. **Entity System** (`entity_system.mbt` + `world_system.mbt`): Entities use a 5-state AI machine (idle/wander/chase/flee/attack). Passive mobs transition between idle and wander with herding behavior. Hostile mobs chase the player within range (12 blocks day, 24 blocks night), switch to attack within 1.8 blocks, and despawn during day if > 40 blocks away. Physics are per-axis AABB like the player. Spawning occurs at 3-8 second intervals on the terrain surface within 30 blocks of the player.

6. **Rendering** (`render_world.mbt` + `render_ui.mbt`): 3D rendering iterates visible chunks within render distance, skipping blocks with no exposed faces. Each block is colored based on type, then modified by height factor, day/night lighting (with torch proximity check), overhang shadow, and distance fog. Entities are rendered as multi-cube 3D models with walking leg animation. 2D UI overlays include the hotbar, health/hunger bars, crosshair, messages, biome indicator, compass, and screen-state overlays (inventory/crafting/pause/death).

### Key Design Patterns

- **Chunk-based World**: The world is divided into 64 chunks of 16x64x16 blocks stored in flat `FixedArray[Int]` arrays. Block access uses `get_world_block`/`set_world_block` which convert world coordinates to chunk index and local coordinates, with bounds checking.

- **Multi-octave Procedural Generation**: Terrain uses `fractal_noise_2d` with configurable octaves and persistence. Biomes are determined by a Whittaker-style temperature/moisture classification. Caves use 3D noise with a threshold. Ores are placed probabilistically with depth-dependent spawn curves.

- **Object Pool Pattern**: Entities (32 max) and particles (64 max) use pre-allocated arrays with `active` flags. Spawning finds the first inactive slot; despawning sets `active = false`.

- **Per-Axis Collision Detection**: Both player and entity physics test collision on each axis (X, Z, Y) independently, preventing wall clipping while allowing sliding along surfaces. Player uses AABB bounds checking against all overlapping solid blocks.

- **State Machine Architecture**: The game has 6 states (menu/playing/paused/inventory/crafting/game_over) with distinct update and render paths. Entity AI uses a 5-state machine (idle/wander/chase/flee/attack) with timer-driven transitions.

- **Tool Effectiveness System**: Mining speed depends on both tool class (pickaxe/axe/shovel/sword) matching the block's preferred class and tool tier (hand/wood/stone/iron). Correct tool + high tier yields multipliers as low as 0.15x of base time.

- **First-Person Ray Targeting**: Block targeting uses a DDA-style ray march from camera origin along the look direction with 0.05 step size up to 5.5 block reach distance. The face normal is determined by tracking the previous step's block position.

## Improvement & Refinement Plan

1. **Replace integer constants with enums**: Block types (0-23), biome types (0-5), entity types (1-6), AI states (0-4), game states (0-5), and tool types (0-12) are all plain integers. Converting to proper MoonBit enums would eliminate magic-number bugs and provide exhaustive match checking.

2. **Implement chunk mesh caching**: Currently `draw_chunk_blocks` iterates every block every frame, checking face visibility in real-time. Pre-building a visible-face mesh when a chunk is modified and reusing it would dramatically improve rendering performance.

3. **Add tool durability tracking**: The `get_tool_max_durability` function exists and `draw_tool_durability` shows a bar, but the durability value is hardcoded to 0.8. Implementing actual per-tool durability tracking (decrement on mine/attack, break tool when depleted) would complete this system.

4. **Use block drops for mob loot**: Mob drops currently use placeholder block IDs (e.g., `block_brick` for pork, `block_dirt` for leather). Adding proper item types separate from block types would make the inventory system more coherent.

5. **Implement chunk dirty flags**: When a block is placed or broken via `set_world_block`, the chunk could be flagged dirty so that only modified chunks rebuild their visible face data. Currently all chunks are re-scanned identically each frame.

6. **Add proper A* pathfinding for hostile mobs**: The current `pathfind_toward_target` uses simple wall avoidance (check left/right, then jump). A proper pathfinding algorithm would handle complex terrain and multi-block obstacles that currently trap mobs.

7. **Implement water spreading**: The constant `water_spread_timer` exists in `Game` and is reset in `start_new_game`, but no water spreading logic is implemented. Adding water flow from source blocks to adjacent air blocks below water level would make the water system dynamic.

8. **Add structure generation during world creation**: The structure templates (`structure_house_block`, `structure_ruin_block`, `structure_tower_block`) are fully defined in levels.mbt but are never called during `generate_terrain_chunk`. Placing structures at suitable biome-specific locations would add discoverable landmarks to the world.
