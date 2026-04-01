///|
pub fn create_all_levels() -> Array[@types.Level] {
  let levels : Array[@types.Level] = []
  // Tier 1: Surveyor (8 levels) - distance + direction clues only
  levels.push(level_01())
  levels.push(level_02())
  levels.push(level_03())
  levels.push(level_04())
  levels.push(level_05())
  levels.push(level_06())
  levels.push(level_07())
  levels.push(level_08())
  // Tier 2: Explorer (9 levels) - all clue types
  levels.push(level_09())
  levels.push(level_10())
  levels.push(level_11())
  levels.push(level_12())
  levels.push(level_13())
  levels.push(level_14())
  levels.push(level_15())
  levels.push(level_16())
  levels.push(level_17())
  // Tier 3: Master (8 levels) - tight constraints
  levels.push(level_18())
  levels.push(level_19())
  levels.push(level_20())
  levels.push(level_21())
  levels.push(level_22())
  levels.push(level_23())
  levels.push(level_24())
  levels.push(level_25())
  levels
}

// ===== TIER 1: SURVEYOR =====

///|
fn level_01() -> @types.Level {
  // Solution: Mountain at (2,2), Town at (5,2)
  @types.new_level(
    "First Steps",
    Surveyor,
    [Mountain, Town],
    [
      @types.new_clue(
        Distance,
        Mountain,
        feature_b=Town,
        distance=3,
        text="The mountain is exactly 3 tiles from the town",
      ),
      @types.new_clue(
        Direction,
        Town,
        feature_b=Mountain,
        direction=E,
        text="The town is east of the mountain",
      ),
      @types.new_clue(
        Not,
        Mountain,
        direction=N,
        row_col=0,
        text="No mountains in row 1",
      ),
    ],
    2,
    description="A simple map with a mountain and a town",
  )
}

///|
fn level_02() -> @types.Level {
  // Solution: Forest at (1,1), Lake at (1,4)
  @types.new_level(
    "Lakeside",
    Surveyor,
    [Forest, Lake],
    [
      @types.new_clue(
        Distance,
        Forest,
        feature_b=Lake,
        distance=3,
        text="The forest is exactly 3 tiles from the lake",
      ),
      @types.new_clue(
        Direction,
        Forest,
        feature_b=Lake,
        direction=N,
        text="The forest is north of the lake",
      ),
      @types.new_clue(
        Not,
        Forest,
        direction=S,
        row_col=0,
        text="No forests in column 1",
      ),
    ],
    2,
    description="Find the forest near the lake",
  )
}

///|
fn level_03() -> @types.Level {
  // Solution: Mountain at (3,1), River at (3,4), Town at (6,1)
  @types.new_level(
    "River Valley",
    Surveyor,
    [Mountain, River, Town],
    [
      @types.new_clue(
        Distance,
        Mountain,
        feature_b=River,
        distance=3,
        text="The mountain is exactly 3 tiles from the river",
      ),
      @types.new_clue(
        Direction,
        Mountain,
        feature_b=River,
        direction=N,
        text="The mountain is north of the river",
      ),
      @types.new_clue(
        Direction,
        Town,
        feature_b=Mountain,
        direction=E,
        text="The town is east of the mountain",
      ),
      @types.new_clue(
        Distance,
        Town,
        feature_b=Mountain,
        distance=3,
        text="The town is exactly 3 tiles from the mountain",
      ),
    ],
    3,
    description="Map a valley with a river running through it",
  )
}

///|
fn level_04() -> @types.Level {
  // Solution: Town at (2,2), Forest at (5,2), Mountain at (2,5)
  @types.new_level(
    "Highland Trail",
    Surveyor,
    [Town, Forest, Mountain],
    [
      @types.new_clue(
        Distance,
        Town,
        feature_b=Forest,
        distance=3,
        text="The town is exactly 3 tiles from the forest",
      ),
      @types.new_clue(
        Direction,
        Forest,
        feature_b=Town,
        direction=E,
        text="The forest is east of the town",
      ),
      @types.new_clue(
        Direction,
        Mountain,
        feature_b=Town,
        direction=S,
        text="The mountain is south of the town",
      ),
      @types.new_clue(
        Distance,
        Mountain,
        feature_b=Town,
        distance=3,
        text="The mountain is exactly 3 tiles from the town",
      ),
    ],
    3,
    description="Chart the highland trail connecting three landmarks",
  )
}

