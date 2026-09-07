// effects_test.mbt - Snapshot tests for the simulation core.
// Tests push physics, damage/shield, heat, stun, and terrain interactions.

///|
/// Helper: create a minimal battle with given grid size and units placed.
fn make_test_battle(
  width : Int,
  height : Int,
  tiles? : Array[(Int, Int, @types.TileKind)] = [],
  hazards? : Array[(Int, Int, @types.HazardKind)] = [],
) -> @types.BattleState {
  let battle = @types.new_battle(DefendGrid(5))
  // Replace the grid with a custom-sized one
  let grid = @types.Grid::new(width, height)
  // Apply special tiles
  for i = 0; i < tiles.length(); i = i + 1 {
    let (x, y, kind) = tiles[i]
    grid.set(x, y, { kind, hazard: None, occupied_by: -1, })
  }
  // Apply hazards
  for i = 0; i < hazards.length(); i = i + 1 {
    let (x, y, haz) = hazards[i]
    let tile = grid.get(x, y)
    grid.set(x, y, { ..tile, hazard: haz, })
  }
  { ..battle, grid, units: [], turn_log: [], }
}

///|
/// Helper: add a unit to a battle and update grid occupancy.
fn add_unit(
  battle : @types.BattleState,
  team : @types.UnitTeam,
  x : Int,
  y : Int,
  hp? : Int = 5,
  shield? : Int = 0,
  heat? : Int = 0,
  max_heat? : Int = 3,
  stunned? : Bool = false,
  mech_class? : @types.MechClass = Vanguard,
  enemy_type? : @types.EnemyType = Rammer,
) -> Int {
  let id = battle.units.length()
  let u : @types.CombatUnit = {
    id,
    active: true,
    team,
    x,
    y,
    hp,
    max_hp: hp,
    shield,
    heat,
    max_heat,
    stunned,
    moved_this_turn: false,
    acted_this_turn: false,
    mech_class,
    enemy_type,
    intent: March(x, y),
    statuses: [],
    upgrade_tier: 0,
    orbital_used: false,
  }
  battle.units.push(u)
  if battle.grid.in_bounds(x, y) {
    battle.grid.set(x, y, { ..battle.grid.get(x, y), occupied_by: id, })
  }
  id
}

///|
test "push into wall deals collision damage" {
  // Unit at (1,0), wall at (0,0), push west
  let battle = make_test_battle(4, 4, tiles=[(0, 0, Wall)])
  let uid = add_unit(battle, Enemy, 1, 0, hp=5)
  try_push(battle, uid, -1, 0, 1)
  // Unit should still be at (1,0) and took 1 collision damage
  inspect(battle.units[uid].hp, content="4")
  inspect(battle.units[uid].x, content="1")
  inspect(battle.units[uid].y, content="0")
}

///|
test "push into map edge deals collision damage" {
  let battle = make_test_battle(4, 4)
  let uid = add_unit(battle, Enemy, 0, 0, hp=5)
  try_push(battle, uid, -1, 0, 1)
  // Hit edge of map, took 1 damage
  inspect(battle.units[uid].hp, content="4")
  inspect(battle.units[uid].x, content="0")
}

///|
test "push into chasm kills unit" {
  let battle = make_test_battle(4, 4, tiles=[(2, 0, Chasm)])
  let uid = add_unit(battle, Enemy, 1, 0, hp=5)
  try_push(battle, uid, 1, 0, 1)
  // Unit fell into chasm: hp=0, inactive
  inspect(battle.units[uid].hp, content="0")
  inspect(battle.units[uid].active, content="false")
}

///|
test "chain push moves both units" {
  // Unit A at (1,0), Unit B at (2,0), empty at (3,0)
  // Push A east: A collides with B, both take 1 damage,
  // then B gets chain-pushed east to (3,0)
  let battle = make_test_battle(4, 4)
  let a = add_unit(battle, Player, 1, 0, hp=5, mech_class=Vanguard)
  let b = add_unit(battle, Enemy, 2, 0, hp=5)
  try_push(battle, a, 1, 0, 1)
  // A collided with B: both took 1 collision damage
  inspect(battle.units[a].hp, content="4")
  inspect(battle.units[b].hp, content="4")
  // A stays at (1,0) since it collided before moving through
  inspect(battle.units[a].x, content="1")
  // B was chain-pushed 1 tile east
  inspect(battle.units[b].x, content="3")
}

