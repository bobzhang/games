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
    _ => level_25()
  }
}

///|
pub fn get_level_name(index : Int) -> String {
  get_level(index).name
}

// ========== TIER 1: VERTICES (levels 0-7) ==========
// Simple convex shapes - just place points at vertices

///|
fn level_01() -> @types.Level {
  // Simple right triangle
  let cx : Float = 640.0
  let cy : Float = 360.0
  {
    target_polygon: @types.make_polygon([
      @types.pt(cx - 120.0, cy + 100.0),
      @types.pt(cx + 120.0, cy + 100.0),
      @types.pt(cx - 120.0, cy - 100.0),
    ]),
    pre_placed_points: [],
    par_points: 4,
    min_points: 3,
    tier: Vertices,
    name: "Right Triangle",
  }
}

///|
fn level_02() -> @types.Level {
  // Equilateral-ish triangle
  let cx : Float = 640.0
  let cy : Float = 360.0
  {
    target_polygon: @types.make_polygon([
      @types.pt(cx, cy - 140.0),
      @types.pt(cx + 140.0, cy + 100.0),
      @types.pt(cx - 140.0, cy + 100.0),
    ]),
    pre_placed_points: [],
    par_points: 4,
    min_points: 3,
    tier: Vertices,
    name: "Tall Triangle",
  }
}

///|
fn level_03() -> @types.Level {
  // Square
  let cx : Float = 640.0
  let cy : Float = 360.0
  let s : Float = 120.0
  {
    target_polygon: @types.make_polygon([
      @types.pt(cx - s, cy - s),
      @types.pt(cx + s, cy - s),
      @types.pt(cx + s, cy + s),
      @types.pt(cx - s, cy + s),
    ]),
    pre_placed_points: [],
    par_points: 5,
    min_points: 4,
    tier: Vertices,
    name: "Square",
  }
}

///|
fn level_04() -> @types.Level {
  // Rectangle
  let cx : Float = 640.0
  let cy : Float = 360.0
  {
    target_polygon: @types.make_polygon([
      @types.pt(cx - 180.0, cy - 80.0),
      @types.pt(cx + 180.0, cy - 80.0),
      @types.pt(cx + 180.0, cy + 80.0),
      @types.pt(cx - 180.0, cy + 80.0),
    ]),
    pre_placed_points: [],
    par_points: 5,
    min_points: 4,
    tier: Vertices,
    name: "Rectangle",
  }
}

///|
fn level_05() -> @types.Level {
  // Pentagon
  let cx : Float = 640.0
  let cy : Float = 360.0
  let r : Float = 140.0
  let verts : Array[@types.Point] = Array::new(capacity=5)
  for i in 0..<5 {
    let angle = Float::from_int(i) * 2.0 * @types.pi / 5.0 - @types.pi / 2.0
    verts.push(
      @types.pt(cx + r * @types.cosf(angle), cy + r * @types.sinf(angle)),
    )
  }
  {
    target_polygon: @types.make_polygon(verts),
    pre_placed_points: [],
    par_points: 6,
    min_points: 5,
    tier: Vertices,
    name: "Pentagon",
  }
}

///|
fn level_06() -> @types.Level {
  // Hexagon
  let cx : Float = 640.0
  let cy : Float = 360.0
  let r : Float = 130.0
  let verts : Array[@types.Point] = Array::new(capacity=6)
  for i in 0..<6 {
    let angle = Float::from_int(i) * 2.0 * @types.pi / 6.0
    verts.push(
      @types.pt(cx + r * @types.cosf(angle), cy + r * @types.sinf(angle)),
    )
  }
  {
    target_polygon: @types.make_polygon(verts),
    pre_placed_points: [],
    par_points: 7,
    min_points: 6,
    tier: Vertices,
    name: "Hexagon",
  }
}

///|
fn level_07() -> @types.Level {
  // Diamond (rotated square)
  let cx : Float = 640.0
  let cy : Float = 360.0
  {
    target_polygon: @types.make_polygon([
      @types.pt(cx, cy - 160.0),
      @types.pt(cx + 120.0, cy),
      @types.pt(cx, cy + 160.0),
      @types.pt(cx - 120.0, cy),
    ]),
    pre_placed_points: [],
    par_points: 5,
    min_points: 4,
    tier: Vertices,
    name: "Diamond",
  }
}

