///|
test "sector_name returns correct names" {
  inspect(@sectors.sector_name(Asteroids), content="ASTEROID FIELD")
  inspect(@sectors.sector_name(Nebula), content="NEBULA")
  inspect(@sectors.sector_name(Station), content="STATION")
  inspect(@sectors.sector_name(BossArena), content="BOSS ARENA")
  inspect(@sectors.sector_name(EliteZone), content="ELITE ZONE")
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
