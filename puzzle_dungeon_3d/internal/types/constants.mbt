// Screen

///|
/// Backbuffer width in pixels for the puzzle viewport.
pub let screen_width : Int = 1024

///|
/// Backbuffer height in pixels for the puzzle viewport.
pub let screen_height : Int = 768

// Grid dimensions

///|
/// Number of logical columns in each floor grid.
pub let grid_w : Int = 12

///|
/// Number of logical rows in each floor grid.
pub let grid_h : Int = 12

// World counts

///|
/// Total number of world themes in the campaign.
pub let num_worlds : Int = 5

///|
/// Number of floors grouped under each world theme.
pub let floors_per_world : Int = 6

// Animation

///|
/// Duration of normal player movement interpolation in seconds.
pub let move_anim_duration : Float = 0.12

///|
/// Duration of push-block animation in seconds.
pub let push_anim_duration : Float = 0.15

///|
/// Duration of pit-fall animation in seconds.
pub let fall_anim_duration : Float = 0.3

///|
/// Full cycle time for timed spike traps in seconds.
pub let spike_cycle_time : Float = 2.0

// Scoring

///|
/// Move-count threshold for earning exactly two stars.
pub let star_threshold_2 : Int = 15

// Camera

///|
/// Orthographic camera height above the board.
pub let camera_height : Float = 12.0

///|
/// Orthographic camera distance from board center.
pub let camera_dist : Float = 10.0

///|
/// Camera vertical field-of-view used by 3D rendering.
pub let camera_fovy : Float = 20.0

// Pools

///|
/// Capacity of pooled particle slots.
pub let max_particles : Int = 512

///|
/// Maximum number of undo snapshots retained.
pub let max_undo : Int = 200

///|
/// Capacity of pooled floor entities (blocks, keys, gems).
pub let max_entities : Int = 64

///|
/// Total campaign floor count.
pub let max_floors : Int = 30

///|
/// Capacity of cached laser beam segments.
pub let max_laser_segments : Int = 32

///|
/// Capacity of pooled decorative props.
pub let max_decorations : Int = 48

// UI

///|
/// Blink speed for highlighted menu selection text.
pub let menu_blink_speed : Float = 3.5

///|
/// Duration of fade/transition overlays in seconds.
pub let transition_time : Float = 0.5

// Level dimensions for undo state

///|
/// Flattened tile count (`grid_w * grid_h`) used for fixed-size buffers.
pub let grid_total : Int = 144 // grid_w * grid_h

// Particle constants

///|
/// Constant downward acceleration applied to particles.
pub let particle_gravity : Float = 6.0

///|
/// Velocity damping multiplier per frame for particles.
pub let particle_drag : Float = 0.98

///|
/// Number of particles emitted when a teleport triggers.
pub let teleport_particle_count : Int = 16

///|
/// Number of particles emitted when a gate toggles.
pub let gate_particle_count : Int = 12

///|
/// Number of particles emitted on floor completion burst.
pub let complete_particle_count : Int = 32

///|
/// Number of particles emitted when collecting key objectives.
pub let collect_particle_count : Int = 12

// World theme: Dungeon colors

///|
/// Red channel for dungeon floor material color.
pub let dungeon_floor_r : Int = 80

///|
/// Green channel for dungeon floor material color.
pub let dungeon_floor_g : Int = 90

///|
/// Blue channel for dungeon floor material color.
pub let dungeon_floor_b : Int = 110

///|
/// Red channel for dungeon wall material color.
pub let dungeon_wall_r : Int = 45

///|
/// Green channel for dungeon wall material color.
pub let dungeon_wall_g : Int = 50

///|
/// Blue channel for dungeon wall material color.
pub let dungeon_wall_b : Int = 65

///|
/// Red channel for dungeon accent light color.
pub let dungeon_accent_r : Int = 160

///|
/// Green channel for dungeon accent light color.
pub let dungeon_accent_g : Int = 130

///|
/// Blue channel for dungeon accent light color.
pub let dungeon_accent_b : Int = 80

// World theme: Ice colors

///|
/// Red channel for ice floor material color.
pub let ice_floor_r : Int = 180

///|
/// Green channel for ice floor material color.
pub let ice_floor_g : Int = 210

///|
/// Blue channel for ice floor material color.
pub let ice_floor_b : Int = 235

