///|
let tex_mario_small : Ref[@raylib.Texture?] = { val: None }

///|
let tex_mario_large : Ref[@raylib.Texture?] = { val: None }

///|
let tex_enemies : Ref[@raylib.Texture?] = { val: None }

///|
let tex_blocks : Ref[@raylib.Texture?] = { val: None }

///|
let tex_items : Ref[@raylib.Texture?] = { val: None }

///|
let tex_ground : Ref[@raylib.Texture?] = { val: None }

///|
let tex_chunks : Ref[@raylib.Texture?] = { val: None }

///|
let tex_score : Ref[@raylib.Texture?] = { val: None }

///|
/// Load all sprite textures. Call after `init_window`.
pub fn load_textures() -> Unit {
  fn load(path : String) -> @raylib.Texture {
    let t = @raylib.load_texture(path)
    @raylib.set_texture_filter(t, @raylib.TextureFilterPoint)
    t
  }

  tex_mario_small.val = Some(load("mario/resources/mario-small.png"))
  tex_mario_large.val = Some(load("mario/resources/mario-large.png"))
  tex_enemies.val = Some(load("mario/resources/enemies.png"))
  tex_blocks.val = Some(load("mario/resources/blocks.png"))
  tex_items.val = Some(load("mario/resources/items.png"))
  tex_ground.val = Some(load("mario/resources/ground.png"))
  tex_chunks.val = Some(load("mario/resources/chunks.png"))
  tex_score.val = Some(load("mario/resources/score.png"))
}

///|
/// Unload all sprite textures. Call before `close_window`.
pub fn unload_textures() -> Unit {
  fn unload(r : Ref[@raylib.Texture?]) -> Unit {
    match r.val {
      Some(t) => {
        @raylib.unload_texture(t)
        r.val = None
      }
      None => ()
    }
  }

  unload(tex_mario_small)
  unload(tex_mario_large)
  unload(tex_enemies)
  unload(tex_blocks)
  unload(tex_items)
  unload(tex_ground)
  unload(tex_chunks)
  unload(tex_score)
}
