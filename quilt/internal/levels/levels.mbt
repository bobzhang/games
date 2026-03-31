///|
fn p(
  n : @types.EdgePattern,
  e : @types.EdgePattern,
  s : @types.EdgePattern,
  w : @types.EdgePattern
) -> @types.Patch {
  @types.new_patch(n, e, s, w)
}

///|
fn pp(
  n : @types.EdgePattern,
  e : @types.EdgePattern,
  s : @types.EdgePattern,
  w : @types.EdgePattern
) -> @types.Patch {
  @types.new_patch_pinned(n, e, s, w)
}

///|
fn pw(
  n : @types.EdgePattern,
  e : @types.EdgePattern,
  s : @types.EdgePattern,
  w : @types.EdgePattern,
  wn : Bool,
  we : Bool,
  ws : Bool,
  ww : Bool
) -> @types.Patch {
  @types.new_patch_wildcard(n, e, s, w, wn, we, ws, ww)
}

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

// Tier 1 "Scraps" - 3x3, 3-4 patterns, no specials

///|
fn level_01() -> @types.Level {
  // Intro: 3 patterns (Zigzag, Dots, Stripes), simple matching
  let z : @types.EdgePattern = Zigzag
  let d : @types.EdgePattern = Dots
  let s : @types.EdgePattern = Stripes
  {
    board_size: 3,
    patches: [
      p(z, d, d, z),
      p(z, s, s, d),
      p(z, z, d, s),
      p(d, d, z, z),
      p(s, s, z, d),
      p(d, z, s, s),
      p(z, z, z, z),
      p(d, d, d, d),
      p(s, s, s, s),
    ],
    pinned_positions: [],
    pinned_patches: [],
    par_rotations: 6,
    par_swaps: 3,
    tier: Scraps,
    level_num: 1,
  }
}

///|
fn level_02() -> @types.Level {
  let z : @types.EdgePattern = Zigzag
  let d : @types.EdgePattern = Dots
  let s : @types.EdgePattern = Stripes
  {
    board_size: 3,
    patches: [
      p(z, z, d, d),
      p(d, d, s, z),
      p(s, s, z, d),
      p(d, z, z, d),
      p(s, d, d, z),
      p(z, s, s, d),
      p(z, d, s, z),
      p(d, s, z, d),
      p(s, z, d, s),
    ],
    pinned_positions: [],
    pinned_patches: [],
    par_rotations: 8,
    par_swaps: 4,
    tier: Scraps,
    level_num: 2,
  }
}

///|
fn level_03() -> @types.Level {
  let z : @types.EdgePattern = Zigzag
  let d : @types.EdgePattern = Dots
  let s : @types.EdgePattern = Stripes
  {
    board_size: 3,
    patches: [
      p(z, s, d, z),
      p(z, z, s, s),
      p(z, d, z, z),
      p(d, s, d, z),
      p(s, z, z, s),
      p(s, d, d, z),
      p(d, d, z, z),
      p(z, z, d, d),
      p(d, z, s, z),
    ],
    pinned_positions: [],
    pinned_patches: [],
    par_rotations: 8,
    par_swaps: 4,
    tier: Scraps,
    level_num: 3,
  }
}

///|
fn level_04() -> @types.Level {
  // Introduce 4th pattern
  let z : @types.EdgePattern = Zigzag
  let d : @types.EdgePattern = Dots
  let s : @types.EdgePattern = Stripes
  let w : @types.EdgePattern = Waves
  {
    board_size: 3,
    patches: [
      p(z, d, w, z),
      p(z, s, d, d),
      p(z, w, s, s),
      p(w, d, z, z),
      p(d, s, w, d),
      p(s, w, z, s),
      p(z, w, d, w),
      p(w, d, s, w),
      p(z, s, w, d),
    ],
    pinned_positions: [],
    pinned_patches: [],
    par_rotations: 10,
    par_swaps: 5,
    tier: Scraps,
    level_num: 4,
  }
}

