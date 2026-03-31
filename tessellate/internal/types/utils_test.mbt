///|
test "rotate_cell 4 rotations returns original" {
  let cell = @types.vec2i(2, 3)
  let r1 = @types.rotate_cell(cell, 1)
  let r2 = @types.rotate_cell(r1, 1)
  let r3 = @types.rotate_cell(r2, 1)
  let r4 = @types.rotate_cell(r3, 1)
  inspect(r4.x == cell.x && r4.y == cell.y, content="true")
}

///|
test "rotate_cell single 90 CW" {
  let cell = @types.vec2i(1, 0)
  let r = @types.rotate_cell(cell, 1)
  // (1,0) rotated 90 CW => (0,1)
  inspect(r.x, content="0")
  inspect(r.y, content="1")
}

///|
test "flip_cell double flip returns original" {
  let cell = @types.vec2i(3, 5)
  let f1 = @types.flip_cell(cell)
  let f2 = @types.flip_cell(f1)
  inspect(f2.x == cell.x && f2.y == cell.y, content="true")
}

///|
test "flip_cell mirrors x" {
  let cell = @types.vec2i(2, 3)
  let f = @types.flip_cell(cell)
  inspect(f.x, content="-2")
  inspect(f.y, content="3")
}

///|
test "transform_cells preserves count" {
  let cells = [@types.vec2i(0, 0), @types.vec2i(1, 0), @types.vec2i(0, 1)]
  let transformed = @types.transform_cells(cells, 2, true)
  inspect(transformed.length(), content="3")
}

///|
test "piece_bounds correct" {
  let cells = [
    @types.vec2i(-1, 0),
    @types.vec2i(0, 0),
    @types.vec2i(1, 0),
    @types.vec2i(0, 1),
  ]
  let (min_x, min_y, max_x, max_y) = @types.piece_bounds(cells)
  inspect(min_x, content="-1")
  inspect(min_y, content="0")
  inspect(max_x, content="1")
  inspect(max_y, content="1")
}

///|
test "rect_region creates correct cell count" {
  let region = @types.rect_region(0, 0, 4, 3)
  let count = @types.count_active_cells(region)
  inspect(count, content="12")
}

///|
test "full_region all cells active" {
  let region = @types.full_region(3, 3)
  let count = @types.count_active_cells(region)
  inspect(count, content="9")
}

///|
test "new_region selective cells" {
  let cells = [@types.vec2i(0, 0), @types.vec2i(1, 1), @types.vec2i(2, 2)]
  let region = @types.new_region(3, 3, cells)
  let count = @types.count_active_cells(region)
  inspect(count, content="3")
  inspect(region.active[0][0], content="true")
  inspect(region.active[0][1], content="false")
  inspect(region.active[1][1], content="true")
}

///|
test "standard polyomino cell counts" {
  let m = @types.monomino(@raylib.white)
  inspect(m.cells.length(), content="1")
  let d = @types.domino_h(@raylib.white)
  inspect(d.cells.length(), content="2")
  let t3i = @types.triomino_i(@raylib.white)
  inspect(t3i.cells.length(), content="3")
  let t3l = @types.triomino_l(@raylib.white)
  inspect(t3l.cells.length(), content="3")
  let ti = @types.tetromino_i(@raylib.white)
  inspect(ti.cells.length(), content="4")
  let to = @types.tetromino_o(@raylib.white)
  inspect(to.cells.length(), content="4")
  let tt = @types.tetromino_t(@raylib.white)
  inspect(tt.cells.length(), content="4")
  let ts = @types.tetromino_s(@raylib.white)
  inspect(ts.cells.length(), content="4")
  let tz = @types.tetromino_z(@raylib.white)
  inspect(tz.cells.length(), content="4")
  let tl = @types.tetromino_l(@raylib.white)
  inspect(tl.cells.length(), content="4")
  let tj = @types.tetromino_j(@raylib.white)
  inspect(tj.cells.length(), content="4")
}

///|
test "pentomino cell counts" {
  let pf = @types.pento_f(@raylib.white)
  inspect(pf.cells.length(), content="5")
  let pi = @types.pento_i(@raylib.white)
  inspect(pi.cells.length(), content="5")
  let pl = @types.pento_l(@raylib.white)
  inspect(pl.cells.length(), content="5")
  let pn = @types.pento_n(@raylib.white)
  inspect(pn.cells.length(), content="5")
  let pp = @types.pento_p(@raylib.white)
  inspect(pp.cells.length(), content="5")
  let pt = @types.pento_t(@raylib.white)
  inspect(pt.cells.length(), content="5")
  let pu = @types.pento_u(@raylib.white)
  inspect(pu.cells.length(), content="5")
  let pv = @types.pento_v(@raylib.white)
  inspect(pv.cells.length(), content="5")
  let pw = @types.pento_w(@raylib.white)
  inspect(pw.cells.length(), content="5")
  let px = @types.pento_x(@raylib.white)
  inspect(px.cells.length(), content="5")
  let py = @types.pento_y(@raylib.white)
  inspect(py.cells.length(), content="5")
  let pz = @types.pento_z(@raylib.white)
  inspect(pz.cells.length(), content="5")
}

///|
test "new_game initial state" {
  let game = @types.new_game()
  inspect(game.screen, content="Title")
  inspect(game.selected_piece, content="-1")
  inspect(game.rotation, content="0")
  inspect(game.flipped, content="false")
  inspect(game.placed_pieces.length(), content="0")
  inspect(game.level_scores.length(), content="30")
  inspect(game.timer, content="0")
}

///|
test "tier_index and tier_from_index roundtrip" {
  inspect(@types.tier_index(Squares), content="0")
  inspect(@types.tier_index(Shapes), content="1")
  inspect(@types.tier_index(Art), content="2")
  inspect(@types.tier_from_index(0), content="Squares")
  inspect(@types.tier_from_index(1), content="Shapes")
  inspect(@types.tier_from_index(2), content="Art")
}

///|
test "level_index calculation" {
  inspect(@types.level_index(Squares, 0), content="0")
  inspect(@types.level_index(Squares, 9), content="9")
  inspect(@types.level_index(Shapes, 0), content="10")
  inspect(@types.level_index(Art, 5), content="25")
}

///|
test "reset_level clears state" {
  let game = @types.new_game()
  game.timer = 42.0
  game.rotation_count = 5
  game.selected_piece = 3
  @types.reset_level(game)
  inspect(game.timer, content="0")
  inspect(game.rotation_count, content="0")
  inspect(game.selected_piece, content="-1")
  inspect(game.placed_pieces.length(), content="0")
}
