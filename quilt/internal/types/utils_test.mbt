///|
test "new_patch creates correct edges" {
  let p = @types.new_patch(Zigzag, Dots, Stripes, Waves)
  inspect(p.edges[0], content="Zigzag")
  inspect(p.edges[1], content="Dots")
  inspect(p.edges[2], content="Stripes")
  inspect(p.edges[3], content="Waves")
  inspect(p.pinned, content="false")
}

///|
test "new_patch_pinned is pinned" {
  let p = @types.new_patch_pinned(Zigzag, Dots, Stripes, Waves)
  inspect(p.pinned, content="true")
}

///|
test "rotate_patch rotates 90CW" {
  let p = @types.new_patch(Zigzag, Dots, Stripes, Waves)
  // Rotate CW: new[0]=old[3](W), new[1]=old[0](N), new[2]=old[1](E), new[3]=old[2](S)
  let r = @types.rotate_patch(p)
  inspect(r.edges[0], content="Waves")
  inspect(r.edges[1], content="Zigzag")
  inspect(r.edges[2], content="Dots")
  inspect(r.edges[3], content="Stripes")
}

///|
test "rotate_patch 4 times returns original" {
  let p = @types.new_patch(Zigzag, Dots, Stripes, Waves)
  let mut r = p
  for _i in 0..<4 {
    r = @types.rotate_patch(r)
  }
  inspect(r.edges[0] == p.edges[0], content="true")
  inspect(r.edges[1] == p.edges[1], content="true")
  inspect(r.edges[2] == p.edges[2], content="true")
  inspect(r.edges[3] == p.edges[3], content="true")
}

///|
test "rotate_patch preserves wildcard_edges" {
  let p = @types.new_patch_wildcard(
    Zigzag,
    Dots,
    Stripes,
    Waves,
    true,
    false,
    false,
    true,
  )
  let r = @types.rotate_patch(p)
  // Wildcard N(true) -> E, E(false) -> S, S(false) -> W, W(true) -> N
  inspect(r.wildcard_edges[0], content="true")
  inspect(r.wildcard_edges[1], content="true")
  inspect(r.wildcard_edges[2], content="false")
  inspect(r.wildcard_edges[3], content="false")
}

///|
test "edges_match same pattern" {
  inspect(@types.edges_match(Zigzag, false, Zigzag, false), content="true")
  inspect(@types.edges_match(Dots, false, Dots, false), content="true")
}

///|
test "edges_match different pattern" {
  inspect(@types.edges_match(Zigzag, false, Dots, false), content="false")
  inspect(@types.edges_match(Stripes, false, Waves, false), content="false")
}

///|
test "edges_match wildcard always matches" {
  inspect(@types.edges_match(Zigzag, true, Dots, false), content="true")
  inspect(@types.edges_match(Zigzag, false, Dots, true), content="true")
  inspect(@types.edges_match(Stars, true, Diamonds, true), content="true")
}

///|
test "new_board creates empty board" {
  let b = @types.new_board(3)
  inspect(b.size, content="3")
  inspect(b.cells.length(), content="9")
  for i in 0..<9 {
    inspect(b.cells[i], content="None")
  }
}

///|
test "board_get and board_set" {
  let b = @types.new_board(3)
  let p = @types.new_patch(Zigzag, Dots, Stripes, Waves)
  @types.board_set(b, 1, 2, Some(p))
  match @types.board_get(b, 1, 2) {
    Some(found) => {
      inspect(found.edges[0], content="Zigzag")
      inspect(found.edges[1], content="Dots")
    }
    None => inspect(false, content="true")
  }
  // Out of bounds returns None
  inspect(@types.board_get(b, -1, 0), content="None")
  inspect(@types.board_get(b, 3, 0), content="None")
}

///|
test "cell_size_for returns correct sizes" {
  inspect(@types.cell_size_for(3), content="120")
  inspect(@types.cell_size_for(4), content="100")
  inspect(@types.cell_size_for(5), content="80")
}

///|
test "pattern_color returns distinct colors" {
  let c1 = @types.pattern_color(Zigzag)
  let c2 = @types.pattern_color(Dots)
  inspect(c1 == c2, content="false")
}

///|
test "tier_levels returns correct ranges" {
  let (s1, c1) = @types.tier_levels(Scraps)
  inspect(s1, content="0")
  inspect(c1, content="8")
  let (s2, c2) = @types.tier_levels(Quilting)
  inspect(s2, content="8")
  inspect(c2, content="9")
  let (s3, c3) = @types.tier_levels(Masterwork)
  inspect(s3, content="17")
  inspect(c3, content="8")
}

///|
test "new_game initializes properly" {
  let game = @types.new_game()
  inspect(game.screen, content="Title")
  inspect(game.level_scores.length(), content="25")
  inspect(game.rotations, content="0")
  inspect(game.swaps, content="0")
  inspect(game.selected_tray, content="-1")
  inspect(game.selected_board, content="-1")
}

///|
test "rng determinism" {
  @types.seed_rng(42)
  let a = @types.rng_int(100)
  let b = @types.rng_int(100)
  @types.seed_rng(42)
  let c = @types.rng_int(100)
  let d = @types.rng_int(100)
  inspect(a == c, content="true")
  inspect(b == d, content="true")
}

///|
test "rng_int stays in range" {
  @types.seed_rng(99)
  for _i in 0..<100 {
    let v = @types.rng_int(6)
    inspect(v >= 0 && v < 6, content="true")
  }
}

///|
test "all_patterns has 6 entries" {
  inspect(@types.all_patterns().length(), content="6")
}
