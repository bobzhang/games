///|
test "symbol_index round-trip" {
  let symbols = @types.all_symbols()
  for i in 0..<symbols.length() {
    let idx = @types.symbol_index(symbols[i])
    inspect(idx, content=i.to_string())
    let sym = @types.symbol_from_index(idx)
    inspect(sym == symbols[i], content="true")
  }
}

///|
test "letter_from_index and letter_index" {
  for i in 0..<20 {
    let letter = @types.letter_from_index(i)
    let idx = @types.letter_index(letter)
    inspect(idx, content=i.to_string())
  }
  inspect(@types.letter_from_index(99), content="?")
  inspect(@types.letter_index("Z"), content="-1")
}

///|
test "new_mapping all unmapped" {
  let m = @types.new_mapping()
  for i in 0..<20 {
    inspect(m.values[i], content="-1")
  }
}

///|
test "mapping set and get" {
  let m = @types.new_mapping()
  @types.mapping_set(m, Circle, 0)
  inspect(@types.mapping_get(m, Circle), content="0")
  inspect(@types.mapping_get(m, Triangle), content="-1")
  @types.mapping_set(m, Triangle, 5)
  inspect(@types.mapping_get(m, Triangle), content="5")
}

///|
test "mapping clear" {
  let m = @types.new_mapping()
  @types.mapping_set(m, Star, 4)
  inspect(@types.mapping_get(m, Star), content="4")
  @types.mapping_clear(m, Star)
  inspect(@types.mapping_get(m, Star), content="-1")
}

///|
test "copy_mapping is independent" {
  let m = @types.new_mapping()
  @types.mapping_set(m, Circle, 0)
  let m2 = @types.copy_mapping(m)
  @types.mapping_set(m2, Circle, 5)
  inspect(@types.mapping_get(m, Circle), content="0")
  inspect(@types.mapping_get(m2, Circle), content="5")
}

///|
test "is_letter_used" {
  let m = @types.new_mapping()
  inspect(@types.is_letter_used(m, 0), content="false")
  @types.mapping_set(m, Circle, 0)
  inspect(@types.is_letter_used(m, 0), content="true")
  inspect(@types.is_letter_used(m, 1), content="false")
}

///|
test "find_symbol_for_letter" {
  let m = @types.new_mapping()
  @types.mapping_set(m, Diamond, 3)
  inspect(@types.find_symbol_for_letter(m, 3), content="3")
  inspect(@types.find_symbol_for_letter(m, 0), content="-1")
}

///|
test "decode_inscription partial" {
  let inscription = @types.new_inscription([
    @types.make_symbol(Circle),
    @types.make_symbol(Triangle),
    @types.make_space(),
    @types.make_symbol(Square),
  ])
  let m = @types.new_mapping()
  @types.mapping_set(m, Circle, 0) // A
  // Triangle unmapped, Square unmapped
  let decoded = @types.decode_inscription(inscription, m)
  inspect(decoded, content="A_ _")
}

///|
test "decode_inscription full" {
  let inscription = @types.new_inscription([
    @types.make_symbol(Circle),
    @types.make_symbol(Triangle),
    @types.make_space(),
    @types.make_symbol(Square),
  ])
  let m = @types.new_mapping()
  @types.mapping_set(m, Circle, 0) // A
  @types.mapping_set(m, Triangle, 1) // B
  @types.mapping_set(m, Square, 2) // C
  let decoded = @types.decode_inscription(inscription, m)
  inspect(decoded, content="AB C")
}

///|
test "get_inscription_symbols_unique" {
  let inscription = @types.new_inscription([
    @types.make_symbol(Circle),
    @types.make_symbol(Triangle),
    @types.make_space(),
    @types.make_symbol(Circle),
    @types.make_symbol(Star),
  ])
  let unique = @types.get_inscription_symbols_unique(inscription)
  inspect(unique.length(), content="3")
}

///|
test "new_game initial state" {
  let game = @types.new_game()
  inspect(game.screen, content="Title")
  inspect(game.scores.length(), content="20")
  inspect(game.guesses, content="0")
  inspect(game.wrong_count, content="0")
}

///|
test "tier operations" {
  inspect(@types.tier_tablet_offset(Fragments), content="0")
  inspect(@types.tier_tablet_offset(Scrolls), content="7")
  inspect(@types.tier_tablet_offset(Monuments), content="14")
  inspect(@types.tier_tablet_count(Fragments), content="7")
  inspect(@types.tier_tablet_count(Scrolls), content="7")
  inspect(@types.tier_tablet_count(Monuments), content="6")
}