///|
fn level_05() -> @types.Level {
  // Solution: Lake at (4,1), Desert at (4,5), Mountain at (1,3)
  @types.new_level(
    "Oasis Search",
    Surveyor,
    [Lake, Desert, Mountain],
    [
      @types.new_clue(
        Distance,
        Lake,
        feature_b=Desert,
        distance=4,
        text="The lake is exactly 4 tiles from the desert",
      ),
      @types.new_clue(
        Direction,
        Lake,
        feature_b=Desert,
        direction=N,
        text="The lake is north of the desert",
      ),
      @types.new_clue(
        Direction,
        Mountain,
        feature_b=Lake,
        direction=W,
        text="The mountain is west of the lake",
      ),
      @types.new_clue(
        Distance,
        Mountain,
        feature_b=Lake,
        distance=5,
        text="The mountain is exactly 5 tiles from the lake",
      ),
    ],
    3,
    description="Find the oasis in the desert near the mountains",
  )
}

///|
fn level_06() -> @types.Level {
  // Solution: Town(2,1) Forest(5,1) River(2,4) Mountain(5,4)
  @types.new_level(
    "Four Corners",
    Surveyor,
    [Town, Forest, River, Mountain],
    [
      @types.new_clue(
        Distance,
        Town,
        feature_b=Forest,
        distance=3,
        text="The town is exactly 3 tiles from the forest",
      ),
      @types.new_clue(
        Direction,
        Forest,
        feature_b=Town,
        direction=E,
        text="The forest is east of the town",
      ),
      @types.new_clue(
        Distance,
        River,
        feature_b=Town,
        distance=3,
        text="The river is exactly 3 tiles from the town",
      ),
      @types.new_clue(
        Direction,
        River,
        feature_b=Town,
        direction=S,
        text="The river is south of the town",
      ),
      @types.new_clue(
        Direction,
        Mountain,
        feature_b=River,
        direction=E,
        text="The mountain is east of the river",
      ),
    ],
    4,
    description="Map four landmarks at the corners of the region",
  )
}

///|
fn level_07() -> @types.Level {
  // Solution: Mountain(3,0) Town(3,3) Lake(6,3) Forest(0,3) Desert(3,6)
  @types.new_level(
    "Star Pattern",
    Surveyor,
    [Mountain, Town, Lake, Forest, Desert],
    [
      @types.new_clue(
        Direction,
        Mountain,
        feature_b=Town,
        direction=N,
        text="The mountain is north of the town",
      ),
      @types.new_clue(
        Distance,
        Mountain,
        feature_b=Town,
        distance=3,
        text="The mountain is exactly 3 tiles from the town",
      ),
      @types.new_clue(
        Direction,
        Lake,
        feature_b=Town,
        direction=E,
        text="The lake is east of the town",
      ),
      @types.new_clue(
        Distance,
        Lake,
        feature_b=Town,
        distance=3,
        text="The lake is exactly 3 tiles from the town",
      ),
      @types.new_clue(
        Direction,
        Forest,
        feature_b=Town,
        direction=W,
        text="The forest is west of the town",
      ),
      @types.new_clue(
        Distance,
        Forest,
        feature_b=Town,
        distance=3,
        text="The forest is exactly 3 tiles from the town",
      ),
    ],
    5,
    description="Five landmarks in a star pattern",
  )
}

///|
fn level_08() -> @types.Level {
  // Solution: Town(1,2) Mountain(4,2) River(4,5) Forest(1,5) Lake(7,2)
  @types.new_level(
    "Expedition",
    Surveyor,
    [Town, Mountain, River, Forest, Lake],
    [
      @types.new_clue(
        Distance,
        Town,
        feature_b=Mountain,
        distance=3,
        text="The town is exactly 3 tiles from the mountain",
      ),
      @types.new_clue(
        Direction,
        Mountain,
        feature_b=Town,
        direction=E,
        text="The mountain is east of the town",
      ),
      @types.new_clue(
        Distance,
        Mountain,
        feature_b=River,
        distance=3,
        text="The mountain is exactly 3 tiles from the river",
      ),
      @types.new_clue(
        Direction,
        River,
        feature_b=Mountain,
        direction=S,
        text="The river is south of the mountain",
      ),
      @types.new_clue(
        Direction,
        Forest,
        feature_b=River,
        direction=W,
        text="The forest is west of the river",
      ),
      @types.new_clue(
        Distance,
        Forest,
        feature_b=River,
        distance=3,
        text="The forest is exactly 3 tiles from the river",
      ),
    ],
    5,
    description="Chart the complete expedition route",
  )
}

// ===== TIER 2: EXPLORER =====

///|
fn level_09() -> @types.Level {
  // Solution: Mountain(3,2) Town(4,2) River(3,5)
  @types.new_level(
    "Neighbors",
    Explorer,
    [Mountain, Town, River, Forest, Lake],
    [
      @types.new_clue(
        Adjacent,
        Mountain,
        feature_b=Town,
        text="The mountain is adjacent to the town",
      ),
      @types.new_clue(
        Direction,
        Town,
        feature_b=Mountain,
        direction=E,
        text="The town is east of the mountain",
      ),
      @types.new_clue(
        Distance,
        River,
        feature_b=Mountain,
        distance=3,
        text="The river is exactly 3 tiles from the mountain",
      ),
      @types.new_clue(
        Direction,
        River,
        feature_b=Mountain,
        direction=S,
        text="The river is south of the mountain",
      ),
      @types.new_clue(
        Adjacent,
        Forest,
        feature_b=Lake,
        text="The forest is adjacent to the lake",
      ),
      @types.new_clue(
        Direction,
        Forest,
        feature_b=Lake,
        direction=N,
        text="The forest is north of the lake",
      ),
      @types.new_clue(
        Distance,
        Forest,
        feature_b=Town,
        distance=4,
        text="The forest is exactly 4 tiles from the town",
      ),
    ],
    5,
    description="Adjacent landmarks reveal the map",
  )
}