///|
fn level_05() -> @types.Level {
  let z : @types.EdgePattern = Zigzag
  let d : @types.EdgePattern = Dots
  let s : @types.EdgePattern = Stripes
  let w : @types.EdgePattern = Waves
  {
    board_size: 3,
    patches: [
      p(d, w, s, z),
      p(d, z, w, w),
      p(d, s, z, z),
      p(s, w, d, z),
      p(w, z, s, w),
      p(z, s, d, z),
      p(d, w, z, w),
      p(s, z, w, w),
      p(d, z, s, z),
    ],
    pinned_positions: [],
    pinned_patches: [],
    par_rotations: 10,
    par_swaps: 5,
    tier: Scraps,
    level_num: 5,
  }
}

///|
fn level_06() -> @types.Level {
  let z : @types.EdgePattern = Zigzag
  let d : @types.EdgePattern = Dots
  let s : @types.EdgePattern = Stripes
  let w : @types.EdgePattern = Waves
  {
    board_size: 3,
    patches: [
      p(w, z, d, w),
      p(w, d, s, z),
      p(w, w, z, d),
      p(d, z, w, w),
      p(s, d, z, z),
      p(z, w, d, d),
      p(w, s, z, s),
      p(z, w, d, s),
      p(d, z, w, w),
    ],
    pinned_positions: [],
    pinned_patches: [],
    par_rotations: 12,
    par_swaps: 5,
    tier: Scraps,
    level_num: 6,
  }
}

///|
fn level_07() -> @types.Level {
  let z : @types.EdgePattern = Zigzag
  let d : @types.EdgePattern = Dots
  let s : @types.EdgePattern = Stripes
  let w : @types.EdgePattern = Waves
  {
    board_size: 3,
    patches: [
      p(z, w, s, d),
      p(z, d, w, w),
      p(z, s, d, d),
      p(s, w, z, d),
      p(w, d, s, w),
      p(d, s, z, d),
      p(z, s, w, w),
      p(s, w, d, s),
      p(z, d, w, w),
    ],
    pinned_positions: [],
    pinned_patches: [],
    par_rotations: 12,
    par_swaps: 6,
    tier: Scraps,
    level_num: 7,
  }
}

///|
fn level_08() -> @types.Level {
  let z : @types.EdgePattern = Zigzag
  let d : @types.EdgePattern = Dots
  let s : @types.EdgePattern = Stripes
  let w : @types.EdgePattern = Waves
  {
    board_size: 3,
    patches: [
      p(w, s, d, z),
      p(w, z, s, s),
      p(w, d, z, z),
      p(d, s, w, z),
      p(s, z, d, s),
      p(z, d, w, z),
      p(w, d, s, w),
      p(d, w, z, d),
      p(w, z, d, w),
    ],
    pinned_positions: [],
    pinned_patches: [],
    par_rotations: 14,
    par_swaps: 6,
    tier: Scraps,
    level_num: 8,
  }
}

// Tier 2 "Quilting" - 4x4, all patterns, pinned patches

///|
fn level_09() -> @types.Level {
  let z : @types.EdgePattern = Zigzag
  let d : @types.EdgePattern = Dots
  let s : @types.EdgePattern = Stripes
  let w : @types.EdgePattern = Waves
  let m : @types.EdgePattern = Diamonds
  let t : @types.EdgePattern = Stars
  {
    board_size: 4,
    patches: [
      p(z, d, s, z),
      p(z, s, w, d),
      p(z, w, m, s),
      p(z, z, t, w),
      p(s, d, z, z),
      p(w, s, d, d),
      p(m, w, s, s),
      p(t, z, w, w),
      p(z, m, t, d),
      p(d, t, z, m),
      p(s, z, d, t),
      p(w, d, s, z),
      p(t, m, z, m),
      p(z, t, d, t),
      p(d, z, s, z),
      p(s, d, w, d),
    ],
    pinned_positions: [0],
    pinned_patches: [pp(z, d, s, z)],
    par_rotations: 16,
    par_swaps: 8,
    tier: Quilting,
    level_num: 9,
  }
}

