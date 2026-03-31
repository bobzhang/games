///|
test "is_prime basic" {
  inspect(@types.is_prime(0), content="false")
  inspect(@types.is_prime(1), content="false")
  inspect(@types.is_prime(2), content="true")
  inspect(@types.is_prime(3), content="true")
  inspect(@types.is_prime(4), content="false")
  inspect(@types.is_prime(5), content="true")
  inspect(@types.is_prime(6), content="false")
  inspect(@types.is_prime(7), content="true")
  inspect(@types.is_prime(8), content="false")
  inspect(@types.is_prime(9), content="false")
}

///|
test "gcd" {
  inspect(@types.gcd(12, 8), content="4")
  inspect(@types.gcd(7, 3), content="1")
  inspect(@types.gcd(9, 6), content="3")
  inspect(@types.gcd(0, 5), content="5")
  inspect(@types.gcd(5, 0), content="5")
}

///|
test "divisible_by" {
  inspect(@types.divisible_by(6, 3), content="true")
  inspect(@types.divisible_by(6, 4), content="false")
  inspect(@types.divisible_by(9, 3), content="true")
  inspect(@types.divisible_by(7, 2), content="false")
  inspect(@types.divisible_by(5, 0), content="false")
}

///|
test "absi" {
  inspect(@types.absi(5), content="5")
  inspect(@types.absi(-5), content="5")
  inspect(@types.absi(0), content="0")
}

///|
test "grid operations" {
  let g = @types.new_grid()
  inspect(g.size, content="5")
  inspect(@types.grid_get(g, 0, 0), content="0")
  @types.grid_set(g, 2, 3, 7)
  inspect(@types.grid_get(g, 2, 3), content="7")
  inspect(@types.grid_is_locked(g, 2, 3), content="false")
  @types.grid_lock(g, 2, 3)
  inspect(@types.grid_is_locked(g, 2, 3), content="true")
}

///|
test "grid_is_full" {
  let g = @types.new_grid()
  inspect(@types.grid_is_full(g), content="false")
  for r in 0..<5 {
    for c in 0..<5 {
      @types.grid_set(g, r, c, 1)
    }
  }
  inspect(@types.grid_is_full(g), content="true")
}

///|
test "new_game initializes" {
  let game = @types.new_game()
  inspect(game.screen, content="Title")
  inspect(game.scores.length(), content="25")
  inspect(game.timer, content="0")
  inspect(game.incorrect_placements, content="0")
}

///|
test "tier_level_count" {
  inspect(@types.tier_level_count(Primes), content="8")
  inspect(@types.tier_level_count(Factors), content="9")
  inspect(@types.tier_level_count(Theorem), content="8")
}

///|
test "tier_start_index" {
  inspect(@types.tier_start_index(Primes), content="0")
  inspect(@types.tier_start_index(Factors), content="8")
  inspect(@types.tier_start_index(Theorem), content="17")
}
