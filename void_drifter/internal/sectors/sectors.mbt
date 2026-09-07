///|
pub fn generate_sector_map(depth : Int) -> @types.SectorMap {
  let nodes : Array[@types.SectorNode] = []
  let layers = @types.sector_map_layers
  let per_layer = @types.nodes_per_layer
  // Layer 0: start node
  nodes.push({
    kind: EmptySpace,
    x: 0,
    y: 1,
    cleared: true,
    connections: [],
    enemy_count: 0,
    has_shop: false,
    reward_tier: 0,
    elite: false,
  })
  // Middle layers
  for layer in 1..<=layers {
    for i in 0..<per_layer {
      let kind = if layer == layers {
        @types.SectorKind::BossArena
      } else {
        random_sector_kind(depth + layer)
      }
      let elite = layer >= 2 && @types.rng_int(100) < 20
      let has_shop = !elite && @types.rng_int(100) < 30
      nodes.push({
        kind,
        x: layer,
        y: i,
        cleared: false,
        connections: [],
        enemy_count: 3 + layer + depth,
        has_shop,
        reward_tier: layer,
        elite,
      })
    }
  }
  // Connect layers
  // Start connects to all layer 1 nodes
  for i in 0..<per_layer {
    nodes[0].connections.push(1 + i)
  }
  // Each subsequent layer connects forward
  for layer in 1..<layers {
    let layer_start = 1 + (layer - 1) * per_layer
    let next_start = 1 + layer * per_layer
    for i in 0..<per_layer {
      let node_idx = layer_start + i
      // Connect to 1-2 nodes in next layer
      let primary = next_start + i
      if primary < nodes.length() {
        nodes[node_idx].connections.push(primary)
      }
      // Sometimes connect to adjacent node too
      if @types.rng_int(100) < 50 {
        let alt = if i + 1 < per_layer {
          next_start + i + 1
        } else {
          next_start + i - 1
        }
        if alt >= next_start &&
          alt < next_start + per_layer &&
          alt < nodes.length() {
          let already = nodes[node_idx].connections.contains(alt)
          if !already {
            nodes[node_idx].connections.push(alt)
          }
        }
      }
    }
  }
  // Boss node is the last one
  let boss_node = nodes.length() - 1
  // Ensure all last-layer-before-boss connect to boss
  let pre_boss_start = 1 + (layers - 2) * per_layer
  for i in 0..<per_layer {
    let idx = pre_boss_start + i
    if idx < nodes.length() && !nodes[idx].connections.contains(boss_node) {
      nodes[idx].connections.push(boss_node)
    }
  }
  { nodes, current: 0, depth, boss_node, }
}

///|
fn random_sector_kind(seed : Int) -> @types.SectorKind {
  let roll = (@types.rng_int(100) + seed) % 100
  if roll < 30 {
    Asteroids
  } else if roll < 55 {
    Nebula
  } else if roll < 75 {
    Station
  } else {
    EliteZone
  }
}

///|
pub fn sector_name(kind : @types.SectorKind) -> String {
  match kind {
    Asteroids => "ASTEROID FIELD"
    Nebula => "NEBULA"
    Station => "STATION"
    BossArena => "BOSS ARENA"
    EliteZone => "ELITE ZONE"
    EmptySpace => "EMPTY SPACE"
  }
}

///|
pub fn can_travel_to(map : @types.SectorMap, target : Int) -> Bool {
  let current = map.nodes[map.current]
  current.connections.contains(target)
}

///|
pub fn enter_sector(game : @types.Game, node_idx : Int) -> Unit {
  match game.sector_map {
    None => ()
    Some(map) => {
      map.current = node_idx
      let node = map.nodes[node_idx]
      game.current_sector_kind = node.kind
      game.sector_enemies_total = 0 // Track only actual spawns
      game.sector_enemies_killed = 0
      game.sector_cleared = false
      game.wave_count = 0
      game.wave_timer = 1.5 // Brief grace period
      // Clear old entities
      for i in 0..<game.enemies.length() {
        game.enemies[i].active = false
      }
      for i in 0..<game.projectiles.length() {
        game.projectiles[i].active = false
      }
      for i in 0..<game.asteroids.length() {
        game.asteroids[i].active = false
      }
      for i in 0..<game.pickups.length() {
        game.pickups[i].active = false
      }
      game.hazards = []
      // Spawn initial asteroids for asteroid fields
      if node.kind == Asteroids {
        spawn_asteroids(game, 8)
      }
      // Boss arena
      if node.kind == BossArena {
        game.boss_intro_timer = @types.boss_intro_duration
        game.screen = BossIntro
      } else {
        game.screen = Playing
      }
      @types.push_sound(game, SectorEnter)
      @types.set_message(game, sector_name(node.kind), 2.0)
    }
  }
}

///|
fn spawn_asteroids(game : @types.Game, count : Int) -> Unit {
  for _i in 0..<count {
    for j in 0..<game.asteroids.length() {
      if !game.asteroids[j].active {
        let ast = game.asteroids[j]
        ast.active = true
        ast.pos = @types.vec2(
          @types.rng_range(100.0, game.arena_width - 100.0),
          @types.rng_range(100.0, game.arena_height - 100.0),
        )
        ast.vel = @types.vec2(
          @types.rng_range(-30.0, 30.0),
          @types.rng_range(-30.0, 30.0),
        )
        ast.radius = @types.rng_range(15.0, 40.0)
        ast.angle = @types.rng_float() * 6.28
        ast.spin = @types.rng_range(-1.0, 1.0)
        ast.hp = @types.asteroid_base_hp
        break
      }
    }
  }
}

///|
pub fn generate_shop_items(game : @types.Game) -> Unit {
  game.shop_items = []
  // Health
  game.shop_items.push({
    name: "REPAIR KIT",
    description: "+2 HP",
    cost: @types.shop_heal_cost,
    purchased: false,
    effect: HealthPack,
  })
  // Shield
  game.shop_items.push({
    name: "SHIELD CELL",
    description: "+2 Shield",
    cost: @types.shop_shield_cost,
    purchased: false,
    effect: ShieldRecharge,
  })
  // Random weapon mod
  let mods : Array[@types.ModKind] = [
    Piercing,
    Homing,
    Split,
    Chain,
    Explosive,
    Freezing,
    Bouncing,
    Overcharge,
  ]
  let mod_kind = mods[@types.rng_int(mods.length())]
  game.shop_items.push({
    name: @weapons.mod_name(mod_kind),
    description: "Primary weapon mod",
    cost: @types.shop_mod_cost,
    purchased: false,
    effect: WeaponMod(mod_kind),
  })
  // Random utility mod
  let utils : Array[@types.UtilityMod] = [
    ShieldDrain,
    Vampire,
    HeatSink,
    Accelerator,
  ]
  let util_kind = utils[@types.rng_int(utils.length())]
  game.shop_items.push({
    name: @weapons.utility_name(util_kind),
    description: "Utility slot",
    cost: @types.shop_mod_cost,
    purchased: false,
    effect: UtilityPickup(util_kind),
  })
  // Random weapon
  let weapons : Array[@types.WeaponKind] = [
    Laser,
    Shotgun,
    Missile,
    Railgun,
    Flak,
    Beam,
  ]
  let wpn = weapons[@types.rng_int(weapons.length())]
  game.shop_items.push({
    name: @weapons.weapon_name(wpn),
    description: "Secondary weapon",
    cost: @types.shop_weapon_cost,
    purchased: false,
    effect: WeaponDrop(wpn),
  })
}
