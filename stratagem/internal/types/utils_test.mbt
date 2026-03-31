///|
test "hex_distance same position" {
  let a = @types.hex(3, 3)
  let b = @types.hex(3, 3)
  inspect(@types.hex_distance(a, b), content="0")
}

///|
test "hex_distance adjacent" {
  let a = @types.hex(3, 3)
  let b = @types.hex(4, 3)
  inspect(@types.hex_distance(a, b), content="1")
}

///|
test "hex_distance two apart" {
  let a = @types.hex(0, 0)
  let b = @types.hex(2, 0)
  inspect(@types.hex_distance(a, b), content="2")
}

///|
test "hex_neighbors count" {
  let c = @types.hex(3, 3)
  let n = @types.hex_neighbors(c)
  inspect(n.length(), content="6")
}

///|
test "hex_neighbors even row" {
  let c = @types.hex(3, 2)
  let n = @types.hex_neighbors(c)
  // Even row neighbors
  inspect(n.length(), content="6")
}

///|
test "hex_valid bounds" {
  inspect(@types.hex_valid(@types.hex(0, 0), 10, 8), content="true")
  inspect(@types.hex_valid(@types.hex(9, 7), 10, 8), content="true")
  inspect(@types.hex_valid(@types.hex(10, 0), 10, 8), content="false")
  inspect(@types.hex_valid(@types.hex(-1, 0), 10, 8), content="false")
  inspect(@types.hex_valid(@types.hex(0, 8), 10, 8), content="false")
}

///|
test "hex_index roundtrip" {
  let c = @types.hex(5, 3)
  let idx = @types.hex_index(c, 10)
  let back = @types.hex_from_index(idx, 10)
  inspect(back.col, content="5")
  inspect(back.row, content="3")
}

///|
test "terrain_move_cost" {
  inspect(@types.terrain_move_cost(Plains), content="1")
  inspect(@types.terrain_move_cost(Forest), content="2")
  inspect(@types.terrain_move_cost(Hills), content="2")
  inspect(@types.terrain_move_cost(Water), content="999")
}

///|
test "unit stats" {
  inspect(@types.unit_base_hp(Infantry), content="3")
  inspect(@types.unit_base_hp(Cavalry), content="2")
  inspect(@types.unit_base_hp(Artillery), content="2")
  inspect(@types.unit_base_atk(Infantry), content="2")
  inspect(@types.unit_base_atk(Cavalry), content="3")
  inspect(@types.unit_base_atk(Artillery), content="4")
  inspect(@types.unit_base_move(Infantry), content="2")
  inspect(@types.unit_base_move(Cavalry), content="4")
  inspect(@types.unit_base_move(Artillery), content="1")
}

///|
test "new_unit constructor" {
  let u = @types.new_unit(0, Infantry, Player, 3, 3)
  inspect(u.hp, content="3")
  inspect(u.atk, content="2")
  inspect(u.move_range, content="2")
  inspect(u.attack_range, content="1")
  inspect(u.sight_range, content="2")
  inspect(u.active, content="true")
  inspect(u.moved, content="false")
}

///|
test "terrain_def_bonus" {
  inspect(@types.terrain_def_bonus(Forest, Infantry), content="2")
  inspect(@types.terrain_def_bonus(Forest, Cavalry), content="1")
  inspect(@types.terrain_def_bonus(Plains, Infantry), content="0")
}

///|
test "terrain_range_bonus" {
  inspect(@types.terrain_range_bonus(Hills, Artillery), content="1")
  inspect(@types.terrain_range_bonus(Hills, Infantry), content="0")
  inspect(@types.terrain_range_bonus(Plains, Artillery), content="0")
}

///|
test "terrain_from_int" {
  inspect(@types.terrain_from_int(0), content="Plains")
  inspect(@types.terrain_from_int(1), content="Forest")
  inspect(@types.terrain_from_int(2), content="Hills")
  inspect(@types.terrain_from_int(3), content="Water")
  inspect(@types.terrain_from_int(99), content="Plains")
}

///|
test "new_game initial state" {
  let g = @types.new_game()
  inspect(g.screen, content="Title")
  inspect(g.frame_count, content="0")
  inspect(g.campaign.levels_unlocked, content="1")
  inspect(g.campaign.total_score, content="0")
}

///|
test "new_battle initial state" {
  let b = @types.new_battle()
  inspect(b.phase, content="Select")
  inspect(b.turn, content="1")
  inspect(b.result, content="Ongoing")
  inspect(b.selected_unit, content="-1")
  inspect(b.units.length(), content="0")
}

///|
test "place and remove unit on map" {
  let b = @types.new_battle()
  let u = @types.new_unit(0, Infantry, Player, 3, 3)
  let _ = @types.place_unit_on_map(b, u)
  let idx = @types.hex_index(@types.hex(3, 3), b.map.width)
  inspect(b.map.tiles[idx].unit_id, content="0")
  let _ = @types.remove_unit_from_map(b, u)
  inspect(b.map.tiles[idx].unit_id, content="-1")
}

///|
test "count_team_units" {
  let b = @types.new_battle()
  let u1 = @types.new_unit(0, Infantry, Player, 1, 1)
  let u2 = @types.new_unit(1, Infantry, Player, 2, 2)
  let u3 = @types.new_unit(2, Infantry, Enemy, 8, 8)
  b.units = [u1, u2, u3]
  inspect(@types.count_team_units(b, Player), content="2")
  inspect(@types.count_team_units(b, Enemy), content="1")
}

///|
test "rng produces values in range" {
  @types.seed_rng(42)
  for _i in 0..<100 {
    let v = @types.rng_int(10)
    inspect(v >= 0 && v < 10, content="true")
  }
}

///|
test "line of sight through forest" {
  let map = @types.new_hex_map(10, 8)
  // Place forest at (3,3)
  let idx = @types.hex_index(@types.hex(3, 3), 10)
  map.tiles[idx].terrain = Forest
  // LOS from (1,3) to (5,3) should be blocked by forest at (3,3)
  let has_los = @types.has_line_of_sight(
    map, @types.hex(1, 3), @types.hex(5, 3),
  )
  inspect(has_los, content="false")
}

///|
test "line of sight without obstacle" {
  let map = @types.new_hex_map(10, 8)
  let has_los = @types.has_line_of_sight(
    map, @types.hex(1, 3), @types.hex(5, 3),
  )
  inspect(has_los, content="true")
}

///|
test "fog of war update" {
  let b = @types.new_battle()
  let u = @types.new_unit(0, Infantry, Player, 5, 4)
  let _ = @types.place_unit_on_map(b, u)
  b.units = [u]
  @types.update_fog_of_war(b)
  // Unit position should be visible
  let idx = @types.hex_index(@types.hex(5, 4), b.map.width)
  inspect(b.map.tiles[idx].fog_player, content="Visible")
  // Far away should be hidden
  let far_idx = @types.hex_index(@types.hex(0, 0), b.map.width)
  inspect(b.map.tiles[far_idx].fog_player, content="Hidden")
}

///|
test "cosf and sinf" {
  inspect(@types.cosf(0.0), content="1")
  inspect(@types.sinf(0.0), content="0")
}

///|
test "absi" {
  inspect(@types.absi(5), content="5")
  inspect(@types.absi(-5), content="5")
  inspect(@types.absi(0), content="0")
}

///|
test "maxi and mini" {
  inspect(@types.maxi(3, 7), content="7")
  inspect(@types.mini(3, 7), content="3")
}
