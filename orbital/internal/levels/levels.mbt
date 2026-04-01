///|
fn level_01() -> @types.Level {
  // Direct Shot - straight line to station, planet off to the side
  @types.make_level(
    [@types.make_planet(400.0, 150.0, 1.0, 30.0)],
    @types.make_station(700.0, 300.0, 25.0),
    [@types.make_waypoint(500.0, 300.0, 20.0)],
    100.0,
    300.0,
    80,
    "Direct Shot",
    Launch,
  )
}

///|
fn level_02() -> @types.Level {
  // Gentle Arc - planet slightly pulls trajectory
  @types.make_level(
    [@types.make_planet(400.0, 200.0, 1.5, 35.0)],
    @types.make_station(650.0, 400.0, 25.0),
    [@types.make_waypoint(550.0, 280.0, 20.0)],
    100.0,
    200.0,
    90,
    "Gentle Arc",
    Launch,
  )
}

///|
fn level_03() -> @types.Level {
  // Upward Curve - planet below pulls probe down then up
  @types.make_level(
    [@types.make_planet(350.0, 450.0, 2.0, 35.0)],
    @types.make_station(700.0, 150.0, 25.0),
    [@types.make_waypoint(500.0, 350.0, 20.0)],
    100.0,
    350.0,
    100,
    "Upward Curve",
    Launch,
  )
}

///|
fn level_04() -> @types.Level {
  // Orbital Bend - significant curve around planet
  @types.make_level(
    [@types.make_planet(400.0, 300.0, 2.5, 40.0)],
    @types.make_station(200.0, 100.0, 25.0),
    [@types.make_waypoint(350.0, 150.0, 20.0)],
    100.0,
    500.0,
    110,
    "Orbital Bend",
    Launch,
  )
}

///|
fn level_05() -> @types.Level {
  // Tight Pass - probe must skim past planet
  @types.make_level(
    [@types.make_planet(350.0, 300.0, 2.0, 45.0)],
    @types.make_station(700.0, 300.0, 25.0),
    [@types.make_waypoint(400.0, 220.0, 18.0)],
    100.0,
    300.0,
    85,
    "Tight Pass",
    Launch,
  )
}

///|
fn level_06() -> @types.Level {
  // Gravity Hook - use planet to hook around to target behind
  @types.make_level(
    [@types.make_planet(400.0, 300.0, 3.0, 40.0)],
    @types.make_station(200.0, 450.0, 25.0),
    [@types.make_waypoint(450.0, 420.0, 20.0)],
    150.0,
    200.0,
    130,
    "Gravity Hook",
    Launch,
  )
}

///|
fn level_07() -> @types.Level {
  // High Lob - launch high, gravity pulls down to target
  @types.make_level(
    [@types.make_planet(400.0, 500.0, 2.5, 35.0)],
    @types.make_station(650.0, 480.0, 25.0),
    [@types.make_waypoint(400.0, 250.0, 20.0)],
    100.0,
    450.0,
    120,
    "High Lob",
    Launch,
  )
}

///|
fn level_08() -> @types.Level {
  // Boomerang - launch away, planet bends back
  @types.make_level(
    [@types.make_planet(350.0, 300.0, 3.5, 45.0)],
    @types.make_station(100.0, 400.0, 25.0),
    [@types.make_waypoint(500.0, 200.0, 20.0)],
    200.0,
    500.0,
    150,
    "Boomerang",
    Launch,
  )
}

// Tier 2: Slingshot (2 planets)

///|
fn level_09() -> @types.Level {
  // Twin Gates - two planets form a corridor
  @types.make_level(
    [
      @types.make_planet(350.0, 200.0, 1.5, 30.0),
      @types.make_planet(350.0, 400.0, 1.5, 30.0),
    ],
    @types.make_station(700.0, 300.0, 25.0),
    [@types.make_waypoint(350.0, 300.0, 18.0)],
    100.0,
    300.0,
    80,
    "Twin Gates",
    Slingshot,
  )
}

///|
fn level_10() -> @types.Level {
  // Gravity Assist - use first planet to sling toward second
  @types.make_level(
    [
      @types.make_planet(300.0, 250.0, 2.0, 35.0),
      @types.make_planet(550.0, 400.0, 2.0, 35.0),
    ],
    @types.make_station(700.0, 200.0, 25.0),
    [@types.make_waypoint(450.0, 350.0, 20.0)],
    100.0,
    400.0,
    110,
    "Gravity Assist",
    Slingshot,
  )
}

