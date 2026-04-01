///|
/// Get a level by index (0-based)
pub fn get_level(idx : Int) -> @types.Level {
  if idx < @types.tier1_count {
    get_tier1_level(idx)
  } else if idx < @types.tier1_count + @types.tier2_count {
    get_tier2_level(idx - @types.tier1_count)
  } else {
    get_tier3_level(idx - @types.tier1_count - @types.tier2_count)
  }
}

///|
/// Tier 1: Plain weave, simple 2-color (7 levels)
fn get_tier1_level(idx : Int) -> @types.Level {
  let rows = @types.grid_rows
  let cols = @types.grid_cols
  match idx {
    0 => {
      // Simple plain weave, single color warp, single color weft
      let warp_c = [0, 0, 0, 0, 0, 0, 0, 0]
      let weft_c = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
      let target = @weave.generate_plain(rows, cols, warp_c, weft_c)
      {
        target,
        warp_colors: warp_c,
        weft_colors: weft_c,
        par_changes: 11,
        weave_type: Plain,
        tier: Apprentice,
        level_num: 1,
        hint: "Alternate every warp each row",
      }
    }
    1 => {
      // Plain weave, 2-color warp stripes
      let warp_c = [0, 1, 0, 1, 0, 1, 0, 1]
      let weft_c = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
      let target = @weave.generate_plain(rows, cols, warp_c, weft_c)
      {
        target,
        warp_colors: warp_c,
        weft_colors: weft_c,
        par_changes: 11,
        weave_type: Plain,
        tier: Apprentice,
        level_num: 2,
        hint: "Checkerboard with alternating warp colors",
      }
    }
    2 => {
      // Plain weave, 2-color weft stripes
      let warp_c = [0, 0, 0, 0, 0, 0, 0, 0]
      let weft_c = [0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1]
      let target = @weave.generate_plain(rows, cols, warp_c, weft_c)
      {
        target,
        warp_colors: warp_c,
        weft_colors: weft_c,
        par_changes: 11,
        weave_type: Plain,
        tier: Apprentice,
        level_num: 3,
        hint: "Same heddle pattern, colors differ by row",
      }
    }
    3 => {
      // Plain weave, both warps and wefts alternate colors
      let warp_c = [0, 1, 0, 1, 0, 1, 0, 1]
      let weft_c = [1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0]
      let target = @weave.generate_plain(rows, cols, warp_c, weft_c)
      {
        target,
        warp_colors: warp_c,
        weft_colors: weft_c,
        par_changes: 11,
        weave_type: Plain,
        tier: Apprentice,
        level_num: 4,
        hint: "Full checkerboard with both warp and weft colors",
      }
    }
    4 => {
      // Plain weave with grouped warp colors (pairs)
      let warp_c = [0, 0, 1, 1, 0, 0, 1, 1]
      let weft_c = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
      let target = @weave.generate_plain(rows, cols, warp_c, weft_c)
      {
        target,
        warp_colors: warp_c,
        weft_colors: weft_c,
        par_changes: 11,
        weave_type: Plain,
        tier: Apprentice,
        level_num: 5,
        hint: "Plain weave with paired warp colors",
      }
    }
    5 => {
      // Plain weave, weft color blocks
      let warp_c = [1, 1, 1, 1, 1, 1, 1, 1]
      let weft_c = [0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0]
      let target = @weave.generate_plain(rows, cols, warp_c, weft_c)
      {
        target,
        warp_colors: warp_c,
        weft_colors: weft_c,
        par_changes: 11,
        weave_type: Plain,
        tier: Apprentice,
        level_num: 6,
        hint: "Weft blocks create horizontal stripes",
      }
    }
    _ => {
      // Plain weave, mixed warp/weft 2-color pattern
      let warp_c = [0, 1, 1, 0, 0, 1, 1, 0]
      let weft_c = [1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1]
      let target = @weave.generate_plain(rows, cols, warp_c, weft_c)
      {
        target,
        warp_colors: warp_c,
        weft_colors: weft_c,
        par_changes: 11,
        weave_type: Plain,
        tier: Apprentice,
        level_num: 7,
        hint: "Symmetric color arrangement",
      }
    }
  }
}

