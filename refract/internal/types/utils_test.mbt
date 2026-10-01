///|
test "beam_color_add red+green=yellow" {
  let r = @types.beam_color_red()
  let g = @types.beam_color_green()
  let result = @types.beam_color_add(r, g)
  assert_eq(result, @types.beam_color_yellow())
}

///|
test "beam_color_add red+blue=magenta" {
  let r = @types.beam_color_red()
  let b = @types.beam_color_blue()
  let result = @types.beam_color_add(r, b)
  assert_eq(result, @types.beam_color_magenta())
}

///|
test "beam_color_add green+blue=cyan" {
  let g = @types.beam_color_green()
  let b = @types.beam_color_blue()
  let result = @types.beam_color_add(g, b)
  assert_eq(result, @types.beam_color_cyan())
}

///|
test "beam_color_add r+g+b=white" {
  let rg = @types.beam_color_add(
    @types.beam_color_red(),
    @types.beam_color_green(),
  )
  let result = @types.beam_color_add(rg, @types.beam_color_blue())
  assert_eq(result, @types.beam_color_white())
}

///|
test "beam_color_remove_channel red filter on white=cyan" {
  let white = @types.beam_color_white()
  let result = @types.beam_color_remove_channel(white, Red)
  assert_eq(result, @types.beam_color_cyan())
}

///|
test "beam_color_remove_channel green filter on white=magenta" {
  let white = @types.beam_color_white()
  let result = @types.beam_color_remove_channel(white, Green)
  assert_eq(result, @types.beam_color_magenta())
}

///|
test "beam_color_remove_channel blue filter on white=yellow" {
  let white = @types.beam_color_white()
  let result = @types.beam_color_remove_channel(white, Blue)
  assert_eq(result, @types.beam_color_yellow())
}

///|
test "beam_color_channel_count" {
  assert_eq(@types.beam_color_channel_count(@types.beam_color_black()), 0)
  assert_eq(@types.beam_color_channel_count(@types.beam_color_red()), 1)
  assert_eq(@types.beam_color_channel_count(@types.beam_color_yellow()), 2)
  assert_eq(@types.beam_color_channel_count(@types.beam_color_white()), 3)
}

///|
test "beam_color_is_black" {
  assert_true(@types.beam_color_is_black(@types.beam_color_black()))
  assert_false(@types.beam_color_is_black(@types.beam_color_red()))
}

///|
test "mirror_reflect slash N->E" {
  let result = @types.mirror_reflect(N, N)
  assert_eq(result, Some(E))
}

///|
test "mirror_reflect slash E->N" {
  let result = @types.mirror_reflect(E, N)
  assert_eq(result, Some(N))
}

///|
test "mirror_reflect slash S->W" {
  let result = @types.mirror_reflect(S, N)
  assert_eq(result, Some(W))
}

///|
test "mirror_reflect slash W->S" {
  let result = @types.mirror_reflect(W, N)
  assert_eq(result, Some(S))
}

///|
test "mirror_reflect backslash N->W" {
  let result = @types.mirror_reflect(N, E)
  assert_eq(result, Some(W))
}

///|
test "mirror_reflect backslash W->N" {
  let result = @types.mirror_reflect(W, E)
  assert_eq(result, Some(N))
}

///|
test "mirror_reflect backslash S->E" {
  let result = @types.mirror_reflect(S, E)
  assert_eq(result, Some(E))
}

///|
test "mirror_reflect backslash E->S" {
  let result = @types.mirror_reflect(E, E)
  assert_eq(result, Some(S))
}

///|
test "direction_opposite" {
  assert_eq(@types.direction_opposite(N), S)
  assert_eq(@types.direction_opposite(S), N)
  assert_eq(@types.direction_opposite(E), W)
  assert_eq(@types.direction_opposite(W), E)
}

///|
test "direction_cw" {
  assert_eq(@types.direction_cw(N), E)
  assert_eq(@types.direction_cw(E), S)
  assert_eq(@types.direction_cw(S), W)
  assert_eq(@types.direction_cw(W), N)
}

///|
test "beam_color_display_name" {
  assert_eq(@types.beam_color_display_name(@types.beam_color_red()), "Red")
  assert_eq(@types.beam_color_display_name(@types.beam_color_white()), "White")
  assert_eq(@types.beam_color_display_name(@types.beam_color_cyan()), "Cyan")
}