///|
fn level_10() -> @types.Level {
  // Solution: Town(2,3) Mountain(5,3) Forest(2,0) River(5,6) Desert(2,6)
  @types.new_level(
    "Row Count",
    Explorer,
    [Town, Mountain, Forest, River, Desert],
    [
      @types.new_clue(
        Count,
        Town,
        direction=N,
        row_col=3,
        count=1,
        text="There is exactly 1 town in row 4",
      ),
      @types.new_clue(
        Count,
        Mountain,
        direction=N,
        row_col=3,
        count=1,
        text="There is exactly 1 mountain in row 4",
      ),
      @types.new_clue(
        Distance,
        Town,
        feature_b=Mountain,
        distance=3,
        text="The town is exactly 3 tiles from the mountain",
      ),
      @types.new_clue(
        Direction,
        Mountain,
        feature_b=Town,
        direction=E,
        text="The mountain is east of the town",
      ),
      @types.new_clue(
        Direction,
        Forest,
        feature_b=Town,
        direction=N,
        text="The forest is north of the town",
      ),
      @types.new_clue(
        Distance,
        Forest,
        feature_b=Town,
        distance=3,
        text="The forest is exactly 3 tiles from the town",
      ),
      @types.new_clue(
        Direction,
        River,
        feature_b=Mountain,
        direction=S,
        text="The river is south of the mountain",
      ),
    ],
    5,
    description="Count the features in each row",
  )
}

///|
fn level_11() -> @types.Level {
  // Solution: Mountain(1,1) Town(4,1) Lake(4,4) Forest(1,4) River(2,1)
  @types.new_level(
    "Crossroads",
    Explorer,
    [Mountain, Town, Lake, Forest, River],
    [
      @types.new_clue(
        Adjacent,
        River,
        feature_b=Mountain,
        text="The river is adjacent to the mountain",
      ),
      @types.new_clue(
        Distance,
        Mountain,
        feature_b=Town,
        distance=3,
        text="The mountain is exactly 3 tiles from the town",
      ),
      @types.new_clue(
        Distance,
        Town,
        feature_b=Lake,
        distance=3,
        text="The town is exactly 3 tiles from the lake",
      ),
      @types.new_clue(
        Direction,
        Lake,
        feature_b=Town,
        direction=S,
        text="The lake is south of the town",
      ),
      @types.new_clue(
        Direction,
        Forest,
        feature_b=Lake,
        direction=W,
        text="The forest is west of the lake",
      ),
      @types.new_clue(
        Distance,
        Forest,
        feature_b=Lake,
        distance=3,
        text="The forest is exactly 3 tiles from the lake",
      ),
    ],
    5,
    description="Where the crossroads meet",
  )
}

///|
fn level_12() -> @types.Level {
  // Solution: Town(3,2) Forest(3,5) Mountain(6,2) Lake(0,5) Desert(6,5)
  @types.new_level(
    "No-Go Zones",
    Explorer,
    [Town, Forest, Mountain, Lake, Desert],
    [
      @types.new_clue(
        Not,
        Town,
        direction=S,
        row_col=4,
        text="No towns in column 5",
      ),
      @types.new_clue(
        Not,
        Mountain,
        direction=N,
        row_col=5,
        text="No mountains in row 6",
      ),
      @types.new_clue(
        Distance,
        Town,
        feature_b=Forest,
        distance=3,
        text="The town is exactly 3 tiles from the forest",
      ),
      @types.new_clue(
        Direction,
        Forest,
        feature_b=Town,
        direction=S,
        text="The forest is south of the town",
      ),
      @types.new_clue(
        Distance,
        Mountain,
        feature_b=Town,
        distance=3,
        text="The mountain is exactly 3 tiles from the town",
      ),
      @types.new_clue(
        Direction,
        Mountain,
        feature_b=Town,
        direction=E,
        text="The mountain is east of the town",
      ),
      @types.new_clue(
        Direction,
        Lake,
        feature_b=Forest,
        direction=W,
        text="The lake is west of the forest",
      ),
    ],
    5,
    description="Some areas are off limits",
  )
}

