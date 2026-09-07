///|
fn make_avail(
  kind : @types.ComponentKind,
  count : Int,
  fc : @types.FilterColor?,
  cf : @types.CrystalFace?,
) -> @types.AvailableComponent {
  { kind, filter_color: fc, crystal_face: cf, count, }
}

///|
pub fn get_all_levels() -> Array[@types.Level] {
  let levels : Array[@types.Level] = []
  // === TIER 1: FUNDAMENTALS (7 levels) - Mirrors, Crystals, basics ===

  // Level 1: First Light
  // Source at W edge facing E, target at E edge. Just press simulate.
  levels.push({
    name: "First Light",
    tier: Fundamentals,
    grid_template: [
      (-3, 0, Source, E, None, None, None),
      (3, 0, Target, W, None, None, Some(@types.beam_color_white())),
    ],
    available: [],
    par_count: 0,
  })
  // Level 2: Bend It
  // Source E, target not in line. Place a crystal to redirect.
  levels.push({
    name: "Bend It",
    tier: Fundamentals,
    grid_template: [
      (-3, 0, Source, E, None, None, None),
      (0, 3, Target, NW, None, None, Some(@types.beam_color_white())),
    ],
    available: [make_avail(Crystal, 1, None, Some(Right60))],
    par_count: 1,
  })
  // Level 3: Double Bend
  levels.push({
    name: "Double Bend",
    tier: Fundamentals,
    grid_template: [
      (-3, 0, Source, E, None, None, None),
      (-3, 3, Target, NE, None, None, Some(@types.beam_color_white())),
    ],
    available: [
      make_avail(Crystal, 1, None, Some(Right60)),
      make_avail(Crystal, 1, None, Some(Left60)),
    ],
    par_count: 2,
  })
  // Level 4: Mirror Bounce
  levels.push({
    name: "Mirror Bounce",
    tier: Fundamentals,
    grid_template: [
      (-3, 0, Source, E, None, None, None),
      (-2, -1, Target, SW, None, None, Some(@types.beam_color_white())),
    ],
    available: [make_avail(Mirror, 1, None, None)],
    par_count: 1,
  })
  // Level 5: Red Filter
  levels.push({
    name: "Red Filter",
    tier: Fundamentals,
    grid_template: [
      (-3, 0, Source, E, None, None, None),
      (3, 0, Target, W, None, None, Some(@types.beam_color_red())),
    ],
    available: [make_avail(Filter, 1, Some(Red), None)],
    par_count: 1,
  })
  // Level 6: Blue Detour
  levels.push({
    name: "Blue Detour",
    tier: Fundamentals,
    grid_template: [
      (0, -3, Source, SE, None, None, None),
      (3, 0, Target, W, None, None, Some(@types.beam_color_blue())),
    ],
    available: [
      make_avail(Crystal, 1, None, Some(Left60)),
      make_avail(Filter, 1, Some(Blue), None),
    ],
    par_count: 2,
  })
  // Level 7: Two Targets
  levels.push({
    name: "Two Targets",
    tier: Fundamentals,
    grid_template: [
      (-3, 0, Source, E, None, None, None),
      (-3, 3, Source, NE, None, None, None),
      (3, 0, Target, W, None, None, Some(@types.beam_color_red())),
      (0, -3, Target, SE, None, None, Some(@types.beam_color_green())),
    ],
    available: [
      make_avail(Filter, 1, Some(Red), None),
      make_avail(Filter, 1, Some(Green), None),
    ],
    par_count: 2,
  })
  // === TIER 2: CHROMATICS (7 levels) - Color mixing, multiple paths ===

  // Level 8: Split Path
  levels.push({
    name: "Split Path",
    tier: Chromatics,
    grid_template: [
      (-3, 0, Source, E, None, None, None),
      (3, 0, Target, W, None, None, Some(@types.beam_color_red())),
      (0, 3, Target, NW, None, None, Some(@types.beam_color_white())),
    ],
    available: [
      make_avail(Crystal, 1, None, Some(Right60)),
      make_avail(Filter, 1, Some(Red), None),
      make_avail(Mirror, 1, None, None),
    ],
    par_count: 3,
  })
  // Level 9: Cyan Route
  levels.push({
    name: "Cyan Route",
    tier: Chromatics,
    grid_template: [
      (-3, 0, Source, E, None, None, None),
      (0, -3, Target, SE, None, None, Some(@types.beam_color_cyan())),
    ],
    available: [
      make_avail(Crystal, 1, None, Some(Left60)),
      make_avail(Filter, 1, Some(Green), None),
      make_avail(Filter, 1, Some(Blue), None),
    ],
    par_count: 2,
  })
  // Level 10: Color Cross
  levels.push({
    name: "Color Cross",
    tier: Chromatics,
    grid_template: [
      (-3, 0, Source, E, None, None, None),
      (0, -3, Source, SW, None, None, None),
      (3, 0, Target, W, None, None, Some(@types.beam_color_green())),
      (0, 3, Target, NE, None, None, Some(@types.beam_color_blue())),
    ],
    available: [
      make_avail(Filter, 1, Some(Green), None),
      make_avail(Filter, 1, Some(Blue), None),
    ],
    par_count: 2,
  })
  // Level 11: Triple Crystal
  levels.push({
    name: "Triple Crystal",
    tier: Chromatics,
    grid_template: [
      (-3, 0, Source, E, None, None, None),
      (3, -3, Target, SW, None, None, Some(@types.beam_color_white())),
    ],
    available: [
      make_avail(Crystal, 2, None, Some(Left60)),
      make_avail(Crystal, 1, None, Some(Right60)),
    ],
    par_count: 3,
  })
  // Level 12: Yellow Path
  levels.push({
    name: "Yellow Path",
    tier: Chromatics,
    grid_template: [
      (-3, 0, Source, E, None, None, None),
      (3, 0, Target, W, None, None, Some(@types.beam_color_yellow())),
    ],
    available: [
      make_avail(Filter, 1, Some(Red), None),
      make_avail(Filter, 1, Some(Green), None),
    ],
    par_count: 1,
  })
  // Level 13: Magenta Mirror
  levels.push({
    name: "Magenta Mirror",
    tier: Chromatics,
    grid_template: [
      (0, -3, Source, SE, None, None, None),
      (-3, 3, Target, NE, None, None, Some(@types.beam_color_magenta())),
    ],
    available: [
      make_avail(Mirror, 2, None, None),
      make_avail(Filter, 1, Some(Red), None),
      make_avail(Filter, 1, Some(Blue), None),
    ],
    par_count: 3,
  })
  // Level 14: Dual Source Mix
  levels.push({
    name: "Dual Source Mix",
    tier: Chromatics,
    grid_template: [
      (-3, 0, Source, E, None, None, Some(@types.beam_color_red())),
      (-3, 3, Source, NE, None, None, Some(@types.beam_color_blue())),
      (3, 0, Target, W, None, None, Some(@types.beam_color_red())),
      (0, -3, Target, SW, None, None, Some(@types.beam_color_blue())),
    ],
    available: [make_avail(Mirror, 2, None, None)],
    par_count: 2,
  })
  // === TIER 3: MASTERY (6 levels) - Complex routing, multiple components ===

  // Level 15: Prism Web
  levels.push({
    name: "Prism Web",
    tier: Mastery,
    grid_template: [
      (-3, 0, Source, E, None, None, None),
      (3, 0, Target, W, None, None, Some(@types.beam_color_red())),
      (0, 3, Target, NW, None, None, Some(@types.beam_color_green())),
      (0, -3, Target, SE, None, None, Some(@types.beam_color_blue())),
    ],
    available: [
      make_avail(Crystal, 2, None, Some(Left60)),
      make_avail(Crystal, 1, None, Some(Right60)),
      make_avail(Filter, 1, Some(Red), None),
      make_avail(Filter, 1, Some(Green), None),
      make_avail(Filter, 1, Some(Blue), None),
    ],
    par_count: 5,
  })
  // Level 16: Mirror Maze
  levels.push({
    name: "Mirror Maze",
    tier: Mastery,
    grid_template: [
      (-3, 0, Source, E, None, None, None),
      (3, -3, Target, SW, None, None, Some(@types.beam_color_white())),
      (-3, 3, Target, NE, None, None, Some(@types.beam_color_white())),
    ],
    available: [
      make_avail(Mirror, 4, None, None),
      make_avail(Crystal, 1, None, Some(Right60)),
    ],
    par_count: 4,
  })
  // Level 17: Color Weave
  levels.push({
    name: "Color Weave",
    tier: Mastery,
    grid_template: [
      (-3, 0, Source, E, None, None, None),
      (0, -3, Source, SE, None, None, None),
      (3, 0, Target, W, None, None, Some(@types.beam_color_cyan())),
      (-3, 3, Target, NE, None, None, Some(@types.beam_color_yellow())),
    ],
    available: [
      make_avail(Crystal, 2, None, Some(Right60)),
      make_avail(Filter, 1, Some(Green), None),
      make_avail(Filter, 1, Some(Blue), None),
      make_avail(Filter, 1, Some(Red), None),
    ],
    par_count: 4,
  })
  // Level 18: Crystal Chain
  levels.push({
    name: "Crystal Chain",
    tier: Mastery,
    grid_template: [
      (-3, 0, Source, E, None, None, None),
      (3, -3, Target, SW, None, None, Some(@types.beam_color_red())),
    ],
    available: [
      make_avail(Crystal, 3, None, Some(Left60)),
      make_avail(Crystal, 2, None, Some(Right60)),
      make_avail(Filter, 1, Some(Red), None),
    ],
    par_count: 4,
  })
  // Level 19: Rainbow Route
  levels.push({
    name: "Rainbow Route",
    tier: Mastery,
    grid_template: [
      (-3, 0, Source, E, None, None, None),
      (0, -3, Source, SW, None, None, None),
      (3, 0, Target, W, None, None, Some(@types.beam_color_blue())),
      (0, 3, Target, NE, None, None, Some(@types.beam_color_green())),
      (-3, 3, Target, E, None, None, Some(@types.beam_color_red())),
    ],
    available: [
      make_avail(Crystal, 2, None, Some(Right60)),
      make_avail(Crystal, 1, None, Some(Left60)),
      make_avail(Mirror, 2, None, None),
      make_avail(Filter, 1, Some(Red), None),
      make_avail(Filter, 1, Some(Green), None),
      make_avail(Filter, 1, Some(Blue), None),
    ],
    par_count: 6,
  })
  // Level 20: Grand Prism
  levels.push({
    name: "Grand Prism",
    tier: Mastery,
    grid_template: [
      (-3, 0, Source, E, None, None, None),
      (3, -3, Source, SW, None, None, None),
      (3, 0, Target, W, None, None, Some(@types.beam_color_yellow())),
      (0, 3, Target, NW, None, None, Some(@types.beam_color_cyan())),
      (-3, 3, Target, NE, None, None, Some(@types.beam_color_magenta())),
      (0, -3, Target, SE, None, None, Some(@types.beam_color_white())),
    ],
    available: [
      make_avail(Crystal, 3, None, Some(Left60)),
      make_avail(Crystal, 2, None, Some(Right60)),
      make_avail(Mirror, 3, None, None),
      make_avail(Filter, 1, Some(Red), None),
      make_avail(Filter, 1, Some(Green), None),
      make_avail(Filter, 1, Some(Blue), None),
    ],
    par_count: 8,
  })
  levels
}

