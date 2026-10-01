///|
test "beam_color_add red+green=yellow" {
  let r = @types.beam_color_red()
  let g = @types.beam_color_green()
  assert_eq(@types.beam_color_add(r, g), @types.beam_color_yellow())
}

///|
test "beam_color_add red+blue=magenta" {
  let r = @types.beam_color_red()
  let b = @types.beam_color_blue()
  assert_eq(@types.beam_color_add(r, b), @types.beam_color_magenta())
}

///|
test "beam_color_add green+blue=cyan" {
  let g = @types.beam_color_green()
  let b = @types.beam_color_blue()
  assert_eq(@types.beam_color_add(g, b), @types.beam_color_cyan())
}

///|
test "beam_color_add all three=white" {
  let rg = @types.beam_color_add(@types.beam_color_red(), @types.beam_color_green())
  let result = @types.beam_color_add(rg, @types.beam_color_blue())
  assert_eq(result, @types.beam_color_white())
}

///|
test "beam_color_filter red from white" {
  let result = @types.beam_color_filter(@types.beam_color_white(), Red)
  assert_eq(result, @types.beam_color_red())
}

///|
test "beam_color_filter green from white" {
  let result = @types.beam_color_filter(@types.beam_color_white(), Green)
  assert_eq(result, @types.beam_color_green())
}

///|
test "beam_color_filter blue from white" {
  let result = @types.beam_color_filter(@types.beam_color_white(), Blue)
  assert_eq(result, @types.beam_color_blue())
}

///|
test "beam_color_filter red from cyan=black" {
  let result = @types.beam_color_filter(@types.beam_color_cyan(), Red)
  assert_true(@types.beam_color_is_black(result))
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
test "beam_color_display_name" {
  assert_eq(@types.beam_color_display_name(@types.beam_color_red()), "Red")
  assert_eq(@types.beam_color_display_name(@types.beam_color_white()), "White")
  assert_eq(@types.beam_color_display_name(@types.beam_color_cyan()), "Cyan")
}
