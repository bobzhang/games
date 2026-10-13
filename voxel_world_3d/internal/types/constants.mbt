// Screen

///|
/// Framebuffer width in pixels.
pub let screen_width : Int32 = 1280

///|
/// Framebuffer height in pixels.
pub let screen_height : Int32 = 720

// Game states

// Block types

///|
/// Block id representing empty air voxel.
pub let block_air : Int32 = 0

///|
/// Block id for dirt terrain.
pub let block_dirt : Int32 = 1

///|
/// Block id for grass terrain surface.
pub let block_grass : Int32 = 2

///|
/// Block id for stone terrain.
pub let block_stone : Int32 = 3

///|
/// Block id for raw wood logs.
pub let block_wood : Int32 = 4

///|
/// Block id for leaf foliage.
pub let block_leaves : Int32 = 5

///|
/// Block id for water voxel.
pub let block_water : Int32 = 6

///|
/// Block id for sand terrain.
pub let block_sand : Int32 = 7

///|
/// Block id for glass block.
pub let block_glass : Int32 = 8

///|
/// Block id for crafted brick block.
pub let block_brick : Int32 = 9

///|
/// Block id for iron ore.
pub let block_ore_iron : Int32 = 10

///|
/// Block id for gold ore.
pub let block_ore_gold : Int32 = 11

///|
/// Block id for diamond ore.
pub let block_ore_diamond : Int32 = 12

///|
/// Block id for snow top layer/terrain.
pub let block_snow : Int32 = 13

///|
/// Block id for gravel block.
pub let block_gravel : Int32 = 14

///|
/// Block id for wooden planks.
pub let block_planks : Int32 = 15

///|
/// Block id for cobblestone.
pub let block_cobblestone : Int32 = 16

///|
/// Block id for torch light source.
pub let block_torch : Int32 = 17

///|
/// Block id for unbreakable bedrock.
pub let block_bedrock : Int32 = 18

///|
/// Block id for red flower decoration.
pub let block_flower_red : Int32 = 19

///|
/// Block id for yellow flower decoration.
pub let block_flower_yellow : Int32 = 20

///|
/// Block id for tall grass decoration.
pub let block_tall_grass : Int32 = 21

///|
/// Block id for cactus hazard/decoration.
pub let block_cactus : Int32 = 22

///|
/// Block id for clay resource block.
pub let block_clay : Int32 = 23

///|
/// Item id for sticks (non-block crafting material).
pub let item_stick : Int32 = 24

///|
/// Item id for workbench.
pub let item_workbench : Int32 = 25

///|
/// Item id for furnace.
pub let item_furnace : Int32 = 26

///|
/// Item id for iron ingot.
pub let item_iron_ingot : Int32 = 27

///|
/// Item id for coal.
pub let item_coal : Int32 = 28

///|
/// Block id for chest block (loot container).
pub let block_chest : Int32 = 29

///|
/// Block id for ladder block.
pub let block_ladder : Int32 = 30

///|
/// Block id for rail track decoration.
pub let block_rail : Int32 = 31

///|
/// Block id for campfire remains.
pub let block_campfire : Int32 = 32

///|
/// Block id for shrine stone (decorative ring block).
pub let block_shrine_stone : Int32 = 33

///|
/// Item id for rotten flesh (zombie drop).
pub let item_rotten_flesh : Int32 = 34

///|
/// Item id for bone (skeleton drop).
pub let item_bone : Int32 = 35

///|
/// Item id for string (spider drop).
pub let item_string : Int32 = 36

///|
/// Item id for arrows (skeleton drop / ammo).
pub let item_arrow : Int32 = 37

///|
/// Item id for raw meat (animal drop).
pub let item_raw_meat : Int32 = 38

///|
/// Item id for cooked meat (furnace output).
pub let item_cooked_meat : Int32 = 39

///|
/// Recipe station requirement: none (basic, craft anywhere).
pub let recipe_station_none : Int32 = 0

///|
/// Recipe station requirement: workbench.
pub let recipe_station_workbench : Int32 = 1

///|
/// Recipe station requirement: furnace.
pub let recipe_station_furnace : Int32 = 2

///|
/// Proximity distance for workbench/furnace usage.
pub let station_proximity : Float = 4.0

// Biome types

// Tool types

///|
/// Tool id for empty hand.
pub let tool_hand : Int32 = 0

///|
/// Tool id for wooden pickaxe.
pub let tool_wooden_pickaxe : Int32 = 1