///|
fn level_10() -> @types.Level {
  let z : @types.EdgePattern = Zigzag
  let d : @types.EdgePattern = Dots
  let s : @types.EdgePattern = Stripes
  let w : @types.EdgePattern = Waves
  let m : @types.EdgePattern = Diamonds
  let t : @types.EdgePattern = Stars
  {
    board_size: 4,
    patches: [
      p(d, s, w, z),
      p(d, w, m, s),
      p(d, m, t, w),
      p(d, z, z, m),
      p(w, s, d, z),
      p(m, w, s, s),
      p(t, m, w, w),
      p(z, z, m, m),
      p(d, t, z, s),
      p(s, z, d, t),
      p(w, d, s, z),
      p(m, s, w, d),
      p(z, t, m, t),
      p(d, z, t, t),
      p(s, d, z, z),
      p(w, s, d, d),
    ],
    pinned_positions: [5],
    pinned_patches: [pp(m, w, s, s)],
    par_rotations: 18,
    par_swaps: 8,
    tier: Quilting,
    level_num: 10,
  }
}

///|
fn level_11() -> @types.Level {
  let z : @types.EdgePattern = Zigzag
  let d : @types.EdgePattern = Dots
  let s : @types.EdgePattern = Stripes
  let w : @types.EdgePattern = Waves
  let m : @types.EdgePattern = Diamonds
  let t : @types.EdgePattern = Stars
  {
    board_size: 4,
    patches: [
      p(t, m, s, z),
      p(t, z, w, m),
      p(t, d, m, z),
      p(t, s, z, d),
      p(s, m, d, z),
      p(w, z, s, m),
      p(m, d, w, z),
      p(z, s, m, d),
      p(d, t, z, m),
      p(s, z, d, t),
      p(w, d, s, z),
      p(m, s, w, d),
      p(z, t, m, t),
      p(d, z, t, t),
      p(s, d, z, z),
      p(w, s, d, d),
    ],
    pinned_positions: [0, 15],
    pinned_patches: [pp(t, m, s, z), pp(w, s, d, d)],
    par_rotations: 18,
    par_swaps: 8,
    tier: Quilting,
    level_num: 11,
  }
}

///|
fn level_12() -> @types.Level {
  let z : @types.EdgePattern = Zigzag
  let d : @types.EdgePattern = Dots
  let s : @types.EdgePattern = Stripes
  let w : @types.EdgePattern = Waves
  let m : @types.EdgePattern = Diamonds
  let t : @types.EdgePattern = Stars
  {
    board_size: 4,
    patches: [
      p(m, d, z, t),
      p(m, s, d, d),
      p(m, w, s, s),
      p(m, t, w, w),
      p(z, d, t, t),
      p(d, s, z, d),
      p(s, w, d, s),
      p(w, t, s, w),
      p(t, m, w, d),
      p(z, t, m, m),
      p(d, z, t, t),
      p(s, d, z, z),
      p(w, m, d, m),
      p(m, t, w, t),
      p(t, z, m, z),
      p(d, d, t, d),
    ],
    pinned_positions: [3, 12],
    pinned_patches: [pp(m, t, w, w), pp(w, m, d, m)],
    par_rotations: 20,
    par_swaps: 10,
    tier: Quilting,
    level_num: 12,
  }
}

///|
fn level_13() -> @types.Level {
  let z : @types.EdgePattern = Zigzag
  let d : @types.EdgePattern = Dots
  let s : @types.EdgePattern = Stripes
  let w : @types.EdgePattern = Waves
  let m : @types.EdgePattern = Diamonds
  let t : @types.EdgePattern = Stars
  {
    board_size: 4,
    patches: [
      p(z, s, d, m),
      p(z, w, s, s),
      p(z, m, w, w),
      p(z, t, m, m),
      p(d, s, z, m),
      p(s, w, d, s),
      p(w, m, s, w),
      p(m, t, w, m),
      p(z, d, t, s),
      p(d, s, z, d),
      p(s, w, d, s),
      p(w, m, s, w),
      p(t, d, m, d),
      p(z, s, t, d),
      p(d, w, z, s),
      p(s, m, d, w),
    ],
    pinned_positions: [5, 10],
    pinned_patches: [pp(s, w, d, s), pp(s, w, d, s)],
    par_rotations: 20,
    par_swaps: 10,
    tier: Quilting,
    level_num: 13,
  }
}

