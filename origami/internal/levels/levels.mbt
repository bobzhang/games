///|
pub fn get_level(index : Int) -> @types.Level {
  match index {
    0 => level_01()
    1 => level_02()
    2 => level_03()
    3 => level_04()
    4 => level_05()
    5 => level_06()
    6 => level_07()
    7 => level_08()
    8 => level_09()
    9 => level_10()
    10 => level_11()
    11 => level_12()
    12 => level_13()
    13 => level_14()
    14 => level_15()
    15 => level_16()
    16 => level_17()
    17 => level_18()
    18 => level_19()
    19 => level_20()
    20 => level_21()
    21 => level_22()
    22 => level_23()
    23 => level_24()
    24 => level_25()
    _ => level_01()
  }
}

// ============================================================
// Tier 1: "Folds" - Center folds only, simple shapes, no layer checks
// ============================================================

///|
fn level_01() -> @types.Level {
  // Simple: fold 8x8 in half left -> 4x8
  let init = @types.full_paper(8, 8)
  let target = @types.make_rect_paper(8, 8, 0, 0, 4, 8)
  set_target_layers(target, 2)
  {
    initial_paper: init,
    target_silhouette: target,
    layer_checks: [],
    par_folds: 1,
    tier: Folds,
    name: "Half",
  }
}

///|
fn level_02() -> @types.Level {
  // Fold 8x8 up (center) -> 8x4
  let init = @types.full_paper(8, 8)
  let target = @types.make_rect_paper(8, 8, 0, 0, 8, 4)
  set_target_layers(target, 2)
  {
    initial_paper: init,
    target_silhouette: target,
    layer_checks: [],
    par_folds: 1,
    tier: Folds,
    name: "Horizon",
  }
}

///|
fn level_03() -> @types.Level {
  // Fold left then up -> 4x4 quarter
  let init = @types.full_paper(8, 8)
  let target = @types.make_rect_paper(8, 8, 0, 0, 4, 4)
  set_target_layers(target, 4)
  {
    initial_paper: init,
    target_silhouette: target,
    layer_checks: [],
    par_folds: 2,
    tier: Folds,
    name: "Quarter",
  }
}

///|
fn level_04() -> @types.Level {
  // Fold right -> right half has 2 layers
  let init = @types.full_paper(8, 8)
  let target = @types.make_rect_paper(8, 8, 4, 0, 8, 8)
  set_target_layers(target, 2)
  {
    initial_paper: init,
    target_silhouette: target,
    layer_checks: [],
    par_folds: 1,
    tier: Folds,
    name: "Mirror",
  }
}

///|
fn level_05() -> @types.Level {
  // Fold down -> bottom half
  let init = @types.full_paper(8, 8)
  let target = @types.make_rect_paper(8, 8, 0, 4, 8, 8)
  set_target_layers(target, 2)
  {
    initial_paper: init,
    target_silhouette: target,
    layer_checks: [],
    par_folds: 1,
    tier: Folds,
    name: "Flip",
  }
}

///|
fn level_06() -> @types.Level {
  // T-shape: start with cross, fold up center
  let init = @types.new_paper(8, 8)
  // Horizontal bar y=3..5 full width
  for y in 3..<5 {
    for x in 0..<8 {
      @types.set_cell(init, x, y, true, 1)
    }
  }
  // Vertical bar x=3..5 full height
  for y in 0..<8 {
    for x in 3..<5 {
      @types.set_cell(init, x, y, true, 1)
    }
  }
  let target = @types.new_paper(8, 8)
  // After fold up at 4: top part doubles, cross upper half
  for y in 0..<4 {
    for x in 3..<5 {
      @types.set_cell(target, x, y, true, 1)
    }
  }
  // Horizontal bar at y=3 (overlaps)
  for x in 0..<8 {
    let c = @types.get_cell(target, x, 3)
    if c.has_paper {
      @types.set_cell(target, x, 3, true, 2)
    } else {
      @types.set_cell(target, x, 3, true, 1)
    }
  }
  // Row 2 gets mirror of row 5 (horizontal bar)
  for x in 0..<8 {
    let c = @types.get_cell(target, x, 2)
    if c.has_paper {
      @types.set_cell(target, x, 2, true, 2)
    } else {
      @types.set_cell(target, x, 2, true, 1)
    }
  }
  // y=1 mirrors y=6 (vertical only)
  @types.set_cell(target, 3, 1, true, 2)
  @types.set_cell(target, 4, 1, true, 2)
  // y=0 mirrors y=7 (vertical only)
  @types.set_cell(target, 3, 0, true, 2)
  @types.set_cell(target, 4, 0, true, 2)
  {
    initial_paper: init,
    target_silhouette: target,
    layer_checks: [],
    par_folds: 1,
    tier: Folds,
    name: "Cross Fold",
  }
}

