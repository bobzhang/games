// campaign.mbt - Campaign map with branching paths.
// Instead of linear missions, show a branching node graph where
// the player chooses which path to take. Paths converge at boss missions.

///|
/// Build the campaign map: 3 columns of choice nodes, converging at bosses.
/// Layout: Start -> Branch (3 paths) -> Boss 1 -> Branch (3 paths) -> Boss 2
pub fn build_campaign_map() -> @types.CampaignMap {
  let nodes : Array[@types.CampaignNode] = []
  // Column 0: Starting mission (1 node)
  nodes.push({
    id: 0,
    kind: Mission(0),
    x: 0,
    y: 2,
    connections: [1, 2, 3],
    difficulty: 1,
    reward_icon: "A",
    theme: Neutral,
  })
  // Column 1: Three branching paths with themes
  // Path A: "Scorched Earth" - fire-themed
  nodes.push({
    id: 1,
    kind: Mission(1),
    x: 1,
    y: 0,
    connections: [4, 5],
    difficulty: 1,
    reward_icon: "A",
    theme: ScorchedEarth,
  })
  // Path B: "Ice Protocol" - mobility-themed
  nodes.push({
    id: 2,
    kind: Mission(2),
    x: 1,
    y: 2,
    connections: [5, 6],
    difficulty: 2,
    reward_icon: "G",
    theme: IceProtocol,
  })
  // Path C: "Void Zone" - push-themed
  nodes.push({
    id: 3,
    kind: Mission(3),
    x: 1,
    y: 4,
    connections: [6, 7],
    difficulty: 2,
    reward_icon: "A",
    theme: VoidZone,
  })
  // Column 2: Mid-tier nodes (rest/shop/event/elite)
  nodes.push({
    id: 4,
    kind: Rest,
    x: 2,
    y: 0,
    connections: [8],
    difficulty: 0,
    reward_icon: "R",
    theme: ScorchedEarth,
  })
  nodes.push({
    id: 5,
    kind: Event,
    x: 2,
    y: 1,
    connections: [8, 9],
    difficulty: 0,
    reward_icon: "?",
    theme: Neutral,
  })
  nodes.push({
    id: 6,
    kind: Shop,
    x: 2,
    y: 3,
    connections: [9, 10],
    difficulty: 0,
    reward_icon: "G",
    theme: Neutral,
  })
  nodes.push({
    id: 7,
    kind: Elite(3),
    x: 2,
    y: 4,
    connections: [10],
    difficulty: 3,
    reward_icon: "A",
    theme: VoidZone,
  })
  // Column 3: Boss 1 approach
  nodes.push({
    id: 8,
    kind: Mission(5),
    x: 3,
    y: 0,
    connections: [11],
    difficulty: 2,
    reward_icon: "A",
    theme: ScorchedEarth,
  })
  nodes.push({
    id: 9,
    kind: Mission(6),
    x: 3,
    y: 2,
    connections: [11],
    difficulty: 2,
    reward_icon: "G",
    theme: IceProtocol,
  })
  nodes.push({
    id: 10,
    kind: Mission(7),
    x: 3,
    y: 4,
    connections: [11],
    difficulty: 2,
    reward_icon: "A",
    theme: VoidZone,
  })
  // Column 4: Boss 1 (Siege Engine)
  nodes.push({
    id: 11,
    kind: Boss(4),
    x: 4,
    y: 2,
    connections: [12, 13, 14],
    difficulty: 3,
    reward_icon: "A",
    theme: Neutral,
  })
  // Column 5: Post-boss rest/event nodes
  nodes.push({
    id: 12,
    kind: Rest,
    x: 5,
    y: 0,
    connections: [15],
    difficulty: 0,
    reward_icon: "R",
    theme: Neutral,
  })
  nodes.push({
    id: 13,
    kind: Event,
    x: 5,
    y: 2,
    connections: [15],
    difficulty: 0,
    reward_icon: "?",
    theme: Neutral,
  })
  nodes.push({
    id: 14,
    kind: Shop,
    x: 5,
    y: 4,
    connections: [15],
    difficulty: 0,
    reward_icon: "G",
    theme: Neutral,
  })
  // Column 6: Final boss (Hivemind)
  nodes.push({
    id: 15,
    kind: Boss(8),
    x: 6,
    y: 2,
    connections: [],
    difficulty: 3,
    reward_icon: "A",
    theme: Neutral,
  })
  { nodes, selected_node: 0, completed_nodes: [] }
}

