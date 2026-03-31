///|
let all_levels : Ref[Array[@types.Level]?] = { val: None }

///|
pub fn get_levels() -> Array[@types.Level] {
  match all_levels.val {
    Some(l) => l
    None => {
      let l = build_levels()
      all_levels.val = Some(l)
      l
    }
  }
}

///|
pub fn get_level(idx : Int) -> @types.Level {
  get_levels()[idx]
}

///|
fn s(cells : Array[@types.Vec2i]) -> @types.Shape {
  @types.new_shape(cells)
}

///|
fn v(x : Int, y : Int) -> @types.Vec2i {
  @types.vec2i(x, y)
}

///|
fn morph_ops() -> Array[@types.OpKind] {
  [Shift, Rotate]
}

///|
fn sculpt_ops() -> Array[@types.OpKind] {
  [Shift, Rotate, Flip, Grow]
}

///|
fn transform_ops() -> Array[@types.OpKind] {
  [Shift, Rotate, Flip, Grow, Shrink]
}

///|
fn build_levels() -> Array[@types.Level] {
  let levels : Array[@types.Level] = []
  // === TIER 1: MORPH (8 levels) - Shift + Rotate only ===
  // Level 1: Simple shift right
  levels.push(
    {
      initial_shape: s([v(1, 3), v(1, 4), v(2, 3), v(2, 4)]),
      target_shape: s([v(4, 3), v(4, 4), v(5, 3), v(5, 4)]),
      par_cost: 4,
      min_cost: 3,
      available_ops: morph_ops(),
      tier: Morph,
      name: "Slide",
    },
  )
  // Level 2: Shift down
  levels.push(
    {
      initial_shape: s([v(3, 1), v(4, 1), v(5, 1)]),
      target_shape: s([v(3, 4), v(4, 4), v(5, 4)]),
      par_cost: 4,
      min_cost: 3,
      available_ops: morph_ops(),
      tier: Morph,
      name: "Drop",
    },
  )
  // Level 3: Shift diagonal
  levels.push(
    {
      initial_shape: s([v(1, 1), v(2, 1), v(1, 2)]),
      target_shape: s([v(3, 3), v(4, 3), v(3, 4)]),
      par_cost: 5,
      min_cost: 4,
      available_ops: morph_ops(),
      tier: Morph,
      name: "Corner",
    },
  )
  // Level 4: Rotate L-shape
  levels.push(
    {
      initial_shape: s([v(3, 2), v(3, 3), v(3, 4), v(4, 4)]),
      target_shape: s([v(3, 4), v(4, 4), v(5, 4), v(5, 3)]),
      par_cost: 3,
      min_cost: 2,
      available_ops: morph_ops(),
      tier: Morph,
      name: "Elbow",
    },
  )
  // Level 5: T-piece rotate
  levels.push(
    {
      initial_shape: s([v(3, 3), v(4, 3), v(5, 3), v(4, 4)]),
      target_shape: s([v(4, 2), v(4, 3), v(4, 4), v(3, 3)]),
      par_cost: 3,
      min_cost: 2,
      available_ops: morph_ops(),
      tier: Morph,
      name: "Pivot",
    },
  )
  // Level 6: Shift and rotate
  levels.push(
    {
      initial_shape: s([v(1, 1), v(2, 1), v(3, 1), v(3, 2)]),
      target_shape: s([v(5, 4), v(5, 5), v(5, 6), v(4, 6)]),
      par_cost: 8,
      min_cost: 6,
      available_ops: morph_ops(),
      tier: Morph,
      name: "Journey",
    },
  )
  // Level 7: Z-piece rotate
  levels.push(
    {
      initial_shape: s([v(3, 3), v(4, 3), v(4, 4), v(5, 4)]),
      target_shape: s([v(4, 2), v(4, 3), v(3, 3), v(3, 4)]),
      par_cost: 3,
      min_cost: 2,
      available_ops: morph_ops(),
      tier: Morph,
      name: "Zigzag",
    },
  )
  // Level 8: Long bar rotate + shift
  levels.push(
    {
      initial_shape: s([v(2, 3), v(3, 3), v(4, 3), v(5, 3)]),
      target_shape: s([v(4, 1), v(4, 2), v(4, 3), v(4, 4)]),
      par_cost: 4,
      min_cost: 3,
      available_ops: morph_ops(),
      tier: Morph,
      name: "Beam",
    },
  )
  // === TIER 2: SCULPT (9 levels) ===
  // Level 9: Simple flip
  levels.push(
    {
      initial_shape: s([v(2, 3), v(2, 4), v(3, 3)]),
      target_shape: s([v(4, 3), v(4, 4), v(3, 3)]),
      par_cost: 3,
      min_cost: 2,
      available_ops: sculpt_ops(),
      tier: Sculpt,
      name: "Mirror",
    },
  )
  // Level 10: Flip vertical
  levels.push(
    {
      initial_shape: s([v(3, 2), v(4, 2), v(3, 3)]),
      target_shape: s([v(3, 4), v(4, 4), v(3, 3)]),
      par_cost: 3,
      min_cost: 2,
      available_ops: sculpt_ops(),
      tier: Sculpt,
      name: "Reflect",
    },
  )
  // Level 11: Grow one cell
  levels.push(
    {
      initial_shape: s([v(3, 3), v(4, 3), v(3, 4)]),
      target_shape: s([v(3, 3), v(4, 3), v(3, 4), v(4, 4)]),
      par_cost: 4,
      min_cost: 3,
      available_ops: sculpt_ops(),
      tier: Sculpt,
      name: "Expand",
    },
  )
  // Level 12: Flip then grow
  levels.push(
    {
      initial_shape: s([v(2, 3), v(3, 3), v(3, 4)]),
      target_shape: s([v(3, 3), v(4, 3), v(3, 4), v(3, 2)]),
      par_cost: 6,
      min_cost: 4,
      available_ops: sculpt_ops(),
      tier: Sculpt,
      name: "Sprout",
    },
  )
  // Level 13: Build a plus
  levels.push(
    {
      initial_shape: s([v(3, 3), v(4, 3), v(5, 3)]),
      target_shape: s([v(4, 2), v(3, 3), v(4, 3), v(5, 3), v(4, 4)]),
      par_cost: 8,
      min_cost: 6,
      available_ops: sculpt_ops(),
      tier: Sculpt,
      name: "Bloom",
    },
  )
  // Level 14: Rotate + flip combo
  levels.push(
    {
      initial_shape: s([v(2, 2), v(3, 2), v(3, 3), v(3, 4)]),
      target_shape: s([v(4, 2), v(3, 2), v(3, 3), v(3, 4)]),
      par_cost: 3,
      min_cost: 2,
      available_ops: sculpt_ops(),
      tier: Sculpt,
      name: "Twist",
    },
  )
  // Level 15: Grow to make T
  levels.push(
    {
      initial_shape: s([v(3, 3), v(4, 3), v(5, 3)]),
      target_shape: s([v(3, 3), v(4, 3), v(5, 3), v(4, 2)]),
      par_cost: 4,
      min_cost: 3,
      available_ops: sculpt_ops(),
      tier: Sculpt,
      name: "Branch",
    },
  )
  // Level 16: Multi-step sculpt
  levels.push(
    {
      initial_shape: s([v(2, 3), v(3, 3), v(4, 3)]),
      target_shape: s([v(4, 2), v(5, 2), v(5, 3), v(5, 4), v(4, 4)]),
      par_cost: 12,
      min_cost: 9,
      available_ops: sculpt_ops(),
      tier: Sculpt,
      name: "Arch",
    },
  )
  // Level 17: Complex flip and grow
  levels.push(
    {
      initial_shape: s([v(1, 3), v(2, 3), v(2, 4), v(3, 4)]),
      target_shape: s([v(4, 3), v(5, 3), v(5, 4), v(6, 4), v(6, 5)]),
      par_cost: 10,
      min_cost: 7,
      available_ops: sculpt_ops(),
      tier: Sculpt,
      name: "Cascade",
    },
  )
  // === TIER 3: TRANSFORM (8 levels) ===
  // Level 18: Simple shrink
  levels.push(
    {
      initial_shape: s([v(3, 3), v(4, 3), v(5, 3), v(4, 4)]),
      target_shape: s([v(3, 3), v(4, 3), v(5, 3)]),
      par_cost: 4,
      min_cost: 3,
      available_ops: transform_ops(),
      tier: Transform,
      name: "Prune",
    },
  )
  // Level 19: Shrink and shift
  levels.push(
    {
      initial_shape: s([v(2, 2), v(3, 2), v(4, 2), v(4, 3)]),
      target_shape: s([v(4, 4), v(5, 4), v(6, 4)]),
      par_cost: 8,
      min_cost: 6,
      available_ops: transform_ops(),
      tier: Transform,
      name: "Trim",
    },
  )
  // Level 20: Shrink + grow reshape
  levels.push(
    {
      initial_shape: s([v(3, 2), v(3, 3), v(3, 4), v(3, 5)]),
      target_shape: s([v(3, 3), v(4, 3), v(3, 4), v(4, 4)]),
      par_cost: 10,
      min_cost: 8,
      available_ops: transform_ops(),
      tier: Transform,
      name: "Reform",
    },
  )
  // Level 21: Complex transformation
  levels.push(
    {
      initial_shape: s([v(2, 2), v(3, 2), v(4, 2), v(2, 3), v(2, 4)]),
      target_shape: s([v(5, 4), v(5, 5), v(5, 6), v(6, 6)]),
      par_cost: 14,
      min_cost: 10,
      available_ops: transform_ops(),
      tier: Transform,
      name: "Morph",
    },
  )
  // Level 22: Tight budget
  levels.push(
    {
      initial_shape: s([v(3, 3), v(4, 3), v(4, 4), v(5, 4)]),
      target_shape: s([v(3, 4), v(4, 4), v(4, 3), v(5, 3)]),
      par_cost: 4,
      min_cost: 2,
      available_ops: transform_ops(),
      tier: Transform,
      name: "Swap",
    },
  )
  // Level 23: Full toolkit
  levels.push(
    {
      initial_shape: s([v(1, 1), v(2, 1), v(3, 1), v(2, 2)]),
      target_shape: s([v(5, 5), v(5, 6), v(6, 5), v(4, 5), v(5, 4)]),
      par_cost: 16,
      min_cost: 12,
      available_ops: transform_ops(),
      tier: Transform,
      name: "Evolve",
    },
  )
  // Level 24: Precision challenge
  levels.push(
    {
      initial_shape: s([v(2, 2), v(3, 2), v(4, 2), v(5, 2), v(3, 3)]),
      target_shape: s([v(4, 4), v(5, 4), v(4, 5), v(5, 5)]),
      par_cost: 14,
      min_cost: 10,
      available_ops: transform_ops(),
      tier: Transform,
      name: "Distill",
    },
  )
  // Level 25: Final challenge
  levels.push(
    {
      initial_shape: s([v(1, 3), v(2, 3), v(3, 3), v(2, 2), v(2, 4)]),
      target_shape: s([v(5, 3), v(6, 3), v(5, 4), v(6, 4), v(5, 5), v(6, 5)]),
      par_cost: 18,
      min_cost: 13,
      available_ops: transform_ops(),
      tier: Transform,
      name: "Transcend",
    },
  )
  levels
}