///|
pub fn load_level(game : @types.Game, level_index : Int) -> Unit {
  let levels = get_all_levels()
  if level_index < 0 || level_index >= levels.length() {
    return
  }
  let level = levels[level_index]
  let grid = game.grid
  @types.grid_clear(grid)
  // Place template components
  for i in 0..<level.grid_template.length() {
    let (q, r, kind, dir, fc, cf, tc) = level.grid_template[i]
    match @types.grid_get(grid, q, r) {
      Some(cell) => {
        cell.component = Some(kind)
        cell.direction = dir
        cell.filter_color = fc
        cell.crystal_face = cf
        cell.target_color = tc
        cell.locked = true
      }
      None => ()
    }
  }
  // Set up palette
  game.palette = []
  for i in 0..<level.available.length() {
    let a = level.available[i]
    game.palette.push({
      kind: a.kind,
      filter_color: a.filter_color,
      crystal_face: a.crystal_face,
      count: a.count,
    })
  }
  game.selected_palette = 0
  game.current_level_index = level_index
  game.par_count = level.par_count
  game.level_name = level.name
  game.play_state = Placing
  game.beams = []
}

///|
pub fn tier_level_range(tier : @types.Tier) -> (Int, Int) {
  match tier {
    Fundamentals => (0, 7)
    Chromatics => (7, 14)
    Mastery => (14, 20)
  }
}

///|
pub fn tier_level_count(tier : @types.Tier) -> Int {
  match tier {
    Fundamentals => 7
    Chromatics => 7
    Mastery => 6
  }
}
