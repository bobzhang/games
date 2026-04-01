///|
test "absf" {
  inspect(absf(-5.0), content="5")
  inspect(absf(3.0), content="3")
  inspect(absf(0.0), content="0")
}

///|
test "maxf and minf" {
  inspect(maxf(3.0, 7.0), content="7")
  inspect(maxf(10.0, 2.0), content="10")
  inspect(minf(3.0, 7.0), content="3")
  inspect(minf(10.0, 2.0), content="2")
}

///|
test "clampf" {
  inspect(clampf(5.0, 0.0, 10.0), content="5")
  inspect(clampf(-1.0, 0.0, 10.0), content="0")
  inspect(clampf(15.0, 0.0, 10.0), content="10")
}

///|
test "lerpf" {
  inspect(lerpf(0.0, 10.0, 0.5), content="5")
  inspect(lerpf(0.0, 10.0, 0.0), content="0")
  inspect(lerpf(0.0, 10.0, 1.0), content="10")
}

///|
test "mini and maxi" {
  inspect(mini(3, 7), content="3")
  inspect(mini(10, 2), content="2")
  inspect(maxi(3, 7), content="7")
  inspect(maxi(10, 2), content="10")
}

///|
test "vec2i constructor" {
  let v = vec2i(4, 9)
  inspect(v.x, content="4")
  inspect(v.y, content="9")
}

///|
test "grid_to_screen and screen_to_grid round trip" {
  let sx = grid_to_screen_x(3, 100)
  let sy = grid_to_screen_y(5, 50)
  // grid_to_screen: offset + col * cell_size + cell_size / 2
  inspect(sx, content="324")
  inspect(sy, content="402")
  // screen_to_grid: (s - offset) / cell_size
  inspect(screen_to_grid_x(sx, 100), content="3")
  inspect(screen_to_grid_y(sy, 50), content="5")
}

///|
test "new_node" {
  let n = new_node(7, 3, 4, Pulley)
  inspect(n.id, content="7")
  inspect(n.pos.x, content="3")
  inspect(n.pos.y, content="4")
  inspect(n.kind, content="Pulley")
  inspect(n.left_conn, content="-1")
  inspect(n.right_conn, content="-1")
  inspect(n.height, content="0")
  inspect(n.locked, content="false")
}

///|
test "new_rope defaults" {
  let r = new_rope()
  inspect(r.active, content="false")
  inspect(r.from_node, content="-1")
  inspect(r.to_node, content="-1")
  inspect(r.from_side, content="LeftSide")
  inspect(r.to_side, content="RightSide")
  inspect(r.broken, content="false")
  inspect(r.breakable, content="false")
}

///|
test "new_weight" {
  let w = new_weight(2, 5.0)
  inspect(w.active, content="true")
  inspect(w.node_id, content="2")
  inspect(w.mass, content="5")
  inspect(w.current_y, content="0")
  inspect(w.target_y, content="0")
}

///|
test "new_crate" {
  let c = new_crate(1, 3.5, 2.0)
  inspect(c.active, content="true")
  inspect(c.node_id, content="1")
  inspect(c.mass, content="3.5")
  inspect(c.target_height, content="2")
  inspect(c.at_target, content="false")
}

///|
test "new_platform" {
  let p = new_platform(4, 2.5)
  inspect(p.active, content="true")
  inspect(p.node_id, content="4")
  inspect(p.width, content="2.5")
  inspect(p.connected_to, content="-1")
}

///|
test "new_bucket" {
  let b = new_bucket(3, 1.0, 10.0, 0.5)
  inspect(b.active, content="true")
  inspect(b.node_id, content="3")
  inspect(b.mass, content="1")
  inspect(b.max_mass, content="10")
  inspect(b.fill_rate, content="0.5")
  inspect(b.filling, content="false")
}

///|
test "new_level_score" {
  let s = new_level_score()
  inspect(s.completed, content="false")
  inspect(s.stars, content="0")
  inspect(s.connections_used, content="0")
  inspect(s.rehooks, content="0")
}

