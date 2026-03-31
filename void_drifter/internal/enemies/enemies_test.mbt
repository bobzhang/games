///|
test "enemy_shape_sides returns correct values" {
  inspect(@enemies.enemy_shape_sides(Drone), content="3")
  inspect(@enemies.enemy_shape_sides(Fighter), content="4")
  inspect(@enemies.enemy_shape_sides(Kiter), content="5")
  inspect(@enemies.enemy_shape_sides(Turret), content="6")
  inspect(@enemies.enemy_shape_sides(Carrier), content="8")
}

///|
test "spawn_enemy activates and sets stats" {
  let game = @types.new_game()
  @enemies.spawn_enemy(game, Drone, 100.0, 200.0)
  // Find the spawned enemy
  let mut found = false
  for i in 0..<game.enemies.length() {
    if game.enemies[i].active {
      let e = game.enemies[i]
      inspect(e.kind, content="Drone")
      inspect(e.hp, content="2")
      inspect(e.damage, content="1")
      inspect(e.pos.x, content="100")
      inspect(e.pos.y, content="200")
      found = true
      break
    }
  }
  inspect(found, content="true")
}

///|
test "spawn_enemy fills pool slots" {
  let game = @types.new_game()
  @enemies.spawn_enemy(game, Fighter, 50.0, 50.0)
  @enemies.spawn_enemy(game, Kiter, 100.0, 100.0)
  inspect(@types.count_active_enemies(game.enemies), content="2")
}

///|
test "spawn_wave adds enemies" {
  let game = @types.new_game()
  game.arena_width = 800.0
  game.arena_height = 600.0
  @types.seed_rng(42)
  @enemies.spawn_wave(game, 1, Asteroids)
  // base_wave_enemies(3) + wave(1) = 4
  inspect(@types.count_active_enemies(game.enemies) > 0, content="true")
  inspect(game.sector_enemies_total > 0, content="true")
}
