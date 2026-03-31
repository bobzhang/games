///|
fn p() -> @types.Cell {
  @types.new_cell(Path)
}

///|
fn s(link : Int) -> @types.Cell {
  @types.make_cell(Switch, switch_link_id=link)
}

///|
fn g(link : Int) -> @types.Cell {
  @types.make_cell(Gate, gate_open=false, switch_link_id=link)
}

///|
fn go(link : Int) -> @types.Cell {
  @types.make_cell(Gate, gate_open=true, switch_link_id=link)
}

///|
fn sy() -> @types.Cell {
  @types.new_cell(SyncPoint)
}

///|
fn os(link : Int) -> @types.Cell {
  @types.make_cell(OneShotSwitch, switch_link_id=link)
}

///|
fn pa(offset : Int) -> @types.Cell {
  @types.make_cell(Path, arrow_offset=offset)
}

///|
fn pp() -> @types.Cell {
  @types.make_cell(Path, has_pickup=true)
}

///|
pub fn get_level(index : Int) -> @types.Level {
  match index {
    0 => level_1_1()
    1 => level_1_2()
    2 => level_1_3()
    3 => level_1_4()
    4 => level_1_5()
    5 => level_1_6()
    6 => level_1_7()
    7 => level_1_8()
    8 => level_2_1()
    9 => level_2_2()
    10 => level_2_3()
    11 => level_2_4()
    12 => level_2_5()
    13 => level_2_6()
    14 => level_2_7()
    15 => level_2_8()
    16 => level_2_9()
    17 => level_3_1()
    18 => level_3_2()
    19 => level_3_3()
    20 => level_3_4()
    21 => level_3_5()
    22 => level_3_6()
    23 => level_3_7()
    _ => level_3_8()
  }
}

// ============================================================
// TIER 1: COIL (Levels 1-8) - Short spirals, switches + gates
// ============================================================

///|
fn level_1_1() -> @types.Level {
  // "First Steps" - Simple intro, no obstacles
  let cw = @types.new_spiral([p(), p(), p(), p(), p(), p(), p(), p()])
  let ccw = @types.new_spiral([p(), p(), p(), p(), p(), p(), p(), p()])
  @types.new_level(cw, ccw, [], 8, 0, "First Steps")
}

///|
fn level_1_2() -> @types.Level {
  // "Gate Ahead" - One switch, one gate
  let cw = @types.new_spiral([
    p(), p(), s(0), p(), p(), p(), p(), p(), p(), p(),
  ])
  let ccw = @types.new_spiral([
    p(), p(), p(), g(0), p(), p(), p(), p(), p(), p(),
  ])
  @types.new_level(
    cw,
    ccw,
    [@types.new_switch_link(2, -1, [], [3])],
    10,
    0,
    "Gate Ahead",
  )
}

///|
fn level_1_3() -> @types.Level {
  // "Double Lock" - Two switches, two gates
  let cw = @types.new_spiral([
    p(), s(0), p(), p(), g(1), p(), p(), p(), p(), p(), p(), p(),
  ])
  let ccw = @types.new_spiral([
    p(), p(), g(0), p(), s(1), p(), p(), p(), p(), p(), p(), p(),
  ])
  @types.new_level(
    cw,
    ccw,
    [
      @types.new_switch_link(1, -1, [], [2]),
      @types.new_switch_link(-1, 4, [4], []),
    ],
    12,
    0,
    "Double Lock",
  )
}

///|
fn level_1_4() -> @types.Level {
  // "Cross Switch" - Switch on one spiral opens gate on the other
  let cw = @types.new_spiral([
    p(), p(), p(), g(0), p(), p(), p(), p(), p(), p(), p(), p(),
  ])
  let ccw = @types.new_spiral([
    p(), s(0), p(), p(), p(), g(0), p(), p(), p(), p(), p(), p(),
  ])
  @types.new_level(
    cw,
    ccw,
    [@types.new_switch_link(-1, 1, [3], [5])],
    12,
    0,
    "Cross Switch",
  )
}