///|
fn level_14() -> @types.Level {
  let z : @types.EdgePattern = Zigzag
  let d : @types.EdgePattern = Dots
  let s : @types.EdgePattern = Stripes
  let w : @types.EdgePattern = Waves
  let m : @types.EdgePattern = Diamonds
  let t : @types.EdgePattern = Stars
  {
    board_size: 4,
    patches: [
      p(t, d, m, z),
      p(t, s, z, d),
      p(t, w, d, s),
      p(t, m, s, w),
      p(m, d, t, z),
      p(z, s, m, d),
      p(d, w, z, s),
      p(s, m, d, w),
      p(t, d, z, z),
      p(m, s, d, d),
      p(z, w, s, s),
      p(d, m, w, w),
      p(z, t, m, d),
      p(d, z, t, t),
      p(s, d, z, z),
      p(w, s, d, d),
    ],
    pinned_positions: [0, 7, 8],
    pinned_patches: [pp(t, d, m, z), pp(s, m, d, w), pp(t, d, z, z)],
    par_rotations: 22,
    par_swaps: 10,
    tier: Quilting,
    level_num: 14,
  }
}

///|
fn level_15() -> @types.Level {
  let z : @types.EdgePattern = Zigzag
  let d : @types.EdgePattern = Dots
  let s : @types.EdgePattern = Stripes
  let w : @types.EdgePattern = Waves
  let m : @types.EdgePattern = Diamonds
  let t : @types.EdgePattern = Stars
  {
    board_size: 4,
    patches: [
      p(m, t, d, z),
      p(m, z, s, t),
      p(m, d, w, z),
      p(m, s, m, d),
      p(d, t, z, z),
      p(s, z, d, t),
      p(w, d, s, z),
      p(m, s, w, d),
      p(z, w, t, t),
      p(d, m, z, w),
      p(s, t, d, m),
      p(w, z, s, t),
      p(t, w, m, w),
      p(z, m, t, w),
      p(d, t, z, m),
      p(s, z, d, t),
    ],
    pinned_positions: [4, 11],
    pinned_patches: [pp(d, t, z, z), pp(w, z, s, t)],
    par_rotations: 22,
    par_swaps: 10,
    tier: Quilting,
    level_num: 15,
  }
}

///|
fn level_16() -> @types.Level {
  let z : @types.EdgePattern = Zigzag
  let d : @types.EdgePattern = Dots
  let s : @types.EdgePattern = Stripes
  let w : @types.EdgePattern = Waves
  let m : @types.EdgePattern = Diamonds
  let t : @types.EdgePattern = Stars
  {
    board_size: 4,
    patches: [
      p(z, m, d, t),
      p(z, t, s, m),
      p(z, z, w, t),
      p(z, d, m, z),
      p(d, m, z, t),
      p(s, t, d, m),
      p(w, z, s, t),
      p(m, d, w, z),
      p(z, s, t, m),
      p(d, w, z, s),
      p(s, m, d, w),
      p(w, t, s, m),
      p(t, s, m, s),
      p(z, w, t, s),
      p(d, m, z, w),
      p(s, t, d, m),
    ],
    pinned_positions: [2, 9, 14],
    pinned_patches: [pp(z, z, w, t), pp(d, w, z, s), pp(d, m, z, w)],
    par_rotations: 24,
    par_swaps: 12,
    tier: Quilting,
    level_num: 16,
  }
}

