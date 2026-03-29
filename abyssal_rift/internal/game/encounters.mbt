///|
pub fn select_encounter(floor_num : Int, rng : UInt) -> (@types.EncounterType, UInt) {
  let (s, roll) = @types.rng_next(rng)
  let encounter : @types.EncounterType = if floor_num <= 2 {
    // Early: mostly standard
    if roll < 0.6 {
      Standard
    } else if roll < 0.85 {
      Swarm
    } else {
      Ambush
    }
  } else if floor_num <= 6 {
    if roll < 0.3 {
      Standard
    } else if roll < 0.5 {
      Swarm
    } else if roll < 0.65 {
      SniperNest
    } else if roll < 0.8 {
      BossRush
    } else if roll < 0.9 {
      PoisonNest
    } else {
      Ambush
    }
  } else {
    if roll < 0.15 {
      Standard
    } else if roll < 0.3 {
      Swarm
    } else if roll < 0.45 {
      SniperNest
    } else if roll < 0.6 {
      BossRush
    } else if roll < 0.75 {
      SurvivalWave
    } else if roll < 0.9 {
      PoisonNest
    } else {
      Ambush
    }
  }
  (encounter, s)
}

///|
pub fn spawn_encounter(
  game : @types.Game,
  encounter : @types.EncounterType,
  room : @types.Room
) -> Unit {
  let ts = @types.tile_sizef
  let cx = Float::from_int(room.x) * ts + Float::from_int(room.w) * ts / 2.0
  let cy = Float::from_int(room.y) * ts + Float::from_int(room.h) * ts / 2.0
  let hw = Float::from_int(room.w - 4) * ts / 2.0
  let hh = Float::from_int(room.h - 4) * ts / 2.0
  match encounter {
    Standard => spawn_encounter_standard(game, cx, cy, hw, hh)
    Swarm => spawn_encounter_swarm(game, cx, cy, hw, hh)
    SniperNest => spawn_encounter_sniper_nest(game, cx, cy, hw, hh)
    BossRush => spawn_encounter_boss_rush(game, cx, cy, hw, hh)
    SurvivalWave => spawn_encounter_survival_wave(game, cx, cy, hw, hh)
    PoisonNest => spawn_encounter_poison_nest(game, cx, cy, hw, hh)
    Ambush => spawn_encounter_ambush(game, cx, cy, hw, hh)
  }
}

///|
fn spawn_encounter_swarm(
  game : @types.Game,
  cx : Float,
  cy : Float,
  hw : Float,
  hh : Float
) -> Unit {
  // Many weak enemies
  let count = 8 + game.floor_num * 2
  for _i in 0..<count {
    let (s1, ox) = @types.rng_range(game.rng_state, -hw, hw)
    let (s2, oy) = @types.rng_range(s1, -hh, hh)
    game.rng_state = s2
    let kind : @types.EnemyKind = if game.rng_state % 3U == 0U {
      Bat
    } else {
      SlimeSmall
    }
    spawn_enemy(game, kind, cx + ox, cy + oy)
  }
}

///|
fn spawn_encounter_sniper_nest(
  game : @types.Game,
  cx : Float,
  cy : Float,
  hw : Float,
  hh : Float
) -> Unit {
  // Archers at corners, spiders near center
  spawn_enemy(game, Archer, cx - hw + 20.0, cy - hh + 20.0)
  spawn_enemy(game, Archer, cx + hw - 20.0, cy - hh + 20.0)
  spawn_enemy(game, Archer, cx - hw + 20.0, cy + hh - 20.0)
  spawn_enemy(game, Archer, cx + hw - 20.0, cy + hh - 20.0)
  spawn_enemy(game, Spider, cx - 40.0, cy)
  spawn_enemy(game, Spider, cx + 40.0, cy)
}