///|
/// Check if a node is available to select (connected from a completed node).
pub fn is_node_available(campaign : @types.CampaignMap, node_id : Int) -> Bool {
  // The first node is always available if nothing completed
  if campaign.completed_nodes.length() == 0 && node_id == 0 {
    return true
  }
  // Otherwise, check if any completed node connects to this one
  for i = 0; i < campaign.completed_nodes.length(); i = i + 1 {
    let cid = campaign.completed_nodes[i]
    if cid >= 0 && cid < campaign.nodes.length() {
      let completed_node = campaign.nodes[cid]
      for j = 0; j < completed_node.connections.length(); j = j + 1 {
        if completed_node.connections[j] == node_id {
          return true
        }
      }
    }
  }
  false
}

///|
/// Check if a node is already completed.
pub fn is_node_completed(campaign : @types.CampaignMap, node_id : Int) -> Bool {
  for i = 0; i < campaign.completed_nodes.length(); i = i + 1 {
    if campaign.completed_nodes[i] == node_id {
      return true
    }
  }
  false
}

///|
/// Get the mission ID for a campaign node.
pub fn get_node_mission_id(campaign : @types.CampaignMap, node_id : Int) -> Int {
  if node_id < 0 || node_id >= campaign.nodes.length() {
    return 0
  }
  let node = campaign.nodes[node_id]
  match node.kind {
    Mission(mid) => mid
    Boss(mid) => mid
    Elite(mid) => mid
    Rest | Shop | Event => -1
  }
}

///|
/// Get the name for a campaign node.
pub fn get_node_name(node : @types.CampaignNode) -> String {
  match node.kind {
    Mission(mid) => @content.get_mission_def(mid).name
    Boss(mid) => @content.get_mission_def(mid).name
    Elite(mid) => "ELITE: " + @content.get_mission_def(mid).name
    Rest => "Rest Stop"
    Shop => "Augment Shop"
    Event => "Unknown Signal"
  }
}

///|
/// Get available (selectable) node IDs for the player.
pub fn get_available_nodes(campaign : @types.CampaignMap) -> Array[Int] {
  let available : Array[Int] = []
  for i = 0; i < campaign.nodes.length(); i = i + 1 {
    if is_node_available(campaign, i) && !is_node_completed(campaign, i) {
      available.push(i)
    }
  }
  available
}

///|
/// Handle campaign screen input.
pub fn update_campaign(game : @types.Game) -> Unit {
  let campaign = match game.run.campaign {
    Some(c) => c
    None => {
      // Initialize campaign if not created yet
      let c = build_campaign_map()
      game.run.campaign = Some(c)
      return
    }
  }
  let available = get_available_nodes(campaign)
  if available.length() == 0 {
    // All nodes completed - run victory summary
    game.screen = RunSummary
    return
  }
  // Navigate between available nodes
  if @raylib.is_key_pressed(@raylib.KeyRight) ||
    @raylib.is_key_pressed(@raylib.KeyDown) {
    // Find next available node
    let mut current_idx = -1
    for i = 0; i < available.length(); i = i + 1 {
      if available[i] == campaign.selected_node {
        current_idx = i
      }
    }
    let next = (current_idx + 1) % available.length()
    campaign.selected_node = available[next]
  }
  if @raylib.is_key_pressed(@raylib.KeyLeft) ||
    @raylib.is_key_pressed(@raylib.KeyUp) {
    let mut current_idx = -1
    for i = 0; i < available.length(); i = i + 1 {
      if available[i] == campaign.selected_node {
        current_idx = i
      }
    }
    let next = if current_idx <= 0 {
      available.length() - 1
    } else {
      current_idx - 1
    }
    campaign.selected_node = available[next]
  }
  // Select node and start mission
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    let node_id = campaign.selected_node
    if is_node_available(campaign, node_id) &&
      !is_node_completed(campaign, node_id) {
      let node = campaign.nodes[node_id]
      match node.kind {
        Rest => {
          // Rest: heal all mechs 50% HP
          apply_rest_heal(game)
          campaign.completed_nodes.push(node_id)
          game.message_text = "Rest complete. Mechs healed 50%."
          game.message_timer = 2.5
          return
        }
        Shop => {
          // Shop: offer 3 augments to buy with GP
          let seed : Ref[UInt] = {
            val: (node_id * 7919 + 42).reinterpret_as_uint(),
          }
          game.run.offered_augments = @content.pick_random_augments(
            seed,
            game.run.augments,
            3,
          )
          game.screen = Reward
          campaign.completed_nodes.push(node_id)
          game.message_text = "Choose an augment (costs 2 GP each)."
          game.message_timer = 3.0
          return
        }
        Event => {
          // Event: resolve based on random event type
          apply_event_node(game, node_id)
          campaign.completed_nodes.push(node_id)
          return
        }
        _ => {
          let mission_id = get_node_mission_id(campaign, node_id)
          if mission_id >= 0 {
            game.run.current_mission = mission_id
            setup_mission_from_def(game, mission_id)
            game.screen = MissionBriefing
            game.message_text = ""
            game.message_timer = 0.0
          }
        }
      }
    }
  }
  // Ensure selected node is available
  let mut is_valid = false
  for i = 0; i < available.length(); i = i + 1 {
    if available[i] == campaign.selected_node {
      is_valid = true
    }
  }
  if !is_valid && available.length() > 0 {
    campaign.selected_node = available[0]
  }
}

