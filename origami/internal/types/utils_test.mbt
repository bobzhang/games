///|
test "new_cell constructor" {
  let c = @types.new_cell(true, 3)
  inspect(c.has_paper, content="true")
  inspect(c.layers, content="3")
}

///|
test "new_cell no paper" {
  let c = @types.new_cell(false, 0)
  inspect(c.has_paper, content="false")
  inspect(c.layers, content="0")
}

///|
test "new_paper creates empty grid" {
  let p = @types.new_paper(4, 3)
  inspect(p.width, content="4")
  inspect(p.height, content="3")
  inspect(p.cells.length(), content="12")
  let c = @types.get_cell(p, 0, 0)
  inspect(c.has_paper, content="false")
  inspect(c.layers, content="0")
}

///|
test "full_paper creates all paper cells" {
  let p = @types.full_paper(3, 2)
  inspect(p.cells.length(), content="6")
  let c = @types.get_cell(p, 1, 1)
  inspect(c.has_paper, content="true")
  inspect(c.layers, content="1")
}

///|
test "get_cell out of bounds returns empty" {
  let p = @types.new_paper(4, 4)
  let c = @types.get_cell(p, -1, 0)
  inspect(c.has_paper, content="false")
  let c2 = @types.get_cell(p, 4, 0)
  inspect(c2.has_paper, content="false")
  let c3 = @types.get_cell(p, 0, -1)
  inspect(c3.has_paper, content="false")
  let c4 = @types.get_cell(p, 0, 4)
  inspect(c4.has_paper, content="false")
}

///|
test "set_cell and get_cell round trip" {
  let p = @types.new_paper(4, 4)
  @types.set_cell(p, 2, 3, true, 5)
  let c = @types.get_cell(p, 2, 3)
  inspect(c.has_paper, content="true")
  inspect(c.layers, content="5")
}

///|
test "set_cell out of bounds is noop" {
  let p = @types.new_paper(4, 4)
  @types.set_cell(p, -1, 0, true, 1) // Should not crash
  @types.set_cell(p, 4, 0, true, 1) // Should not crash
  inspect(p.cells.length(), content="16")
}

///|
test "clone_paper is independent copy" {
  let p = @types.full_paper(3, 3)
  let c = @types.clone_paper(p)
  @types.set_cell(c, 0, 0, false, 0)
  // Original should not be affected
  let orig = @types.get_cell(p, 0, 0)
  inspect(orig.has_paper, content="true")
  inspect(orig.layers, content="1")
  let cloned = @types.get_cell(c, 0, 0)
  inspect(cloned.has_paper, content="false")
}

///|
test "paper_matches_silhouette identical papers" {
  let a = @types.full_paper(4, 4)
  let b = @types.full_paper(4, 4)
  inspect(@types.paper_matches_silhouette(a, b), content="true")
}

///|
test "paper_matches_silhouette different papers" {
  let a = @types.full_paper(4, 4)
  let b = @types.new_paper(4, 4)
  inspect(@types.paper_matches_silhouette(a, b), content="false")
}

///|
test "paper_matches_silhouette different sizes" {
  let a = @types.full_paper(3, 3)
  let b = @types.full_paper(4, 4)
  inspect(@types.paper_matches_silhouette(a, b), content="false")
}

///|
test "check_layer_requirements all satisfied" {
  let p = @types.full_paper(4, 4)
  @types.set_cell(p, 1, 1, true, 3)
  let checks : Array[@types.LayerCheck] = [
    { pos: { x: 0, y: 0, }, required_layers: 1, },
    { pos: { x: 1, y: 1, }, required_layers: 3, },
  ]
  inspect(@types.check_layer_requirements(p, checks), content="true")
}

///|
test "check_layer_requirements fails on wrong layer count" {
  let p = @types.full_paper(4, 4)
  let checks : Array[@types.LayerCheck] = [
    { pos: { x: 0, y: 0, }, required_layers: 2, },
  ]
  inspect(@types.check_layer_requirements(p, checks), content="false")
}