///|
/// Tool id for stone pickaxe.
pub let tool_stone_pickaxe : Int32 = 2

///|
/// Tool id for iron pickaxe.
pub let tool_iron_pickaxe : Int32 = 3

///|
/// Tool id for wooden axe.
pub let tool_wooden_axe : Int32 = 4

///|
/// Tool id for stone axe.
pub let tool_stone_axe : Int32 = 5

///|
/// Tool id for iron axe.
pub let tool_iron_axe : Int32 = 6

///|
/// Tool id for wooden shovel.
pub let tool_wooden_shovel : Int32 = 7

///|
/// Tool id for stone shovel.
pub let tool_stone_shovel : Int32 = 8

///|
/// Tool id for iron shovel.
pub let tool_iron_shovel : Int32 = 9

///|
/// Tool id for wooden sword.
pub let tool_wooden_sword : Int32 = 10

///|
/// Tool id for stone sword.
pub let tool_stone_sword : Int32 = 11

///|
/// Tool id for iron sword.
pub let tool_iron_sword : Int32 = 12

// Chunk dimensions

///|
/// Chunk size along X axis in blocks.
pub let chunk_x : Int32 = 16

///|
/// Chunk size along Y axis in blocks.
pub let chunk_y : Int32 = 64

///|
/// Chunk size along Z axis in blocks.
pub let chunk_z : Int32 = 16

// World dimensions (in chunks)

///|
/// Number of chunks along world X axis.
pub let world_chunks_x : Int32 = 8

///|
/// Number of chunks along world Z axis.
pub let world_chunks_z : Int32 = 8

// Render distance (in chunks from player)

///|
/// Chunk radius around player considered for rendering.
pub let render_distance : Int32 = 3

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
pub let player_max_health : Int32 = 20

///|
/// Maximum hunger points.
pub let player_max_hunger : Int32 = 20

///|
/// Maximum breathable air units underwater.
pub let player_max_air : Int32 = 10

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
pub let base_height : Int32 = 20

///|
/// Terrain height amplitude for height noise.
pub let terrain_amplitude : Float = 12.0

///|
/// Frequency for terrain height noise.
pub let terrain_frequency : Float = 0.04

// Caves

///|
/// Frequency for cave noise sampling.
pub let cave_frequency : Float = 0.08

///|
/// Threshold above which cave voxels are carved.
pub let cave_threshold : Float = 0.55

///|
/// Minimum Y where caves may appear.
pub let cave_min_height : Int32 = 5

///|
/// Maximum Y where caves may appear.
pub let cave_max_height : Int32 = 40

// Ore generation

///|
/// Minimum Y level for iron ore generation.
pub let ore_iron_min_y : Int32 = 2

///|
/// Maximum Y level for iron ore generation.
pub let ore_iron_max_y : Int32 = 45

///|
/// Base chance for iron ore placement.
pub let ore_iron_chance : Float = 0.03

///|
/// Minimum Y level for gold ore generation.
pub let ore_gold_min_y : Int32 = 2

///|
/// Maximum Y level for gold ore generation.
pub let ore_gold_max_y : Int32 = 28

///|
/// Base chance for gold ore placement.
pub let ore_gold_chance : Float = 0.015

///|
/// Minimum Y level for diamond ore generation.
pub let ore_diamond_min_y : Int32 = 2

///|
/// Maximum Y level for diamond ore generation.
pub let ore_diamond_max_y : Int32 = 16

///|
/// Base chance for diamond ore placement.
pub let ore_diamond_chance : Float = 0.006

// Inventory

///|
/// Total inventory slot count.
pub let inventory_slots : Int32 = 36

///|
/// Number of quick-access hotbar slots.
pub let hotbar_slots : Int32 = 9

///|
/// Inventory grid column count.
pub let inventory_cols : Int32 = 9

///|
/// Inventory grid row count.
pub let inventory_rows : Int32 = 4

///|
/// Maximum stack size per inventory slot.
pub let stack_max : Int32 = 64

// Lighting

// Entities

///|
/// Maximum number of active entities.
pub let entity_max : Int32 = 32

///|
/// Entity kind id for pig.
pub let entity_pig : Int32 = 1

///|
/// Entity kind id for cow.
pub let entity_cow : Int32 = 2

///|
/// Entity kind id for chicken.
pub let entity_chicken : Int32 = 3

///|
/// Entity kind id for zombie.
pub let entity_zombie : Int32 = 4

///|
/// Entity kind id for skeleton.
pub let entity_skeleton : Int32 = 5