///|
fn level_1_5() -> @types.Level {
  // "Toggle Trouble" - Switch toggles, must time correctly
  let cw = @types.new_spiral([
    p(), p(), s(0), p(), p(), p(), g(0), p(), p(), p(), p(), p(), p(), p(),
  ])
  let ccw = @types.new_spiral([
    p(), p(), p(), p(), s(0), p(), p(), p(), g(0), p(), p(), p(), p(), p(),
  ])
  @types.new_level(
    cw,
    ccw,
    [@types.new_switch_link(2, 4, [6], [8])],
    14,
    0,
    "Toggle Trouble",
  )
}

///|
fn level_1_6() -> @types.Level {
  // "Pickup Run" - Pickups and simple gates
  let cw = @types.new_spiral([
    p(), pp(), p(), s(0), p(), pp(), p(), p(), p(), p(), p(), p(), p(), p(),
    p(), p(),
  ])
  let ccw = @types.new_spiral([
    p(), p(), pp(), p(), g(0), p(), pp(), p(), p(), p(), p(), p(), p(), p(),
    p(), p(),
  ])
  @types.new_level(
    cw,
    ccw,
    [@types.new_switch_link(3, -1, [], [4])],
    16,
    4,
    "Pickup Run",
  )
}

///|
fn level_1_7() -> @types.Level {
  // "Chain Reaction" - Three linked switches/gates
  let cw = @types.new_spiral([
    p(), s(0), p(), p(), g(1), p(), s(2), p(), p(), p(), p(), p(), p(), p(),
    p(), p(), p(), p(),
  ])
  let ccw = @types.new_spiral([
    p(), p(), g(0), p(), s(1), p(), p(), g(2), p(), p(), p(), p(), p(), p(),
    p(), p(), p(), p(),
  ])
  @types.new_level(
    cw,
    ccw,
    [
      @types.new_switch_link(1, -1, [], [2]),
      @types.new_switch_link(-1, 4, [4], []),
      @types.new_switch_link(6, -1, [], [7]),
    ],
    18,
    0,
    "Chain Reaction",
  )
}

///|
fn level_1_8() -> @types.Level {
  // "Coil Finale" - Complex gate network, one gate starts open
  let cw = @types.new_spiral([
    p(), s(0), p(), go(1), p(), p(), s(2), p(), g(0), p(), p(), p(), p(), p(),
    p(), p(), p(), p(), p(), p(),
  ])
  let ccw = @types.new_spiral([
    p(), g(0), p(), s(1), p(), g(2), p(), p(), p(), s(0), p(), p(), p(), p(),
    p(), p(), p(), p(), p(), p(),
  ])
  @types.new_level(
    cw,
    ccw,
    [
      @types.new_switch_link(1, 9, [8], [1]),
      @types.new_switch_link(-1, 3, [3], []),
      @types.new_switch_link(6, -1, [], [5]),
    ],
    20,
    0,
    "Coil Finale",
  )
}

// ============================================================
// TIER 2: TWIST (Levels 9-17) - Sync points, one-shot switches
// ============================================================

///|
fn level_2_1() -> @types.Level {
  // "Sync Up" - Introduction to sync points
  let cw = @types.new_spiral([
    p(), p(), p(), p(), sy(), p(), p(), p(), p(), p(), p(), p(), p(), p(),
    p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(),
  ])
  let ccw = @types.new_spiral([
    p(), p(), p(), p(), sy(), p(), p(), p(), p(), p(), p(), p(), p(), p(),
    p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(),
  ])
  @types.new_level(cw, ccw, [], 25, 0, "Sync Up")
}

///|
fn level_2_2() -> @types.Level {
  // "One Shot" - Introduction to one-shot switches
  let cw = @types.new_spiral([
    p(), p(), os(0), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(),
    p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(),
  ])
  let ccw = @types.new_spiral([
    p(), p(), p(), p(), g(0), p(), p(), p(), p(), p(), p(), p(), p(), p(),
    p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(),
  ])
  @types.new_level(
    cw,
    ccw,
    [@types.new_switch_link(2, -1, [], [4])],
    25,
    0,
    "One Shot",
  )
}

///|
fn level_2_3() -> @types.Level {
  // "Sync & Switch" - Combo of sync and switch
  let cw = @types.new_spiral([
    p(), s(0), p(), p(), sy(), p(), p(), p(), g(1), p(), p(), p(), p(), p(),
    p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(),
  ])
  let ccw = @types.new_spiral([
    p(), p(), g(0), p(), sy(), p(), s(1), p(), p(), p(), p(), p(), p(), p(),
    p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(),
  ])
  @types.new_level(
    cw,
    ccw,
    [
      @types.new_switch_link(1, -1, [], [2]),
      @types.new_switch_link(-1, 6, [8], []),
    ],
    25,
    0,
    "Sync & Switch",
  )
}

