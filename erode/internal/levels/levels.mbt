///|
let t : Bool = true

///|
let f : Bool = false

///|
fn make_level(
  tier : @types.Tier,
  name : String,
  initial : Array[Array[Bool]],
  target : Array[Array[Bool]],
  water~ : Int,
  wind~ : Int,
  frost~ : Int,
  heat~ : Int,
  par~ : Int,
) -> @types.Level {
  let size = 8
  {
    tier,
    name,
    initial_block: @types.grid_from_rows(size, initial),
    target_shape: @types.grid_from_rows(size, target),
    budget: { water, wind, frost, heat, },
    par_forces: par,
  }
}

// ============================================================
// Tier 1: Clay (7 levels) - Water + Wind only
// ============================================================

///|
fn level_01() -> @types.Level {
  // "Flat Top" - Simple: remove top row from full block
  make_level(
    Clay,
    "Flat Top",
    [
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
    ],
    [
      [f, f, f, f, f, f, f, f],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
    ],
    water=1,
    wind=0,
    frost=0,
    heat=0,
    par=1,
  )
}

///|
fn level_02() -> @types.Level {
  // "Left Trim" - Remove left column
  make_level(
    Clay,
    "Left Trim",
    [
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
    ],
    [
      [f, t, t, t, t, t, t, t],
      [f, t, t, t, t, t, t, t],
      [f, t, t, t, t, t, t, t],
      [f, t, t, t, t, t, t, t],
      [f, t, t, t, t, t, t, t],
      [f, t, t, t, t, t, t, t],
      [f, t, t, t, t, t, t, t],
      [f, t, t, t, t, t, t, t],
    ],
    water=0,
    wind=1,
    frost=0,
    heat=0,
    par=1,
  )
}

///|
fn level_03() -> @types.Level {
  // "L Shape" - Water + wind left to make L
  make_level(
    Clay,
    "L Shape",
    [
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
    ],
    [
      [f, f, f, f, f, f, f, f],
      [f, t, t, t, t, t, t, t],
      [f, t, t, t, t, t, t, t],
      [f, t, t, t, t, t, t, t],
      [f, t, t, t, t, t, t, t],
      [f, t, t, t, t, t, t, t],
      [f, t, t, t, t, t, t, t],
      [f, t, t, t, t, t, t, t],
    ],
    water=1,
    wind=1,
    frost=0,
    heat=0,
    par=2,
  )
}

///|
fn level_04() -> @types.Level {
  // "Step Down" - Two water applications on a stepped shape
  make_level(
    Clay,
    "Step Down",
    [
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [f, f, f, f, t, t, t, t],
      [f, f, f, f, t, t, t, t],
      [f, f, f, f, t, t, t, t],
      [f, f, f, f, t, t, t, t],
    ],
    [
      [f, f, f, f, f, f, f, f],
      [t, t, t, t, f, f, f, f],
      [t, t, t, t, f, f, f, f],
      [t, t, t, t, f, f, f, f],
      [f, f, f, f, t, t, t, t],
      [f, f, f, f, t, t, t, t],
      [f, f, f, f, t, t, t, t],
      [f, f, f, f, t, t, t, t],
    ],
    water=2,
    wind=0,
    frost=0,
    heat=0,
    par=2,
  )
}

///|
fn level_05() -> @types.Level {
  // "Pillar" - Wind from both sides to make narrow pillar
  make_level(
    Clay,
    "Pillar",
    [
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
    ],
    [
      [f, f, t, t, t, t, f, f],
      [f, f, t, t, t, t, f, f],
      [f, f, t, t, t, t, f, f],
      [f, f, t, t, t, t, f, f],
      [f, f, t, t, t, t, f, f],
      [f, f, t, t, t, t, f, f],
      [f, f, t, t, t, t, f, f],
      [f, f, t, t, t, t, f, f],
    ],
    water=0,
    wind=4,
    frost=0,
    heat=0,
    par=4,
  )
}

///|
fn level_06() -> @types.Level {
  // "Shelf" - Water twice, wind right once
  make_level(
    Clay,
    "Shelf",
    [
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
    ],
    [
      [f, f, f, f, f, f, f, f],
      [f, f, f, f, f, f, f, f],
      [t, t, t, t, t, t, t, f],
      [t, t, t, t, t, t, t, f],
      [t, t, t, t, t, t, t, f],
      [t, t, t, t, t, t, t, f],
      [t, t, t, t, t, t, t, f],
      [t, t, t, t, t, t, t, f],
    ],
    water=2,
    wind=1,
    frost=0,
    heat=0,
    par=3,
  )
}

