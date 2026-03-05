///|
/// Window width in pixels.
pub let screen_w : Int = 1720

///|
/// Window height in pixels.
pub let screen_h : Int = 980

///|
/// Fixed update/render target frequency.
pub let target_fps : Int = 120

///|
/// Maximum supported puzzle width/height.
pub let max_board : Int = 12

///|
/// Maximum number of cells in a puzzle grid.
pub let max_cells : Int = max_board * max_board

///|
/// Cell state id for untouched cells.
pub let cell_unknown : Int = 0

///|
/// Cell state id for filled cells.
pub let cell_fill : Int = 1

///|
/// Cell state id for crossed-out cells.
pub let cell_cross : Int = 2

///|
/// Title-screen state id.
pub let state_title : Int = 0

///|
/// Active puzzle gameplay state id.
pub let state_play : Int = 1

///|
/// Level-clear transition state id.
pub let state_level_clear : Int = 2

///|
/// Campaign-clear summary state id.
pub let state_campaign_clear : Int = 3

///|
/// Level-fail state id.
pub let state_level_fail : Int = 4

///|
/// Tool id for fill action.
pub let tool_fill : Int = 1

///|
/// Tool id for cross action.
pub let tool_cross : Int = 2

///|
/// Direction id for no held movement.
pub let dir_none : Int = 0

///|
/// Direction id for left movement.
pub let dir_left : Int = 1

///|
/// Direction id for right movement.
pub let dir_right : Int = 2

///|
/// Direction id for upward movement.
pub let dir_up : Int = 3

///|
/// Direction id for downward movement.
pub let dir_down : Int = 4