///|
fn level_08() -> @types.Level {
  // Octagon
  let cx : Float = 640.0
  let cy : Float = 360.0
  let r : Float = 140.0
  let verts : Array[@types.Point] = Array::new(capacity=8)
  for i in 0..<8 {
    let angle = Float::from_int(i) * 2.0 * @types.pi / 8.0 + @types.pi / 8.0
    verts.push(
      @types.pt(cx + r * @types.cosf(angle), cy + r * @types.sinf(angle)),
    )
  }
  {
    target_polygon: @types.make_polygon(verts),
    pre_placed_points: [],
    par_points: 9,
    min_points: 8,
    tier: Vertices,
    name: "Octagon",
  }
}

// ========== TIER 2: EDGES (levels 8-16) ==========
// Shapes that might need points along edges, interior points as distractors

///|
fn level_09() -> @types.Level {
  // Triangle with interior point already placed
  let cx : Float = 640.0
  let cy : Float = 360.0
  {
    target_polygon: @types.make_polygon([
      @types.pt(cx, cy - 140.0),
      @types.pt(cx + 160.0, cy + 120.0),
      @types.pt(cx - 160.0, cy + 120.0),
    ]),
    pre_placed_points: [@types.pt(cx, cy)],
    par_points: 4,
    min_points: 3,
    tier: Edges,
    name: "Centered Triangle",
  }
}

///|
fn level_10() -> @types.Level {
  // Trapezoid
  let cx : Float = 640.0
  let cy : Float = 360.0
  {
    target_polygon: @types.make_polygon([
      @types.pt(cx - 80.0, cy - 100.0),
      @types.pt(cx + 80.0, cy - 100.0),
      @types.pt(cx + 160.0, cy + 100.0),
      @types.pt(cx - 160.0, cy + 100.0),
    ]),
    pre_placed_points: [@types.pt(cx, cy)],
    par_points: 5,
    min_points: 4,
    tier: Edges,
    name: "Trapezoid",
  }
}

///|
fn level_11() -> @types.Level {
  // Kite shape
  let cx : Float = 640.0
  let cy : Float = 360.0
  {
    target_polygon: @types.make_polygon([
      @types.pt(cx, cy - 180.0),
      @types.pt(cx + 100.0, cy - 40.0),
      @types.pt(cx, cy + 140.0),
      @types.pt(cx - 100.0, cy - 40.0),
    ]),
    pre_placed_points: [
      @types.pt(cx + 20.0, cy - 60.0),
      @types.pt(cx - 20.0, cy + 20.0),
    ],
    par_points: 5,
    min_points: 4,
    tier: Edges,
    name: "Kite",
  }
}

///|
fn level_12() -> @types.Level {
  // Arrow shape (pentagon)
  let cx : Float = 640.0
  let cy : Float = 360.0
  {
    target_polygon: @types.make_polygon([
      @types.pt(cx + 180.0, cy),
      @types.pt(cx + 40.0, cy - 120.0),
      @types.pt(cx - 140.0, cy - 60.0),
      @types.pt(cx - 140.0, cy + 60.0),
      @types.pt(cx + 40.0, cy + 120.0),
    ]),
    pre_placed_points: [@types.pt(cx - 40.0, cy), @types.pt(cx + 60.0, cy)],
    par_points: 6,
    min_points: 5,
    tier: Edges,
    name: "Arrow",
  }
}

///|
fn level_13() -> @types.Level {
  // Wide hexagon with pre-placed interior
  let cx : Float = 640.0
  let cy : Float = 360.0
  let verts : Array[@types.Point] = [
    @types.pt(cx - 60.0, cy - 120.0),
    @types.pt(cx + 60.0, cy - 120.0),
    @types.pt(cx + 160.0, cy),
    @types.pt(cx + 60.0, cy + 120.0),
    @types.pt(cx - 60.0, cy + 120.0),
    @types.pt(cx - 160.0, cy),
  ]
  {
    target_polygon: @types.make_polygon(verts),
    pre_placed_points: [
      @types.pt(cx, cy),
      @types.pt(cx + 40.0, cy - 40.0),
      @types.pt(cx - 40.0, cy + 40.0),
    ],
    par_points: 7,
    min_points: 6,
    tier: Edges,
    name: "Wide Hexagon",
  }
}

