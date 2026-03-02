// Screen

///|
/// Framebuffer width in pixels.
pub let screen_width : Int = 1280

///|
/// Framebuffer height in pixels.
pub let screen_height : Int = 720

// Game states

///|
/// Game state id for main menu.
pub let state_menu : Int = 0

///|
/// Game state id for active gameplay.
pub let state_playing : Int = 1

///|
/// Game state id for pause overlay.
pub let state_paused : Int = 2

///|
/// Game state id for inventory screen.
pub let state_inventory : Int = 3

///|
/// Game state id for crafting screen.
pub let state_crafting : Int = 4

///|
/// Game state id for player death/game-over screen.
pub let state_game_over : Int = 5

// Block types

///|
/// Block id representing empty air voxel.
pub let block_air : Int = 0

///|
/// Block id for dirt terrain.
pub let block_dirt : Int = 1

///|
/// Block id for grass terrain surface.
pub let block_grass : Int = 2

///|
/// Block id for stone terrain.
pub let block_stone : Int = 3

///|
/// Block id for raw wood logs.
pub let block_wood : Int = 4

///|
/// Block id for leaf foliage.
pub let block_leaves : Int = 5

///|
/// Block id for water voxel.
pub let block_water : Int = 6

///|
/// Block id for sand terrain.
pub let block_sand : Int = 7

///|
/// Block id for glass block.
pub let block_glass : Int = 8

///|
/// Block id for crafted brick block.
pub let block_brick : Int = 9

///|
/// Block id for iron ore.
pub let block_ore_iron : Int = 10

///|
/// Block id for gold ore.
pub let block_ore_gold : Int = 11

///|
/// Block id for diamond ore.
pub let block_ore_diamond : Int = 12

///|
/// Block id for snow top layer/terrain.
pub let block_snow : Int = 13

///|
/// Block id for gravel block.
pub let block_gravel : Int = 14

///|
/// Block id for wooden planks.
pub let block_planks : Int = 15

///|
/// Block id for cobblestone.
pub let block_cobblestone : Int = 16

///|
/// Block id for torch light source.
pub let block_torch : Int = 17

///|
/// Block id for unbreakable bedrock.
pub let block_bedrock : Int = 18

///|
/// Block id for red flower decoration.
pub let block_flower_red : Int = 19

///|
/// Block id for yellow flower decoration.
pub let block_flower_yellow : Int = 20

///|
/// Block id for tall grass decoration.
pub let block_tall_grass : Int = 21

///|
/// Block id for cactus hazard/decoration.
pub let block_cactus : Int = 22

///|
/// Block id for clay resource block.
pub let block_clay : Int = 23

///|
/// Total number of block ids.
pub let block_count : Int = 24

// Biome types

///|
/// Biome id for plains.
pub let biome_plains : Int = 0

///|
/// Biome id for forest.
pub let biome_forest : Int = 1

///|
/// Biome id for desert.
pub let biome_desert : Int = 2

///|
/// Biome id for mountains.
pub let biome_mountains : Int = 3

///|
/// Biome id for tundra.
pub let biome_tundra : Int = 4

///|
/// Biome id for swamp.
pub let biome_swamp : Int = 5

///|
/// Total number of biome ids.
pub let biome_count : Int = 6

// Tool types

///|
/// Tool id for empty hand.
pub let tool_hand : Int = 0

///|
/// Tool id for wooden pickaxe.
pub let tool_wooden_pickaxe : Int = 1

///|
/// Tool id for stone pickaxe.
pub let tool_stone_pickaxe : Int = 2

///|
/// Tool id for iron pickaxe.
pub let tool_iron_pickaxe : Int = 3

///|
/// Tool id for wooden axe.
pub let tool_wooden_axe : Int = 4

///|
/// Tool id for stone axe.
pub let tool_stone_axe : Int = 5

///|
/// Tool id for iron axe.
pub let tool_iron_axe : Int = 6

///|
/// Tool id for wooden shovel.
pub let tool_wooden_shovel : Int = 7

///|
/// Tool id for stone shovel.
pub let tool_stone_shovel : Int = 8

///|
/// Tool id for iron shovel.
pub let tool_iron_shovel : Int = 9