///|
fn level_13() -> @types.Level {
  // Solution: Mountain(2,1) Town(5,1) Forest(2,4) Lake(5,4) River(2,7) Desert(5,7)
  @types.new_level(
    "Grid Lines",
    Explorer,
    [Mountain, Town, Forest, Lake, River, Desert],
    [
      @types.new_clue(
        Count,
        Mountain,
        direction=N,
        row_col=1,
        count=1,
        text="There is exactly 1 mountain in row 2",
      ),
      @types.new_clue(
        Count,
        Town,
        direction=N,
        row_col=1,
        count=1,
        text="There is exactly 1 town in row 2",
      ),
      @types.new_clue(
        Distance,
        Mountain,
        feature_b=Town,
        distance=3,
        text="The mountain is exactly 3 tiles from the town",
      ),
      @types.new_clue(
        Direction,
        Town,
        feature_b=Mountain,
        direction=E,
        text="The town is east of the mountain",
      ),
      @types.new_clue(
        Distance,
        Forest,
        feature_b=Mountain,
        distance=3,
        text="The forest is exactly 3 tiles from the mountain",
      ),
      @types.new_clue(
        Direction,
        Forest,
        feature_b=Mountain,
        direction=S,
        text="The forest is south of the mountain",
      ),
      @types.new_clue(
        Distance,
        Lake,
        feature_b=Town,
        distance=3,
        text="The lake is exactly 3 tiles from the town",
      ),
      @types.new_clue(
        Direction,
        Lake,
        feature_b=Town,
        direction=S,
        text="The lake is south of the town",
      ),
    ],
    6,
    description="Features align along grid lines",
  )
}

///|
fn level_14() -> @types.Level {
  // Solution: Town(3,3) Mountain(3,0) Lake(6,3) Forest(0,3) River(3,6) Desert(6,6)
  @types.new_level(
    "Compass Rose",
    Explorer,
    [Town, Mountain, Lake, Forest, River, Desert],
    [
      @types.new_clue(
        Direction,
        Mountain,
        feature_b=Town,
        direction=N,
        text="The mountain is north of the town",
      ),
      @types.new_clue(
        Distance,
        Mountain,
        feature_b=Town,
        distance=3,
        text="The mountain is exactly 3 tiles from the town",
      ),
      @types.new_clue(
        Direction,
        Lake,
        feature_b=Town,
        direction=E,
        text="The lake is east of the town",
      ),
      @types.new_clue(
        Distance,
        Lake,
        feature_b=Town,
        distance=3,
        text="The lake is exactly 3 tiles from the town",
      ),
      @types.new_clue(
        Direction,
        Forest,
        feature_b=Town,
        direction=W,
        text="The forest is west of the town",
      ),
      @types.new_clue(
        Distance,
        Forest,
        feature_b=Town,
        distance=3,
        text="The forest is exactly 3 tiles from the town",
      ),
      @types.new_clue(
        Direction,
        River,
        feature_b=Town,
        direction=S,
        text="The river is south of the town",
      ),
      @types.new_clue(
        Adjacent,
        Desert,
        feature_b=Lake,
        text="The desert is adjacent to the lake",
      ),
    ],
    6,
    description="All four cardinal directions from the town",
  )
}

///|
fn level_15() -> @types.Level {
  // Solution: Town(2,2) Mountain(5,2) Forest(2,5) Lake(5,5) River(3,2) Road(4,2)
  @types.new_level(
    "Trade Route",
    Explorer,
    [Town, Mountain, Forest, Lake, River, Road],
    [
      @types.new_clue(
        Adjacent,
        Road,
        feature_b=Town,
        text="The road is adjacent to the town",
      ),
      @types.new_clue(
        Adjacent,
        Road,
        feature_b=Mountain,
        text="The road is adjacent to the mountain",
      ),
      @types.new_clue(
        Distance,
        Town,
        feature_b=Mountain,
        distance=3,
        text="The town is exactly 3 tiles from the mountain",
      ),
      @types.new_clue(
        Adjacent,
        River,
        feature_b=Town,
        text="The river is adjacent to the town",
      ),
      @types.new_clue(
        Direction,
        Forest,
        feature_b=Town,
        direction=S,
        text="The forest is south of the town",
      ),
      @types.new_clue(
        Distance,
        Forest,
        feature_b=Town,
        distance=3,
        text="The forest is exactly 3 tiles from the town",
      ),
      @types.new_clue(
        Direction,
        Lake,
        feature_b=Forest,
        direction=E,
        text="The lake is east of the forest",
      ),
    ],
    6,
    description="The road connects the town to the mountain",
  )
}