///|
test "check_layer_requirements fails on empty cell" {
  let p = @types.new_paper(4, 4)
  let checks : Array[@types.LayerCheck] = [
    { pos: { x: 0, y: 0, }, required_layers: 1, },
  ]
  inspect(@types.check_layer_requirements(p, checks), content="false")
}

///|
test "single_layer_check_ok" {
  let p = @types.full_paper(4, 4)
  let ok : @types.LayerCheck = { pos: { x: 0, y: 0, }, required_layers: 1, }
  inspect(@types.single_layer_check_ok(p, ok), content="true")
  let fail : @types.LayerCheck = { pos: { x: 0, y: 0, }, required_layers: 2, }
  inspect(@types.single_layer_check_ok(p, fail), content="false")
}

///|
test "count_paper_cells" {
  let p = @types.new_paper(4, 4)
  @types.set_cell(p, 0, 0, true, 1)
  @types.set_cell(p, 1, 1, true, 2)
  @types.set_cell(p, 2, 2, true, 1)
  inspect(@types.count_paper_cells(p), content="3")
}

///|
test "count_paper_cells on full paper" {
  let p = @types.full_paper(3, 3)
  inspect(@types.count_paper_cells(p), content="9")
}

///|
test "max_layers" {
  let p = @types.new_paper(4, 4)
  @types.set_cell(p, 0, 0, true, 1)
  @types.set_cell(p, 1, 1, true, 4)
  @types.set_cell(p, 2, 2, true, 2)
  inspect(@types.max_layers(p), content="4")
}

///|
test "max_layers on empty paper" {
  let p = @types.new_paper(4, 4)
  inspect(@types.max_layers(p), content="0")
}

///|
test "make_rect_paper" {
  let p = @types.make_rect_paper(8, 8, 2, 2, 5, 5)
  // Cells inside the rect should have paper
  let inside = @types.get_cell(p, 3, 3)
  inspect(inside.has_paper, content="true")
  inspect(inside.layers, content="1")
  // Cells outside should not
  let outside = @types.get_cell(p, 0, 0)
  inspect(outside.has_paper, content="false")
  let outside2 = @types.get_cell(p, 5, 5)
  inspect(outside2.has_paper, content="false")
}

///|
test "tier_name values" {
  inspect(@types.tier_name(Folds), content="Folds")
  inspect(@types.tier_name(Layers), content="Layers")
  inspect(@types.tier_name(Craft), content="Craft")
}

///|
test "tier_level_count values" {
  inspect(@types.tier_level_count(Folds), content="8")
  inspect(@types.tier_level_count(Layers), content="9")
  inspect(@types.tier_level_count(Craft), content="8")
}

///|
test "tier_start_index values" {
  inspect(@types.tier_start_index(Folds), content="0")
  inspect(@types.tier_start_index(Layers), content="8")
  inspect(@types.tier_start_index(Craft), content="17")
}

///|
test "new_level_score defaults" {
  let s = @types.new_level_score()
  inspect(s.completed, content="false")
  inspect(s.stars, content="Zero")
  inspect(s.folds_used, content="0")
}

///|
test "mini and maxi" {
  inspect(@types.mini(2, 8), content="2")
  inspect(@types.mini(8, 2), content="2")
  inspect(@types.maxi(2, 8), content="8")
  inspect(@types.maxi(8, 2), content="8")
}

///|
test "absi" {
  inspect(@types.absi(-7), content="7")
  inspect(@types.absi(7), content="7")
  inspect(@types.absi(0), content="0")
}

///|
test "clamp_int" {
  inspect(@types.clamp_int(5, 0, 10), content="5")
  inspect(@types.clamp_int(-3, 0, 10), content="0")
  inspect(@types.clamp_int(15, 0, 10), content="10")
}

///|
test "new_game initializes properly" {
  let g = @types.new_game()
  inspect(g.screen, content="Title")
  inspect(g.current_tier, content="Folds")
  inspect(g.scores.length(), content="25")
  inspect(g.fold_line, content="4")
  inspect(g.fold_dir, content="Left")
  inspect(g.play_state, content="Selecting")
  inspect(g.show_target, content="false")
}
