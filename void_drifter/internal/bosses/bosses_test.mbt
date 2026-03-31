///|
test "boss_name returns correct names" {
  inspect(@bosses.boss_name(Leviathan), content="THE LEVIATHAN")
  inspect(@bosses.boss_name(Hive), content="THE HIVE MIND")
  inspect(@bosses.boss_name(Dreadnought), content="DREADNOUGHT")
}

///|
test "boss_for_depth cycles bosses" {
  inspect(@bosses.boss_for_depth(0), content="Leviathan")
  inspect(@bosses.boss_for_depth(1), content="Hive")
  inspect(@bosses.boss_for_depth(2), content="Dreadnought")
  inspect(@bosses.boss_for_depth(3), content="Leviathan")
}

///|
test "spawn_boss creates active boss" {
  let game = @types.new_game()
  @bosses.spawn_boss(game, Leviathan)
  match game.boss {
    Some(boss) => {
      inspect(boss.active, content="true")
      inspect(boss.kind, content="Leviathan")
      inspect(boss.hp, content="60")
      inspect(boss.phase, content="1")
      inspect(boss.enraged, content="false")
    }
    None => inspect(false, content="true") // Should not happen
  }
}

///|
test "spawn_boss dreadnought has shield" {
  let game = @types.new_game()
  @bosses.spawn_boss(game, Dreadnought)
  match game.boss {
    Some(boss) => {
      inspect(boss.hp, content="80")
      inspect(boss.shield, content="10")
    }
    None => inspect(false, content="true")
  }
}