///|
fn level_16() -> @types.Level {
  // Solution: Mountain(1,1) Town(4,1) Forest(7,1) Lake(1,4) River(4,4) Desert(7,4)
  @types.new_level(
    "Twin Rows",
    Explorer,
    [Mountain, Town, Forest, Lake, River, Desert],
    [
      @types.new_clue(
        Count,
        Mountain,
        direction=N,
        row_col=1,
        count=1,
        text="There is exactly 1 mountain in row 2",
      ),
      @types.new_clue(
        Count,
        Town,
        direction=N,
        row_col=1,
        count=1,
        text="There is exactly 1 town in row 2",
      ),
      @types.new_clue(
        Count,
        Forest,
        direction=N,
        row_col=1,
        count=1,
        text="There is exactly 1 forest in row 2",
      ),
      @types.new_clue(
        Distance,
        Mountain,
        feature_b=Town,
        distance=3,
        text="The mountain is exactly 3 tiles from the town",
      ),
      @types.new_clue(
        Distance,
        Town,
        feature_b=Forest,
        distance=3,
        text="The town is exactly 3 tiles from the forest",
      ),
      @types.new_clue(
        Direction,
        Lake,
        feature_b=Mountain,
        direction=S,
        text="The lake is south of the mountain",
      ),
      @types.new_clue(
        Distance,
        Lake,
        feature_b=Mountain,
        distance=3,
        text="The lake is exactly 3 tiles from the mountain",
      ),
      @types.new_clue(
        Direction,
        Desert,
        feature_b=Forest,
        direction=S,
        text="The desert is south of the forest",
      ),
    ],
    6,
    description="Landmarks arranged in two parallel rows",
  )
}

///|
fn level_17() -> @types.Level {
  // Solution: Town(3,1) Mountain(6,1) Forest(3,4) Lake(6,4) River(0,4) Road(3,7) Desert(6,7)
  @types.new_level(
    "The Borderlands",
    Explorer,
    [Town, Mountain, Forest, Lake, River, Road, Desert],
    [
      @types.new_clue(
        Distance,
        Town,
        feature_b=Mountain,
        distance=3,
        text="The town is exactly 3 tiles from the mountain",
      ),
      @types.new_clue(
        Direction,
        Mountain,
        feature_b=Town,
        direction=E,
        text="The mountain is east of the town",
      ),
      @types.new_clue(
        Distance,
        Forest,
        feature_b=Town,
        distance=3,
        text="The forest is exactly 3 tiles from the town",
      ),
      @types.new_clue(
        Direction,
        Forest,
        feature_b=Town,
        direction=S,
        text="The forest is south of the town",
      ),
      @types.new_clue(
        Adjacent,
        Lake,
        feature_b=Forest,
        text="The lake is adjacent to the forest",
      ),
      @types.new_clue(
        Direction,
        Lake,
        feature_b=Forest,
        direction=E,
        text="The lake is east of the forest",
      ),
      @types.new_clue(
        Not,
        River,
        direction=N,
        row_col=1,
        text="No rivers in row 2",
      ),
      @types.new_clue(
        Distance,
        River,
        feature_b=Forest,
        distance=3,
        text="The river is exactly 3 tiles from the forest",
      ),
    ],
    7,
    description="Chart the borderlands between settlements",
  )
}

// ===== TIER 3: MASTER =====

///|
fn level_18() -> @types.Level {
  // Solution: Town(2,1) Mountain(5,1) Forest(2,4) Lake(5,4) River(2,7) Desert(5,7) Road(3,1)
  @types.new_level(
    "Cartographer's Trial",
    Master,
    [Town, Mountain, Forest, Lake, River, Desert, Road],
    [
      @types.new_clue(
        Adjacent,
        Road,
        feature_b=Town,
        text="The road is adjacent to the town",
      ),
      @types.new_clue(
        Adjacent,
        Road,
        feature_b=Mountain,
        text="The road is adjacent to the mountain",
      ),
      @types.new_clue(
        Distance,
        Town,
        feature_b=Mountain,
        distance=3,
        text="The town is exactly 3 tiles from the mountain",
      ),
      @types.new_clue(
        Direction,
        Mountain,
        feature_b=Town,
        direction=E,
        text="The mountain is east of the town",
      ),
      @types.new_clue(
        Distance,
        Forest,
        feature_b=Town,
        distance=3,
        text="The forest is exactly 3 tiles from the town",
      ),
      @types.new_clue(
        Direction,
        Forest,
        feature_b=Town,
        direction=S,
        text="The forest is south of the town",
      ),
      @types.new_clue(
        Distance,
        Lake,
        feature_b=Mountain,
        distance=3,
        text="The lake is exactly 3 tiles from the mountain",
      ),
      @types.new_clue(
        Direction,
        Lake,
        feature_b=Mountain,
        direction=S,
        text="The lake is south of the mountain",
      ),
      @types.new_clue(
        Not,
        Desert,
        direction=N,
        row_col=4,
        text="No deserts in row 5",
      ),
      @types.new_clue(
        Count,
        River,
        direction=S,
        row_col=2,
        count=1,
        text="There is exactly 1 river in column 3",
      ),
    ],
    7,
    description="The true test of a cartographer begins",
  )
}

