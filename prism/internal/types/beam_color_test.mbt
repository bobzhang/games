///|
test "beam_color_add red+green=yellow" {
  let r = beam_color_red()
  let g = beam_color_green()
  assert_eq(beam_color_add(r, g), beam_color_yellow())
}

///|
test "beam_color_add red+blue=magenta" {
  let r = beam_color_red()
  let b = beam_color_blue()
  assert_eq(beam_color_add(r, b), beam_color_magenta())
}

///|
test "beam_color_add green+blue=cyan" {
  let g = beam_color_green()
  let b = beam_color_blue()
  assert_eq(beam_color_add(g, b), beam_color_cyan())
}

///|
test "beam_color_add all three=white" {
  let rg = beam_color_add(beam_color_red(), beam_color_green())
  let result = beam_color_add(rg, beam_color_blue())
  assert_eq(result, beam_color_white())
}

///|
test "beam_color_filter red from white" {
  let result = beam_color_filter(beam_color_white(), Red)
  assert_eq(result, beam_color_red())
}

///|
test "beam_color_filter green from white" {
  let result = beam_color_filter(beam_color_white(), Green)
  assert_eq(result, beam_color_green())
}

///|
test "beam_color_filter blue from white" {
  let result = beam_color_filter(beam_color_white(), Blue)
  assert_eq(result, beam_color_blue())
}

///|
test "beam_color_filter red from cyan=black" {
  let result = beam_color_filter(beam_color_cyan(), Red)
  assert_true(beam_color_is_black(result))
}

///|
test "beam_color_channel_count" {
  assert_eq(beam_color_channel_count(beam_color_black()), 0)
  assert_eq(beam_color_channel_count(beam_color_red()), 1)
  assert_eq(beam_color_channel_count(beam_color_yellow()), 2)
  assert_eq(beam_color_channel_count(beam_color_white()), 3)
}

///|
test "beam_color_is_black" {
  assert_true(beam_color_is_black(beam_color_black()))
  assert_false(beam_color_is_black(beam_color_red()))
}

///|
test "beam_color_display_name" {
  assert_eq(beam_color_display_name(beam_color_red()), "Red")
  assert_eq(beam_color_display_name(beam_color_white()), "White")
  assert_eq(beam_color_display_name(beam_color_cyan()), "Cyan")
}