///|
fn spawn_encounter_boss_rush(
  game : @types.Game,
  cx : Float,
  cy : Float,
  hw : Float,
  hh : Float
) -> Unit {
  // One elite + supporting minions
  let affixes : Array[@types.EliteAffix] = [
    Fast, Armored, Splitting, Vampiric, Explosive,
  ]
  let (s1, idx_f) = @types.rng_next(game.rng_state)
  game.rng_state = s1
  let affix_idx = (idx_f * 5.0).to_int() % 5
  let kinds : Array[@types.EnemyKind] = [Skeleton, Golem, Spider]
  let (s2, kind_f) = @types.rng_next(game.rng_state)
  game.rng_state = s2
  let kind_idx = (kind_f * 3.0).to_int() % 3
  spawn_elite(game, kinds[kind_idx], cx, cy, affixes[affix_idx])
  // Support minions
  for _i in 0..<3 {
    let (s3, ox) = @types.rng_range(game.rng_state, -hw * 0.5, hw * 0.5)
    let (s4, oy) = @types.rng_range(s3, -hh * 0.5, hh * 0.5)
    game.rng_state = s4
    spawn_enemy(game, Slime, cx + ox, cy + oy)
  }
}

///|
fn spawn_encounter_poison_nest(
  game : @types.Game,
  cx : Float,
  cy : Float,
  hw : Float,
  hh : Float
) -> Unit {
  // Lots of spiders
  let count = 4 + game.floor_num
  for _i in 0..<count {
    let (s1, ox) = @types.rng_range(game.rng_state, -hw * 0.7, hw * 0.7)
    let (s2, oy) = @types.rng_range(s1, -hh * 0.7, hh * 0.7)
    game.rng_state = s2
    spawn_enemy(game, Spider, cx + ox, cy + oy)
  }
}

///|
fn spawn_encounter_ambush(
  game : @types.Game,
  cx : Float,
  cy : Float,
  hw : Float,
  hh : Float
) -> Unit {
  // Enemies at room edges
  let count = 4 + game.floor_num
  for i in 0..<count {
    let edge = i % 4
    let (s1, offset) = @types.rng_range(game.rng_state, -0.7, 0.7)
    game.rng_state = s1
    let (ex, ey) = match edge {
      0 => (cx - hw + 20.0, cy + offset * hh)
      1 => (cx + hw - 20.0, cy + offset * hh)
      2 => (cx + offset * hw, cy - hh + 20.0)
      _ => (cx + offset * hw, cy + hh - 20.0)
    }
    let (s2, kind_roll) = @types.rng_next(game.rng_state)
    game.rng_state = s2
    let kind : @types.EnemyKind = if kind_roll < 0.4 {
      Skeleton
    } else if kind_roll < 0.7 {
      Bat
    } else {
      Archer
    }
    spawn_enemy(game, kind, ex, ey)
  }
}

///|
fn spawn_encounter_survival_wave(
  game : @types.Game,
  cx : Float,
  cy : Float,
  hw : Float,
  hh : Float
) -> Unit {
  // Spawn only a small first wave; subsequent waves handled by room_flow
  let count = 3
  for _i in 0..<count {
    let (s1, ox) = @types.rng_range(game.rng_state, -hw * 0.5, hw * 0.5)
    let (s2, oy) = @types.rng_range(s1, -hh * 0.5, hh * 0.5)
    game.rng_state = s2
    if @types.dist2(cx + ox, cy + oy, game.player.x, game.player.y) > 80.0 * 80.0 {
      spawn_enemy(game, SlimeSmall, cx + ox, cy + oy)
    }
  }
}

///|
fn spawn_encounter_standard(
  game : @types.Game,
  cx : Float,
  cy : Float,
  hw : Float,
  hh : Float
) -> Unit {
  // Use existing curated pack system
  let budget = 3 + game.floor_num * 2
  let mut remaining = budget
  while remaining > 0 {
    let (pack, s) = get_encounter_pack(game.floor_num, game.rng_state)
    game.rng_state = s
    for j in 0..<pack.length() {
      let (s1, ox) = @types.rng_range(game.rng_state, -hw * 0.6, hw * 0.6)
      let (s2, oy) = @types.rng_range(s1, -hh * 0.6, hh * 0.6)
      game.rng_state = s2
      let d2 = @types.dist2(cx + ox, cy + oy, game.player.x, game.player.y)
      if d2 > 80.0 * 80.0 {
        spawn_enemy(game, pack[j], cx + ox, cy + oy)
      }
      remaining -= 1
    }
    if remaining <= 0 {
      break
    }
  }
}