///|
fn level_19() -> @types.Level {
  // Solution: Town(1,2) Mountain(4,2) Lake(7,2) Forest(1,5) River(4,5) Desert(7,5) Road(1,7)
  @types.new_level(
    "Dual Paths",
    Master,
    [Town, Mountain, Lake, Forest, River, Desert, Road],
    [
      @types.new_clue(
        Count,
        Town,
        direction=N,
        row_col=2,
        count=1,
        text="There is exactly 1 town in row 3",
      ),
      @types.new_clue(
        Distance,
        Town,
        feature_b=Mountain,
        distance=3,
        text="The town is exactly 3 tiles from the mountain",
      ),
      @types.new_clue(
        Direction,
        Mountain,
        feature_b=Town,
        direction=E,
        text="The mountain is east of the town",
      ),
      @types.new_clue(
        Distance,
        Mountain,
        feature_b=Lake,
        distance=3,
        text="The mountain is exactly 3 tiles from the lake",
      ),
      @types.new_clue(
        Direction,
        Lake,
        feature_b=Mountain,
        direction=E,
        text="The lake is east of the mountain",
      ),
      @types.new_clue(
        Direction,
        Forest,
        feature_b=Town,
        direction=S,
        text="The forest is south of the town",
      ),
      @types.new_clue(
        Distance,
        Forest,
        feature_b=Town,
        distance=3,
        text="The forest is exactly 3 tiles from the town",
      ),
      @types.new_clue(
        Adjacent,
        Road,
        feature_b=Forest,
        text="The road is adjacent to the forest",
      ),
      @types.new_clue(
        Not,
        Desert,
        direction=S,
        row_col=1,
        text="No deserts in column 2",
      ),
    ],
    7,
    description="Two parallel paths through the wilderness",
  )
}

///|
fn level_20() -> @types.Level {
  // Solution: Town(3,1) Mountain(3,4) Forest(6,1) Lake(6,4) River(0,1) Desert(0,4) Road(3,7)
  @types.new_level(
    "Column Puzzle",
    Master,
    [Town, Mountain, Forest, Lake, River, Desert, Road],
    [
      @types.new_clue(
        Count,
        Town,
        direction=S,
        row_col=3,
        count=1,
        text="There is exactly 1 town in column 4",
      ),
      @types.new_clue(
        Count,
        Mountain,
        direction=S,
        row_col=3,
        count=1,
        text="There is exactly 1 mountain in column 4",
      ),
      @types.new_clue(
        Direction,
        Mountain,
        feature_b=Town,
        direction=S,
        text="The mountain is south of the town",
      ),
      @types.new_clue(
        Distance,
        Mountain,
        feature_b=Town,
        distance=3,
        text="The mountain is exactly 3 tiles from the town",
      ),
      @types.new_clue(
        Direction,
        Forest,
        feature_b=Town,
        direction=E,
        text="The forest is east of the town",
      ),
      @types.new_clue(
        Distance,
        Forest,
        feature_b=Town,
        distance=3,
        text="The forest is exactly 3 tiles from the town",
      ),
      @types.new_clue(
        Direction,
        Lake,
        feature_b=Forest,
        direction=S,
        text="The lake is south of the forest",
      ),
      @types.new_clue(
        Distance,
        Lake,
        feature_b=Forest,
        distance=3,
        text="The lake is exactly 3 tiles from the forest",
      ),
      @types.new_clue(
        Not,
        River,
        direction=N,
        row_col=4,
        text="No rivers in row 5",
      ),
      @types.new_clue(
        Direction,
        Desert,
        feature_b=River,
        direction=S,
        text="The desert is south of the river",
      ),
    ],
    7,
    description="Features align in columns",
  )
}

///|
fn level_21() -> @types.Level {
  // Solution: Town(2,2) Mountain(5,2) Forest(2,5) Lake(5,5) River(7,2) Desert(7,5) Road(0,2) Road is tricky
  @types.new_level(
    "Boundary Survey",
    Master,
    [Town, Mountain, Forest, Lake, River, Desert, Road],
    [
      @types.new_clue(
        Distance,
        Town,
        feature_b=Mountain,
        distance=3,
        text="The town is exactly 3 tiles from the mountain",
      ),
      @types.new_clue(
        Direction,
        Mountain,
        feature_b=Town,
        direction=E,
        text="The mountain is east of the town",
      ),
      @types.new_clue(
        Distance,
        Forest,
        feature_b=Town,
        distance=3,
        text="The forest is exactly 3 tiles from the town",
      ),
      @types.new_clue(
        Direction,
        Forest,
        feature_b=Town,
        direction=S,
        text="The forest is south of the town",
      ),
      @types.new_clue(
        Distance,
        Lake,
        feature_b=Mountain,
        distance=3,
        text="The lake is exactly 3 tiles from the mountain",
      ),
      @types.new_clue(
        Direction,
        Lake,
        feature_b=Mountain,
        direction=S,
        text="The lake is south of the mountain",
      ),
      @types.new_clue(
        Adjacent,
        River,
        feature_b=Mountain,
        text="The river is adjacent to the mountain",
      ),
      @types.new_clue(
        Direction,
        River,
        feature_b=Mountain,
        direction=E,
        text="The river is east of the mountain",
      ),
      @types.new_clue(
        Adjacent,
        Desert,
        feature_b=Lake,
        text="The desert is adjacent to the lake",
      ),
      @types.new_clue(
        Direction,
        Desert,
        feature_b=Lake,
        direction=E,
        text="The desert is east of the lake",
      ),
      @types.new_clue(
        Not,
        Road,
        direction=N,
        row_col=5,
        text="No roads in row 6",
      ),
    ],
    7,
    description="Survey the boundary of the kingdom",
  )
}

