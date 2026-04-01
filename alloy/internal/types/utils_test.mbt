///|
test "star_count" {
  inspect(@types.star_count(Zero), content="0")
  inspect(@types.star_count(One), content="1")
  inspect(@types.star_count(Two), content="2")
  inspect(@types.star_count(Three), content="3")
}

///|
test "metal_props iron" {
  let props = @types.metal_props(Iron)
  inspect(props.hardness, content="80")
  inspect(props.flexibility, content="20")
  inspect(props.conductivity, content="30")
}

///|
test "metal_props copper" {
  let props = @types.metal_props(Copper)
  inspect(props.hardness, content="25")
  inspect(props.flexibility, content="50")
  inspect(props.conductivity, content="90")
}

///|
test "metal_props tin" {
  let props = @types.metal_props(Tin)
  inspect(props.hardness, content="15")
  inspect(props.flexibility, content="85")
  inspect(props.conductivity, content="40")
}

///|
test "metal_props gold" {
  let props = @types.metal_props(Gold)
  inspect(props.hardness, content="10")
  inspect(props.flexibility, content="60")
  inspect(props.conductivity, content="95")
}

///|
test "metal_props carbon" {
  let props = @types.metal_props(Carbon)
  inspect(props.hardness, content="95")
  inspect(props.flexibility, content="5")
  inspect(props.conductivity, content="10")
}

///|
test "metal_props zinc" {
  let props = @types.metal_props(Zinc)
  inspect(props.hardness, content="35")
  inspect(props.flexibility, content="45")
  inspect(props.conductivity, content="55")
}

///|
test "metal_name" {
  inspect(@types.metal_name(Iron), content="Iron")
  inspect(@types.metal_name(Copper), content="Copper")
  inspect(@types.metal_name(Tin), content="Tin")
  inspect(@types.metal_name(Gold), content="Gold")
  inspect(@types.metal_name(Carbon), content="Carbon")
  inspect(@types.metal_name(Zinc), content="Zinc")
}

///|
test "temp_name" {
  inspect(@types.temp_name(Low), content="Low")
  inspect(@types.temp_name(Medium), content="Medium")
  inspect(@types.temp_name(High), content="High")
}

///|
test "clampf" {
  inspect(@types.clampf(50.0, 0.0, 100.0), content="50")
  inspect(@types.clampf(-5.0, 0.0, 100.0), content="0")
  inspect(@types.clampf(120.0, 0.0, 100.0), content="100")
}

///|
test "absf" {
  inspect(@types.absf(5.0), content="5")
  inspect(@types.absf(-5.0), content="5")
  inspect(@types.absf(0.0), content="0")
}

///|
test "minf and maxf" {
  inspect(@types.minf(3.0, 7.0), content="3")
  inspect(@types.maxf(3.0, 7.0), content="7")
}

///|
test "new_game initializes correctly" {
  let game = @types.new_game()
  inspect(game.screen, content="Title")
  inspect(game.current_level, content="0")
  inspect(game.crucible.length(), content="0")
  inspect(game.temperature, content="Medium")
  inspect(game.level_progress.length(), content="20")
  inspect(game.total_stars, content="0")
}

///|
test "add_ingredient new metal" {
  let game = @types.new_game()
  @types.add_ingredient(game, Iron)
  inspect(game.crucible.length(), content="1")
  inspect(game.crucible[0].metal, content="Iron")
  inspect(game.crucible[0].amount, content="1")
}

///|
test "add_ingredient same metal increases amount" {
  let game = @types.new_game()
  @types.add_ingredient(game, Iron)
  @types.add_ingredient(game, Iron)
  inspect(game.crucible.length(), content="1")
  inspect(game.crucible[0].amount, content="2")
}

///|
test "add_ingredient different metals" {
  let game = @types.new_game()
  @types.add_ingredient(game, Iron)
  @types.add_ingredient(game, Copper)
  inspect(game.crucible.length(), content="2")
}

///|
test "remove_ingredient decreases amount" {
  let game = @types.new_game()
  @types.add_ingredient(game, Iron)
  @types.add_ingredient(game, Iron)
  @types.remove_ingredient(game, 0)
  inspect(game.crucible.length(), content="1")
  inspect(game.crucible[0].amount, content="1")
}

///|
test "remove_ingredient removes slot when amount is 1" {
  let game = @types.new_game()
  @types.add_ingredient(game, Iron)
  @types.remove_ingredient(game, 0)
  inspect(game.crucible.length(), content="0")
}

///|
test "total_ingredient_count" {
  let game = @types.new_game()
  @types.add_ingredient(game, Iron)
  @types.add_ingredient(game, Iron)
  @types.add_ingredient(game, Copper)
  inspect(@types.total_ingredient_count(game), content="3")
}

///|
test "clear_crucible" {
  let game = @types.new_game()
  @types.add_ingredient(game, Iron)
  @types.add_ingredient(game, Copper)
  @types.clear_crucible(game)
  inspect(game.crucible.length(), content="0")
}

///|
test "is_level_unlocked first level always true" {
  let game = @types.new_game()
  inspect(@types.is_level_unlocked(game, 0), content="true")
  inspect(@types.is_level_unlocked(game, 1), content="false")
}

///|
test "is_level_unlocked after completion" {
  let game = @types.new_game()
  game.level_progress[0].completed = true
  inspect(@types.is_level_unlocked(game, 1), content="true")
}