///|
fn level_14() -> @types.Level {
  // Parallelogram
  let cx : Float = 640.0
  let cy : Float = 360.0
  {
    target_polygon: @types.make_polygon([
      @types.pt(cx - 120.0, cy - 80.0),
      @types.pt(cx + 60.0, cy - 80.0),
      @types.pt(cx + 120.0, cy + 80.0),
      @types.pt(cx - 60.0, cy + 80.0),
    ]),
    pre_placed_points: [@types.pt(cx, cy)],
    par_points: 5,
    min_points: 4,
    tier: Edges,
    name: "Parallelogram",
  }
}

///|
fn level_15() -> @types.Level {
  // House shape (pentagon)
  let cx : Float = 640.0
  let cy : Float = 360.0
  {
    target_polygon: @types.make_polygon([
      @types.pt(cx, cy - 160.0),
      @types.pt(cx + 140.0, cy - 40.0),
      @types.pt(cx + 140.0, cy + 120.0),
      @types.pt(cx - 140.0, cy + 120.0),
      @types.pt(cx - 140.0, cy - 40.0),
    ]),
    pre_placed_points: [@types.pt(cx, cy + 40.0), @types.pt(cx + 60.0, cy)],
    par_points: 6,
    min_points: 5,
    tier: Edges,
    name: "House",
  }
}

///|
fn level_16() -> @types.Level {
  // Star-like convex (heptagon)
  let cx : Float = 640.0
  let cy : Float = 360.0
  let r : Float = 150.0
  let verts : Array[@types.Point] = Array::new(capacity=7)
  for i in 0..<7 {
    let angle = Float::from_int(i) * 2.0 * @types.pi / 7.0 - @types.pi / 2.0
    verts.push(
      @types.pt(cx + r * @types.cosf(angle), cy + r * @types.sinf(angle)),
    )
  }
  {
    target_polygon: @types.make_polygon(verts),
    pre_placed_points: [
      @types.pt(cx + 20.0, cy - 20.0),
      @types.pt(cx - 40.0, cy + 20.0),
      @types.pt(cx + 30.0, cy + 40.0),
    ],
    par_points: 8,
    min_points: 7,
    tier: Edges,
    name: "Heptagon",
  }
}

///|
fn level_17() -> @types.Level {
  // Long thin triangle with edge points needed
  let cx : Float = 640.0
  let cy : Float = 360.0
  {
    target_polygon: @types.make_polygon([
      @types.pt(cx - 200.0, cy + 60.0),
      @types.pt(cx + 200.0, cy + 60.0),
      @types.pt(cx, cy - 160.0),
    ]),
    pre_placed_points: [@types.pt(cx - 60.0, cy), @types.pt(cx + 60.0, cy)],
    par_points: 4,
    min_points: 3,
    tier: Edges,
    name: "Flat Triangle",
  }
}

// ========== TIER 3: SCULPT (levels 17-24) ==========
// Complex shapes. Must strategically remove pre-placed interior points that distort hull.

///|
fn level_18() -> @types.Level {
  // Square but with extra points outside that must be removed
  let cx : Float = 640.0
  let cy : Float = 360.0
  let s : Float = 100.0
  {
    target_polygon: @types.make_polygon([
      @types.pt(cx - s, cy - s),
      @types.pt(cx + s, cy - s),
      @types.pt(cx + s, cy + s),
      @types.pt(cx - s, cy + s),
    ]),
    pre_placed_points: [
      @types.pt(cx - s, cy - s),
      @types.pt(cx + s, cy - s),
      @types.pt(cx + s, cy + s),
      @types.pt(cx - s, cy + s),
      @types.pt(cx, cy - s - 80.0),
      @types.pt(cx + s + 80.0, cy),
    ],
    par_points: 5,
    min_points: 4,
    tier: Sculpt,
    name: "Trim Square",
  }
}

