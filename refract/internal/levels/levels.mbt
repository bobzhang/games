///|
fn make_avail(
  kind : @types.ComponentKind,
  count : Int,
  fc : @types.FilterColor?,
) -> @types.AvailableComponent {
  { kind, filter_color: fc, count, }
}

///|
pub fn get_all_levels() -> Array[@types.Level] {
  let levels : Array[@types.Level] = []
  // === TIER 1: SPECTRUM (8 levels) - Mirrors + Filters ===

  // Level 1: Straight Shot
  // Source(E) -> Receiver(Red) with red filter to remove G,B
  levels.push({
    name: "Straight Shot",
    tier: Spectrum,
    grid_template: [
      (0, 3, Source, E, None, None),
      (9, 3, Receiver, W, None, Some(@types.beam_color_red())),
    ],
    available: [
      make_avail(Filter, 1, Some(Green)),
      make_avail(Filter, 1, Some(Blue)),
    ],
    par_count: 2,
  })
  // Level 2: Corner Turn
  levels.push({
    name: "Corner Turn",
    tier: Spectrum,
    grid_template: [
      (0, 1, Source, E, None, None),
      (5, 6, Receiver, N, None, Some(@types.beam_color_white())),
    ],
    available: [make_avail(Mirror, 1, None)],
    par_count: 1,
  })
  // Level 3: Double Bounce
  levels.push({
    name: "Double Bounce",
    tier: Spectrum,
    grid_template: [
      (0, 0, Source, E, None, None),
      (0, 7, Receiver, E, None, Some(@types.beam_color_white())),
    ],
    available: [make_avail(Mirror, 2, None)],
    par_count: 2,
  })
  // Level 4: Color Strip
  levels.push({
    name: "Color Strip",
    tier: Spectrum,
    grid_template: [
      (0, 3, Source, E, None, None),
      (9, 3, Receiver, W, None, Some(@types.beam_color_green())),
    ],
    available: [
      make_avail(Filter, 1, Some(Red)),
      make_avail(Filter, 1, Some(Blue)),
    ],
    par_count: 2,
  })
  // Level 5: Cyan Path
  levels.push({
    name: "Cyan Path",
    tier: Spectrum,
    grid_template: [
      (0, 2, Source, E, None, None),
      (7, 5, Receiver, N, None, Some(@types.beam_color_cyan())),
    ],
    available: [make_avail(Mirror, 1, None), make_avail(Filter, 1, Some(Red))],
    par_count: 2,
  })
  // Level 6: Yellow Detour
  levels.push({
    name: "Yellow Detour",
    tier: Spectrum,
    grid_template: [
      (1, 0, Source, S, None, None),
      (8, 7, Receiver, N, None, Some(@types.beam_color_yellow())),
    ],
    available: [make_avail(Mirror, 2, None), make_avail(Filter, 1, Some(Blue))],
    par_count: 3,
  })
  // Level 7: Magenta Route
  levels.push({
    name: "Magenta Route",
    tier: Spectrum,
    grid_template: [
      (0, 4, Source, E, None, None),
      (9, 1, Receiver, S, None, Some(@types.beam_color_magenta())),
    ],
    available: [make_avail(Mirror, 2, None), make_avail(Filter, 1, Some(Green))],
    par_count: 3,
  })
  // Level 8: Dual Delivery
  levels.push({
    name: "Dual Delivery",
    tier: Spectrum,
    grid_template: [
      (0, 2, Source, E, None, None),
      (0, 5, Source, E, None, None),
      (9, 2, Receiver, W, None, Some(@types.beam_color_cyan())),
      (9, 5, Receiver, W, None, Some(@types.beam_color_yellow())),
    ],
    available: [
      make_avail(Filter, 1, Some(Red)),
      make_avail(Filter, 1, Some(Blue)),
    ],
    par_count: 2,
  })
  // === TIER 2: PRISMS (8 levels) - Prisms introduced ===

  // Level 9: First Split
  levels.push({
    name: "First Split",
    tier: Prisms,
    grid_template: [
      (0, 3, Source, E, None, None),
      (9, 3, Receiver, W, None, Some(@types.beam_color_red())),
      (5, 0, Receiver, S, None, Some(@types.beam_color_green())),
      (5, 7, Receiver, N, None, Some(@types.beam_color_blue())),
    ],
    available: [make_avail(Prism, 1, None), make_avail(Mirror, 2, None)],
    par_count: 3,
  })
  // Level 10: Split and Route
  levels.push({
    name: "Split and Route",
    tier: Prisms,
    grid_template: [
      (0, 4, Source, E, None, None),
      (9, 1, Receiver, W, None, Some(@types.beam_color_red())),
      (9, 7, Receiver, W, None, Some(@types.beam_color_blue())),
    ],
    available: [make_avail(Prism, 1, None), make_avail(Mirror, 3, None)],
    par_count: 4,
  })
  // Level 11: Prism Chain
  levels.push({
    name: "Prism Chain",
    tier: Prisms,
    grid_template: [
      (0, 3, Source, E, None, None),
      (9, 1, Receiver, W, None, Some(@types.beam_color_red())),
      (9, 3, Receiver, W, None, Some(@types.beam_color_green())),
      (9, 5, Receiver, W, None, Some(@types.beam_color_blue())),
    ],
    available: [make_avail(Prism, 1, None), make_avail(Mirror, 4, None)],
    par_count: 5,
  })
  // Level 12: Yellow Extract
  levels.push({
    name: "Yellow Extract",
    tier: Prisms,
    grid_template: [
      (0, 3, Source, E, None, None),
      (9, 2, Receiver, W, None, Some(@types.beam_color_yellow())),
      (9, 6, Receiver, W, None, Some(@types.beam_color_blue())),
    ],
    available: [
      make_avail(Prism, 1, None),
      make_avail(Mirror, 2, None),
      make_avail(Filter, 1, Some(Blue)),
    ],
    par_count: 4,
  })
  // Level 13: Two Sources Split
  levels.push({
    name: "Two Source Split",
    tier: Prisms,
    grid_template: [
      (0, 1, Source, E, None, None),
      (0, 6, Source, E, None, None),
      (9, 0, Receiver, W, None, Some(@types.beam_color_red())),
      (9, 3, Receiver, W, None, Some(@types.beam_color_green())),
      (9, 7, Receiver, W, None, Some(@types.beam_color_blue())),
    ],
    available: [make_avail(Prism, 2, None), make_avail(Mirror, 3, None)],
    par_count: 5,
  })
  // Level 14: Cross Beams
  levels.push({
    name: "Cross Beams",
    tier: Prisms,
    grid_template: [
      (0, 3, Source, E, None, None),
      (5, 0, Source, S, None, Some(@types.beam_color_red())),
      (9, 3, Receiver, W, None, Some(@types.beam_color_cyan())),
      (5, 7, Receiver, N, None, Some(@types.beam_color_red())),
    ],
    available: [
      make_avail(Prism, 1, None),
      make_avail(Mirror, 2, None),
      make_avail(Filter, 1, Some(Red)),
    ],
    par_count: 4,
  })
  // Level 15: Triple Route
  levels.push({
    name: "Triple Route",
    tier: Prisms,
    grid_template: [
      (0, 4, Source, E, None, None),
      (3, 0, Receiver, S, None, Some(@types.beam_color_red())),
      (7, 0, Receiver, S, None, Some(@types.beam_color_green())),
      (9, 4, Receiver, W, None, Some(@types.beam_color_blue())),
    ],
    available: [make_avail(Prism, 1, None), make_avail(Mirror, 4, None)],
    par_count: 5,
  })
  // Level 16: Filter After Split
  levels.push({
    name: "Filter After Split",
    tier: Prisms,
    grid_template: [
      (0, 3, Source, E, None, None),
      (9, 1, Receiver, W, None, Some(@types.beam_color_red())),
      (9, 5, Receiver, W, None, Some(@types.beam_color_green())),
    ],
    available: [
      make_avail(Prism, 1, None),
      make_avail(Mirror, 3, None),
      make_avail(Filter, 1, Some(Blue)),
    ],
    par_count: 5,
  })
  // === TIER 3: SYNTHESIS (8 levels) - Combiners ===

  // Level 17: Simple Merge
  levels.push({
    name: "Simple Merge",
    tier: Synthesis,
    grid_template: [
      (0, 2, Source, E, None, Some(@types.beam_color_red())),
      (0, 5, Source, E, None, Some(@types.beam_color_green())),
      (9, 3, Receiver, W, None, Some(@types.beam_color_yellow())),
    ],
    available: [make_avail(Combiner, 1, None), make_avail(Mirror, 2, None)],
    par_count: 3,
  })
  // Level 18: Cyan Blend
  levels.push({
    name: "Cyan Blend",
    tier: Synthesis,
    grid_template: [
      (0, 1, Source, E, None, Some(@types.beam_color_green())),
      (0, 6, Source, E, None, Some(@types.beam_color_blue())),
      (9, 3, Receiver, W, None, Some(@types.beam_color_cyan())),
    ],
    available: [make_avail(Combiner, 1, None), make_avail(Mirror, 2, None)],
    par_count: 3,
  })
  // Level 19: White from Three
  levels.push({
    name: "White from Three",
    tier: Synthesis,
    grid_template: [
      (0, 1, Source, E, None, Some(@types.beam_color_red())),
      (0, 4, Source, E, None, Some(@types.beam_color_green())),
      (0, 7, Source, E, None, Some(@types.beam_color_blue())),
      (9, 4, Receiver, W, None, Some(@types.beam_color_white())),
    ],
    available: [make_avail(Combiner, 2, None), make_avail(Mirror, 4, None)],
    par_count: 6,
  })
  // Level 20: Split and Recombine
  levels.push({
    name: "Split Recombine",
    tier: Synthesis,
    grid_template: [
      (0, 3, Source, E, None, None),
      (9, 2, Receiver, W, None, Some(@types.beam_color_yellow())),
      (9, 6, Receiver, W, None, Some(@types.beam_color_blue())),
    ],
    available: [
      make_avail(Prism, 1, None),
      make_avail(Combiner, 1, None),
      make_avail(Mirror, 4, None),
    ],
    par_count: 6,
  })
  // Level 21: Color Factory
  levels.push({
    name: "Color Factory",
    tier: Synthesis,
    grid_template: [
      (0, 2, Source, E, None, None),
      (0, 5, Source, E, None, None),
      (9, 0, Receiver, W, None, Some(@types.beam_color_magenta())),
      (9, 7, Receiver, W, None, Some(@types.beam_color_cyan())),
    ],
    available: [
      make_avail(Prism, 2, None),
      make_avail(Combiner, 2, None),
      make_avail(Mirror, 4, None),
    ],
    par_count: 8,
  })
  // Level 22: Triple Synthesis
  levels.push({
    name: "Triple Synthesis",
    tier: Synthesis,
    grid_template: [
      (0, 3, Source, E, None, None),
      (9, 1, Receiver, W, None, Some(@types.beam_color_yellow())),
      (9, 4, Receiver, W, None, Some(@types.beam_color_magenta())),
      (9, 7, Receiver, W, None, Some(@types.beam_color_cyan())),
    ],
    available: [
      make_avail(Prism, 1, None),
      make_avail(Combiner, 3, None),
      make_avail(Mirror, 6, None),
    ],
    par_count: 10,
  })
  // Level 23: Full Spectrum
  levels.push({
    name: "Full Spectrum",
    tier: Synthesis,
    grid_template: [
      (0, 0, Source, E, None, None),
      (0, 7, Source, E, None, None),
      (9, 0, Receiver, W, None, Some(@types.beam_color_red())),
      (9, 3, Receiver, W, None, Some(@types.beam_color_white())),
      (9, 7, Receiver, W, None, Some(@types.beam_color_blue())),
    ],
    available: [
      make_avail(Prism, 2, None),
      make_avail(Combiner, 2, None),
      make_avail(Mirror, 5, None),
      make_avail(Filter, 1, Some(Green)),
    ],
    par_count: 10,
  })
  // Level 24: Master Optics
  levels.push({
    name: "Master Optics",
    tier: Synthesis,
    grid_template: [
      (0, 1, Source, E, None, None),
      (0, 6, Source, E, None, None),
      (9, 0, Receiver, W, None, Some(@types.beam_color_yellow())),
      (9, 3, Receiver, W, None, Some(@types.beam_color_cyan())),
      (9, 5, Receiver, W, None, Some(@types.beam_color_magenta())),
      (9, 7, Receiver, W, None, Some(@types.beam_color_white())),
    ],
    available: [
      make_avail(Prism, 2, None),
      make_avail(Combiner, 4, None),
      make_avail(Mirror, 8, None),
    ],
    par_count: 14,
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
    let (x, y, kind, dir, fc, tc) = level.grid_template[i]
    match @types.grid_get(grid, x, y) {
      Some(cell) => {
        cell.component = Some(kind)
        cell.direction = dir
        cell.filter_color = fc
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
    Spectrum => (0, 8)
    Prisms => (8, 16)
    Synthesis => (16, 24)
  }
}
