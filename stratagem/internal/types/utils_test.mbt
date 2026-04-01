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
  inspect(u.def, content="1")
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
  inspect(@types.terrain_def_bonus(Hills, Infantry), content="1")
  inspect(@types.terrain_def_bonus(Hills, Artillery), content="1")
  inspect(@types.terrain_def_bonus(Hills, Cavalry), content="0")
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
    map,
    @types.hex(1, 3),
    @types.hex(5, 3),
  )
  inspect(has_los, content="false")
}

///|
test "line of sight without obstacle" {
  let map = @types.new_hex_map(10, 8)
  let has_los = @types.has_line_of_sight(
    map,
    @types.hex(1, 3),
    @types.hex(5, 3),
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

// Extended hex math tests

///|
test "hex_distance diagonal" {
  let a = @types.hex(0, 0)
  let b = @types.hex(2, 2)
  let dist = @types.hex_distance(a, b)
  // Diagonal distance on hex grid
  inspect(dist > 0, content="true")
  inspect(dist <= 4, content="true")
}

///|
test "hex_distance symmetry" {
  let a = @types.hex(2, 3)
  let b = @types.hex(7, 5)
  inspect(
    @types.hex_distance(a, b) == @types.hex_distance(b, a),
    content="true",
  )
}

///|
test "hex_to_cube roundtrip preserves constraint" {
  // For cube coordinates: x + y + z == 0
  for row in 0..<8 {
    for col in 0..<10 {
      let (x, y, z) = @types.hex_to_cube(@types.hex(col, row))
      inspect(x + y + z, content="0")
    }
  }
}

///|
test "hex_neighbors all valid in center" {
  let c = @types.hex(5, 4)
  let n = @types.hex_neighbors(c)
  // All neighbors of a center hex should be within 10x8 grid
  for i in 0..<n.length() {
    inspect(@types.hex_valid(n[i], 10, 8), content="true")
  }
}

///|
test "hex_neighbors are all distance 1" {
  let c = @types.hex(4, 3)
  let n = @types.hex_neighbors(c)
  for i in 0..<n.length() {
    inspect(@types.hex_distance(c, n[i]), content="1")
  }
}

///|
test "hex_neighbors edge has some out of bounds" {
  let c = @types.hex(0, 0)
  let n = @types.hex_neighbors(c)
  let mut out_count = 0
  for i in 0..<n.length() {
    if !@types.hex_valid(n[i], 10, 8) {
      out_count = out_count + 1
    }
  }
  // Corner hex should have some neighbors out of bounds
  inspect(out_count > 0, content="true")
}

///|
test "hex_line returns endpoints" {
  let a = @types.hex(1, 1)
  let b = @types.hex(5, 1)
  let line = @types.hex_line(a, b)
  // First element should be start
  inspect(line[0].col == a.col && line[0].row == a.row, content="true")
  // Last element should be near end
  let last = line[line.length() - 1]
  inspect(@types.hex_distance(last, b) <= 1, content="true")
}

///|
test "hex_line single point" {
  let a = @types.hex(3, 3)
  let line = @types.hex_line(a, a)
  inspect(line.length(), content="1")
}

///|
test "terrain modifiers rock-paper-scissors balance" {
  // Infantry in forest: +2 DEF
  inspect(@types.terrain_def_bonus(Forest, Infantry), content="2")
  // Cavalry in forest: +1 DEF but -1 move penalty
  inspect(@types.terrain_def_bonus(Forest, Cavalry), content="1")
  inspect(@types.terrain_move_penalty(Forest, Cavalry), content="1")
  // Artillery on hills: +1 range, +1 ATK
  inspect(@types.terrain_range_bonus(Hills, Artillery), content="1")
  inspect(@types.terrain_atk_bonus(Hills, Plains), content="1")
  // Hills give sight bonus
  inspect(@types.terrain_sight_bonus(Hills), content="1")
  inspect(@types.terrain_sight_bonus(Plains), content="0")
}

///|
test "terrain_move_cost values are sensible" {
  // Plains should be cheapest
  let plains_cost = @types.terrain_move_cost(Plains)
  let forest_cost = @types.terrain_move_cost(Forest)
  let hills_cost = @types.terrain_move_cost(Hills)
  let water_cost = @types.terrain_move_cost(Water)
  inspect(plains_cost < forest_cost, content="true")
  inspect(plains_cost < hills_cost, content="true")
  inspect(water_cost > 100, content="true")
}

///|
test "unit base stats form triangle" {
  // Infantry: high HP (3), low ATK (2), medium move (2), melee
  // Cavalry: low HP (2), medium ATK (3), high move (4), melee
  // Artillery: low HP (2), high ATK (4), low move (1), ranged
  inspect(
    @types.unit_base_hp(Infantry) > @types.unit_base_hp(Cavalry),
    content="true",
  )
  inspect(
    @types.unit_base_atk(Artillery) > @types.unit_base_atk(Cavalry),
    content="true",
  )
  inspect(
    @types.unit_base_move(Cavalry) > @types.unit_base_move(Infantry),
    content="true",
  )
  inspect(
    @types.unit_base_range(Artillery) > @types.unit_base_range(Infantry),
    content="true",
  )
}

///|
test "effective ranges with terrain" {
  let b = @types.new_battle()
  // Place artillery on hills
  let hills_idx = @types.hex_index(@types.hex(3, 3), b.map.width)
  b.map.tiles[hills_idx].terrain = Hills
  let arty = @types.new_unit(0, Artillery, Player, 3, 3)
  let _ = @types.place_unit_on_map(b, arty)
  b.units = [arty]
  // Artillery on hills should have range 3 (base 2 + 1 bonus)
  inspect(@types.effective_attack_range(b, arty), content="3")
  // Effective sight on hills
  inspect(@types.effective_sight_range(arty, Hills), content="3")
}

///|
test "effective move range cavalry in forest" {
  let b = @types.new_battle()
  let forest_idx = @types.hex_index(@types.hex(5, 4), b.map.width)
  b.map.tiles[forest_idx].terrain = Forest
  let cav = @types.new_unit(0, Cavalry, Player, 5, 4)
  let _ = @types.place_unit_on_map(b, cav)
  b.units = [cav]
  // Cavalry in forest should have reduced move (4 - 1 = 3)
  inspect(@types.effective_move_range(b, cav), content="3")
}

///|
test "unit_kind_name" {
  inspect(@types.unit_kind_name(Infantry), content="Infantry")
  inspect(@types.unit_kind_name(Cavalry), content="Cavalry")
  inspect(@types.unit_kind_name(Artillery), content="Artillery")
}

///|
test "terrain_name" {
  inspect(@types.terrain_name(Plains), content="Plains")
  inspect(@types.terrain_name(Forest), content="Forest")
  inspect(@types.terrain_name(Hills), content="Hills")
  inspect(@types.terrain_name(Water), content="Water")
}

///|
test "rng_float is between 0 and 1" {
  @types.seed_rng(99)
  for _i in 0..<100 {
    let v = @types.rng_float()
    inspect(v >= 0.0 && v < 1.0, content="true")
  }
}

///|
test "rng deterministic with same seed" {
  @types.seed_rng(42)
  let a = @types.rng_next()
  let b = @types.rng_next()
  @types.seed_rng(42)
  let c = @types.rng_next()
  let d = @types.rng_next()
  inspect(a == c, content="true")
  inspect(b == d, content="true")
}

///|
test "rng_int zero max returns zero" {
  inspect(@types.rng_int(0), content="0")
  inspect(@types.rng_int(-5), content="0")
}

///|
test "maxf and minf" {
  inspect(@types.maxf(1.5, 2.5), content="2.5")
  inspect(@types.minf(1.5, 2.5), content="1.5")
}

///|
test "absf" {
  inspect(@types.absf(3.5), content="3.5")
  inspect(@types.absf(-3.5), content="3.5")
  inspect(@types.absf(0.0), content="0")
}

///|
test "sqrtf" {
  inspect(@types.sqrtf(4.0), content="2")
  inspect(@types.sqrtf(1.0), content="1")
}

///|
test "get_unit and get_unit_at" {
  let b = @types.new_battle()
  let u = @types.new_unit(0, Infantry, Player, 3, 3)
  let _ = @types.place_unit_on_map(b, u)
  b.units = [u]
  inspect(@types.get_unit(b, 0) is Some(_), content="true")
  inspect(@types.get_unit(b, 99) is None, content="true")
  inspect(@types.get_unit_at(b, @types.hex(3, 3)) is Some(_), content="true")
  inspect(@types.get_unit_at(b, @types.hex(0, 0)) is None, content="true")
}

///|
test "all_player_done" {
  let b = @types.new_battle()
  let u1 = @types.new_unit(0, Infantry, Player, 1, 1)
  let u2 = @types.new_unit(1, Infantry, Player, 2, 2)
  b.units = [u1, u2]
  inspect(@types.all_player_done(b), content="false")
  u1.moved = true
  u1.attacked = true
  inspect(@types.all_player_done(b), content="false")
  u2.moved = true
  u2.attacked = true
  inspect(@types.all_player_done(b), content="true")
}

///|
test "reset_team_turn" {
  let b = @types.new_battle()
  let u1 = @types.new_unit(0, Infantry, Player, 1, 1)
  let u2 = @types.new_unit(1, Infantry, Enemy, 8, 8)
  u1.moved = true
  u1.attacked = true
  u2.moved = true
  u2.attacked = true
  b.units = [u1, u2]
  @types.reset_team_turn(b, Player)
  inspect(u1.moved, content="false")
  inspect(u1.attacked, content="false")
  // Enemy should still be marked as acted
  inspect(u2.moved, content="true")
  inspect(u2.attacked, content="true")
}

///|
test "new_hex_map creates correct size" {
  let map = @types.new_hex_map(5, 3)
  inspect(map.width, content="5")
  inspect(map.height, content="3")
  inspect(map.tiles.length(), content="15")
}