///|
fn level_17() -> @types.Level {
  let z : @types.EdgePattern = Zigzag
  let d : @types.EdgePattern = Dots
  let s : @types.EdgePattern = Stripes
  let w : @types.EdgePattern = Waves
  let m : @types.EdgePattern = Diamonds
  let t : @types.EdgePattern = Stars
  {
    board_size: 4,
    patches: [
      p(w, d, t, m),
      p(w, s, z, d),
      p(w, w, d, s),
      p(w, m, s, w),
      p(t, d, w, m),
      p(z, s, t, d),
      p(d, w, z, s),
      p(s, m, d, w),
      p(w, t, m, d),
      p(t, z, w, t),
      p(z, d, t, z),
      p(d, s, z, d),
      p(m, t, d, t),
      p(w, z, s, t),
      p(t, d, w, z),
      p(z, s, t, d),
    ],
    pinned_positions: [0, 5, 10, 15],
    pinned_patches: [
      pp(w, d, t, m),
      pp(z, s, t, d),
      pp(z, d, t, z),
      pp(z, s, t, d),
    ],
    par_rotations: 24,
    par_swaps: 12,
    tier: Quilting,
    level_num: 17,
  }
}

// Tier 3 "Masterwork" - 4x4/5x5, wildcards, pinned, complex

///|
fn level_18() -> @types.Level {
  let z : @types.EdgePattern = Zigzag
  let d : @types.EdgePattern = Dots
  let s : @types.EdgePattern = Stripes
  let w : @types.EdgePattern = Waves
  let m : @types.EdgePattern = Diamonds
  let t : @types.EdgePattern = Stars
  {
    board_size: 4,
    patches: [
      pw(z, d, s, m, false, false, false, true),
      p(z, s, w, d),
      p(z, w, m, s),
      p(z, m, t, w),
      p(s, d, z, m),
      p(w, s, d, d),
      p(m, w, s, s),
      p(t, m, w, w),
      p(z, t, d, d),
      p(d, z, s, t),
      p(s, d, w, z),
      p(w, s, m, d),
      pw(d, t, z, t, false, true, false, false),
      p(s, z, d, t),
      p(w, d, s, z),
      p(m, s, w, d),
    ],
    pinned_positions: [6],
    pinned_patches: [pp(m, w, s, s)],
    par_rotations: 20,
    par_swaps: 10,
    tier: Masterwork,
    level_num: 18,
  }
}

///|
fn level_19() -> @types.Level {
  let z : @types.EdgePattern = Zigzag
  let d : @types.EdgePattern = Dots
  let s : @types.EdgePattern = Stripes
  let w : @types.EdgePattern = Waves
  let m : @types.EdgePattern = Diamonds
  let t : @types.EdgePattern = Stars
  {
    board_size: 4,
    patches: [
      p(t, s, m, z),
      pw(t, w, z, s, false, false, true, false),
      p(t, m, d, w),
      p(t, t, s, m),
      p(m, s, t, z),
      p(z, w, m, s),
      p(d, m, z, w),
      p(s, t, d, m),
      p(t, d, z, s),
      p(m, s, d, d),
      pw(z, w, s, s, true, false, false, false),
      p(d, m, w, w),
      p(z, d, t, d),
      p(d, s, z, d),
      p(s, w, d, s),
      p(w, m, s, w),
    ],
    pinned_positions: [3, 12],
    pinned_patches: [pp(t, t, s, m), pp(z, d, t, d)],
    par_rotations: 22,
    par_swaps: 10,
    tier: Masterwork,
    level_num: 19,
  }
}

///|
fn level_20() -> @types.Level {
  let z : @types.EdgePattern = Zigzag
  let d : @types.EdgePattern = Dots
  let s : @types.EdgePattern = Stripes
  let w : @types.EdgePattern = Waves
  let m : @types.EdgePattern = Diamonds
  let t : @types.EdgePattern = Stars
  {
    board_size: 5,
    patches: [
      p(z, d, s, z),
      p(z, s, w, d),
      p(z, w, m, s),
      p(z, m, t, w),
      p(z, z, z, m),
      p(s, d, z, z),
      p(w, s, d, d),
      p(m, w, s, s),
      p(t, m, w, w),
      p(z, z, m, m),
      p(z, t, d, d),
      p(d, z, s, t),
      p(s, d, w, z),
      p(w, s, m, d),
      p(m, w, t, s),
      p(d, t, z, t),
      p(s, z, d, t),
      p(w, d, s, z),
      p(m, s, w, d),
      p(t, w, m, s),
      p(z, m, d, t),
      p(d, t, z, m),
      p(s, z, d, t),
      p(w, d, s, z),
      p(m, s, w, d),
    ],
    pinned_positions: [0, 12, 24],
    pinned_patches: [pp(z, d, s, z), pp(s, d, w, z), pp(m, s, w, d)],
    par_rotations: 30,
    par_swaps: 15,
    tier: Masterwork,
    level_num: 20,
  }
}