///|
fn level_07() -> @types.Level {
  // L-shape: fold left center
  let init = @types.new_paper(8, 8)
  // L-shape: bottom row + left column
  for x in 0..<8 {
    @types.set_cell(init, x, 7, true, 1)
  }
  for y in 0..<8 {
    @types.set_cell(init, 0, y, true, 1)
  }
  // Target: fold left at 4
  let target = @types.new_paper(8, 8)
  for x in 0..<4 {
    @types.set_cell(target, x, 7, true, 1)
  }
  // col 0 stays, mirror of cols 4-7 row 7 lands on cols 3,2,1,0
  @types.set_cell(target, 3, 7, true, 2)
  @types.set_cell(target, 2, 7, true, 2)
  @types.set_cell(target, 1, 7, true, 2)
  @types.set_cell(target, 0, 7, true, 2)
  // Left column stays
  for y in 0..<7 {
    @types.set_cell(target, 0, y, true, 1)
  }
  {
    initial_paper: init,
    target_silhouette: target,
    layer_checks: [],
    par_folds: 1,
    tier: Folds,
    name: "L-Bend",
  }
}

///|
fn level_08() -> @types.Level {
  // Fold left then down -> small square
  let init = @types.full_paper(8, 8)
  let target = @types.make_rect_paper(8, 8, 0, 4, 4, 8)
  set_target_layers(target, 4)
  {
    initial_paper: init,
    target_silhouette: target,
    layer_checks: [],
    par_folds: 2,
    tier: Folds,
    name: "Compact",
  }
}

// ============================================================
// Tier 2: "Layers" - Off-center folds, layer count targets
// ============================================================

///|
fn level_09() -> @types.Level {
  // Fold left at col 6 -> 2 cols fold onto 4 cols
  let init = @types.full_paper(8, 8)
  let target = @types.new_paper(8, 8)
  for y in 0..<8 {
    for x in 0..<6 {
      if x >= 4 {
        @types.set_cell(target, x, y, true, 2)
      } else {
        @types.set_cell(target, x, y, true, 1)
      }
    }
  }
  let checks : Array[@types.LayerCheck] = [
    { pos: { x: 5, y: 4, }, required_layers: 2, },
    { pos: { x: 2, y: 4, }, required_layers: 1, },
  ]
  {
    initial_paper: init,
    target_silhouette: target,
    layer_checks: checks,
    par_folds: 1,
    tier: Layers,
    name: "Edge Fold",
  }
}

///|
fn level_10() -> @types.Level {
  // Fold up at row 6 -> bottom 2 rows fold onto rows 4-5
  let init = @types.full_paper(8, 8)
  let target = @types.new_paper(8, 8)
  for y in 0..<6 {
    for x in 0..<8 {
      if y >= 4 {
        @types.set_cell(target, x, y, true, 2)
      } else {
        @types.set_cell(target, x, y, true, 1)
      }
    }
  }
  let checks : Array[@types.LayerCheck] = [
    { pos: { x: 4, y: 5, }, required_layers: 2, },
  ]
  {
    initial_paper: init,
    target_silhouette: target,
    layer_checks: checks,
    par_folds: 1,
    tier: Layers,
    name: "Hem",
  }
}

///|
fn level_11() -> @types.Level {
  // Fold left at 2 -> 2 cols fold onto cols 0-1 (doesn't reach further)
  let init = @types.full_paper(8, 8)
  let target = @types.new_paper(8, 8)
  for y in 0..<8 {
    for x in 0..<2 {
      @types.set_cell(target, x, y, true, 2)
    }
  }
  let checks : Array[@types.LayerCheck] = [
    { pos: { x: 0, y: 0, }, required_layers: 2, },
    { pos: { x: 1, y: 7, }, required_layers: 2, },
  ]
  {
    initial_paper: init,
    target_silhouette: target,
    layer_checks: checks,
    par_folds: 1,
    tier: Layers,
    name: "Narrow",
  }
}