///|
/// Tool id for wooden sword.
pub let tool_wooden_sword : Int = 10

///|
/// Tool id for stone sword.
pub let tool_stone_sword : Int = 11

///|
/// Tool id for iron sword.
pub let tool_iron_sword : Int = 12

///|
/// Total number of tool ids.
pub let tool_count : Int = 13

// Chunk dimensions

///|
/// Chunk size along X axis in blocks.
pub let chunk_x : Int = 16

///|
/// Chunk size along Y axis in blocks.
pub let chunk_y : Int = 64

///|
/// Chunk size along Z axis in blocks.
pub let chunk_z : Int = 16

// World dimensions (in chunks)

///|
/// Number of chunks along world X axis.
pub let world_chunks_x : Int = 8

///|
/// Number of chunks along world Z axis.
pub let world_chunks_z : Int = 8

// Render distance (in chunks from player)

///|
/// Chunk radius around player considered for rendering.
pub let render_distance : Int = 3

// Player

///|
/// Player collider height.
pub let player_height : Float = 1.7

///|
/// Eye offset above player base used for camera.
pub let player_eye_height : Float = 1.6

///|
/// Base walking speed.
pub let player_speed : Float = 5.0

///|
/// Sprint speed multiplier.
pub let player_sprint_mult : Float = 1.6

///|
/// Player horizontal collision radius.
pub let player_radius : Float = 0.3

///|
/// Upward jump impulse.
pub let player_jump_force : Float = 7.5

///|
/// Mouse sensitivity scalar for look controls.
pub let player_mouse_sensitivity : Float = 0.003

///|
/// Maximum player health.
pub let player_max_health : Int = 20

///|
/// Maximum hunger points.
pub let player_max_hunger : Int = 20

///|
/// Maximum breathable air units underwater.
pub let player_max_air : Int = 10

// Camera

///|
/// Perspective camera field-of-view angle.
pub let camera_fovy : Float = 70.0

// Physics

///|
/// Gravity acceleration used by players/entities.
pub let gravity : Float = 18.0

///|
/// Maximum downward velocity cap.
pub let terminal_velocity : Float = 30.0

// Interaction

///|
/// Maximum interaction distance for block targeting.
pub let reach_distance : Float = 6.0

///|
/// Step size for ray-march block targeting.
pub let ray_step : Float = 0.02

// Day/night cycle

///|
/// Full day-night cycle duration in seconds.
pub let day_length : Float = 120.0

///|
/// Start normalized time for dawn segment.
pub let dawn_start : Float = 0.0

///|
/// End normalized time for dawn segment.
pub let dawn_end : Float = 0.1

///|
/// End normalized time for morning segment.
pub let morning_end : Float = 0.25

///|
/// End normalized time for daytime segment.
pub let day_end : Float = 0.45

///|
/// End normalized time for dusk segment.
pub let dusk_end : Float = 0.55

///|
/// End normalized time for late-dusk segment.
pub let late_dusk_end : Float = 0.65

// PI constant

///|
/// PI constant.
pub let pi : Float = 3.14159265

///|
/// `2 * PI` constant.
pub let two_pi : Float = 6.2831853

// Terrain generation

///|
/// Base terrain height baseline.
pub let base_height : Int = 20

///|
/// Terrain height amplitude for height noise.
pub let terrain_amplitude : Float = 12.0

///|
/// Frequency for terrain height noise.
pub let terrain_frequency : Float = 0.04

///|
/// Frequency controlling tree-placement noise.
pub let tree_frequency : Float = 0.03

// Caves

///|
/// Frequency for cave noise sampling.
pub let cave_frequency : Float = 0.08

///|
/// Threshold above which cave voxels are carved.
pub let cave_threshold : Float = 0.55

///|
/// Minimum Y where caves may appear.
pub let cave_min_height : Int = 5

///|
/// Maximum Y where caves may appear.
pub let cave_max_height : Int = 40

// Ore generation

///|
/// Minimum Y level for iron ore generation.
pub let ore_iron_min_y : Int = 2

///|
/// Maximum Y level for iron ore generation.
pub let ore_iron_max_y : Int = 45