///|
test "tier_name" {
  inspect(tier_name(Basics), content="Basics")
  inspect(tier_name(Chains), content="Chains")
  inspect(tier_name(Workshop), content="Workshop")
}

///|
test "tier_from_index" {
  inspect(tier_from_index(0), content="Basics")
  inspect(tier_from_index(1), content="Chains")
  inspect(tier_from_index(2), content="Workshop")
  inspect(tier_from_index(99), content="Workshop")
}

///|
test "level_index_for_tier" {
  inspect(level_index_for_tier(0, 3), content="3")
  inspect(level_index_for_tier(1, 2), content="10")
  inspect(level_index_for_tier(2, 0), content="17")
}

///|
test "levels_in_tier" {
  inspect(levels_in_tier(0), content="8")
  inspect(levels_in_tier(1), content="9")
  inspect(levels_in_tier(2), content="8")
}

///|
test "tier_unlocked" {
  let scores : Array[LevelScore] = []
  for _i in 0..<total_levels {
    scores.push(new_level_score())
  }
  // Tier 0 always unlocked
  inspect(tier_unlocked(scores, 0), content="true")
  // Tier 1 needs 4 completed in tier 0
  inspect(tier_unlocked(scores, 1), content="false")
  for i in 0..<4 {
    scores[i].completed = true
  }
  inspect(tier_unlocked(scores, 1), content="true")
  // Tier 2 needs 5 completed in tier 1
  inspect(tier_unlocked(scores, 2), content="false")
  for i in tier1_levels..<(tier1_levels + 5) {
    scores[i].completed = true
  }
  inspect(tier_unlocked(scores, 2), content="true")
}

///|
test "total_stars" {
  let scores : Array[LevelScore] = []
  for _i in 0..<3 {
    scores.push(new_level_score())
  }
  scores[0].stars = 3
  scores[1].stars = 1
  scores[2].stars = 2
  inspect(total_stars(scores), content="6")
}

///|
test "find_node_at" {
  let nodes : Array[Node] = [
    new_node(0, 2, 3, Pulley),
    new_node(1, 5, 7, Anchor),
  ]
  inspect(find_node_at(nodes, 2, 3), content="0")
  inspect(find_node_at(nodes, 5, 7), content="1")
  inspect(find_node_at(nodes, 0, 0), content="-1")
}

///|
test "can_connect" {
  let n = new_node(0, 0, 0, Pulley)
  inspect(can_connect(n, LeftSide), content="true")
  inspect(can_connect(n, RightSide), content="true")
  n.left_conn = 5
  inspect(can_connect(n, LeftSide), content="false")
  inspect(can_connect(n, RightSide), content="true")
}

///|
test "count_connections" {
  let game = new_game()
  inspect(count_connections(game), content="0")
  let r1 = new_rope()
  r1.active = true
  game.ropes.push(r1)
  inspect(count_connections(game), content="1")
  let r2 = new_rope()
  r2.active = true
  r2.broken = true
  game.ropes.push(r2)
  inspect(count_connections(game), content="1")
}

///|
test "node_screen_x and node_screen_y" {
  let n = new_node(0, 3, 5, Pulley)
  // node_screen_x = grid_to_screen_x(3, offset_x) = offset_x + 3*64 + 32
  let sx = node_screen_x(n, 100)
  inspect(sx, content="324")
  // node_screen_y = grid_to_screen_y(5, offset_y) + height * cell_size
  let sy = node_screen_y(n, 50)
  inspect(sy, content="402")
}

///|
test "set_message" {
  let game = new_game()
  set_message(game, "Hello", 2.5)
  inspect(game.message, content="Hello")
  inspect(game.message_timer, content="2.5")
}

///|
test "sinf and cosf basic values" {
  // sin(0) = 0, cos(0) = 1
  let s = sinf(0.0)
  let c = cosf(0.0)
  inspect(s, content="0")
  inspect(c, content="1")
}