///|
fn level_12() -> @types.Level {
  // Fold right at 2 -> cols 0,1 fold to cols 2,3
  let init = @types.full_paper(8, 8)
  let target = @types.new_paper(8, 8)
  for y in 0..<8 {
    for x in 2..<8 {
      if x <= 3 {
        @types.set_cell(target, x, y, true, 2)
      } else {
        @types.set_cell(target, x, y, true, 1)
      }
    }
  }
  let checks : Array[@types.LayerCheck] = [
    { pos: { x: 2, y: 3, }, required_layers: 2, },
    { pos: { x: 6, y: 3, }, required_layers: 1, },
  ]
  {
    initial_paper: init,
    target_silhouette: target,
    layer_checks: checks,
    par_folds: 1,
    tier: Layers,
    name: "Shift",
  }
}

///|
fn level_13() -> @types.Level {
  // Fold left at 4, then fold up at 4 -> 4x4 with 4 layers
  let init = @types.full_paper(8, 8)
  let target = @types.make_rect_paper(8, 8, 0, 0, 4, 4)
  set_target_layers(target, 4)
  let checks : Array[@types.LayerCheck] = [
    { pos: { x: 2, y: 2, }, required_layers: 4, },
    { pos: { x: 0, y: 0, }, required_layers: 4, },
  ]
  {
    initial_paper: init,
    target_silhouette: target,
    layer_checks: checks,
    par_folds: 2,
    tier: Layers,
    name: "Quad",
  }
}

///|
fn level_14() -> @types.Level {
  // Off-center: fold left at 6, then fold left at 4 -> stacked layers
  let init = @types.full_paper(8, 8)
  // After fold left at 6: cols 0-3 have 1 layer, cols 4-5 have 2 layers
  // Then fold left at 4: cols 4-5 (2 layers) mirror to cols 2-3 adding to existing
  let target = @types.new_paper(8, 8)
  for y in 0..<8 {
    @types.set_cell(target, 0, y, true, 1)
    @types.set_cell(target, 1, y, true, 1)
    @types.set_cell(target, 2, y, true, 3)
    @types.set_cell(target, 3, y, true, 3)
  }
  let checks : Array[@types.LayerCheck] = [
    { pos: { x: 2, y: 0, }, required_layers: 3, },
    { pos: { x: 0, y: 0, }, required_layers: 1, },
  ]
  {
    initial_paper: init,
    target_silhouette: target,
    layer_checks: checks,
    par_folds: 2,
    tier: Layers,
    name: "Stack",
  }
}

///|
fn level_15() -> @types.Level {
  // Fold up at 2 -> rows 0-1 become 2 layers
  let init = @types.full_paper(8, 8)
  let target = @types.new_paper(8, 8)
  for y in 0..<2 {
    for x in 0..<8 {
      @types.set_cell(target, x, y, true, 2)
    }
  }
  let checks : Array[@types.LayerCheck] = [
    { pos: { x: 4, y: 0, }, required_layers: 2, },
    { pos: { x: 4, y: 1, }, required_layers: 2, },
  ]
  {
    initial_paper: init,
    target_silhouette: target,
    layer_checks: checks,
    par_folds: 1,
    tier: Layers,
    name: "Thin Strip",
  }
}

///|
fn level_16() -> @types.Level {
  // Fold down at 6, then fold left at 4
  let init = @types.full_paper(8, 8)
  // After fold down at 6: rows 0-5 stay, rows 4-5 become 2, rest 1
  // Then fold left at 4: cols 4-7 mirror
  let target = @types.new_paper(8, 8)
  for y in 0..<6 {
    for x in 0..<4 {
      if y >= 4 {
        @types.set_cell(target, x, y, true, 4)
      } else {
        @types.set_cell(target, x, y, true, 2)
      }
    }
  }
  let checks : Array[@types.LayerCheck] = [
    { pos: { x: 2, y: 5, }, required_layers: 4, },
    { pos: { x: 2, y: 1, }, required_layers: 2, },
  ]
  {
    initial_paper: init,
    target_silhouette: target,
    layer_checks: checks,
    par_folds: 2,
    tier: Layers,
    name: "Frame",
  }
}

// ============================================================
// Tier 3: "Craft" - Multi-fold, tight layer requirements
// ============================================================

