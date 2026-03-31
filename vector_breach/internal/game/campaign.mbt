// campaign.mbt - Campaign map with branching paths.
// Instead of linear missions, show a branching node graph where
// the player chooses which path to take. Paths converge at boss missions.

///|
/// Build the campaign map: 3 columns of choice nodes, converging at bosses.
/// Layout: Start -> Branch (3 paths) -> Boss 1 -> Branch (3 paths) -> Boss 2
pub fn build_campaign_map() -> @types.CampaignMap {
  let nodes : Array[@types.CampaignNode] = []
  // Column 0: Starting mission (1 node)
  nodes.push(
    { id: 0, kind: Mission(0), x: 0, y: 1, connections: [1, 2, 3] },
  )
  // Column 1: Three branching paths (missions 1, 2, 3)
  nodes.push(
    { id: 1, kind: Mission(1), x: 1, y: 0, connections: [4] },
  )
  nodes.push(
    { id: 2, kind: Mission(2), x: 1, y: 1, connections: [4] },
  )
  nodes.push(
    { id: 3, kind: Mission(3), x: 1, y: 2, connections: [4] },
  )
  // Column 2: Boss 1 (mission 4 - Siege Engine)
  nodes.push(
    { id: 4, kind: Boss(4), x: 2, y: 1, connections: [5, 6, 7] },
  )
  // Column 3: Three branching paths (missions 5, 6, 7)
  nodes.push(
    { id: 5, kind: Mission(5), x: 3, y: 0, connections: [8] },
  )
  nodes.push(
    { id: 6, kind: Mission(6), x: 3, y: 1, connections: [8] },
  )
  nodes.push(
    { id: 7, kind: Mission(7), x: 3, y: 2, connections: [8] },
  )
  // Column 4: Final boss (mission 8 - Hivemind)
  nodes.push(
    { id: 8, kind: Boss(8), x: 4, y: 1, connections: [] },
  )
  { nodes, selected_node: 0, completed_nodes: [] }
}

///|
/// Check if a node is available to select (connected from a completed node).
pub fn is_node_available(
  campaign : @types.CampaignMap,
  node_id : Int,
) -> Bool {
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
pub fn is_node_completed(
  campaign : @types.CampaignMap,
  node_id : Int,
) -> Bool {
  for i = 0; i < campaign.completed_nodes.length(); i = i + 1 {
    if campaign.completed_nodes[i] == node_id {
      return true
    }
  }
  false
}

///|
/// Get the mission ID for a campaign node.
pub fn get_node_mission_id(
  campaign : @types.CampaignMap,
  node_id : Int,
) -> Int {
  if node_id < 0 || node_id >= campaign.nodes.length() {
    return 0
  }
  let node = campaign.nodes[node_id]
  match node.kind {
    Mission(mid) => mid
    Boss(mid) => mid
    Rest | Shop => -1
  }
}

///|
/// Get the name for a campaign node.
pub fn get_node_name(node : @types.CampaignNode) -> String {
  match node.kind {
    Mission(mid) => @content.get_mission_def(mid).name
    Boss(mid) => @content.get_mission_def(mid).name
    Rest => "Rest Stop"
    Shop => "Augment Shop"
  }
}

///|
/// Get available (selectable) node IDs for the player.
pub fn get_available_nodes(
  campaign : @types.CampaignMap,
) -> Array[Int] {
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
    // All nodes completed - victory
    game.screen = Victory
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
      let mission_id = get_node_mission_id(campaign, node_id)
      if mission_id >= 0 {
        game.run.current_mission = mission_id
        setup_mission_from_def(game, mission_id)
        game.screen = Battle
        game.message_text = @content.get_mission_def(mission_id).name
        game.message_timer = 3.0
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
  // Place special terrain tiles from mission definition
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
  // Place procedural terrain
  place_terrain(battle, mission_id)
  // Place 3 player mechs with augment-modified stats
  let classes : Array[@types.MechClass] = [Vanguard, Striker, Sentinel]
  for i = 0; i < 3; i = i + 1 {
    let stats = @content.get_augmented_mech_stats(
      classes[i],
      game.run.augments,
    )
    let px = 1
    let py = 1 + i * 3
    let mut shield = 0
    // ShieldGenerator augment: start with 2 shield
    if @types.has_augment(game.run, ShieldGenerator) {
      shield = 2
    }
    let u : @types.CombatUnit = {
      id: i,
      active: true,
      team: Player,
      x: px,
      y: py,
      hp: stats.hp,
      max_hp: stats.hp,
      shield,
      heat: 0,
      max_heat: stats.max_heat,
      stunned: false,
      moved_this_turn: false,
      acted_this_turn: false,
      mech_class: classes[i],
      enemy_type: Rammer,
      intent: March(px, py),
    }
    battle.units.push(u)
    if battle.grid.in_bounds(px, py) {
      battle.grid.set(
        px,
        py,
        { ..battle.grid.get(px, py), occupied_by: u.id },
      )
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
      shield: if etype == Boss { 2 } else { 0 },
      heat: 0,
      max_heat: 0,
      stunned: false,
      moved_this_turn: false,
      acted_this_turn: false,
      mech_class: Vanguard,
      enemy_type: etype,
      intent: March(actual_x, actual_y),
    }
    battle.units.push(eu)
    if battle.grid.in_bounds(actual_x, actual_y) {
      battle.grid.set(
        actual_x,
        actual_y,
        { ..battle.grid.get(actual_x, actual_y), occupied_by: eu.id },
      )
    }
  }
}

///|
/// Mark the current campaign node as completed and transition to reward.
pub fn complete_campaign_node(game : @types.Game) -> Unit {
  match game.run.campaign {
    Some(campaign) => {
      campaign.completed_nodes.push(campaign.selected_node)
      // Check if final boss completed
      let node = campaign.nodes[campaign.selected_node]
      match node.kind {
        Boss(8) => {
          // Final boss defeated - game victory
          game.screen = Victory
          return
        }
        _ => ()
      }
    }
    None => ()
  }
}
