///|
pub fn mirror_h_pos(pos : @types.Vec2i, grid_h : Int) -> @types.Vec2i {
  @types.vec2i(pos.x, grid_h - 1 - pos.y)
}

///|
pub fn mirror_v_pos(pos : @types.Vec2i, grid_w : Int) -> @types.Vec2i {
  @types.vec2i(grid_w - 1 - pos.x, pos.y)
}

///|
pub fn mirror_d_pos(pos : @types.Vec2i) -> @types.Vec2i {
  @types.vec2i(pos.y, pos.x)
}

///|
pub fn rotate2_pos(
  pos : @types.Vec2i,
  grid_w : Int,
  grid_h : Int,
) -> @types.Vec2i {
  @types.vec2i(grid_w - 1 - pos.x, grid_h - 1 - pos.y)
}

///|
pub fn rotate4_pos_90(
  pos : @types.Vec2i,
  grid_w : Int,
  _grid_h : Int,
) -> @types.Vec2i {
  @types.vec2i(grid_w - 1 - pos.y, pos.x)
}

///|
pub fn rotate4_pos_180(
  pos : @types.Vec2i,
  grid_w : Int,
  grid_h : Int,
) -> @types.Vec2i {
  rotate2_pos(pos, grid_w, grid_h)
}

///|
pub fn rotate4_pos_270(
  pos : @types.Vec2i,
  _grid_w : Int,
  grid_h : Int,
) -> @types.Vec2i {
  @types.vec2i(pos.y, grid_h - 1 - pos.x)
}

///|
pub fn glide_pos(pos : @types.Vec2i, grid_w : Int) -> @types.Vec2i {
  let shifted_x = (pos.x + grid_w / 2) % grid_w
  @types.vec2i(shifted_x, grid_w - 1 - pos.y)
}

///|
pub fn transform_tile(
  tile : @types.Tile,
  sym : @types.SymmetryKind,
) -> @types.Tile {
  let c = tile.color
  let s = tile.shape
  let o = tile.orientation
  if @types.is_symmetric_shape(s) {
    return @types.new_tile(c, s, o)
  }
  match sym {
    MirrorH => @types.new_tile(c, s, @types.mirror_orient_h(o))
    MirrorV => @types.new_tile(c, s, @types.mirror_orient_v(o))
    MirrorD => @types.new_tile(c, s, @types.mirror_orient_d(o))
    Rotate2 => @types.new_tile(c, s, @types.rotate_orient_180(o))
    Rotate4 => @types.new_tile(c, s, @types.rotate_orient_90(o))
    Glide => @types.new_tile(c, s, @types.mirror_orient_h(o))
  }
}

///|
pub fn get_symmetric_pos(
  pos : @types.Vec2i,
  sym : @types.SymmetryKind,
  grid_w : Int,
  grid_h : Int,
) -> Array[@types.Vec2i] {
  match sym {
    MirrorH => [mirror_h_pos(pos, grid_h)]
    MirrorV => [mirror_v_pos(pos, grid_w)]
    MirrorD => [mirror_d_pos(pos)]
    Rotate2 => [rotate2_pos(pos, grid_w, grid_h)]
    Rotate4 =>
      [
        rotate4_pos_90(pos, grid_w, grid_h),
        rotate4_pos_180(pos, grid_w, grid_h),
        rotate4_pos_270(pos, grid_w, grid_h),
      ]
    Glide => [glide_pos(pos, grid_w)]
  }
}

///|
pub fn expected_tile_at(
  grid : @types.MosaicGrid,
  hole : @types.Vec2i,
  sym : @types.SymmetryKind,
) -> @types.Tile? {
  let partners = get_symmetric_pos(hole, sym, grid.width, grid.height)
  for i in 0..<partners.length() {
    let p = partners[i]
    match @types.get_tile(grid, p.x, p.y) {
      Some(t) => {
        let expected = transform_tile(t, sym)
        return Some(expected)
      }
      None => continue
    }
  }
  None
}

///|
pub fn get_expected_for_rotate4(
  grid : @types.MosaicGrid,
  hole : @types.Vec2i,
) -> @types.Tile? {
  let w = grid.width
  let h = grid.height
  let p90 = rotate4_pos_90(hole, w, h)
  match @types.get_tile(grid, p90.x, p90.y) {
    Some(t) => {
      let expected = transform_tile(t, Rotate4)
      return Some(expected)
    }
    None => ()
  }
  let p180 = rotate4_pos_180(hole, w, h)
  match @types.get_tile(grid, p180.x, p180.y) {
    Some(t) => {
      let c = t.color
      let s = t.shape
      let o = t.orientation
      if @types.is_symmetric_shape(s) {
        return Some(@types.new_tile(c, s, o))
      }
      return Some(@types.new_tile(c, s, @types.rotate_orient_180(o)))
    }
    None => ()
  }
  let p270 = rotate4_pos_270(hole, w, h)
  match @types.get_tile(grid, p270.x, p270.y) {
    Some(t) => {
      let c = t.color
      let s = t.shape
      let o = t.orientation
      if @types.is_symmetric_shape(s) {
        return Some(@types.new_tile(c, s, o))
      }
      return Some(@types.new_tile(c, s, @types.rotate_orient_270(o)))
    }
    None => ()
  }
  None
}