///|
fn level_17() -> @types.Level {
  // Triple fold: left at 4, up at 4, left at 2 -> 2x4 with 8 layers
  let init = @types.full_paper(8, 8)
  let target = @types.make_rect_paper(8, 8, 0, 0, 2, 4)
  set_target_layers(target, 8)
  let checks : Array[@types.LayerCheck] = [
    { pos: { x: 0, y: 0, }, required_layers: 8, },
    { pos: { x: 1, y: 3, }, required_layers: 8, },
  ]
  {
    initial_paper: init,
    target_silhouette: target,
    layer_checks: checks,
    par_folds: 3,
    tier: Craft,
    name: "Tight Pack",
  }
}

///|
fn level_18() -> @types.Level {
  // Fold left at 4, fold up at 4, fold left at 2, fold up at 2 -> 2x2 with 16
  let init = @types.full_paper(8, 8)
  let target = @types.make_rect_paper(8, 8, 0, 0, 2, 2)
  set_target_layers(target, 16)
  let checks : Array[@types.LayerCheck] = [
    { pos: { x: 0, y: 0, }, required_layers: 16, },
    { pos: { x: 1, y: 1, }, required_layers: 16, },
  ]
  {
    initial_paper: init,
    target_silhouette: target,
    layer_checks: checks,
    par_folds: 4,
    tier: Craft,
    name: "Ultra Pack",
  }
}

///|
fn level_19() -> @types.Level {
  // Fold left at 6, fold left at 4, fold up at 4
  let init = @types.full_paper(8, 8)
  let target = @types.new_paper(8, 8)
  for y in 0..<4 {
    @types.set_cell(target, 0, y, true, 2)
    @types.set_cell(target, 1, y, true, 2)
    @types.set_cell(target, 2, y, true, 6)
    @types.set_cell(target, 3, y, true, 6)
  }
  let checks : Array[@types.LayerCheck] = [
    { pos: { x: 3, y: 0, }, required_layers: 6, },
    { pos: { x: 0, y: 0, }, required_layers: 2, },
  ]
  {
    initial_paper: init,
    target_silhouette: target,
    layer_checks: checks,
    par_folds: 3,
    tier: Craft,
    name: "Layered Stack",
  }
}

///|
fn level_20() -> @types.Level {
  // Start with 6x6 center, fold left at 4, fold up at 4
  let init = @types.make_rect_paper(8, 8, 1, 1, 7, 7)
  let target = @types.new_paper(8, 8)
  for y in 1..<4 {
    for x in 1..<4 {
      @types.set_cell(target, x, y, true, 4)
    }
  }
  // Edge cells that only partially overlap
  for y in 1..<4 {
    @types.set_cell(target, 0, y, false, 0)
  }
  let checks : Array[@types.LayerCheck] = [
    { pos: { x: 2, y: 2, }, required_layers: 4, },
  ]
  {
    initial_paper: init,
    target_silhouette: target,
    layer_checks: checks,
    par_folds: 2,
    tier: Craft,
    name: "Center Piece",
  }
}

///|
fn level_21() -> @types.Level {
  // Fold down at 2, fold right at 6 -> corner accumulation
  let init = @types.full_paper(8, 8)
  // After fold down at 2: rows 0,1 fold to rows 2,3 (2 layers), rows 4-7 stay 1
  // After fold right at 6: cols 0-5 fold to cols 6,7 but only cols 4,5 reach 6,7
  let target = @types.new_paper(8, 8)
  for y in 2..<8 {
    for x in 6..<8 {
      if y <= 3 {
        @types.set_cell(target, x, y, true, 4)
      } else {
        @types.set_cell(target, x, y, true, 2)
      }
    }
  }
  let checks : Array[@types.LayerCheck] = [
    { pos: { x: 6, y: 2, }, required_layers: 4, },
    { pos: { x: 7, y: 6, }, required_layers: 2, },
  ]
  {
    initial_paper: init,
    target_silhouette: target,
    layer_checks: checks,
    par_folds: 2,
    tier: Craft,
    name: "Corner",
  }
}