///|
/// Set up a battle from a mission definition (used by campaign).
pub fn setup_mission_from_def(game : @types.Game, mission_id : Int) -> Unit {
  let def = @content.get_mission_def(mission_id)
  let battle = @types.new_battle(def.objective)
  battle.mission_id = mission_id
  battle.augments = game.run.augments
  // 1. Place procedural terrain first
  place_terrain(battle, mission_id)
  // 2. THEN apply mission-specific tiles (authored layout overrides procedural)
  for i = 0; i < def.special_tiles.length(); i = i + 1 {
    let (tx, ty, tkind) = def.special_tiles[i]
    if battle.grid.in_bounds(tx, ty) {
      battle.grid.set(tx, ty, { kind: tkind, hazard: None, occupied_by: -1 })
    }
  }
  // Place hazard tiles from mission definition
  for i = 0; i < def.hazard_tiles.length(); i = i + 1 {
    let (hx, hy, hkind) = def.hazard_tiles[i]
    if battle.grid.in_bounds(hx, hy) {
      let tile = battle.grid.get(hx, hy)
      battle.grid.set(hx, hy, { ..tile, hazard: hkind })
    }
  }
  // Place 3 player mechs with augment-modified stats
  let classes : Array[@types.MechClass] = [Vanguard, Striker, Sentinel]
  for i = 0; i < 3; i = i + 1 {
    let stats = @content.get_augmented_mech_stats(classes[i], game.run.augments)
    let tier = @content.get_upgrade_tier(game.run, classes[i])
    // Apply tier 1 stat bonuses
    let (hp, move_range, _ability_range, _ability_damage) = @content.apply_upgrade_stats(
      classes[i],
      tier,
      stats.hp,
      stats.move_range,
      stats.ability_range,
      stats.ability_damage,
    )
    ignore(move_range)
    let px = 1
    let py = 1 + i * 3
    let mut shield = 0
    // ShieldGenerator augment: start with 2 shield
    if @types.has_augment(game.run, ShieldGenerator) {
      shield = 2
    }
    // Persistent HP: use saved HP if available and > 0
    let actual_hp = if i < game.run.mech_hp.length() && game.run.mech_hp[i] > 0 {
      if game.run.mech_hp[i] > hp {
        hp
      } else {
        game.run.mech_hp[i]
      }
    } else {
      hp
    }
    let u : @types.CombatUnit = {
      id: i,
      active: actual_hp > 0,
      team: Player,
      x: px,
      y: py,
      hp: actual_hp,
      max_hp: hp,
      shield,
      heat: 0,
      max_heat: stats.max_heat,
      stunned: false,
      moved_this_turn: false,
      acted_this_turn: false,
      mech_class: classes[i],
      enemy_type: Rammer,
      intent: March(px, py),
      statuses: [],
      upgrade_tier: tier,
      orbital_used: false,
    }
    battle.units.push(u)
    if battle.grid.in_bounds(px, py) {
      battle.grid.set(px, py, { ..battle.grid.get(px, py), occupied_by: u.id })
    }
  }
  // Spawn enemies from mission definition
  spawn_mission_enemies(battle, def)
  // Generate initial intents
  generate_enemy_intents(battle)
  game.battle = Some(battle)
}

