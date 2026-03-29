///|
pub(all) struct InputState {
  mut move_x : Float
  mut move_y : Float
  mut aim_x : Float
  mut aim_y : Float
  mut attack_pressed : Bool
  mut dash_pressed : Bool
  mut pause_pressed : Bool
  mut confirm_pressed : Bool
}

///|
pub fn InputState::new() -> InputState {
  {
    move_x: 0.0, move_y: 0.0,
    aim_x: 0.0, aim_y: 0.0,
    attack_pressed: false, dash_pressed: false,
    pause_pressed: false, confirm_pressed: false,
  }
}

///|
pub fn read_input(game : @types.Game) -> InputState {
  let input = InputState::new()
  // Movement
  if @raylib.is_key_down(@raylib.KeyW) || @raylib.is_key_down(@raylib.KeyUp) {
    input.move_y = -1.0
  }
  if @raylib.is_key_down(@raylib.KeyS) || @raylib.is_key_down(@raylib.KeyDown) {
    input.move_y = 1.0
  }
  if @raylib.is_key_down(@raylib.KeyA) || @raylib.is_key_down(@raylib.KeyLeft) {
    input.move_x = -1.0
  }
  if @raylib.is_key_down(@raylib.KeyD) || @raylib.is_key_down(@raylib.KeyRight) {
    input.move_x = 1.0
  }
  // Normalize diagonal movement
  let len = @types.dist(0.0, 0.0, input.move_x, input.move_y)
  if len > 1.0 {
    input.move_x = input.move_x / len
    input.move_y = input.move_y / len
  }
  // Aim toward mouse (world coords, accounting for camera offset)
  let mouse = @raylib.get_mouse_position()
  let world_mouse_x = mouse.x - Float::from_int(@types.screen_w) / 2.0 + game.camera.x + game.camera.offset_x
  let world_mouse_y = mouse.y - Float::from_int(@types.screen_h) / 2.0 + game.camera.y + game.camera.offset_y
  let raw_aim_x = world_mouse_x - game.player.x
  let raw_aim_y = world_mouse_y - game.player.y
  let (nx, ny) = @types.normalize(raw_aim_x, raw_aim_y)
  input.aim_x = nx
  input.aim_y = ny
  // Update facing direction
  if @types.absf(nx) > 0.01 || @types.absf(ny) > 0.01 {
    game.player.facing_x = nx
    game.player.facing_y = ny
  }
  // Actions
  input.attack_pressed = @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft)
  input.dash_pressed = @raylib.is_key_pressed(@raylib.KeySpace) || @raylib.is_mouse_button_pressed(@raylib.MouseButtonRight)
  input.pause_pressed = @raylib.is_key_pressed(@raylib.KeyEscape)
  input.confirm_pressed = @raylib.is_key_pressed(@raylib.KeyEnter) || @raylib.is_key_pressed(@raylib.KeySpace)
  input
}