///|
/// Red channel for ice wall material color.
pub let ice_wall_r : Int = 120

///|
/// Green channel for ice wall material color.
pub let ice_wall_g : Int = 150

///|
/// Blue channel for ice wall material color.
pub let ice_wall_b : Int = 180

///|
/// Red channel for ice world accent lighting.
pub let ice_accent_r : Int = 100

///|
/// Green channel for ice world accent lighting.
pub let ice_accent_g : Int = 200

///|
/// Blue channel for ice world accent lighting.
pub let ice_accent_b : Int = 255

// World theme: Lava colors

///|
/// Red channel for lava floor material color.
pub let lava_floor_r : Int = 100

///|
/// Green channel for lava floor material color.
pub let lava_floor_g : Int = 60

///|
/// Blue channel for lava floor material color.
pub let lava_floor_b : Int = 50

///|
/// Red channel for lava wall material color.
pub let lava_wall_r : Int = 70

///|
/// Green channel for lava wall material color.
pub let lava_wall_g : Int = 35

///|
/// Blue channel for lava wall material color.
pub let lava_wall_b : Int = 30

///|
/// Red channel for lava world accent lighting.
pub let lava_accent_r : Int = 255

///|
/// Green channel for lava world accent lighting.
pub let lava_accent_g : Int = 120

///|
/// Blue channel for lava world accent lighting.
pub let lava_accent_b : Int = 30

// World theme: Garden colors

///|
/// Red channel for garden floor material color.
pub let garden_floor_r : Int = 70

///|
/// Green channel for garden floor material color.
pub let garden_floor_g : Int = 120

///|
/// Blue channel for garden floor material color.
pub let garden_floor_b : Int = 65

///|
/// Red channel for garden wall material color.
pub let garden_wall_r : Int = 55

///|
/// Green channel for garden wall material color.
pub let garden_wall_g : Int = 85

///|
/// Blue channel for garden wall material color.
pub let garden_wall_b : Int = 50

///|
/// Red channel for garden accent lighting.
pub let garden_accent_r : Int = 200

///|
/// Green channel for garden accent lighting.
pub let garden_accent_g : Int = 230

///|
/// Blue channel for garden accent lighting.
pub let garden_accent_b : Int = 100

// World theme: Void colors

///|
/// Red channel for void floor material color.
pub let void_floor_r : Int = 50

///|
/// Green channel for void floor material color.
pub let void_floor_g : Int = 40

///|
/// Blue channel for void floor material color.
pub let void_floor_b : Int = 80

///|
/// Red channel for void wall material color.
pub let void_wall_r : Int = 30

///|
/// Green channel for void wall material color.
pub let void_wall_g : Int = 25

///|
/// Blue channel for void wall material color.
pub let void_wall_b : Int = 55

///|
/// Red channel for void accent lighting.
pub let void_accent_r : Int = 180

///|
/// Green channel for void accent lighting.
pub let void_accent_g : Int = 100

///|
/// Blue channel for void accent lighting.
pub let void_accent_b : Int = 255

// Common colors

///|
/// Red channel for pressure plate highlight.
pub let color_plate_r : Int = 200

///|
/// Green channel for pressure plate highlight.
pub let color_plate_g : Int = 180

///|
/// Blue channel for pressure plate highlight.
pub let color_plate_b : Int = 50

///|
/// Red channel for opened-exit visual color.
pub let color_exit_r : Int = 50

///|
/// Green channel for opened-exit visual color.
pub let color_exit_g : Int = 200

///|
/// Blue channel for opened-exit visual color.
pub let color_exit_b : Int = 100

///|
/// Red channel used by ice tile overlays.
pub let color_ice_r : Int = 150

///|
/// Green channel used by ice tile overlays.
pub let color_ice_g : Int = 210

///|
/// Blue channel used by ice tile overlays.
pub let color_ice_b : Int = 240

///|
/// Red channel for movable block tint.
pub let color_block_r : Int = 180

///|
/// Green channel for movable block tint.
pub let color_block_g : Int = 120

///|
/// Blue channel for movable block tint.
pub let color_block_b : Int = 60

///|
/// Red channel for collectible diamond tint.
pub let color_diamond_r : Int = 100

///|
/// Green channel for collectible diamond tint.
pub let color_diamond_g : Int = 200

///|
/// Blue channel for collectible diamond tint.
pub let color_diamond_b : Int = 255