///|
/// Base chance for iron ore placement.
pub let ore_iron_chance : Float = 0.03

///|
/// Minimum Y level for gold ore generation.
pub let ore_gold_min_y : Int = 2

///|
/// Maximum Y level for gold ore generation.
pub let ore_gold_max_y : Int = 28

///|
/// Base chance for gold ore placement.
pub let ore_gold_chance : Float = 0.015

///|
/// Minimum Y level for diamond ore generation.
pub let ore_diamond_min_y : Int = 2

///|
/// Maximum Y level for diamond ore generation.
pub let ore_diamond_max_y : Int = 16

///|
/// Base chance for diamond ore placement.
pub let ore_diamond_chance : Float = 0.006

// Inventory

///|
/// Total inventory slot count.
pub let inventory_slots : Int = 36

///|
/// Number of quick-access hotbar slots.
pub let hotbar_slots : Int = 9

///|
/// Inventory grid column count.
pub let inventory_cols : Int = 9

///|
/// Inventory grid row count.
pub let inventory_rows : Int = 4

///|
/// Maximum stack size per inventory slot.
pub let stack_max : Int = 64

// Lighting

///|
/// Maximum light level value.
pub let max_light_level : Int = 15

///|
/// Emitted light level from torch blocks.
pub let torch_light_level : Int = 14

///|
/// Sky/sun light level at daytime.
pub let sun_light_level : Int = 15

///|
/// Minimum ambient brightness multiplier at darkest time.
pub let min_ambient_light : Float = 0.15

// Entities

///|
/// Maximum number of active entities.
pub let entity_max : Int = 32

///|
/// Entity kind id for pig.
pub let entity_pig : Int = 1

///|
/// Entity kind id for cow.
pub let entity_cow : Int = 2

///|
/// Entity kind id for chicken.
pub let entity_chicken : Int = 3

///|
/// Entity kind id for zombie.
pub let entity_zombie : Int = 4

///|
/// Entity kind id for skeleton.
pub let entity_skeleton : Int = 5

///|
/// Entity kind id for spider.
pub let entity_spider : Int = 6

// Entity AI states

///|
/// AI state id for idle behavior.
pub let ai_idle : Int = 0

///|
/// AI state id for roaming/wandering.
pub let ai_wander : Int = 1

///|
/// AI state id for fleeing behavior.
pub let ai_flee : Int = 2

///|
/// AI state id for chase behavior.
pub let ai_chase : Int = 3

///|
/// AI state id for attack behavior.
pub let ai_attack : Int = 4

// Entity stats

///|
/// Base health for pigs.
pub let pig_health : Int = 10

///|
/// Base health for cows.
pub let cow_health : Int = 10

///|
/// Base health for chickens.
pub let chicken_health : Int = 4

///|
/// Base health for zombies.
pub let zombie_health : Int = 20

///|
/// Base health for skeletons.
pub let skeleton_health : Int = 20

///|
/// Base health for spiders.
pub let spider_health : Int = 16

///|
/// Contact damage dealt by zombies.
pub let zombie_damage : Int = 3

///|
/// Ranged/contact damage dealt by skeletons.
pub let skeleton_damage : Int = 2

///|
/// Contact damage dealt by spiders.
pub let spider_damage : Int = 2

// Entity movement

///|
/// Movement speed for passive mobs.
pub let entity_speed_passive : Float = 1.5

///|
/// Movement speed for hostile mobs.
pub let entity_speed_hostile : Float = 2.8

///|
/// Preferred spawn radius around player for entity spawns.
pub let entity_spawn_radius : Float = 30.0

///|
/// Distance beyond which entities despawn.
pub let entity_despawn_radius : Float = 60.0

///|
/// Attack range threshold for hostile melee behavior.
pub let entity_attack_range : Float = 1.8

// Particles

///|
/// Maximum active particle count.
pub let particle_max : Int = 64

///|
/// Default particle lifetime in seconds.
pub let particle_lifetime : Float = 1.0

///|
/// Gravity acceleration applied to particles.
pub let particle_gravity : Float = 12.0

///|
/// Default particle ejection speed scale.
pub let particle_speed : Float = 4.0