///|
fn level_22() -> @types.Level {
  // Three folds: fold left at 4, fold up at 6, fold up at 4
  let init = @types.full_paper(8, 8)
  // After fold left at 4: 4x8 with 2 layers
  // After fold up at 6: rows 6,7 flip to rows 4,5 -> 4x6, rows 4-5 have 4
  // After fold up at 4: rows 4,5 flip to rows 2,3 -> 4x4
  let target = @types.new_paper(8, 8)
  for y in 0..<4 {
    for x in 0..<4 {
      if y >= 2 {
        @types.set_cell(target, x, y, true, 6)
      } else {
        @types.set_cell(target, x, y, true, 2)
      }
    }
  }
  let checks : Array[@types.LayerCheck] = [
    { pos: { x: 1, y: 0, }, required_layers: 2, },
    { pos: { x: 1, y: 3, }, required_layers: 6, },
  ]
  {
    initial_paper: init,
    target_silhouette: target,
    layer_checks: checks,
    par_folds: 3,
    tier: Craft,
    name: "Triple Fold",
  }
}

///|
fn level_23() -> @types.Level {
  // Complex: fold right at 2, fold down at 2, fold left at 4
  let init = @types.full_paper(8, 8)
  // After fold right at 2: cols 0,1 -> cols 2,3 (2 layers), cols 4-7 (1 layer)
  // After fold down at 2: rows 0,1 -> rows 2,3
  // After fold left at 4: cols 4-7 -> cols 0-3
  let target = @types.new_paper(8, 8)
  for y in 2..<8 {
    for x in 0..<4 {
      if y <= 3 && x >= 2 {
        @types.set_cell(target, x, y, true, 8)
      } else if y <= 3 {
        @types.set_cell(target, x, y, true, 4)
      } else if x >= 2 {
        @types.set_cell(target, x, y, true, 4)
      } else {
        @types.set_cell(target, x, y, true, 2)
      }
    }
  }
  let checks : Array[@types.LayerCheck] = [
    { pos: { x: 2, y: 2, }, required_layers: 8, },
    { pos: { x: 0, y: 6, }, required_layers: 2, },
    { pos: { x: 3, y: 6, }, required_layers: 4, },
  ]
  {
    initial_paper: init,
    target_silhouette: target,
    layer_checks: checks,
    par_folds: 3,
    tier: Craft,
    name: "Complex",
  }
}

///|
fn level_24() -> @types.Level {
  // Fold left at 4, fold down at 4, fold left at 2
  // After left 4: 4x8 2-layer
  // After down 4: rows 0-3 fold to rows 4-7 -> rows 4-7 have 4 layers
  // After left 2: cols 2,3 (4 layers) fold to cols 0,1 -> 8 layers, rows 4-7
  let init = @types.full_paper(8, 8)
  let target = @types.new_paper(8, 8)
  for y in 4..<8 {
    @types.set_cell(target, 0, y, true, 8)
    @types.set_cell(target, 1, y, true, 8)
  }
  let checks : Array[@types.LayerCheck] = [
    { pos: { x: 0, y: 4, }, required_layers: 8, },
    { pos: { x: 1, y: 7, }, required_layers: 8, },
  ]
  {
    initial_paper: init,
    target_silhouette: target,
    layer_checks: checks,
    par_folds: 3,
    tier: Craft,
    name: "Origami Master",
  }
}

///|
fn level_25() -> @types.Level {
  // Grand finale: 5 folds to 1x1 with 32 layers? No, max with 8x8 is tricky
  // 4 folds: left 4, up 4, left 2, up 2 -> 2x2 with 16 layers, then left at 1 -> 1x2 32 layers
  // Actually just do a neat 3-fold
  // Fold right at 4, fold down at 4, fold right at 6 -> 2x4 with layers
  let init = @types.full_paper(8, 8)
  // Simpler: fold left 4, fold up 4, fold left 2 -> 2x4 with 8 layers
  // Then fold up 2 -> 2x2 with 16
  let target = @types.make_rect_paper(8, 8, 0, 0, 2, 2)
  set_target_layers(target, 16)
  let checks : Array[@types.LayerCheck] = [
    { pos: { x: 0, y: 0, }, required_layers: 16, },
    { pos: { x: 1, y: 0, }, required_layers: 16, },
    { pos: { x: 0, y: 1, }, required_layers: 16, },
    { pos: { x: 1, y: 1, }, required_layers: 16, },
  ]
  {
    initial_paper: init,
    target_silhouette: target,
    layer_checks: checks,
    par_folds: 4,
    tier: Craft,
    name: "Grand Finale",
  }
}

// Helper to set all paper cells in a target to a uniform layer count

///|
fn set_target_layers(paper : @types.Paper, layers : Int) -> Unit {
  for i in 0..<paper.cells.length() {
    if paper.cells[i].has_paper {
      paper.cells[i].layers = layers
    }
  }
}