///|
/// Red channel for key collectible tint.
pub let color_key_r : Int = 255

///|
/// Green channel for key collectible tint.
pub let color_key_g : Int = 215

///|
/// Blue channel for key collectible tint.
pub let color_key_b : Int = 0

///|
/// Red channel for conveyor surface tint.
pub let color_conveyor_r : Int = 150

///|
/// Green channel for conveyor surface tint.
pub let color_conveyor_g : Int = 150

///|
/// Blue channel for conveyor surface tint.
pub let color_conveyor_b : Int = 170

///|
/// Red channel for bridge tile tint.
pub let color_bridge_r : Int = 140

///|
/// Green channel for bridge tile tint.
pub let color_bridge_g : Int = 100

///|
/// Blue channel for bridge tile tint.
pub let color_bridge_b : Int = 60

///|
/// Red channel for gate tile tint.
pub let color_gate_r : Int = 160

///|
/// Green channel for gate tile tint.
pub let color_gate_g : Int = 160

///|
/// Blue channel for gate tile tint.
pub let color_gate_b : Int = 180

///|
/// Red channel for mirror tile tint.
pub let color_mirror_r : Int = 200

///|
/// Green channel for mirror tile tint.
pub let color_mirror_g : Int = 220

///|
/// Blue channel for mirror tile tint.
pub let color_mirror_b : Int = 255

///|
/// Red channel for laser beam emission color.
pub let color_laser_r : Int = 255

///|
/// Green channel for laser beam emission color.
pub let color_laser_g : Int = 50

///|
/// Blue channel for laser beam emission color.
pub let color_laser_b : Int = 50

///|
/// Red channel for laser target highlight.
pub let color_target_r : Int = 255

///|
/// Green channel for laser target highlight.
pub let color_target_g : Int = 200

///|
/// Blue channel for laser target highlight.
pub let color_target_b : Int = 80

///|
/// Red channel for rotate-platform glow.
pub let color_rotate_r : Int = 130

///|
/// Green channel for rotate-platform glow.
pub let color_rotate_g : Int = 100

///|
/// Blue channel for rotate-platform glow.
pub let color_rotate_b : Int = 170

// Tutorial messages

///|
/// Intro tutorial prompt explaining movement controls.
pub let tutorial_msg_move : String = "Use WASD or Arrow keys to move"

///|
/// Tutorial prompt for push-block interaction.
pub let tutorial_msg_push : String = "Walk into a block to push it"

///|
/// Tutorial prompt for pressure-plate objective logic.
pub let tutorial_msg_plate : String = "Push blocks onto golden plates to open the exit"

///|
/// Tutorial prompt for undo controls.
pub let tutorial_msg_undo : String = "Press Z to undo your last move"

///|
/// Tutorial prompt introducing ice-slide behavior.
pub let tutorial_msg_ice : String = "Ice is slippery - you slide until hitting something"

///|
/// Tutorial prompt introducing teleporter pairing.
pub let tutorial_msg_teleport : String = "Step on a portal to teleport to its pair"

///|
/// Tutorial prompt introducing switch-triggered hazards.
pub let tutorial_msg_switch : String = "Switches toggle spikes on and off"

///|
/// Tutorial prompt for collapsing cracked tiles.
pub let tutorial_msg_cracked : String = "Cracked floors collapse after you step off them"

///|
/// Tutorial prompt for diamond collection objective.
pub let tutorial_msg_diamond : String = "Collect all gems to open the exit"

// Achievement thresholds

///|
/// Achievement id granted on first floor clear.
pub let achievement_first_clear : Int = 0

///|
/// Achievement id granted for completing world 1.
pub let achievement_world_1 : Int = 1

///|
/// Achievement id for clearing while avoiding undo usage.
pub let achievement_no_undo : Int = 8

///|
/// Total count of supported achievements.
pub let max_achievements : Int = 9

// World names

///|
/// Display name for world index `0`.
pub let world_name_0 : String = "Stone Dungeon"

///|
/// Display name for world index `1`.
pub let world_name_1 : String = "Frozen Cavern"

///|
/// Display name for world index `2`.
pub let world_name_2 : String = "Magma Fortress"

///|
/// Display name for world index `3`.
pub let world_name_3 : String = "Verdant Garden"

///|
/// Display name for world index `4`.
pub let world_name_4 : String = "The Void"