///|
test "is_given_symbol" {
  let m = @types.new_mapping()
  @types.mapping_set(m, Circle, 0)
  let solution = @types.new_mapping()
  @types.mapping_set(solution, Circle, 0)
  @types.mapping_set(solution, Triangle, 1)
  let tablet : @types.Tablet = {
    inscription: @types.new_inscription([]),
    solution_mapping: solution,
    given_mapping: m,
    theme_name: "Test",
    par_guesses: 5,
    tier: Fragments,
  }
  inspect(@types.is_given_symbol(tablet, Circle), content="true")
  inspect(@types.is_given_symbol(tablet, Triangle), content="false")
}

///|
test "count_symbol_frequency" {
  let inscription = @types.new_inscription([
    @types.make_symbol(Circle),
    @types.make_symbol(Triangle),
    @types.make_space(),
    @types.make_symbol(Circle),
    @types.make_symbol(Circle),
    @types.make_symbol(Star),
  ])
  inspect(@types.count_symbol_frequency(inscription, Circle), content="3")
  inspect(@types.count_symbol_frequency(inscription, Triangle), content="1")
  inspect(@types.count_symbol_frequency(inscription, Star), content="1")
  inspect(@types.count_symbol_frequency(inscription, Diamond), content="0")
}

///|
test "compute_symbol_positions basic" {
  let inscription = @types.new_inscription([
    @types.make_symbol(Circle),
    @types.make_symbol(Triangle),
    @types.make_space(),
    @types.make_symbol(Square),
  ])
  let positions = @types.compute_symbol_positions(
    inscription, 100, // base_x
     200, // base_y
     500, // max_width
     90, // line_height
     56, // spacing
     30, // gap
  )
  inspect(positions.length(), content="4")
  // First symbol at base
  inspect(positions[0].x, content="100")
  inspect(positions[0].y, content="200")
  // Second symbol offset by spacing
  inspect(positions[1].x, content="156")
  inspect(positions[1].y, content="200")
  // Third is a space
  debug_inspect(positions[2].symbol, content="None")
  // Fourth symbol after space gap
  inspect(positions[3].x, content="242")
  inspect(positions[3].y, content="200")
}

///|
test "compute_symbol_positions wraps at boundary" {
  // max_width=120, spacing=56 → fits 2 symbols per row (0, 56; 112 > 120-56=64 → wraps)
  let inscription = @types.new_inscription([
    @types.make_symbol(Circle),
    @types.make_symbol(Triangle),
    @types.make_symbol(Square),
  ])
  let positions = @types.compute_symbol_positions(
    inscription, 10, // base_x
     20, // base_y
     120, // max_width
     90, // line_height
     56, // spacing
     30, // gap
  )
  inspect(positions.length(), content="3")
  // First two fit on row 0
  inspect(positions[0].y, content="20")
  inspect(positions[1].y, content="20")
  // Third wraps to next row
  inspect(positions[2].x, content="10")
  inspect(positions[2].y, content="110")
}

///|
test "compute_symbol_positions wraps after space" {
  // Space pushes cx past boundary → next symbol on new line
  let inscription = @types.new_inscription([
    @types.make_symbol(Circle),
    @types.make_space(),
    @types.make_symbol(Triangle),
  ])
  let positions = @types.compute_symbol_positions(
    inscription, 10, // base_x
     20, // base_y
     100, // max_width — tight: 56 + 30 = 86 cx after space; 86 > 100-56=44 → wraps
     90, // line_height
     56, // spacing
     30, // gap
  )
  inspect(positions.length(), content="3")
  inspect(positions[0].y, content="20")
  // Triangle should be on next row since space pushed past boundary
  inspect(positions[2].x, content="10")
  inspect(positions[2].y, content="110")
}

///|
test "palette_button_pos" {
  // 5 cols, gap=6, btn_size=44, label_offset=28
  let (x0, y0) = @types.palette_button_pos(0, 100, 50, 44, 6, 5, 28)
  inspect(x0, content="100")
  inspect(y0, content="78") // 50 + 28
  let (x1, y1) = @types.palette_button_pos(1, 100, 50, 44, 6, 5, 28)
  inspect(x1, content="150") // 100 + 1*(44+6)
  inspect(y1, content="78")
  let (x5, y5) = @types.palette_button_pos(5, 100, 50, 44, 6, 5, 28)
  inspect(x5, content="100") // wraps to second row
  inspect(y5, content="128") // 78 + 44 + 6
}

///|
test "sinf and cosf" {
  inspect(@types.sinf(0.0), content="0")
  inspect(@types.cosf(0.0), content="1")
}

///|
test "absf" {
  inspect(@types.absf(5.0), content="5")
  inspect(@types.absf(-5.0), content="5")
}

///|
test "clampf" {
  inspect(@types.clampf(0.5, 0.0, 1.0), content="0.5")
  inspect(@types.clampf(-1.0, 0.0, 1.0), content="0")
  inspect(@types.clampf(2.0, 0.0, 1.0), content="1")
}