///|
fn level_21() -> @types.Level {
  let z : @types.EdgePattern = Zigzag
  let d : @types.EdgePattern = Dots
  let s : @types.EdgePattern = Stripes
  let w : @types.EdgePattern = Waves
  let m : @types.EdgePattern = Diamonds
  let t : @types.EdgePattern = Stars
  {
    board_size: 5,
    patches: [
      p(m, t, d, z),
      p(m, z, s, t),
      pw(m, d, w, z, false, true, false, false),
      p(m, s, m, d),
      p(m, w, t, s),
      p(d, t, z, z),
      p(s, z, d, t),
      p(w, d, s, z),
      p(m, s, w, d),
      p(t, w, m, s),
      p(z, m, t, t),
      p(d, t, z, m),
      p(s, z, d, t),
      p(w, d, s, z),
      p(m, s, w, d),
      p(t, m, z, m),
      p(z, t, d, t),
      p(d, z, s, t),
      pw(s, d, w, z, false, false, true, false),
      p(w, s, m, d),
      p(z, d, t, m),
      p(d, s, z, d),
      p(s, w, d, s),
      p(w, m, s, w),
      p(m, t, w, m),
    ],
    pinned_positions: [6, 18],
    pinned_patches: [pp(w, d, s, z), pp(s, d, w, z)],
    par_rotations: 32,
    par_swaps: 16,
    tier: Masterwork,
    level_num: 21,
  }
}

///|
fn level_22() -> @types.Level {
  let z : @types.EdgePattern = Zigzag
  let d : @types.EdgePattern = Dots
  let s : @types.EdgePattern = Stripes
  let w : @types.EdgePattern = Waves
  let m : @types.EdgePattern = Diamonds
  let t : @types.EdgePattern = Stars
  {
    board_size: 5,
    patches: [
      p(t, s, w, z),
      pw(t, w, m, s, false, false, true, false),
      p(t, m, t, w),
      p(t, t, z, m),
      p(t, z, d, t),
      p(w, s, t, z),
      p(m, w, z, s),
      p(t, m, d, w),
      p(z, t, s, m),
      p(d, z, w, t),
      p(t, d, m, s),
      p(z, s, t, d),
      pw(d, w, z, s, true, false, false, false),
      p(s, m, d, w),
      p(w, t, s, m),
      p(m, d, t, d),
      p(t, s, z, d),
      p(z, w, d, s),
      p(d, m, s, w),
      p(s, t, w, m),
      p(t, m, w, d),
      p(z, t, m, m),
      p(d, z, t, t),
      p(s, d, z, z),
      p(w, s, d, d),
    ],
    pinned_positions: [0, 12, 24],
    pinned_patches: [
      pp(t, s, w, z),
      pp(d, w, z, s),
      pp(w, s, d, d),
    ],
    par_rotations: 34,
    par_swaps: 16,
    tier: Masterwork,
    level_num: 22,
  }
}