///|
/// Tier 2: Twill patterns, 3 colors (7 levels)
fn get_tier2_level(idx : Int) -> @types.Level {
  let rows = @types.grid_rows
  let cols = @types.grid_cols
  match idx {
    0 => {
      // Simple 2/2 twill, 2-color
      let warp_c = [0, 0, 0, 0, 0, 0, 0, 0]
      let weft_c = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
      let target = @weave.generate_twill(rows, cols, warp_c, weft_c, 2)
      {
        target,
        warp_colors: warp_c,
        weft_colors: weft_c,
        par_changes: 7,
        weave_type: Twill,
        tier: Journeyman,
        level_num: 8,
        hint: "Two warps up, two warps down, shifting each row",
      }
    }
    1 => {
      // 2/2 twill with alternating warp colors
      let warp_c = [0, 2, 0, 2, 0, 2, 0, 2]
      let weft_c = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
      let target = @weave.generate_twill(rows, cols, warp_c, weft_c, 2)
      {
        target,
        warp_colors: warp_c,
        weft_colors: weft_c,
        par_changes: 7,
        weave_type: Twill,
        tier: Journeyman,
        level_num: 9,
        hint: "Twill diagonal with three colors",
      }
    }
    2 => {
      // 3/3 twill - wider diagonal
      let warp_c = [0, 1, 2, 0, 1, 2, 0, 1]
      let weft_c = [2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]
      let target = @weave.generate_twill(rows, cols, warp_c, weft_c, 3)
      {
        target,
        warp_colors: warp_c,
        weft_colors: weft_c,
        par_changes: 5,
        weave_type: Twill,
        tier: Journeyman,
        level_num: 10,
        hint: "Wider diagonal - three warps up, three down",
      }
    }
    3 => {
      // Twill with 3-color weft
      let warp_c = [0, 0, 0, 0, 0, 0, 0, 0]
      let weft_c = [1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2]
      let target = @weave.generate_twill(rows, cols, warp_c, weft_c, 2)
      {
        target,
        warp_colors: warp_c,
        weft_colors: weft_c,
        par_changes: 7,
        weave_type: Twill,
        tier: Journeyman,
        level_num: 11,
        hint: "Twill with alternating weft colors",
      }
    }
    4 => {
      // Twill with mixed warp grouping
      let warp_c = [0, 0, 1, 1, 2, 2, 0, 0]
      let weft_c = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
      let target = @weave.generate_twill(rows, cols, warp_c, weft_c, 2)
      {
        target,
        warp_colors: warp_c,
        weft_colors: weft_c,
        par_changes: 7,
        weave_type: Twill,
        tier: Journeyman,
        level_num: 12,
        hint: "Color pairs along the twill diagonal",
      }
    }
    5 => {
      // Satin weave - 5 harness
      let warp_c = [0, 1, 0, 1, 0, 1, 0, 1]
      let weft_c = [2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]
      let target = @weave.generate_satin(rows, cols, warp_c, weft_c, 5, 2)
      {
        target,
        warp_colors: warp_c,
        weft_colors: weft_c,
        par_changes: 9,
        weave_type: Satin,
        tier: Journeyman,
        level_num: 13,
        hint: "Sparse warp points - each row has few raised warps",
      }
    }
    _ => {
      // Satin weave - 4 harness
      let warp_c = [2, 0, 2, 0, 2, 0, 2, 0]
      let weft_c = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
      let target = @weave.generate_satin(rows, cols, warp_c, weft_c, 4, 1)
      {
        target,
        warp_colors: warp_c,
        weft_colors: weft_c,
        par_changes: 9,
        weave_type: Satin,
        tier: Journeyman,
        level_num: 14,
        hint: "Four-harness satin with offset floats",
      }
    }
  }
}

