///|
pub(all) struct MinimapConfig {
  x : Int
  y : Int
  scale : Float
  room_size : Int
}

///|
pub fn default_minimap_config() -> MinimapConfig {
  { x: @types.screen_w - 180, y: 55, scale: 3.0, room_size: 6, }
}
