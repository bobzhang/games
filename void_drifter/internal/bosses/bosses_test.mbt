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
test "boss_for_depth full cycle" {
  // Verify the cycle repeats correctly
  inspect(@bosses.boss_for_depth(4), content="Hive")
  inspect(@bosses.boss_for_depth(5), content="Dreadnought")
  inspect(@bosses.boss_for_depth(6), content="Leviathan")
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

///|
test "spawn_boss hive stats" {
  let game = @types.new_game()
  @bosses.spawn_boss(game, Hive)
  match game.boss {
    Some(boss) => {
      inspect(boss.hp, content="40")
      inspect(boss.max_hp, content="40")
      inspect(boss.shield, content="0")
      inspect(boss.score_value, content="400")
    }
    None => inspect(false, content="true")
  }
}

///|
test "boss phase transitions at 50 percent HP" {
  let game = @types.new_game()
  @bosses.spawn_boss(game, Leviathan)
  match game.boss {
    Some(boss) => {
      // Phase 1 initially
      inspect(boss.phase, content="1")
      // Drop to exactly 50% - should NOT trigger phase 2 (needs < 0.5)
      boss.hp = 30
      @bosses.update_boss(game, 0.016)
      inspect(boss.phase, content="1")
      // Drop to below 50% - should trigger phase 2
      boss.hp = 29
      @bosses.update_boss(game, 0.016)
      inspect(boss.phase, content="2")
      inspect(boss.enraged, content="false")
    }
    None => inspect(false, content="true")
  }
}

///|
test "boss phase transitions at 25 percent HP triggers enrage" {
  let game = @types.new_game()
  @bosses.spawn_boss(game, Leviathan)
  match game.boss {
    Some(boss) => {
      // Drop to below 25% - should jump to phase 3 and enrage
      boss.hp = 14
      @bosses.update_boss(game, 0.016)
      inspect(boss.phase, content="3")
      inspect(boss.enraged, content="true")
    }
    None => inspect(false, content="true")
  }
}

///|
test "boss phase 3 triggers enrage message" {
  let game = @types.new_game()
  @bosses.spawn_boss(game, Hive)
  match game.boss {
    Some(boss) => {
      boss.hp = 9 // Below 25% of 40
      @bosses.update_boss(game, 0.016)
      inspect(boss.phase, content="3")
      inspect(boss.enraged, content="true")
      inspect(game.message, content="BOSS ENRAGED!")
    }
    None => inspect(false, content="true")
  }
}

///|
test "boss phase 2 triggers phase message" {
  let game = @types.new_game()
  @bosses.spawn_boss(game, Dreadnought)
  match game.boss {
    Some(boss) => {
      boss.hp = 39 // Below 50% of 80
      @bosses.update_boss(game, 0.016)
      inspect(boss.phase, content="2")
      inspect(game.message, content="BOSS PHASE 2")
    }
    None => inspect(false, content="true")
  }
}

///|
test "boss phase does not regress" {
  let game = @types.new_game()
  @bosses.spawn_boss(game, Leviathan)
  match game.boss {
    Some(boss) => {
      // Trigger phase 3
      boss.hp = 10
      @bosses.update_boss(game, 0.016)
      inspect(boss.phase, content="3")
      // Even if HP somehow goes back up, phase stays at 3
      boss.hp = 50
      @bosses.update_boss(game, 0.016)
      inspect(boss.phase, content="3")
    }
    None => inspect(false, content="true")
  }
}

///|
test "boss skips phase 2 if HP drops directly below 25 percent" {
  let game = @types.new_game()
  @bosses.spawn_boss(game, Leviathan)
  match game.boss {
    Some(boss) => {
      // Skip phase 2 entirely by dropping directly to phase 3 range
      inspect(boss.phase, content="1")
      boss.hp = 5
      @bosses.update_boss(game, 0.016)
      // Should be phase 3 (skipped phase 2)
      inspect(boss.phase, content="3")
      inspect(boss.enraged, content="true")
    }
    None => inspect(false, content="true")
  }
}

///|
test "boss position is set to arena center on spawn" {
  let game = @types.new_game()
  @bosses.spawn_boss(game, Leviathan)
  match game.boss {
    Some(boss) => {
      inspect(boss.pos.x == game.arena_width / 2.0, content="true")
      inspect(boss.pos.y == 200.0, content="true")
    }
    None => inspect(false, content="true")
  }
}

///|
test "dreadnought shield regen in phase 1" {
  let game = @types.new_game()
  @bosses.spawn_boss(game, Dreadnought)
  match game.boss {
    Some(boss) => {
      // Remove some shield
      boss.shield = 5
      boss.spawn_timer = 0.0 // Ready to regen
      // Stay in phase 1 (high HP)
      inspect(boss.phase, content="1")
      @bosses.update_boss(game, 0.016)
      // Shield should have regenerated (+3, capped at 10)
      inspect(boss.shield, content="8")
    }
    None => inspect(false, content="true")
  }
}

///|
test "inactive boss is not updated" {
  let game = @types.new_game()
  @bosses.spawn_boss(game, Leviathan)
  match game.boss {
    Some(boss) => {
      boss.active = false
      let old_timer = boss.phase_timer
      @bosses.update_boss(game, 1.0)
      // Timer should not have changed
      inspect(boss.phase_timer == old_timer, content="true")
    }
    None => inspect(false, content="true")
  }
}