///|
fn level_22() -> @types.Level {
  // Solution: Town(1,1) Mountain(4,1) Forest(7,1) Lake(1,4) River(4,4) Desert(7,4) Road(1,7) Road2 -> use Forest(4,7)
  // Adjust: 8 features
  @types.new_level(
    "Eight Points",
    Master,
    [Town, Mountain, Forest, Lake, River, Desert, Road, Forest],
    [
      @types.new_clue(
        Distance,
        Town,
        feature_b=Mountain,
        distance=3,
        text="The town is exactly 3 tiles from the mountain",
      ),
      @types.new_clue(
        Direction,
        Mountain,
        feature_b=Town,
        direction=E,
        text="The mountain is east of the town",
      ),
      @types.new_clue(
        Distance,
        Mountain,
        feature_b=Forest,
        distance=3,
        text="A mountain is exactly 3 tiles from a forest",
      ),
      @types.new_clue(
        Count,
        Forest,
        direction=N,
        row_col=1,
        count=1,
        text="There is exactly 1 forest in row 2",
      ),
      @types.new_clue(
        Direction,
        Lake,
        feature_b=Town,
        direction=S,
        text="The lake is south of the town",
      ),
      @types.new_clue(
        Distance,
        Lake,
        feature_b=Town,
        distance=3,
        text="The lake is exactly 3 tiles from the town",
      ),
      @types.new_clue(
        Direction,
        River,
        feature_b=Mountain,
        direction=S,
        text="The river is south of the mountain",
      ),
      @types.new_clue(
        Distance,
        River,
        feature_b=Mountain,
        distance=3,
        text="The river is exactly 3 tiles from the mountain",
      ),
      @types.new_clue(
        Not,
        Desert,
        direction=S,
        row_col=1,
        text="No deserts in column 2",
      ),
      @types.new_clue(
        Direction,
        Road,
        feature_b=Lake,
        direction=S,
        text="The road is south of the lake",
      ),
      @types.new_clue(
        Distance,
        Road,
        feature_b=Lake,
        distance=3,
        text="The road is exactly 3 tiles from the lake",
      ),
    ],
    8,
    description="Eight landmarks to chart precisely",
  )
}

///|
fn level_23() -> @types.Level {
  // Solution: Town(3,0) Mountain(3,3) Lake(3,6) Forest(0,3) River(6,3) Desert(6,0) Road(6,6)
  @types.new_level(
    "The Cross",
    Master,
    [Town, Mountain, Lake, Forest, River, Desert, Road],
    [
      @types.new_clue(
        Direction,
        Town,
        feature_b=Mountain,
        direction=N,
        text="The town is north of the mountain",
      ),
      @types.new_clue(
        Distance,
        Town,
        feature_b=Mountain,
        distance=3,
        text="The town is exactly 3 tiles from the mountain",
      ),
      @types.new_clue(
        Direction,
        Lake,
        feature_b=Mountain,
        direction=S,
        text="The lake is south of the mountain",
      ),
      @types.new_clue(
        Distance,
        Lake,
        feature_b=Mountain,
        distance=3,
        text="The lake is exactly 3 tiles from the mountain",
      ),
      @types.new_clue(
        Direction,
        Forest,
        feature_b=Mountain,
        direction=W,
        text="The forest is west of the mountain",
      ),
      @types.new_clue(
        Distance,
        Forest,
        feature_b=Mountain,
        distance=3,
        text="The forest is exactly 3 tiles from the mountain",
      ),
      @types.new_clue(
        Direction,
        River,
        feature_b=Mountain,
        direction=E,
        text="The river is east of the mountain",
      ),
      @types.new_clue(
        Distance,
        River,
        feature_b=Mountain,
        distance=3,
        text="The river is exactly 3 tiles from the mountain",
      ),
      @types.new_clue(
        Not,
        Desert,
        direction=N,
        row_col=3,
        text="No deserts in row 4",
      ),
      @types.new_clue(
        Direction,
        Desert,
        feature_b=Town,
        direction=E,
        text="The desert is east of the town",
      ),
      @types.new_clue(
        Adjacent,
        Road,
        feature_b=Lake,
        text="The road is adjacent to the lake",
      ),
      @types.new_clue(
        Direction,
        Road,
        feature_b=Lake,
        direction=E,
        text="The road is east of the lake",
      ),
    ],
    7,
    description="A cross pattern centered on the mountain",
  )
}

