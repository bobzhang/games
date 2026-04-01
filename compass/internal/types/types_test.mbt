///|
test "direction_dx" {
  inspect(@types.direction_dx(North), content="0")
  inspect(@types.direction_dx(South), content="0")
  inspect(@types.direction_dx(East), content="1")
  inspect(@types.direction_dx(West), content="-1")
}

///|
test "direction_dy" {
  inspect(@types.direction_dy(North), content="-1")
  inspect(@types.direction_dy(South), content="1")
  inspect(@types.direction_dy(East), content="0")
  inspect(@types.direction_dy(West), content="0")
}

///|
test "direction_name" {
  inspect(@types.direction_name(North), content="N")
  inspect(@types.direction_name(South), content="S")
  inspect(@types.direction_name(East), content="E")
  inspect(@types.direction_name(West), content="W")
}

///|
test "in_bounds" {
  inspect(@types.in_bounds(0, 0), content="true")
  inspect(@types.in_bounds(11, 9), content="true")
  inspect(@types.in_bounds(12, 0), content="false")
  inspect(@types.in_bounds(0, 10), content="false")
  inspect(@types.in_bounds(-1, 0), content="false")
  inspect(@types.in_bounds(0, -1), content="false")
}

///|
test "star_rating_value" {
  inspect(@types.star_rating_value(None), content="0")
  inspect(@types.star_rating_value(One), content="1")
  inspect(@types.star_rating_value(Two), content="2")
  inspect(@types.star_rating_value(Three), content="3")
}

///|
test "new_ship" {
  let ship = @types.new_ship({ x: 3, y: 5 })
  inspect(ship.pos, content="{x: 3, y: 5}")
  inspect(ship.hp, content="3")
  inspect(ship.steps, content="0")
  inspect(ship.landmarks_found, content="0")
}

///|
test "new_game" {
  let game = @types.new_game()
  inspect(game.current_level, content="0")
  inspect(game.phase, content="Menu")
  inspect(game.stars.length(), content="20")
  inspect(game.level_state, content="None")
}

///|
test "bearing_to_degrees" {
  inspect(@types.bearing_to_degrees(0.0).to_int(), content="0")
  let pi : Float = Float::from_double(@math.PI)
  inspect(@types.bearing_to_degrees(pi).to_int(), content="180")
  inspect(@types.bearing_to_degrees(-pi / 2.0).to_int(), content="270")
}

///|
test "compute_bearing_east" {
  let from : @types.Pos = { x: 0, y: 0 }
  let to : @types.Pos = { x: 5, y: 0 }
  let bearing = @types.compute_bearing(from, to)
  let deg = @types.bearing_to_degrees(bearing).to_int()
  inspect(deg, content="90")
}

///|
test "compute_bearing_south" {
  let from : @types.Pos = { x: 0, y: 0 }
  let to : @types.Pos = { x: 0, y: 5 }
  let bearing = @types.compute_bearing(from, to)
  let deg = @types.bearing_to_degrees(bearing).to_int()
  inspect(deg, content="180")
}

///|
test "heading_to_compass_north" {
  inspect(@types.heading_to_compass(0.0), content="N")
}

///|
test "pos_equality" {
  let a : @types.Pos = { x: 1, y: 2 }
  let b : @types.Pos = { x: 1, y: 2 }
  let c : @types.Pos = { x: 3, y: 4 }
  inspect(a == b, content="true")
  inspect(a == c, content="false")
}

///|
test "tile_show" {
  inspect(@types.Tile::Ocean, content="Ocean")
  inspect(@types.Tile::Land, content="Land")
  inspect(@types.Tile::Lighthouse, content="Lighthouse")
  inspect(@types.Tile::Reef, content="Reef")
  inspect(@types.Tile::Landmark, content="Landmark")
  inspect(@types.Tile::Current(North), content="Current(North)")
}