///|
fn level_11() -> @types.Level {
  // Double Bend - two sequential curves
  @types.make_level(
    [
      @types.make_planet(250.0, 200.0, 2.0, 35.0),
      @types.make_planet(500.0, 450.0, 2.5, 35.0),
    ],
    @types.make_station(700.0, 150.0, 25.0),
    [@types.make_waypoint(400.0, 300.0, 20.0)],
    100.0,
    350.0,
    120,
    "Double Bend",
    Slingshot,
  )
}

///|
fn level_12() -> @types.Level {
  // Pinch Point - planets close together create tight channel
  @types.make_level(
    [
      @types.make_planet(400.0, 230.0, 2.0, 40.0),
      @types.make_planet(400.0, 370.0, 2.0, 40.0),
    ],
    @types.make_station(700.0, 300.0, 25.0),
    [@types.make_waypoint(400.0, 300.0, 15.0)],
    100.0,
    300.0,
    85,
    "Pinch Point",
    Slingshot,
  )
}

///|
fn level_13() -> @types.Level {
  // Slingshot Express - big planet slings to small planet area
  @types.make_level(
    [
      @types.make_planet(300.0, 300.0, 3.5, 45.0),
      @types.make_planet(600.0, 150.0, 1.0, 25.0),
    ],
    @types.make_station(700.0, 500.0, 25.0),
    [@types.make_waypoint(550.0, 300.0, 20.0)],
    100.0,
    200.0,
    130,
    "Slingshot Express",
    Slingshot,
  )
}

///|
fn level_14() -> @types.Level {
  // Zigzag Path - alternating planet pulls
  @types.make_level(
    [
      @types.make_planet(250.0, 150.0, 2.0, 30.0),
      @types.make_planet(500.0, 450.0, 2.0, 30.0),
    ],
    @types.make_station(700.0, 300.0, 25.0),
    [@types.make_waypoint(380.0, 250.0, 20.0)],
    100.0,
    500.0,
    140,
    "Zigzag Path",
    Slingshot,
  )
}

///|
fn level_15() -> @types.Level {
  // Figure Eight - must loop between both planets
  @types.make_level(
    [
      @types.make_planet(300.0, 200.0, 3.0, 40.0),
      @types.make_planet(500.0, 400.0, 3.0, 40.0),
    ],
    @types.make_station(150.0, 450.0, 25.0),
    [@types.make_waypoint(400.0, 300.0, 20.0)],
    700.0,
    100.0,
    160,
    "Figure Eight",
    Slingshot,
  )
}

///|
fn level_16() -> @types.Level {
  // Heavy Pull - one large planet dominates
  @types.make_level(
    [
      @types.make_planet(400.0, 300.0, 5.0, 55.0),
      @types.make_planet(650.0, 150.0, 1.0, 25.0),
    ],
    @types.make_station(650.0, 500.0, 25.0),
    [@types.make_waypoint(500.0, 180.0, 20.0)],
    100.0,
    150.0,
    140,
    "Heavy Pull",
    Slingshot,
  )
}

///|
fn level_17() -> @types.Level {
  // Orbit Escape - must break free from planet pair
  @types.make_level(
    [
      @types.make_planet(350.0, 250.0, 2.5, 35.0),
      @types.make_planet(450.0, 350.0, 2.5, 35.0),
    ],
    @types.make_station(100.0, 100.0, 25.0),
    [@types.make_waypoint(250.0, 200.0, 20.0)],
    700.0,
    300.0,
    150,
    "Orbit Escape",
    Slingshot,
  )
}

// Tier 3: Navigation (3+ planets)

///|
fn level_18() -> @types.Level {
  // Asteroid Field - three planets scattered
  @types.make_level(
    [
      @types.make_planet(250.0, 200.0, 1.5, 30.0),
      @types.make_planet(450.0, 400.0, 1.5, 30.0),
      @types.make_planet(600.0, 200.0, 1.5, 30.0),
    ],
    @types.make_station(700.0, 450.0, 25.0),
    [@types.make_waypoint(350.0, 300.0, 20.0)],
    100.0,
    300.0,
    100,
    "Asteroid Field",
    Navigation,
  )
}

///|
fn level_19() -> @types.Level {
  // Triple Bypass - weave through three planets
  @types.make_level(
    [
      @types.make_planet(250.0, 250.0, 2.0, 35.0),
      @types.make_planet(400.0, 400.0, 2.0, 35.0),
      @types.make_planet(550.0, 200.0, 2.0, 35.0),
    ],
    @types.make_station(700.0, 350.0, 25.0),
    [@types.make_waypoint(320.0, 350.0, 18.0)],
    100.0,
    150.0,
    120,
    "Triple Bypass",
    Navigation,
  )
}