///|
fn level_2_4() -> @types.Level {
  // "Arrow Forward" - Introduction to arrow offsets
  let cw = @types.new_spiral([
    p(), p(), pa(2), p(), p(), p(), s(0), p(), p(), p(), p(), p(), p(), p(),
    p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(),
  ])
  let ccw = @types.new_spiral([
    p(), p(), p(), p(), g(0), p(), p(), pa(-1), p(), p(), p(), p(), p(), p(),
    p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(),
  ])
  @types.new_level(
    cw,
    ccw,
    [@types.new_switch_link(6, -1, [], [4])],
    25,
    0,
    "Arrow Forward",
  )
}

///|
fn level_2_5() -> @types.Level {
  // "Double Sync" - Two sync points
  let cw = @types.new_spiral([
    p(), p(), p(), sy(), p(), p(), s(0), p(), p(), sy(), p(), p(), p(), p(),
    p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(),
  ])
  let ccw = @types.new_spiral([
    p(), p(), p(), sy(), p(), g(0), p(), p(), p(), sy(), p(), p(), p(), p(),
    p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(),
  ])
  @types.new_level(
    cw,
    ccw,
    [@types.new_switch_link(6, -1, [], [5])],
    28,
    0,
    "Double Sync",
  )
}

///|
fn level_2_6() -> @types.Level {
  // "Pickup Maze" - Many pickups, gates, one-shot
  let cw = @types.new_spiral([
    p(), pp(), p(), os(0), p(), pp(), p(), g(1), p(), p(), pp(), p(), p(),
    p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(),
    p(), p(), p(),
  ])
  let ccw = @types.new_spiral([
    p(), p(), pp(), p(), g(0), p(), pp(), p(), s(1), p(), p(), pp(), p(),
    p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(),
    p(), p(), p(),
  ])
  @types.new_level(
    cw,
    ccw,
    [
      @types.new_switch_link(3, -1, [], [4]),
      @types.new_switch_link(-1, 8, [7], []),
    ],
    30,
    6,
    "Pickup Maze",
  )
}

///|
fn level_2_7() -> @types.Level {
  // "Backtrack" - Arrow sends token backward
  let cw = @types.new_spiral([
    p(), p(), s(0), p(), p(), pa(-2), p(), p(), g(1), p(), p(), p(), p(),
    p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(),
    p(), p(), p(),
  ])
  let ccw = @types.new_spiral([
    p(), p(), p(), g(0), p(), p(), s(1), p(), p(), p(), pa(2), p(), p(),
    p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(),
    p(), p(), p(),
  ])
  @types.new_level(
    cw,
    ccw,
    [
      @types.new_switch_link(2, -1, [], [3]),
      @types.new_switch_link(-1, 6, [8], []),
    ],
    30,
    0,
    "Backtrack",
  )
}

///|
fn level_2_8() -> @types.Level {
  // "Sync Gate" - Sync behind a gate
  let cw = @types.new_spiral([
    p(), p(), s(0), p(), p(), g(1), sy(), p(), p(), p(), p(), s(2), p(), p(),
    p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(),
    p(), p(),
  ])
  let ccw = @types.new_spiral([
    p(), g(0), p(), p(), s(1), p(), sy(), p(), p(), g(2), p(), p(), p(), p(),
    p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(),
    p(), p(),
  ])
  @types.new_level(
    cw,
    ccw,
    [
      @types.new_switch_link(2, -1, [], [1]),
      @types.new_switch_link(-1, 4, [5], []),
      @types.new_switch_link(11, -1, [], [9]),
    ],
    30,
    0,
    "Sync Gate",
  )
}