// Mining speeds (seconds to break with hand)

///|
/// Base mining time for dirt blocks.
pub let mine_speed_dirt : Float = 0.5

///|
/// Base mining time for grass blocks.
pub let mine_speed_grass : Float = 0.6

///|
/// Base mining time for sand blocks.
pub let mine_speed_sand : Float = 0.5

///|
/// Base mining time for gravel blocks.
pub let mine_speed_gravel : Float = 0.6

///|
/// Base mining time for stone blocks.
pub let mine_speed_stone : Float = 2.0

///|
/// Base mining time for cobblestone blocks.
pub let mine_speed_cobblestone : Float = 2.0

///|
/// Base mining time for log blocks.
pub let mine_speed_wood : Float = 1.5

///|
/// Base mining time for plank blocks.
pub let mine_speed_planks : Float = 1.0

///|
/// Base mining time for leaf blocks.
pub let mine_speed_leaves : Float = 0.3

///|
/// Base mining time for glass blocks.
pub let mine_speed_glass : Float = 0.4

///|
/// Base mining time for brick blocks.
pub let mine_speed_brick : Float = 2.5

///|
/// Base mining time for ore blocks.
pub let mine_speed_ore : Float = 3.0

///|
/// Mining time for bedrock (effectively unmineable).
pub let mine_speed_bedrock : Float = 999.0

// Crafting recipe IDs

///|
/// Recipe id for crafting planks.
pub let recipe_planks : Int = 0

///|
/// Recipe id for crafting sticks.
pub let recipe_sticks : Int = 1

///|
/// Recipe id for crafting table.
pub let recipe_crafting_table : Int = 2

///|
/// Recipe id for wooden pickaxe.
pub let recipe_wooden_pickaxe : Int = 3

///|
/// Recipe id for stone pickaxe.
pub let recipe_stone_pickaxe : Int = 4

///|
/// Recipe id for iron pickaxe.
pub let recipe_iron_pickaxe : Int = 5

///|
/// Recipe id for wooden axe.
pub let recipe_wooden_axe : Int = 6

///|
/// Recipe id for wooden shovel.
pub let recipe_wooden_shovel : Int = 7

///|
/// Recipe id for wooden sword.
pub let recipe_wooden_sword : Int = 8

///|
/// Recipe id for furnace.
pub let recipe_furnace : Int = 9

///|
/// Recipe id for torch.
pub let recipe_torch : Int = 10

///|
/// Recipe id for brick.
pub let recipe_brick : Int = 11

///|
/// Recipe id for glass.
pub let recipe_glass : Int = 12

///|
/// Total number of recipe ids.
pub let recipe_count : Int = 13

// Fog

///|
/// Distance where fog blending starts.
pub let fog_start_distance : Float = 32.0

///|
/// Distance where fog reaches full strength.
pub let fog_end_distance : Float = 52.0

///|
/// Fog density parameter for distance haze.
pub let fog_density : Float = 0.02

// Water

///|
/// Update interval for water spread simulation.
pub let water_spread_interval : Float = 0.5

///|
/// Default sea/water level Y coordinate.
pub let water_level : Int = 16

// Hunger

///|
/// Baseline hunger drain per second.
pub let hunger_drain_rate : Float = 0.015

///|
/// Additional hunger drain per second while sprinting.
pub let hunger_sprint_drain : Float = 0.04

///|
/// Hunger threshold above which passive healing is allowed.
pub let hunger_heal_threshold : Int = 16

///|
/// Hunger threshold at which starvation begins.
pub let hunger_starve_threshold : Int = 0

///|
/// Interval between starvation damage ticks.
pub let starve_damage_interval : Float = 2.0

// Fall damage

///|
/// Fall distance before fall damage is applied.
pub let fall_damage_threshold : Float = 4.0

///|
/// Damage multiplier for distance beyond fall threshold.
pub let fall_damage_multiplier : Float = 1.0

// Respawn

///|
/// Post-respawn invulnerability duration.
pub let respawn_invulnerability : Float = 3.0

// Block physics

///|
/// Update interval for gravity-affected block simulation.
pub let gravity_block_interval : Float = 0.15
