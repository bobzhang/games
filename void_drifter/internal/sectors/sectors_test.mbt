///|
test "sector_name returns correct names" {
  inspect(@sectors.sector_name(Asteroids), content="ASTEROID FIELD")
  inspect(@sectors.sector_name(Nebula), content="NEBULA")
  inspect(@sectors.sector_name(Station), content="STATION")
  inspect(@sectors.sector_name(BossArena), content="BOSS ARENA")
  inspect(@sectors.sector_name(EliteZone), content="ELITE ZONE")
  inspect(@sectors.sector_name(EmptySpace), content="EMPTY SPACE")
}

///|
test "generate_sector_map creates valid graph" {
  @types.seed_rng(42)
  let map = @sectors.generate_sector_map(0)
  // Should have start node + layers * nodes_per_layer nodes
  inspect(map.nodes.length() > 0, content="true")
  // Start node should be cleared
  inspect(map.nodes[0].cleared, content="true")
  inspect(map.current, content="0")
  // Start should have connections
  inspect(map.nodes[0].connections.length() > 0, content="true")
  // Boss node should be BossArena
  inspect(map.nodes[map.boss_node].kind, content="BossArena")
}

///|
test "generate_sector_map has correct node count" {
  @types.seed_rng(99)
  let map = @sectors.generate_sector_map(0)
  // 1 start + sector_map_layers * nodes_per_layer = 1 + 4*3 = 13
  let expected = 1 + @types.sector_map_layers * @types.nodes_per_layer
  inspect(map.nodes.length(), content=expected.to_string())
}

///|
test "sector map start node is EmptySpace and cleared" {
  @types.seed_rng(7)
  let map = @sectors.generate_sector_map(0)
  inspect(map.nodes[0].kind, content="EmptySpace")
  inspect(map.nodes[0].cleared, content="true")
  inspect(map.nodes[0].enemy_count, content="0")
}

///|
test "sector map last layer is all BossArena" {
  @types.seed_rng(123)
  let map = @sectors.generate_sector_map(1)
  let layers = @types.sector_map_layers
  let per_layer = @types.nodes_per_layer
  let last_layer_start = 1 + (layers - 1) * per_layer
  for i in 0..<per_layer {
    inspect(map.nodes[last_layer_start + i].kind, content="BossArena")
  }
}

///|
test "sector map all layer 1 nodes reachable from start" {
  @types.seed_rng(55)
  let map = @sectors.generate_sector_map(0)
  let per_layer = @types.nodes_per_layer
  // Start should connect to all layer 1 nodes
  inspect(map.nodes[0].connections.length(), content=per_layer.to_string())
  for i in 0..<per_layer {
    let target_idx = 1 + i
    inspect(map.nodes[0].connections.contains(target_idx), content="true")
  }
}

///|
test "sector map every non-start node has at least one incoming connection" {
  @types.seed_rng(42)
  let map = @sectors.generate_sector_map(0)
  // Check that every node (except start) is reachable from some earlier node
  for target_idx in 1..<map.nodes.length() {
    let mut has_incoming = false
    for src_idx in 0..<map.nodes.length() {
      if map.nodes[src_idx].connections.contains(target_idx) {
        has_incoming = true
        break
      }
    }
    inspect(has_incoming, content="true")
  }
}

///|
test "sector map pre-boss layer connects to boss node" {
  @types.seed_rng(77)
  let map = @sectors.generate_sector_map(0)
  let layers = @types.sector_map_layers
  let per_layer = @types.nodes_per_layer
  let pre_boss_start = 1 + (layers - 2) * per_layer
  for i in 0..<per_layer {
    let idx = pre_boss_start + i
    inspect(
      map.nodes[idx].connections.contains(map.boss_node),
      content="true",
    )
  }
}

///|
test "sector map enemy count increases with depth and layer" {
  @types.seed_rng(42)
  let map_d0 = @sectors.generate_sector_map(0)
  @types.seed_rng(42)
  let map_d3 = @sectors.generate_sector_map(3)
  // Same layer, deeper map should have more enemies
  let node_d0 = map_d0.nodes[1]
  let node_d3 = map_d3.nodes[1]
  inspect(node_d3.enemy_count > node_d0.enemy_count, content="true")
}

///|
test "sector map no duplicate connections" {
  @types.seed_rng(42)
  let map = @sectors.generate_sector_map(0)
  for i in 0..<map.nodes.length() {
    let conns = map.nodes[i].connections
    for a in 0..<conns.length() {
      for b in (a + 1)..<conns.length() {
        inspect(conns[a] == conns[b], content="false")
      }
    }
  }
}

///|
test "can_travel_to checks connections" {
  @types.seed_rng(42)
  let map = @sectors.generate_sector_map(0)
  // Can travel to connected nodes from start
  let first_conn = map.nodes[0].connections[0]
  inspect(@sectors.can_travel_to(map, first_conn), content="true")
  // Can't travel to non-connected node
  inspect(@sectors.can_travel_to(map, map.boss_node), content="false")
}

///|
test "can_travel_to rejects self-travel" {
  @types.seed_rng(42)
  let map = @sectors.generate_sector_map(0)
  // Start node does not connect to itself
  inspect(@sectors.can_travel_to(map, 0), content="false")
}

///|
test "generate_shop_items creates items" {
  @types.seed_rng(42)
  let game = @types.new_game()
  @sectors.generate_shop_items(game)
  inspect(game.shop_items.length(), content="5")
  // First item is always repair kit
  inspect(game.shop_items[0].name, content="REPAIR KIT")
  // Second is shield cell
  inspect(game.shop_items[1].name, content="SHIELD CELL")
}

///|
test "shop items have correct costs" {
  @types.seed_rng(42)
  let game = @types.new_game()
  @sectors.generate_shop_items(game)
  inspect(game.shop_items[0].cost, content=@types.shop_heal_cost.to_string())
  inspect(
    game.shop_items[1].cost,
    content=@types.shop_shield_cost.to_string(),
  )
  inspect(game.shop_items[2].cost, content=@types.shop_mod_cost.to_string())
  inspect(game.shop_items[3].cost, content=@types.shop_mod_cost.to_string())
  inspect(
    game.shop_items[4].cost,
    content=@types.shop_weapon_cost.to_string(),
  )
}

///|
test "shop items start unpurchased" {
  @types.seed_rng(42)
  let game = @types.new_game()
  @sectors.generate_shop_items(game)
  for i in 0..<game.shop_items.length() {
    inspect(game.shop_items[i].purchased, content="false")
  }
}

///|
test "shop item effects have correct types" {
  @types.seed_rng(42)
  let game = @types.new_game()
  @sectors.generate_shop_items(game)
  // Item 0 is always HealthPack
  inspect(game.shop_items[0].effect, content="HealthPack")
  // Item 1 is always ShieldRecharge
  inspect(game.shop_items[1].effect, content="ShieldRecharge")
}

///|
test "sector map depth is preserved" {
  @types.seed_rng(42)
  let map = @sectors.generate_sector_map(5)
  inspect(map.depth, content="5")
}

///|
test "sector map connections only go forward" {
  @types.seed_rng(42)
  let map = @sectors.generate_sector_map(0)
  for i in 0..<map.nodes.length() {
    let node = map.nodes[i]
    for c in 0..<node.connections.length() {
      let target = node.connections[c]
      // Target node should be in a later layer
      inspect(map.nodes[target].x > node.x, content="true")
    }
  }
}