///|
fn level_19() -> @types.Level {
  // Pentagon with outlier points
  let cx : Float = 640.0
  let cy : Float = 360.0
  let r : Float = 120.0
  let verts : Array[@types.Point] = Array::new(capacity=5)
  for i in 0..<5 {
    let angle = Float::from_int(i) * 2.0 * @types.pi / 5.0 - @types.pi / 2.0
    verts.push(
      @types.pt(cx + r * @types.cosf(angle), cy + r * @types.sinf(angle)),
    )
  }
  let pre : Array[@types.Point] = Array::new(capacity=8)
  for i in 0..<5 {
    pre.push(verts[i])
  }
  // Add outliers
  pre.push(@types.pt(cx - 200.0, cy - 160.0))
  pre.push(@types.pt(cx + 200.0, cy + 120.0))
  pre.push(@types.pt(cx, cy + 200.0))
  {
    target_polygon: @types.make_polygon(verts),
    pre_placed_points: pre,
    par_points: 6,
    min_points: 5,
    tier: Sculpt,
    name: "Prune Pentagon",
  }
}

///|
fn level_20() -> @types.Level {
  // Triangle with many distorting points
  let cx : Float = 640.0
  let cy : Float = 360.0
  {
    target_polygon: @types.make_polygon([
      @types.pt(cx, cy - 140.0),
      @types.pt(cx + 160.0, cy + 100.0),
      @types.pt(cx - 160.0, cy + 100.0),
    ]),
    pre_placed_points: [
      @types.pt(cx, cy - 140.0),
      @types.pt(cx + 160.0, cy + 100.0),
      @types.pt(cx - 160.0, cy + 100.0),
      @types.pt(cx, cy + 160.0),
      @types.pt(cx + 200.0, cy - 40.0),
      @types.pt(cx - 200.0, cy - 40.0),
      @types.pt(cx, cy),
    ],
    par_points: 4,
    min_points: 3,
    tier: Sculpt,
    name: "Clean Triangle",
  }
}

///|
fn level_21() -> @types.Level {
  // Hexagon with spikes to remove
  let cx : Float = 640.0
  let cy : Float = 360.0
  let r : Float = 120.0
  let verts : Array[@types.Point] = Array::new(capacity=6)
  for i in 0..<6 {
    let angle = Float::from_int(i) * 2.0 * @types.pi / 6.0
    verts.push(
      @types.pt(cx + r * @types.cosf(angle), cy + r * @types.sinf(angle)),
    )
  }
  let pre : Array[@types.Point] = Array::new(capacity=10)
  for i in 0..<6 {
    pre.push(verts[i])
  }
  // Spikes extending beyond
  pre.push(@types.pt(cx + 200.0, cy))
  pre.push(@types.pt(cx - 200.0, cy))
  pre.push(@types.pt(cx, cy - 200.0))
  pre.push(@types.pt(cx, cy + 200.0))
  {
    target_polygon: @types.make_polygon(verts),
    pre_placed_points: pre,
    par_points: 7,
    min_points: 6,
    tier: Sculpt,
    name: "Trim Hexagon",
  }
}

///|
fn level_22() -> @types.Level {
  // Rectangle with corner extensions
  let cx : Float = 640.0
  let cy : Float = 360.0
  {
    target_polygon: @types.make_polygon([
      @types.pt(cx - 140.0, cy - 80.0),
      @types.pt(cx + 140.0, cy - 80.0),
      @types.pt(cx + 140.0, cy + 80.0),
      @types.pt(cx - 140.0, cy + 80.0),
    ]),
    pre_placed_points: [
      @types.pt(cx - 140.0, cy - 80.0),
      @types.pt(cx + 140.0, cy - 80.0),
      @types.pt(cx + 140.0, cy + 80.0),
      @types.pt(cx - 140.0, cy + 80.0),
      @types.pt(cx - 220.0, cy - 160.0),
      @types.pt(cx + 220.0, cy - 160.0),
      @types.pt(cx + 220.0, cy + 160.0),
      @types.pt(cx - 220.0, cy + 160.0),
      @types.pt(cx, cy),
    ],
    par_points: 5,
    min_points: 4,
    tier: Sculpt,
    name: "Inner Rectangle",
  }
}