///|
/// Entity kind id for spider.
pub let entity_spider : Int32 = 6

// Entity AI states

// Entity stats

///|
/// Base health for pigs.
pub let pig_health : Int32 = 10

///|
/// Base health for cows.
pub let cow_health : Int32 = 10

///|
/// Base health for chickens.
pub let chicken_health : Int32 = 4

///|
/// Base health for zombies.
pub let zombie_health : Int32 = 20

///|
/// Base health for skeletons.
pub let skeleton_health : Int32 = 20

///|
/// Base health for spiders.
pub let spider_health : Int32 = 16

///|
/// Contact damage dealt by zombies.
pub let zombie_damage : Int32 = 3

///|
/// Ranged/contact damage dealt by skeletons.
pub let skeleton_damage : Int32 = 2

///|
/// Contact damage dealt by spiders.
pub let spider_damage : Int32 = 2

// Entity movement

///|
/// Movement speed for passive mobs.
pub let entity_speed_passive : Float = 1.5

///|
/// Movement speed for hostile mobs.
pub let entity_speed_hostile : Float = 2.8

///|
/// Movement speed for spiders (faster than other hostiles).
pub let entity_speed_spider : Float = 3.8

///|
/// Spider lunge speed burst distance threshold.
pub let spider_lunge_range : Float = 4.0

///|
/// Spider lunge speed multiplier.
pub let spider_lunge_speed : Float = 7.0

///|
/// Skeleton ranged attack range.
pub let skeleton_shoot_range : Float = 8.0

///|
/// Skeleton arrow fire interval in seconds.
pub let skeleton_shoot_interval : Float = 2.0

///|
/// Arrow projectile speed.
pub let arrow_speed : Float = 12.0

///|
/// Arrow damage on hit.
pub let arrow_damage : Int32 = 3

///|
/// Maximum active projectiles.
pub let projectile_max : Int32 = 16

///|
/// Torch spawn suppression radius in blocks.
pub let torch_spawn_suppress_radius : Int32 = 5

///|
/// Dusk warning normalized time threshold (just before night).
pub let dusk_warning_time : Float = 0.58

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
pub let particle_max : Int32 = 64

///|
/// Gravity acceleration applied to particles.
pub let particle_gravity : Float = 12.0

// Mining speeds (seconds to break with hand)

///|
/// Base mining time for dirt blocks.
pub let mine_speed_dirt : Float = 0.5

///|
/// Base mining time for grass blocks.
pub let mine_speed_grass : Float = 0.6

///|
/// Base mining time for stone blocks.
pub let mine_speed_stone : Float = 2.0

///|
/// Base mining time for log blocks.
pub let mine_speed_wood : Float = 1.5

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

// Fog

///|
/// Distance where fog blending starts.
pub let fog_start_distance : Float = 32.0

///|
/// Distance where fog reaches full strength.
pub let fog_end_distance : Float = 52.0

// Water

///|
/// Default sea/water level Y coordinate.
pub let water_level : Int32 = 16

// Hunger

///|
/// Baseline hunger drain per second.
pub let hunger_drain_rate : Float = 0.015

///|
/// Additional hunger drain per second while sprinting.
pub let hunger_sprint_drain : Float = 0.04

///|
/// Hunger threshold above which passive healing is allowed.
pub let hunger_heal_threshold : Int32 = 16

///|
/// Hunger threshold at which starvation begins.
pub let hunger_starve_threshold : Int32 = 0

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
/// Durability for wooden tools.
pub let durability_wood : Int32 = 60

///|
/// Durability for stone tools.
pub let durability_stone : Int32 = 132

///|
/// Durability for iron tools.
pub let durability_iron : Int32 = 250

///|
/// Update interval for gravity-affected block simulation.
pub let gravity_block_interval : Float = 0.15

///|
/// AI behavior state.
pub(all) enum AiState {
  Idle
  Wander
  Flee
  Chase
  Attack
} derive(Eq)

///|
pub extend AiState with Eq::{not_equal, equal}

///|
/// World biome type.
pub(all) enum Biome {
  Plains
  Forest
  Desert
  Mountains
  Tundra
  Swamp
} derive(Eq)

///|
pub extend Biome with Eq::{not_equal, equal}

///|
/// Current game state.
pub(all) enum GameState {
  Menu
  Playing
  Paused
  Inventory
  Crafting
  GameOver
} derive(Eq)

///|
pub extend GameState with Eq::{not_equal, equal}