///|
fn level_2_9() -> @types.Level {
  // "Twist Finale" - Everything from Tier 2
  let cw = @types.new_spiral([
    p(), s(0), p(), p(), sy(), p(), g(1), p(), os(2), p(), p(), pp(), p(),
    p(), pa(2), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(),
    p(), p(), p(), p(), p(), p(), p(), p(),
  ])
  let ccw = @types.new_spiral([
    p(), g(0), p(), p(), sy(), p(), s(1), p(), p(), g(2), p(), p(), pp(),
    pa(-1), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(),
    p(), p(), p(), p(), p(), p(), p(), p(),
  ])
  @types.new_level(
    cw,
    ccw,
    [
      @types.new_switch_link(1, -1, [], [1]),
      @types.new_switch_link(-1, 6, [6], []),
      @types.new_switch_link(8, -1, [], [9]),
    ],
    35,
    2,
    "Twist Finale",
  )
}

// ============================================================
// TIER 3: DOUBLE HELIX (Levels 18-25) - All mechanics
// ============================================================

///|
fn level_3_1() -> @types.Level {
  // "Helix Entry" - Long spirals, multi-gate
  let cw = @types.new_spiral([
    p(), s(0), p(), p(), g(1), p(), p(), s(2), p(), p(), g(0), p(), p(), p(),
    p(), sy(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(),
    p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(),
  ])
  let ccw = @types.new_spiral([
    p(), g(0), p(), s(1), p(), p(), g(2), p(), p(), p(), p(), s(0), p(), p(),
    p(), sy(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(),
    p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(),
  ])
  @types.new_level(
    cw,
    ccw,
    [
      @types.new_switch_link(1, 11, [10], [1]),
      @types.new_switch_link(-1, 3, [4], []),
      @types.new_switch_link(7, -1, [], [6]),
    ],
    40,
    0,
    "Helix Entry",
  )
}

///|
fn level_3_2() -> @types.Level {
  // "Interlocked" - Tightly coupled switches
  let cw = @types.new_spiral([
    p(), s(0), p(), g(1), p(), s(2), p(), p(), g(0), p(), os(3), p(), p(),
    p(), p(), p(), pp(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(),
    p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(),
  ])
  let ccw = @types.new_spiral([
    p(), g(0), p(), s(1), p(), g(2), p(), p(), p(), s(0), p(), g(3), p(),
    p(), pp(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(),
    p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(),
  ])
  @types.new_level(
    cw,
    ccw,
    [
      @types.new_switch_link(1, 9, [8], [1]),
      @types.new_switch_link(-1, 3, [3], []),
      @types.new_switch_link(5, -1, [], [5]),
      @types.new_switch_link(10, -1, [], [11]),
    ],
    40,
    2,
    "Interlocked",
  )
}

///|
fn level_3_3() -> @types.Level {
  // "Arrow Maze"
  let cw = @types.new_spiral([
    p(), p(), s(0), p(), pa(2), p(), p(), g(1), p(), p(), pa(-1), p(), p(),
    s(2), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(),
    p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(),
  ])
  let ccw = @types.new_spiral([
    p(), g(0), p(), p(), p(), pa(-1), s(1), p(), p(), p(), g(2), p(), pa(2),
    p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(),
    p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(),
  ])
  @types.new_level(
    cw,
    ccw,
    [
      @types.new_switch_link(2, -1, [], [1]),
      @types.new_switch_link(-1, 6, [7], []),
      @types.new_switch_link(13, -1, [], [10]),
    ],
    40,
    0,
    "Arrow Maze",
  )
}

///|
fn level_3_4() -> @types.Level {
  // "Triple Sync"
  let cw = @types.new_spiral([
    p(), p(), sy(), p(), s(0), p(), p(), sy(), p(), p(), g(1), p(), sy(),
    p(), p(), p(), p(), p(), p(), p(), p(), p(), pp(), p(), p(), p(), p(),
    p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(),
    p(), p(), p(), p(),
  ])
  let ccw = @types.new_spiral([
    p(), p(), sy(), p(), g(0), p(), p(), sy(), p(), s(1), p(), p(), sy(),
    p(), p(), pp(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(),
    p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(),
    p(), p(), p(), p(),
  ])
  @types.new_level(
    cw,
    ccw,
    [
      @types.new_switch_link(4, -1, [], [4]),
      @types.new_switch_link(-1, 9, [10], []),
    ],
    45,
    2,
    "Triple Sync",
  )
}

///|
fn level_3_5() -> @types.Level {
  // "Gate Cascade"
  let cw = @types.new_spiral([
    p(), s(0), p(), g(1), p(), s(2), p(), g(3), p(), p(), os(4), p(), p(),
    p(), g(0), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(),
    p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(),
    p(), p(), p(), p(),
  ])
  let ccw = @types.new_spiral([
    p(), g(0), p(), s(1), p(), g(2), p(), s(3), p(), g(4), p(), p(), p(),
    p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(),
    p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(),
    p(), p(), p(), p(),
  ])
  @types.new_level(
    cw,
    ccw,
    [
      @types.new_switch_link(1, -1, [14], [1]),
      @types.new_switch_link(-1, 3, [3], []),
      @types.new_switch_link(5, -1, [], [5]),
      @types.new_switch_link(-1, 7, [7], []),
      @types.new_switch_link(10, -1, [], [9]),
    ],
    45,
    0,
    "Gate Cascade",
  )
}

///|
fn level_3_6() -> @types.Level {
  // "Dual Arrows"
  let cw = @types.new_spiral([
    p(), p(), s(0), p(), pa(2), p(), p(), g(1), p(), sy(), p(), pa(-2), p(),
    p(), s(2), p(), pp(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(),
    p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(),
    p(), p(), p(), p(), p(), p(), p(), p(), p(),
  ])
  let ccw = @types.new_spiral([
    p(), g(0), p(), p(), pa(-1), p(), s(1), p(), p(), sy(), p(), p(), g(2),
    p(), pp(), pa(2), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(),
    p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(),
    p(), p(), p(), p(), p(), p(), p(), p(), p(),
  ])
  @types.new_level(
    cw,
    ccw,
    [
      @types.new_switch_link(2, -1, [], [1]),
      @types.new_switch_link(-1, 6, [7], []),
      @types.new_switch_link(14, -1, [], [12]),
    ],
    50,
    2,
    "Dual Arrows",
  )
}

///|
fn level_3_7() -> @types.Level {
  // "Lockstep"
  let cw = @types.new_spiral([
    p(), s(0), p(), g(1), p(), sy(), p(), s(2), p(), g(3), p(), p(), os(4),
    p(), p(), sy(), p(), p(), pp(), p(), p(), p(), p(), p(), p(), p(), p(),
    p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(),
    p(), p(), p(), p(), p(), p(), p(), p(), p(),
  ])
  let ccw = @types.new_spiral([
    p(), g(0), p(), s(1), p(), sy(), p(), g(2), p(), s(3), p(), p(), p(),
    g(4), p(), sy(), p(), pp(), p(), p(), p(), p(), p(), p(), p(), p(), p(),
    p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(),
    p(), p(), p(), p(), p(), p(), p(), p(), p(),
  ])
  @types.new_level(
    cw,
    ccw,
    [
      @types.new_switch_link(1, -1, [], [1]),
      @types.new_switch_link(-1, 3, [3], []),
      @types.new_switch_link(7, -1, [], [7]),
      @types.new_switch_link(-1, 9, [9], []),
      @types.new_switch_link(12, -1, [], [13]),
    ],
    50,
    2,
    "Lockstep",
  )
}

///|
fn level_3_8() -> @types.Level {
  // "Double Helix" - Final level
  let cw = @types.new_spiral([
    p(), s(0), p(), g(1), p(), pa(2), p(), sy(), p(), s(2), p(), g(3), p(),
    p(), os(4), p(), p(), sy(), p(), g(0), p(), pp(), p(), p(), p(), p(),
    p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(),
    p(), p(), p(), p(), p(), p(), p(), p(), p(), p(),
  ])
  let ccw = @types.new_spiral([
    p(), g(0), p(), s(1), p(), p(), pa(-1), sy(), p(), g(2), p(), s(3), p(),
    g(4), p(), p(), p(), sy(), p(), p(), s(0), pp(), p(), p(), p(), p(), p(),
    p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(), p(),
    p(), p(), p(), p(), p(), p(), p(), p(), p(),
  ])
  @types.new_level(
    cw,
    ccw,
    [
      @types.new_switch_link(1, 20, [19], [1]),
      @types.new_switch_link(-1, 3, [3], []),
      @types.new_switch_link(9, -1, [], [9]),
      @types.new_switch_link(-1, 11, [11], []),
      @types.new_switch_link(14, -1, [], [13]),
    ],
    50,
    2,
    "Double Helix",
  )
}