///|
test "push distance 2 moves unit 2 tiles" {
  let battle = make_test_battle(6, 4)
  let uid = add_unit(battle, Enemy, 1, 0, hp=5)
  try_push(battle, uid, 1, 0, 2)
  // Should have moved 2 tiles east
  inspect(battle.units[uid].x, content="3")
  inspect(battle.units[uid].hp, content="5")
}

///|
test "ice slide continues until wall" {
  // Ice at (2,0), (3,0). Wall at (4,0). Unit pushed east onto ice from (1,0).
  let battle = make_test_battle(6, 4, tiles=[
    (2, 0, Ice),
    (3, 0, Ice),
    (4, 0, Wall),
  ])
  let uid = add_unit(battle, Enemy, 1, 0, hp=5)
  try_push(battle, uid, 1, 0, 1)
  // Unit slides on ice at (2,0), continues, slides on ice at (3,0),
  // then hits wall at (4,0): collision damage
  inspect(battle.units[uid].x, content="3")
  inspect(battle.units[uid].hp, content="4")
}

///|
test "ice slide to open space stops at edge of ice" {
  // Ice at (2,0), floor at (3,0). Unit pushed east from (1,0).
  let battle = make_test_battle(6, 4, tiles=[(2, 0, Ice)])
  let uid = add_unit(battle, Enemy, 1, 0, hp=5)
  try_push(battle, uid, 1, 0, 1)
  // Lands on ice at (2,0), slides one more step to (3,0) which is floor
  inspect(battle.units[uid].x, content="3")
  inspect(battle.units[uid].hp, content="5")
}

///|
test "shield absorbs damage before HP" {
  let battle = make_test_battle(4, 4)
  let uid = add_unit(battle, Enemy, 0, 0, hp=5, shield=2)
  // Deal 3 damage: shield absorbs 2, HP takes 1
  let dealt = apply_damage(battle, uid, 3)
  inspect(battle.units[uid].shield, content="0")
  inspect(battle.units[uid].hp, content="4")
  inspect(dealt, content="1")
}

///|
test "shield fully absorbs small damage" {
  let battle = make_test_battle(4, 4)
  let uid = add_unit(battle, Enemy, 0, 0, hp=5, shield=3)
  let dealt = apply_damage(battle, uid, 2)
  inspect(battle.units[uid].shield, content="1")
  inspect(battle.units[uid].hp, content="5")
  inspect(dealt, content="0")
}

///|
test "damage kills unit when HP reaches zero" {
  let battle = make_test_battle(4, 4)
  let uid = add_unit(battle, Enemy, 0, 0, hp=2)
  let _ = apply_damage(battle, uid, 3)
  inspect(battle.units[uid].hp, content="0")
  inspect(battle.units[uid].active, content="false")
}

///|
test "apply heat increases heat" {
  let battle = make_test_battle(4, 4)
  let uid = add_unit(battle, Player, 0, 0, hp=5, heat=0, max_heat=3)
  apply_heat(battle, uid, 2)
  inspect(battle.units[uid].heat, content="2")
  inspect(battle.units[uid].stunned, content="false")
}

///|
test "overheat stuns and resets heat" {
  let battle = make_test_battle(4, 4)
  let uid = add_unit(battle, Player, 0, 0, hp=5, heat=2, max_heat=3)
  apply_heat(battle, uid, 2)
  // heat 2+2=4 > max_heat 3: overheated
  inspect(battle.units[uid].heat, content="0")
  inspect(battle.units[uid].stunned, content="true")
}

///|
test "stun prevents action via player command" {
  let battle = make_test_battle(8, 8)
  let uid = add_unit(
    battle,
    Player,
    1,
    1,
    hp=5,
    stunned=true,
    mech_class=Vanguard,
  )
  let original_x = battle.units[uid].x
  let original_y = battle.units[uid].y
  // Try to move via player command
  execute_player_command(battle, 0, Move(2, 1))
  // Unit should not have moved because it is stunned
  inspect(battle.units[uid].x, content=original_x.to_string())
  inspect(battle.units[uid].y, content=original_y.to_string())
}