///|
fn level_20() -> @types.Level {
  // Gravity Maze - complex field
  @types.make_level(
    [
      @types.make_planet(200.0, 150.0, 2.5, 35.0),
      @types.make_planet(400.0, 350.0, 2.5, 35.0),
      @types.make_planet(600.0, 150.0, 2.5, 35.0),
    ],
    @types.make_station(700.0, 500.0, 25.0),
    [@types.make_waypoint(300.0, 250.0, 20.0)],
    100.0,
    500.0,
    140,
    "Gravity Maze",
    Navigation,
  )
}

///|
fn level_21() -> @types.Level {
  // Four Corners - planets in each quadrant
  @types.make_level(
    [
      @types.make_planet(200.0, 150.0, 1.5, 30.0),
      @types.make_planet(600.0, 150.0, 1.5, 30.0),
      @types.make_planet(200.0, 450.0, 1.5, 30.0),
      @types.make_planet(600.0, 450.0, 1.5, 30.0),
    ],
    @types.make_station(400.0, 300.0, 25.0),
    [@types.make_waypoint(400.0, 150.0, 18.0)],
    100.0,
    300.0,
    100,
    "Four Corners",
    Navigation,
  )
}

///|
fn level_22() -> @types.Level {
  // Dense Cluster - tight grouping of planets
  @types.make_level(
    [
      @types.make_planet(350.0, 250.0, 2.0, 30.0),
      @types.make_planet(450.0, 250.0, 2.0, 30.0),
      @types.make_planet(400.0, 350.0, 2.0, 30.0),
    ],
    @types.make_station(700.0, 150.0, 25.0),
    [@types.make_waypoint(400.0, 180.0, 18.0)],
    100.0,
    450.0,
    130,
    "Dense Cluster",
    Navigation,
  )
}

///|
fn level_23() -> @types.Level {
  // Grand Tour - must pass near many planets
  @types.make_level(
    [
      @types.make_planet(200.0, 200.0, 2.0, 30.0),
      @types.make_planet(400.0, 150.0, 2.0, 30.0),
      @types.make_planet(550.0, 350.0, 2.0, 30.0),
      @types.make_planet(350.0, 480.0, 2.0, 30.0),
    ],
    @types.make_station(100.0, 500.0, 25.0),
    [@types.make_waypoint(600.0, 200.0, 18.0)],
    700.0,
    100.0,
    170,
    "Grand Tour",
    Navigation,
  )
}

///|
fn level_24() -> @types.Level {
  // Gauntlet - long path through many gravity wells
  @types.make_level(
    [
      @types.make_planet(200.0, 250.0, 2.5, 35.0),
      @types.make_planet(350.0, 400.0, 2.5, 35.0),
      @types.make_planet(500.0, 200.0, 2.5, 35.0),
      @types.make_planet(650.0, 400.0, 2.5, 35.0),
    ],
    @types.make_station(750.0, 200.0, 25.0),
    [@types.make_waypoint(425.0, 300.0, 18.0)],
    50.0,
    300.0,
    160,
    "Gauntlet",
    Navigation,
  )
}

///|
fn level_25() -> @types.Level {
  // Final Frontier - 5 planets, maximum complexity
  @types.make_level(
    [
      @types.make_planet(200.0, 150.0, 2.0, 30.0),
      @types.make_planet(400.0, 300.0, 3.0, 40.0),
      @types.make_planet(600.0, 150.0, 2.0, 30.0),
      @types.make_planet(300.0, 450.0, 2.0, 30.0),
      @types.make_planet(550.0, 480.0, 2.0, 30.0),
    ],
    @types.make_station(750.0, 300.0, 25.0),
    [@types.make_waypoint(350.0, 200.0, 16.0)],
    50.0,
    300.0,
    180,
    "Final Frontier",
    Navigation,
  )
}

///|
let all_levels : Ref[Array[@types.Level]?] = { val: None }

///|
fn init_levels() -> Array[@types.Level] {
  [
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
    level_21(),
    level_22(),
    level_23(),
    level_24(),
    level_25(),
  ]
}

///|
pub fn get_levels() -> Array[@types.Level] {
  match all_levels.val {
    Some(levels) => levels
    None => {
      let levels = init_levels()
      all_levels.val = Some(levels)
      levels
    }
  }
}

///|
pub fn get_level(index : Int) -> @types.Level {
  get_levels()[index]
}

///|
pub fn level_count() -> Int {
  get_levels().length()
}
