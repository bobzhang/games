///|
pub let screen_width : Int32 = 1024

///|
pub let screen_height : Int32 = 768

///|
pub let target_fps : Int32 = 60

///|
pub let grid_cols : Int32 = 10

///|
pub let grid_rows : Int32 = 8

///|
pub let cell_size : Int32 = 64

///|
pub let grid_offset_x : Int32 = 32

///|
pub let grid_offset_y : Int32 = 96

///|
pub let toolbar_height : Int32 = 80

///|
pub let hud_height : Int32 = 64

///|
pub let total_levels : Int32 = 20

///|
pub let tier1_count : Int32 = 7

///|
pub let tier2_count : Int32 = 7

///|
pub let tier3_count : Int32 = 6

///|
pub let max_species : Int32 = 6

///|
pub let predator_safe_distance : Int32 = 3

// Colors - zoo / nature palette

///|
pub let color_bg : @raylib.Color = @raylib.Color::new(34, 40, 49, 255)

///|
pub let color_grass : @raylib.Color = @raylib.Color::new(76, 175, 80, 255)

///|
pub let color_water : @raylib.Color = @raylib.Color::new(33, 150, 243, 255)

///|
pub let color_sand : @raylib.Color = @raylib.Color::new(255, 213, 79, 255)

///|
pub let color_rock : @raylib.Color = @raylib.Color::new(158, 158, 158, 255)

///|
pub let color_trees : @raylib.Color = @raylib.Color::new(27, 94, 32, 255)

///|
pub let color_empty : @raylib.Color = @raylib.Color::new(55, 63, 72, 255)

///|
pub let color_fence : @raylib.Color = @raylib.Color::new(121, 85, 72, 255)

///|
pub let color_fence_highlight : @raylib.Color = @raylib.Color::new(
  188, 143, 106, 255,
)

///|
pub let color_grid_line : @raylib.Color = @raylib.Color::new(70, 78, 88, 255)

///|
pub let color_hud_bg : @raylib.Color = @raylib.Color::new(24, 28, 36, 240)

///|
pub let color_hud_text : @raylib.Color = @raylib.Color::new(220, 230, 240, 255)

///|
pub let color_title : @raylib.Color = @raylib.Color::new(255, 193, 7, 255)

///|
pub let color_star_gold : @raylib.Color = @raylib.Color::new(255, 215, 0, 255)

///|
pub let color_star_empty : @raylib.Color = @raylib.Color::new(80, 80, 80, 255)

///|
pub let color_success : @raylib.Color = @raylib.Color::new(76, 175, 80, 255)

///|
pub let color_error : @raylib.Color = @raylib.Color::new(244, 67, 54, 255)

///|
pub let color_warning : @raylib.Color = @raylib.Color::new(255, 152, 0, 255)

///|
pub let color_lion : @raylib.Color = @raylib.Color::new(255, 167, 38, 255)

///|
pub let color_penguin : @raylib.Color = @raylib.Color::new(66, 66, 66, 255)

///|
pub let color_elephant : @raylib.Color = @raylib.Color::new(120, 144, 156, 255)

///|
pub let color_snake : @raylib.Color = @raylib.Color::new(139, 195, 74, 255)

///|
pub let color_monkey : @raylib.Color = @raylib.Color::new(141, 110, 99, 255)

///|
pub let color_bear : @raylib.Color = @raylib.Color::new(93, 64, 55, 255)

///|
pub let color_toolbar_bg : @raylib.Color = @raylib.Color::new(38, 44, 54, 240)

///|
pub let color_tool_selected : @raylib.Color = @raylib.Color::new(
  255, 193, 7, 180,
)

///|
pub let color_tool_hover : @raylib.Color = @raylib.Color::new(
  100, 120, 140, 120,
)

///|
pub let color_button : @raylib.Color = @raylib.Color::new(63, 81, 181, 255)

///|
pub let color_button_hover : @raylib.Color = @raylib.Color::new(
  92, 107, 192, 255,
)

///|
pub let color_level_locked : @raylib.Color = @raylib.Color::new(60, 60, 60, 255)

///|
pub let color_level_available : @raylib.Color = @raylib.Color::new(
  63, 81, 181, 255,
)

///|
pub let color_level_completed : @raylib.Color = @raylib.Color::new(
  76, 175, 80, 255,
)

// Level select layout

///|
pub let level_button_y : Int32 = 140

///|
pub let level_button_h : Int32 = 56

///|
pub let level_button_gap : Int32 = 8

///|
pub let level_visible_count : Int32 = 9

///|
pub let level_button_x : Int32 = 80

///|
pub let level_button_w : Int32 = 864

// Toolbar layout

///|
pub let toolbar_slot_w : Int32 = 72

///|
pub let toolbar_slot_gap : Int32 = 4

///|
pub let toolbar_start_x : Int32 = 16

///|
pub let toolbar_slot_h : Int32 = 56