///|
test "apply_shield adds shield" {
  let battle = make_test_battle(4, 4)
  let uid = add_unit(battle, Player, 0, 0, hp=5, shield=0)
  apply_shield(battle, uid, 3)
  inspect(battle.units[uid].shield, content="3")
}

///|
test "apply_stun sets stunned flag" {
  let battle = make_test_battle(4, 4)
  let uid = add_unit(battle, Enemy, 0, 0, hp=5)
  apply_stun(battle, uid)
  inspect(battle.units[uid].stunned, content="true")
}

///|
test "move_unit_to updates position and grid occupancy" {
  let battle = make_test_battle(4, 4)
  let uid = add_unit(battle, Player, 1, 1, hp=5)
  move_unit_to(battle, uid, 2, 3)
  inspect(battle.units[uid].x, content="2")
  inspect(battle.units[uid].y, content="3")
  // Old tile should be clear
  inspect(battle.grid.get(1, 1).occupied_by, content="-1")
  // New tile should be occupied
  inspect(battle.grid.get(2, 3).occupied_by, content="0")
}

///|
test "kill_unit marks inactive and clears tile" {
  let battle = make_test_battle(4, 4)
  let uid = add_unit(battle, Enemy, 2, 2, hp=5)
  kill_unit(battle, uid)
  inspect(battle.units[uid].active, content="false")
  inspect(battle.units[uid].hp, content="0")
  inspect(battle.grid.get(2, 2).occupied_by, content="-1")
}

///|
test "unit_at finds occupant" {
  let battle = make_test_battle(4, 4)
  let uid = add_unit(battle, Enemy, 2, 2, hp=5)
  inspect(unit_at(battle, 2, 2), content=uid.to_string())
  inspect(unit_at(battle, 0, 0), content="-1")
  inspect(unit_at(battle, -1, 0), content="-1")
}

///|
test "is_walkable checks floors and occupancy" {
  let battle = make_test_battle(4, 4, tiles=[(1, 0, Wall), (2, 0, Chasm)])
  let _ = add_unit(battle, Enemy, 0, 0, hp=5)
  inspect(is_walkable(battle, 0, 0), content="false") // occupied
  inspect(is_walkable(battle, 1, 0), content="false") // wall
  inspect(is_walkable(battle, 2, 0), content="false") // chasm
  inspect(is_walkable(battle, 3, 0), content="true") // empty floor
  inspect(is_walkable(battle, -1, 0), content="false") // out of bounds
}

///|
test "find_nearest_unit returns closest by manhattan distance" {
  let battle = make_test_battle(8, 8)
  let _ = add_unit(battle, Enemy, 5, 5, hp=3)
  let closer = add_unit(battle, Enemy, 2, 2, hp=3)
  let nearest = find_nearest_unit(battle, 1, 1, Enemy)
  inspect(nearest, content=closer.to_string())
}

///|
test "try_pull moves unit toward puller" {
  let battle = make_test_battle(6, 4)
  let uid = add_unit(battle, Enemy, 4, 0, hp=5)
  try_pull(battle, uid, 1, 0, 2)
  // Pulled west 2 tiles toward (1,0)
  inspect(battle.units[uid].x, content="2")
  inspect(battle.units[uid].hp, content="5")
}

///|
test "simulate_turn advances turn counter" {
  let battle = make_test_battle(8, 8)
  let _ = add_unit(battle, Player, 1, 1, hp=5, mech_class=Vanguard)
  let _ = add_unit(battle, Enemy, 6, 6, hp=3)
  inspect(battle.turn, content="1")
  let _ = simulate_turn(battle, [Wait])
  inspect(battle.turn, content="2")
}

///|
test "hazard damage applies to units on fire" {
  let battle = make_test_battle(4, 4, hazards=[(1, 1, Fire)])
  let uid = add_unit(battle, Enemy, 1, 1, hp=5)
  let _ = simulate_turn(battle, [])
  // Unit should have taken 1 fire hazard damage
  inspect(battle.units[uid].hp, content="4")
}

///|
test "overcharged_push augment adds distance" {
  let battle = make_test_battle(8, 4)
  battle.augments = [OverchargedPush]
  let uid = add_unit(battle, Enemy, 1, 0, hp=5)
  try_push(battle, uid, 1, 0, 1)
  // Normal push 1 + bonus 1 = 2 tiles
  inspect(battle.units[uid].x, content="3")
}