///|
fn level_24() -> @types.Level {
  // Solution: Town(1,1) Mountain(1,4) Forest(1,7) Lake(4,1) River(4,4) Desert(4,7) Road(7,1) + extra town at 7,4
  @types.new_level(
    "Grid Master",
    Master,
    [Town, Mountain, Forest, Lake, River, Desert, Road, Town],
    [
      @types.new_clue(
        Count,
        Town,
        direction=S,
        row_col=1,
        count=1,
        text="There is exactly 1 town in column 2",
      ),
      @types.new_clue(
        Count,
        Town,
        direction=S,
        row_col=7,
        count=1,
        text="There is exactly 1 town in column 8",
      ),
      @types.new_clue(
        Distance,
        Mountain,
        feature_b=Lake,
        distance=3,
        text="A mountain is exactly 3 tiles from a lake",
      ),
      @types.new_clue(
        Direction,
        Mountain,
        feature_b=Forest,
        direction=N,
        text="The mountain is north of the forest",
      ),
      @types.new_clue(
        Distance,
        Mountain,
        feature_b=Forest,
        distance=3,
        text="The mountain is exactly 3 tiles from the forest",
      ),
      @types.new_clue(
        Direction,
        Lake,
        feature_b=River,
        direction=N,
        text="The lake is north of the river",
      ),
      @types.new_clue(
        Distance,
        Lake,
        feature_b=River,
        distance=3,
        text="The lake is exactly 3 tiles from the river",
      ),
      @types.new_clue(
        Not,
        Forest,
        direction=N,
        row_col=0,
        text="No forests in row 1",
      ),
      @types.new_clue(
        Not,
        Desert,
        direction=S,
        row_col=0,
        text="No deserts in column 1",
      ),
      @types.new_clue(
        Direction,
        Road,
        feature_b=Lake,
        direction=E,
        text="The road is east of the lake",
      ),
      @types.new_clue(
        Distance,
        Road,
        feature_b=Lake,
        distance=3,
        text="The road is exactly 3 tiles from the lake",
      ),
    ],
    8,
    description="Master the full 3x3 grid of landmarks",
  )
}

///|
fn level_25() -> @types.Level {
  // Solution: sprawling map with 10 features
  // Town(1,1) Mountain(4,1) Forest(7,1) Lake(1,4) River(4,4) Desert(7,4) Road(1,7) Town2(4,7) Mountain2(7,7) Forest2(0,0)
  @types.new_level(
    "Grand Cartograph",
    Master,
    [Town, Mountain, Forest, Lake, River, Desert, Road, Town, Mountain, Forest],
    [
      @types.new_clue(
        Count,
        Town,
        direction=N,
        row_col=1,
        count=1,
        text="There is exactly 1 town in row 2",
      ),
      @types.new_clue(
        Count,
        Mountain,
        direction=N,
        row_col=1,
        count=1,
        text="There is exactly 1 mountain in row 2",
      ),
      @types.new_clue(
        Count,
        Forest,
        direction=N,
        row_col=1,
        count=1,
        text="There is exactly 1 forest in row 2",
      ),
      @types.new_clue(
        Distance,
        Lake,
        feature_b=River,
        distance=3,
        text="A lake is exactly 3 tiles from a river",
      ),
      @types.new_clue(
        Direction,
        Lake,
        feature_b=River,
        direction=W,
        text="The lake is west of the river",
      ),
      @types.new_clue(
        Not,
        Desert,
        direction=S,
        row_col=1,
        text="No deserts in column 2",
      ),
      @types.new_clue(
        Not,
        Road,
        direction=N,
        row_col=1,
        text="No roads in row 2",
      ),
      @types.new_clue(
        Direction,
        Road,
        feature_b=Lake,
        direction=S,
        text="The road is south of the lake",
      ),
      @types.new_clue(
        Distance,
        Road,
        feature_b=Lake,
        distance=3,
        text="The road is exactly 3 tiles from the lake",
      ),
      @types.new_clue(
        Count,
        Forest,
        direction=N,
        row_col=0,
        count=1,
        text="There is exactly 1 forest in row 1",
      ),
      @types.new_clue(
        Count,
        Town,
        direction=N,
        row_col=7,
        count=1,
        text="There is exactly 1 town in row 8",
      ),
      @types.new_clue(
        Count,
        Mountain,
        direction=N,
        row_col=7,
        count=1,
        text="There is exactly 1 mountain in row 8",
      ),
    ],
    10,
    description="The ultimate cartography challenge - map the entire realm",
  )
}