///|
/// Tier 3: Complex patterns - herringbone, diamond, 4 colors (6 levels)
fn get_tier3_level(idx : Int) -> @types.Level {
  let rows = @types.grid_rows
  let cols = @types.grid_cols
  match idx {
    0 => {
      // Herringbone basic
      let warp_c = [0, 1, 0, 1, 0, 1, 0, 1]
      let weft_c = [2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]
      let target = @weave.generate_herringbone(rows, cols, warp_c, weft_c, 4)
      {
        target,
        warp_colors: warp_c,
        weft_colors: weft_c,
        par_changes: 9,
        weave_type: Herringbone,
        tier: Master,
        level_num: 15,
        hint: "Twill that reverses direction halfway",
      }
    }
    1 => {
      // Herringbone with 4 colors
      let warp_c = [0, 1, 2, 3, 0, 1, 2, 3]
      let weft_c = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
      let target = @weave.generate_herringbone(rows, cols, warp_c, weft_c, 4)
      {
        target,
        warp_colors: warp_c,
        weft_colors: weft_c,
        par_changes: 9,
        weave_type: Herringbone,
        tier: Master,
        level_num: 16,
        hint: "Four-color herringbone - watch the reversal",
      }
    }
    2 => {
      // Diamond basic
      let warp_c = [0, 0, 1, 1, 0, 0, 1, 1]
      let weft_c = [2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]
      let target = @weave.generate_diamond(rows, cols, warp_c, weft_c, 4)
      {
        target,
        warp_colors: warp_c,
        weft_colors: weft_c,
        par_changes: 10,
        weave_type: Diamond,
        tier: Master,
        level_num: 17,
        hint: "Diamond shapes - symmetric in both axes",
      }
    }
    3 => {
      // Diamond with 4 colors
      let warp_c = [0, 1, 2, 3, 3, 2, 1, 0]
      let weft_c = [0, 1, 2, 3, 3, 2, 1, 0, 0, 1, 2, 3]
      let target = @weave.generate_diamond(rows, cols, warp_c, weft_c, 4)
      {
        target,
        warp_colors: warp_c,
        weft_colors: weft_c,
        par_changes: 10,
        weave_type: Diamond,
        tier: Master,
        level_num: 18,
        hint: "Rainbow diamond - colors mirror at center",
      }
    }
    4 => {
      // Complex herringbone with weft color variation
      let warp_c = [0, 2, 1, 3, 0, 2, 1, 3]
      let weft_c = [3, 1, 2, 0, 3, 1, 2, 0, 3, 1, 2, 0]
      let target = @weave.generate_herringbone(rows, cols, warp_c, weft_c, 4)
      {
        target,
        warp_colors: warp_c,
        weft_colors: weft_c,
        par_changes: 9,
        weave_type: Herringbone,
        tier: Master,
        level_num: 19,
        hint: "Full palette herringbone - all four colors in play",
      }
    }
    _ => {
      // Diamond with large repeat and 4 colors
      let warp_c = [0, 1, 2, 3, 0, 1, 2, 3]
      let weft_c = [3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0]
      let target = @weave.generate_diamond(rows, cols, warp_c, weft_c, 3)
      {
        target,
        warp_colors: warp_c,
        weft_colors: weft_c,
        par_changes: 10,
        weave_type: Diamond,
        tier: Master,
        level_num: 20,
        hint: "Master diamond - small repeat, all colors",
      }
    }
  }
}

///|
/// Compute star rating for a level
pub fn compute_stars(
  level : @types.Level,
  heddle_changes : Int,
  correct_type : Bool,
) -> Int {
  let mut stars = 1
  if heddle_changes <= level.par_changes {
    stars = 2
  }
  if stars == 2 && correct_type {
    stars = 3
  }
  stars
}