///|
fn level_23() -> @types.Level {
  let z : @types.EdgePattern = Zigzag
  let d : @types.EdgePattern = Dots
  let s : @types.EdgePattern = Stripes
  let w : @types.EdgePattern = Waves
  let m : @types.EdgePattern = Diamonds
  let t : @types.EdgePattern = Stars
  {
    board_size: 5,
    patches: [
      p(z, m, d, t),
      pw(z, t, s, m, false, true, false, false),
      p(z, z, w, t),
      p(z, d, m, z),
      p(z, s, t, d),
      p(d, m, z, t),
      p(s, t, d, m),
      p(w, z, s, t),
      p(m, d, w, z),
      p(t, s, m, d),
      pw(z, w, t, m, true, false, false, false),
      p(d, m, z, w),
      p(s, t, d, m),
      p(w, z, s, t),
      p(m, d, w, z),
      p(t, w, z, w),
      p(z, m, d, w),
      p(d, t, s, m),
      p(s, z, w, t),
      pw(w, d, m, z, false, false, false, true),
      p(z, s, t, w),
      p(d, w, z, s),
      p(s, m, d, w),
      p(w, t, s, m),
      p(m, z, w, t),
    ],
    pinned_positions: [4, 12, 20],
    pinned_patches: [pp(z, s, t, d), pp(s, t, d, m), pp(z, s, t, w)],
    par_rotations: 36,
    par_swaps: 18,
    tier: Masterwork,
    level_num: 23,
  }
}

///|
fn level_24() -> @types.Level {
  let z : @types.EdgePattern = Zigzag
  let d : @types.EdgePattern = Dots
  let s : @types.EdgePattern = Stripes
  let w : @types.EdgePattern = Waves
  let m : @types.EdgePattern = Diamonds
  let t : @types.EdgePattern = Stars
  {
    board_size: 5,
    patches: [
      pw(m, d, t, z, false, false, true, false),
      p(m, s, z, d),
      p(m, w, d, s),
      pw(m, m, s, w, false, true, false, false),
      p(m, t, w, m),
      p(t, d, m, z),
      p(z, s, t, d),
      p(d, w, z, s),
      p(s, m, d, w),
      p(w, t, s, m),
      p(m, z, w, d),
      p(t, d, m, z),
      p(z, s, t, d),
      p(d, w, z, s),
      pw(s, m, d, w, false, false, true, false),
      p(w, z, s, z),
      p(m, d, w, z),
      p(t, s, m, d),
      p(z, w, t, s),
      p(d, m, z, w),
      p(s, t, d, z),
      p(w, z, s, t),
      p(m, d, w, z),
      p(t, s, m, d),
      pw(z, w, t, s, true, false, false, false),
    ],
    pinned_positions: [0, 6, 18, 24],
    pinned_patches: [
      pp(m, d, t, z),
      pp(d, w, z, s),
      pp(t, s, m, d),
      pp(z, w, t, s),
    ],
    par_rotations: 38,
    par_swaps: 18,
    tier: Masterwork,
    level_num: 24,
  }
}

///|
fn level_25() -> @types.Level {
  let z : @types.EdgePattern = Zigzag
  let d : @types.EdgePattern = Dots
  let s : @types.EdgePattern = Stripes
  let w : @types.EdgePattern = Waves
  let m : @types.EdgePattern = Diamonds
  let t : @types.EdgePattern = Stars
  {
    board_size: 5,
    patches: [
      pw(t, m, d, z, false, false, false, true),
      pw(t, t, s, m, true, false, false, false),
      p(t, z, w, t),
      p(t, d, m, z),
      pw(t, s, t, d, false, true, false, false),
      p(d, m, t, z),
      p(s, t, z, m),
      p(w, z, d, t),
      p(m, d, s, z),
      p(t, s, w, d),
      p(t, d, m, m),
      p(z, s, t, d),
      pw(d, w, z, s, false, false, true, false),
      p(s, m, d, w),
      p(w, t, s, m),
      p(m, d, w, d),
      p(t, s, m, d),
      p(z, w, t, s),
      p(d, m, z, w),
      pw(s, t, d, m, false, false, false, true),
      p(w, z, s, d),
      p(m, d, w, z),
      p(t, s, m, d),
      p(z, w, t, s),
      p(d, m, z, w),
    ],
    pinned_positions: [0, 6, 12, 18, 24],
    pinned_patches: [
      pp(t, m, d, z),
      pp(w, z, d, t),
      pp(d, w, z, s),
      pp(d, m, z, w),
      pp(d, m, z, w),
    ],
    par_rotations: 40,
    par_swaps: 20,
    tier: Masterwork,
    level_num: 25,
  }
}
