///|
pub(all) struct MinimapConfig {
  x : Int32
  y : Int32
  scale : Float
  room_size : Int32
}

///|
pub fn default_minimap_config() -> MinimapConfig {
  { x: @types.screen_w - 180, y: 55, scale: 3.0, room_size: 6, }
}