///|
fn level_23() -> @types.Level {
  // Narrow diamond with wide distractors
  let cx : Float = 640.0
  let cy : Float = 360.0
  {
    target_polygon: @types.make_polygon([
      @types.pt(cx, cy - 180.0),
      @types.pt(cx + 80.0, cy),
      @types.pt(cx, cy + 180.0),
      @types.pt(cx - 80.0, cy),
    ]),
    pre_placed_points: [
      @types.pt(cx, cy - 180.0),
      @types.pt(cx + 80.0, cy),
      @types.pt(cx, cy + 180.0),
      @types.pt(cx - 80.0, cy),
      @types.pt(cx + 200.0, cy - 100.0),
      @types.pt(cx - 200.0, cy + 100.0),
      @types.pt(cx + 160.0, cy + 140.0),
      @types.pt(cx, cy),
    ],
    par_points: 5,
    min_points: 4,
    tier: Sculpt,
    name: "Slim Diamond",
  }
}

///|
fn level_24() -> @types.Level {
  // Octagon with many exterior spikes
  let cx : Float = 640.0
  let cy : Float = 360.0
  let r : Float = 120.0
  let verts : Array[@types.Point] = Array::new(capacity=8)
  for i in 0..<8 {
    let angle = Float::from_int(i) * 2.0 * @types.pi / 8.0 + @types.pi / 8.0
    verts.push(
      @types.pt(cx + r * @types.cosf(angle), cy + r * @types.sinf(angle)),
    )
  }
  let pre : Array[@types.Point] = Array::new(capacity=14)
  for i in 0..<8 {
    pre.push(verts[i])
  }
  // Six spike points
  pre.push(@types.pt(cx + 240.0, cy))
  pre.push(@types.pt(cx - 240.0, cy))
  pre.push(@types.pt(cx, cy - 240.0))
  pre.push(@types.pt(cx, cy + 240.0))
  pre.push(@types.pt(cx + 180.0, cy + 180.0))
  pre.push(@types.pt(cx - 180.0, cy - 180.0))
  {
    target_polygon: @types.make_polygon(verts),
    pre_placed_points: pre,
    par_points: 9,
    min_points: 8,
    tier: Sculpt,
    name: "Spike Octagon",
  }
}

///|
fn level_25() -> @types.Level {
  // Complex convex 10-gon with lots of noise
  let cx : Float = 640.0
  let cy : Float = 360.0
  let verts : Array[@types.Point] = [
    @types.pt(cx - 40.0, cy - 160.0),
    @types.pt(cx + 60.0, cy - 160.0),
    @types.pt(cx + 140.0, cy - 100.0),
    @types.pt(cx + 180.0, cy - 20.0),
    @types.pt(cx + 160.0, cy + 80.0),
    @types.pt(cx + 80.0, cy + 140.0),
    @types.pt(cx - 40.0, cy + 160.0),
    @types.pt(cx - 120.0, cy + 100.0),
    @types.pt(cx - 160.0, cy),
    @types.pt(cx - 120.0, cy - 100.0),
  ]
  let pre : Array[@types.Point] = Array::new(capacity=18)
  for i in 0..<verts.length() {
    pre.push(verts[i])
  }
  // 8 noise points
  pre.push(@types.pt(cx + 260.0, cy - 80.0))
  pre.push(@types.pt(cx - 240.0, cy - 60.0))
  pre.push(@types.pt(cx, cy + 240.0))
  pre.push(@types.pt(cx + 200.0, cy + 200.0))
  pre.push(@types.pt(cx - 200.0, cy + 180.0))
  pre.push(@types.pt(cx + 60.0, cy - 240.0))
  pre.push(@types.pt(cx, cy))
  pre.push(@types.pt(cx + 40.0, cy + 40.0))
  {
    target_polygon: @types.make_polygon(verts),
    pre_placed_points: pre,
    par_points: 11,
    min_points: 10,
    tier: Sculpt,
    name: "Grand Decagon",
  }
}
