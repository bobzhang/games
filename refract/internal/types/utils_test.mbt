///|
test "beam_color_add red+green=yellow" {
  let r = beam_color_red()
  let g = beam_color_green()
  let result = beam_color_add(r, g)
  assert_eq!(result, beam_color_yellow())
}

///|
test "beam_color_add red+blue=magenta" {
  let r = beam_color_red()
  let b = beam_color_blue()
  let result = beam_color_add(r, b)
  assert_eq!(result, beam_color_magenta())
}

///|
test "beam_color_add green+blue=cyan" {
  let g = beam_color_green()
  let b = beam_color_blue()
  let result = beam_color_add(g, b)
  assert_eq!(result, beam_color_cyan())
}

///|
test "beam_color_add r+g+b=white" {
  let rg = beam_color_add(beam_color_red(), beam_color_green())
  let result = beam_color_add(rg, beam_color_blue())
  assert_eq!(result, beam_color_white())
}

///|
test "beam_color_remove_channel red filter on white=cyan" {
  let white = beam_color_white()
  let result = beam_color_remove_channel(white, Red)
  assert_eq!(result, beam_color_cyan())
}

///|
test "beam_color_remove_channel green filter on white=magenta" {
  let white = beam_color_white()
  let result = beam_color_remove_channel(white, Green)
  assert_eq!(result, beam_color_magenta())
}

///|
test "beam_color_remove_channel blue filter on white=yellow" {
  let white = beam_color_white()
  let result = beam_color_remove_channel(white, Blue)
  assert_eq!(result, beam_color_yellow())
}

///|
test "beam_color_channel_count" {
  assert_eq!(beam_color_channel_count(beam_color_black()), 0)
  assert_eq!(beam_color_channel_count(beam_color_red()), 1)
  assert_eq!(beam_color_channel_count(beam_color_yellow()), 2)
  assert_eq!(beam_color_channel_count(beam_color_white()), 3)
}

///|
test "beam_color_is_black" {
  assert_true!(beam_color_is_black(beam_color_black()))
  assert_false!(beam_color_is_black(beam_color_red()))
}

///|
test "mirror_reflect slash N->E" {
  let result = mirror_reflect(N, N)
  assert_eq!(result, Some(E))
}

///|
test "mirror_reflect slash E->N" {
  let result = mirror_reflect(E, N)
  assert_eq!(result, Some(N))
}

///|
test "mirror_reflect slash S->W" {
  let result = mirror_reflect(S, N)
  assert_eq!(result, Some(W))
}

///|
test "mirror_reflect slash W->S" {
  let result = mirror_reflect(W, N)
  assert_eq!(result, Some(S))
}

///|
test "mirror_reflect backslash N->W" {
  let result = mirror_reflect(N, E)
  assert_eq!(result, Some(W))
}

///|
test "mirror_reflect backslash W->N" {
  let result = mirror_reflect(W, E)
  assert_eq!(result, Some(N))
}

///|
test "mirror_reflect backslash S->E" {
  let result = mirror_reflect(S, E)
  assert_eq!(result, Some(E))
}

///|
test "mirror_reflect backslash E->S" {
  let result = mirror_reflect(E, E)
  assert_eq!(result, Some(S))
}

///|
test "direction_opposite" {
  assert_eq!(direction_opposite(N), S)
  assert_eq!(direction_opposite(S), N)
  assert_eq!(direction_opposite(E), W)
  assert_eq!(direction_opposite(W), E)
}

///|
test "direction_cw" {
  assert_eq!(direction_cw(N), E)
  assert_eq!(direction_cw(E), S)
  assert_eq!(direction_cw(S), W)
  assert_eq!(direction_cw(W), N)
}

///|
test "beam_color_display_name" {
  assert_eq!(beam_color_display_name(beam_color_red()), "Red")
  assert_eq!(beam_color_display_name(beam_color_white()), "White")
  assert_eq!(beam_color_display_name(beam_color_cyan()), "Cyan")
}
