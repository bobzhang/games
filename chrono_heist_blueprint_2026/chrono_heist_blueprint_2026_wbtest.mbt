///|
fn make_tiles() -> Array[Int] {
  Array::make(grid_w * grid_h, tile_empty)
}

///|
fn make_guards() -> Array[Guard] {
  Array::makei(max_guards, fn(_i) {
    {
      active: false,
      x: 0,
      y: 0,
      ax: 0,
      ay: 0,
      bx: 0,
      by: 0,
      to_b: true,
      alert_x: 0,
      alert_y: 0,
      alert_t: 0,
    }
  })
}

///|
fn make_doors() -> Array[Door] {
  Array::makei(max_doors, fn(_i) {
    { active: false, x: 0, y: 0, plate_x: 0, plate_y: 0, title: "" }
  })
}

///|
fn make_ghosts() -> Array[Actor] {
  Array::makei(max_ghosts, fn(_i) { { x: 0, y: 0 } })
}

///|
test "level 1 setup places critical tiles and door" {
  let tiles = make_tiles()
  let guards = make_guards()
  let doors = make_doors()
  let setup = setup_level(1, tiles, guards, doors)

  assert_eq(setup.0, 1)
  assert_eq(setup.1, 1)
  assert_eq(setup.2, 8)
  assert_eq(setup.3, 2)
  assert_eq(setup.4, 10)
  assert_eq(setup.5, 6)
  assert_eq(tiles[idx(2, 6)], tile_key)
  assert_eq(tiles[idx(8, 2)], tile_vault)
  assert_eq(tiles[idx(10, 6)], tile_exit)
  assert_true(doors[0].active)
  assert_eq(doors[0].x, 5)
  assert_eq(doors[0].y, 4)
}

///|
test "plate ghost opens breach door" {
  let tiles = make_tiles()
  let guards = make_guards()
  let doors = make_doors()
  ignore(setup_level(1, tiles, guards, doors))

  let player = { x: 1, y: 1 }
  let ghosts = make_ghosts()

  assert_true(tile_blocked(tiles, doors, player, ghosts, 0, 5, 4))
  ghosts[0].x = doors[0].plate_x
  ghosts[0].y = doors[0].plate_y
  assert_false(tile_blocked(tiles, doors, player, ghosts, 1, 5, 4))
}