///|
fn level_07() -> @types.Level {
  // "Notch" - Create a notch using water on a pre-carved shape
  make_level(
    Clay,
    "Notch",
    [
      [f, f, f, f, f, f, f, f],
      [t, t, t, t, t, t, t, t],
      [t, t, t, f, f, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
    ],
    [
      [f, f, f, f, f, f, f, f],
      [f, f, f, f, f, f, f, f],
      [t, t, f, f, f, f, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
    ],
    water=2,
    wind=1,
    frost=0,
    heat=0,
    par=3,
  )
}

// ============================================================
// Tier 2: Stone (7 levels) - Water + Wind + Frost
// ============================================================

///|
fn level_08() -> @types.Level {
  // "Corner Cut" - Use frost to remove exposed corners
  make_level(
    Stone,
    "Corner Cut",
    [
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
    ],
    [
      [f, t, t, t, t, t, t, f],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
    ],
    water=0,
    wind=0,
    frost=1,
    heat=0,
    par=1,
  )
}

///|
fn level_09() -> @types.Level {
  // "Rounded Top" - Water then frost to round the top
  make_level(
    Stone,
    "Rounded Top",
    [
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
    ],
    [
      [f, f, f, f, f, f, f, f],
      [f, t, t, t, t, t, t, f],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
    ],
    water=1,
    wind=0,
    frost=1,
    heat=0,
    par=2,
  )
}

///|
fn level_10() -> @types.Level {
  // "Diamond" - Carve a diamond from the block
  make_level(
    Stone,
    "Diamond",
    [
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
    ],
    [
      [f, f, f, t, t, f, f, f],
      [f, f, t, t, t, t, f, f],
      [f, t, t, t, t, t, t, f],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [f, t, t, t, t, t, t, f],
      [f, f, t, t, t, t, f, f],
      [f, f, f, t, t, f, f, f],
    ],
    water=1,
    wind=2,
    frost=3,
    heat=0,
    par=5,
  )
}

///|
fn level_11() -> @types.Level {
  // "Arch" - Create an arch shape
  make_level(
    Stone,
    "Arch",
    [
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, f, f, t, t, t],
      [t, t, t, f, f, t, t, t],
      [t, t, t, f, f, t, t, t],
      [t, t, t, f, f, t, t, t],
      [t, t, t, f, f, t, t, t],
    ],
    [
      [f, f, f, f, f, f, f, f],
      [f, t, t, f, f, t, t, f],
      [f, t, t, f, f, t, t, f],
      [f, t, t, f, f, t, t, f],
      [f, t, t, f, f, t, t, f],
      [f, t, t, f, f, t, t, f],
      [f, t, t, f, f, t, t, f],
      [f, t, t, f, f, t, t, f],
    ],
    water=1,
    wind=2,
    frost=1,
    heat=0,
    par=4,
  )
}

///|
fn level_12() -> @types.Level {
  // "Pyramid" - Sculpt a pyramid shape
  make_level(
    Stone,
    "Pyramid",
    [
      [f, f, f, f, f, f, f, f],
      [f, f, f, f, f, f, f, f],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
    ],
    [
      [f, f, f, f, f, f, f, f],
      [f, f, f, f, f, f, f, f],
      [f, f, f, t, t, f, f, f],
      [f, f, t, t, t, t, f, f],
      [f, t, t, t, t, t, t, f],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
    ],
    water=0,
    wind=2,
    frost=3,
    heat=0,
    par=5,
  )
}

///|
fn level_13() -> @types.Level {
  // "Cross" - Sculpt a plus/cross shape
  make_level(
    Stone,
    "Cross",
    [
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
    ],
    [
      [f, f, t, t, t, t, f, f],
      [f, f, t, t, t, t, f, f],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [f, f, t, t, t, t, f, f],
      [f, f, t, t, t, t, f, f],
    ],
    water=0,
    wind=2,
    frost=2,
    heat=0,
    par=4,
  )
}

///|
fn level_14() -> @types.Level {
  // "Canyon" - Carve a deep canyon
  make_level(
    Stone,
    "Canyon",
    [
      [t, t, t, f, f, t, t, t],
      [t, t, t, f, f, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
    ],
    [
      [t, t, f, f, f, f, t, t],
      [t, t, f, f, f, f, t, t],
      [t, t, f, f, f, f, t, t],
      [t, t, f, f, f, f, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
    ],
    water=2,
    wind=1,
    frost=1,
    heat=0,
    par=4,
  )
}

// ============================================================
// Tier 3: Crystal (6 levels) - All forces including Heat
// ============================================================

///|
fn level_15() -> @types.Level {
  // "Melt" - Use heat to thin walls
  make_level(
    Crystal,
    "Melt",
    [
      [f, f, f, f, f, f, f, f],
      [f, t, f, t, t, f, t, f],
      [f, t, f, t, t, f, t, f],
      [f, t, t, t, t, t, t, f],
      [f, t, t, t, t, t, t, f],
      [f, t, f, t, t, f, t, f],
      [f, t, f, t, t, f, t, f],
      [f, f, f, f, f, f, f, f],
    ],
    [
      [f, f, f, f, f, f, f, f],
      [f, f, f, t, t, f, f, f],
      [f, f, f, t, t, f, f, f],
      [f, f, t, t, t, t, f, f],
      [f, f, t, t, t, t, f, f],
      [f, f, f, t, t, f, f, f],
      [f, f, f, t, t, f, f, f],
      [f, f, f, f, f, f, f, f],
    ],
    water=0,
    wind=0,
    frost=0,
    heat=1,
    par=1,
  )
}

///|
fn level_16() -> @types.Level {
  // "Spire" - Combine all forces to make a spire
  make_level(
    Crystal,
    "Spire",
    [
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
    ],
    [
      [f, f, f, t, t, f, f, f],
      [f, f, t, t, t, t, f, f],
      [f, f, t, t, t, t, f, f],
      [f, t, t, t, t, t, t, f],
      [f, t, t, t, t, t, t, f],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
    ],
    water=1,
    wind=3,
    frost=2,
    heat=1,
    par=5,
  )
}

///|
fn level_17() -> @types.Level {
  // "Hollow" - Create a hollow box using heat
  make_level(
    Crystal,
    "Hollow",
    [
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, f, f, f, f, t, t],
      [t, t, f, t, t, f, t, t],
      [t, t, f, t, t, f, t, t],
      [t, t, f, f, f, f, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
    ],
    [
      [f, f, f, f, f, f, f, f],
      [f, t, t, t, t, t, t, f],
      [f, t, f, f, f, f, t, f],
      [f, t, f, f, f, f, t, f],
      [f, t, f, f, f, f, t, f],
      [f, t, f, f, f, f, t, f],
      [f, t, t, t, t, t, t, f],
      [f, f, f, f, f, f, f, f],
    ],
    water=1,
    wind=0,
    frost=1,
    heat=2,
    par=4,
  )
}

///|
fn level_18() -> @types.Level {
  // "Staircase" - Precision carving
  make_level(
    Crystal,
    "Staircase",
    [
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
    ],
    [
      [f, f, f, f, f, f, f, f],
      [f, f, f, f, f, f, f, t],
      [f, f, f, f, f, f, t, t],
      [f, f, f, f, f, t, t, t],
      [f, f, f, f, t, t, t, t],
      [f, f, f, t, t, t, t, t],
      [f, f, t, t, t, t, t, t],
      [f, t, t, t, t, t, t, t],
    ],
    water=2,
    wind=3,
    frost=2,
    heat=1,
    par=6,
  )
}

///|
fn level_19() -> @types.Level {
  // "Fortress" - Complex multi-force puzzle
  make_level(
    Crystal,
    "Fortress",
    [
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, f, f, t, t, t],
      [t, t, t, f, f, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
    ],
    [
      [f, f, f, f, f, f, f, f],
      [f, t, f, f, f, f, t, f],
      [f, t, f, f, f, f, t, f],
      [f, t, f, f, f, f, t, f],
      [f, t, f, f, f, f, t, f],
      [f, t, f, f, f, f, t, f],
      [f, t, t, t, t, t, t, f],
      [f, f, f, f, f, f, f, f],
    ],
    water=2,
    wind=2,
    frost=2,
    heat=2,
    par=6,
  )
}

///|
fn level_20() -> @types.Level {
  // "Masterwork" - Final challenge requiring precise sequencing
  make_level(
    Crystal,
    "Masterwork",
    [
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
      [t, t, t, t, t, t, t, t],
    ],
    [
      [f, f, f, f, f, f, f, f],
      [f, f, t, f, f, t, f, f],
      [f, t, t, t, t, t, t, f],
      [f, t, t, t, t, t, t, f],
      [f, t, t, t, t, t, t, f],
      [f, t, t, t, t, t, t, f],
      [f, f, t, t, t, t, f, f],
      [f, f, f, t, t, f, f, f],
    ],
    water=2,
    wind=3,
    frost=3,
    heat=2,
    par=7,
  )
}

///|
let all_levels_cache : Ref[Array[@types.Level]?] = { val: None, }

///|
pub fn get_all_levels() -> Array[@types.Level] {
  match all_levels_cache.val {
    Some(levels) => levels
    None => {
      let levels : Array[@types.Level] = [
        level_01(),
        level_02(),
        level_03(),
        level_04(),
        level_05(),
        level_06(),
        level_07(),
        level_08(),
        level_09(),
        level_10(),
        level_11(),
        level_12(),
        level_13(),
        level_14(),
        level_15(),
        level_16(),
        level_17(),
        level_18(),
        level_19(),
        level_20(),
      ]
      all_levels_cache.val = Some(levels)
      levels
    }
  }
}

///|
pub fn get_level(index : Int) -> @types.Level {
  get_all_levels()[index]
}

///|
pub fn level_count() -> Int {
  get_all_levels().length()
}
