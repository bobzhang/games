///|
pub fn get_level(id : Int) -> @types.LevelDef {
  match id {
    0 => make_level_1()
    1 => make_level_2()
    2 => make_level_3()
    3 => make_level_4()
    4 => make_level_5()
    5 => make_level_6()
    6 => make_level_7()
    7 => make_level_8()
    8 => make_level_9()
    9 => make_level_10()
    10 => make_level_11()
    11 => make_level_12()
    12 => make_level_13()
    13 => make_level_14()
    14 => make_level_15()
    15 => make_level_16()
    16 => make_level_17()
    17 => make_level_18()
    18 => make_level_19()
    19 => make_level_20()
    _ => make_level_1()
  }
}

///|
pub fn load_level(game : @types.Game, level_id : Int) -> Unit {
  let def = get_level(level_id)
  game.current_level = level_id
  game.level_def = def
  game.components = []
  @types.clear_grid(game)
  @types.reset_simulation(game.sim)
  game.selected_palette = -1
  game.dragging_component = -1
  // Place fixed components
  for i in 0..<def.fixed_components.length() {
    let src = def.fixed_components[i]
    let c = @types.new_component(src.kind, src.col, src.row)
    c.fixed = true
    c.rotation_speed = src.rotation_speed
    c.bell_target_tick = src.bell_target_tick
    let idx = game.components.length()
    game.components.push(c)
    @types.grid_set(game, src.col, src.row, idx)
  }
}

///|
pub fn level_tier(id : Int) -> @types.Tier {
  if id < @types.tier1_levels {
    Ticks
  } else if id < @types.tier1_levels + @types.tier2_levels {
    Timing
  } else {
    Clockwork
  }
}

///|
pub fn level_name(id : Int) -> String {
  get_level(id).name
}

///|
pub fn levels_in_tier(tier : @types.Tier) -> (Int, Int) {
  match tier {
    Ticks => (0, @types.tier1_levels)
    Timing => (@types.tier1_levels, @types.tier1_levels + @types.tier2_levels)
    Clockwork => (
      @types.tier1_levels + @types.tier2_levels,
      @types.total_levels,
    )
  }
}

///|
pub fn tier_unlocked(game : @types.Game, tier : @types.Tier) -> Bool {
  match tier {
    Ticks => true
    Timing => {
      // Need at least 4 stars in tier 1
      let mut stars = 0
      for i in 0..<@types.tier1_levels {
        stars += game.level_stars[i]
      }
      stars >= 4
    }
    Clockwork => {
      // Need at least 4 stars in tier 2
      let mut stars = 0
      let start = @types.tier1_levels
      let end = @types.tier1_levels + @types.tier2_levels
      for i = start; i < end; i = i + 1 {
        stars += game.level_stars[i]
      }
      stars >= 4
    }
  }
}