///|
/// Spawn enemies from a mission definition.
fn spawn_mission_enemies(
  battle : @types.BattleState,
  def : @content.MissionDef,
) -> Unit {
  let base_id = 3 // player mechs are 0,1,2
  for i = 0; i < def.enemy_types.length(); i = i + 1 {
    let (etype, ex, ey) = def.enemy_types[i]
    let eid = base_id + i
    let ehp = if etype == Boss {
      @content.get_boss_hp(def.id)
    } else {
      @content.get_enemy_hp(etype)
    }
    let mut actual_x = ex
    let mut actual_y = ey
    // If tile is occupied, find nearby free tile
    if battle.grid.in_bounds(actual_x, actual_y) {
      let tile = battle.grid.get(actual_x, actual_y)
      if tile.occupied_by >= 0 || tile.kind == Wall || tile.kind == Chasm {
        let dx_arr = [0, 1, -1, 0, 0, 1, -1, 1, -1]
        let dy_arr = [0, 0, 0, 1, -1, 1, -1, -1, 1]
        for d = 0; d < 9; d = d + 1 {
          let nx = ex + dx_arr[d]
          let ny = ey + dy_arr[d]
          if battle.grid.in_bounds(nx, ny) {
            let nt = battle.grid.get(nx, ny)
            if nt.occupied_by < 0 && nt.kind == Floor {
              actual_x = nx
              actual_y = ny
              break
            }
          }
        }
      }
    }
    let eu : @types.CombatUnit = {
      id: eid,
      active: true,
      team: Enemy,
      x: actual_x,
      y: actual_y,
      hp: ehp,
      max_hp: ehp,
      shield: if etype == Boss {
        2
      } else {
        0
      },
      heat: 0,
      max_heat: 0,
      stunned: false,
      moved_this_turn: false,
      acted_this_turn: false,
      mech_class: Vanguard,
      enemy_type: etype,
      intent: March(actual_x, actual_y),
      statuses: [],
      upgrade_tier: 0,
      orbital_used: false,
    }
    battle.units.push(eu)
    if battle.grid.in_bounds(actual_x, actual_y) {
      battle.grid.set(actual_x, actual_y, {
        ..battle.grid.get(actual_x, actual_y),
        occupied_by: eu.id,
      })
    }
  }
}

///|
/// Apply rest node: heal all mechs' persistent HP by 50%.
fn apply_rest_heal(game : @types.Game) -> Unit {
  // If mech_hp tracking is initialized (non-zero), heal 50%
  let classes : Array[@types.MechClass] = [Vanguard, Striker, Sentinel]
  for i = 0; i < 3; i = i + 1 {
    let stats = @content.get_augmented_mech_stats(classes[i], game.run.augments)
    let max_hp = stats.hp
    if game.run.mech_hp[i] <= 0 {
      // Not initialized yet, set to full
      game.run.mech_hp[i] = max_hp
    } else {
      let heal = max_hp / 2
      game.run.mech_hp[i] = (game.run.mech_hp[i] + heal).clamp(
        min=1,
        max=max_hp,
      )
    }
  }
}

///|
/// Apply a random event node.
fn apply_event_node(game : @types.Game, node_id : Int) -> Unit {
  let seed : Ref[UInt] = { val: (node_id * 3571 + 137).reinterpret_as_uint() }
  let event_roll = @types.rand_range(seed, 0, 2)
  match event_roll {
    0 => {
      // Scavenger: give a free augment (simplified - no fight/pay choice for now)
      if game.run.grid_power >= 2 {
        game.run.grid_power -= 2
        let offered = @content.pick_random_augments(seed, game.run.augments, 1)
        if offered.length() > 0 {
          game.run.augments.push(offered[0])
          let name = @content.get_augment_name(offered[0])
          game.message_text = "Scavenger: Paid 2 GP, got \{name}!"
        } else {
          game.message_text = "Scavenger: No augments available."
        }
      } else {
        game.message_text = "Scavenger: Not enough GP (need 2)."
      }
      game.message_timer = 3.0
    }
    1 => {
      // Intel: reveal info (just give bonus score)
      game.run.total_score += 50
      game.message_text = "Intel gathered. +50 score. Enemies revealed ahead."
      game.message_timer = 3.0
    }
    _ => {
      // Ambush: give double GP reward
      game.run.grid_power += 4
      game.message_text = "Ambush survived! +4 Grid Power."
      game.message_timer = 3.0
    }
  }
}

///|
/// Save mech HP from battle back to persistent run state.
pub fn save_mech_hp(game : @types.Game) -> Unit {
  match game.battle {
    Some(b) =>
      for i = 0; i < b.units.length(); i = i + 1 {
        let u = b.units[i]
        if u.team == Player {
          let idx = match u.mech_class {
            Vanguard => 0
            Striker => 1
            Sentinel => 2
          }
          if idx < game.run.mech_hp.length() {
            game.run.mech_hp[idx] = if u.active && u.hp > 0 { u.hp } else { 0 }
          }
        }
      }
    None => ()
  }
}

///|
/// Mark the current campaign node as completed and transition to reward.
pub fn complete_campaign_node(game : @types.Game) -> Unit {
  // Save persistent mech HP
  save_mech_hp(game)
  match game.run.campaign {
    Some(campaign) => {
      campaign.completed_nodes.push(campaign.selected_node)
      // Check if final boss completed
      let node = campaign.nodes[campaign.selected_node]
      match node.kind {
        Boss(mid) =>
          if mid == 8 {
            // Final boss defeated - run summary
            game.screen = RunSummary
            return
          }
        _ => ()
      }
    }
    None => ()
  }
}
