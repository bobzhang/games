///|
/// Generate a floor with procedural layout and enemies.
pub fn generate_floor(game : @types.Game, floor_num : Int) -> @types.Floor {
  if @types.is_boss_floor(floor_num) {
    return generate_boss_floor(game, floor_num)
  }
  let theme = @types.floor_theme(floor_num)
  let w = @types.grid_w
  let h = @types.grid_h
  let grid = @types.Grid::new(w, h)
  let rng = @types.game_rng(game)
  // Place walls around the border
  for x in 0..<w {
    @types.grid_set_kind(grid, x, 0, Wall)
    @types.grid_set_kind(grid, x, h - 1, Wall)
  }
  for y in 0..<h {
    @types.grid_set_kind(grid, 0, y, Wall)
    @types.grid_set_kind(grid, w - 1, y, Wall)
  }
  // Scatter interior walls based on floor difficulty
  let wall_count = 6 + floor_num
  for _ in 0..<wall_count {
    let wx = @types.rand_range(rng, 2, w - 3)
    let wy = @types.rand_range(rng, 2, h - 3)
    if !(wx == 1 && wy == 1) && !(wx == w - 2 && wy == h - 2) {
      @types.grid_set_kind(grid, wx, wy, Wall)
    }
  }
  // Theme-specific hazard placement
  place_theme_hazards(grid, rng, floor_num, theme, w, h)
  // Place exit
  let exit_x = w - 2
  let exit_y = h - 2
  @types.grid_set_kind(grid, exit_x, exit_y, Exit)
  // Place varied items on floor tiles
  let item_count = 3 + floor_num / 2
  place_items(grid, rng, item_count, w, h, exit_x, exit_y)
  // Place weapon pickups on some floors
  if floor_num % 3 == 0 {
    place_weapon_item(grid, rng, w, h, exit_x, exit_y)
  }
  // Spawn enemies using themed rosters
  let kinds = themed_enemy_kinds(floor_num, theme)
  let count = floor_enemy_count(floor_num)
  let enemies : Array[@types.Enemy] = []
  for i in 0..<count {
    for attempt = 0; attempt < 50; attempt = attempt + 1 {
      let ex = @types.rand_range(rng, 2, w - 3)
      let ey = @types.rand_range(rng, 2, h - 3)
      if @types.grid_is_walkable(grid, ex, ey) &&
        !(ex == 1 && ey == 1) &&
        !(ex == exit_x && ey == exit_y) &&
        !(@types.has_enemy_at(enemies, ex, ey)) {
        let kind_idx = @types.rand_range(rng, 0, kinds.length() - 1)
        let kind = kinds[kind_idx]
        enemies.push(make_enemy(kind, i, ex, ey))
        break
      }
    }
  }
  @types.sync_rng(game, rng)
  // Set the floor theme on game
  game.floor_theme = Some(@types.theme_data(theme))
  { grid, enemies, floor_num, exit_x, exit_y }
}

///|
/// Place hazards based on floor theme.
fn place_theme_hazards(
  grid : @types.Grid,
  rng : Ref[Int],
  floor_num : Int,
  theme : @types.FloorTheme,
  w : Int,
  h : Int,
) -> Unit {
  match theme {
    Meadow => {
      // Light spikes on floor 2
      if floor_num >= 2 {
        let spike_count = 2
        for _ in 0..<spike_count {
          let sx = @types.rand_range(rng, 1, w - 2)
          let sy = @types.rand_range(rng, 1, h - 2)
          if @types.grid_is_walkable(grid, sx, sy) &&
            !(sx == 1 && sy == 1) &&
            !(sx == w - 2 && sy == h - 2) {
            @types.grid_set_kind(grid, sx, sy, Spike)
          }
        }
      }
    }
    Cave => {
      // Spikes and pits
      let spike_count = 2 + floor_num / 2
      for _ in 0..<spike_count {
        let sx = @types.rand_range(rng, 1, w - 2)
        let sy = @types.rand_range(rng, 1, h - 2)
        if @types.grid_is_walkable(grid, sx, sy) &&
          !(sx == 1 && sy == 1) &&
          !(sx == w - 2 && sy == h - 2) {
          @types.grid_set_kind(grid, sx, sy, Spike)
        }
      }
      let pit_count = floor_num / 3
      for _ in 0..<pit_count {
        let px = @types.rand_range(rng, 2, w - 3)
        let py = @types.rand_range(rng, 2, h - 3)
        if @types.grid_is_walkable(grid, px, py) &&
          !(px == 1 && py == 1) &&
          !(px == w - 2 && py == h - 2) {
          @types.grid_set_kind(grid, px, py, Pit)
        }
      }
    }
    IceDungeon => {
      // Lots of ice + some spikes
      let ice_count = 6 + floor_num
      for _ in 0..<ice_count {
        let ix = @types.rand_range(rng, 1, w - 2)
        let iy = @types.rand_range(rng, 1, h - 2)
        if @types.grid_is_walkable(grid, ix, iy) &&
          !(ix == 1 && iy == 1) &&
          !(ix == w - 2 && iy == h - 2) {
          @types.grid_set_kind(grid, ix, iy, Ice)
        }
      }
      let spike_count = 2
      for _ in 0..<spike_count {
        let sx = @types.rand_range(rng, 1, w - 2)
        let sy = @types.rand_range(rng, 1, h - 2)
        if @types.grid_is_walkable(grid, sx, sy) &&
          !(sx == 1 && sy == 1) &&
          !(sx == w - 2 && sy == h - 2) {
          @types.grid_set_kind(grid, sx, sy, Spike)
        }
      }
    }
    Volcano => {
      // Lava tiles and spikes
      let lava_count = 4 + floor_num
      for _ in 0..<lava_count {
        let lx = @types.rand_range(rng, 1, w - 2)
        let ly = @types.rand_range(rng, 1, h - 2)
        if @types.grid_is_walkable(grid, lx, ly) &&
          !(lx == 1 && ly == 1) &&
          !(lx == w - 2 && ly == h - 2) {
          @types.grid_set_kind(grid, lx, ly, Lava)
        }
      }
      let spike_count = floor_num / 2
      for _ in 0..<spike_count {
        let sx = @types.rand_range(rng, 1, w - 2)
        let sy = @types.rand_range(rng, 1, h - 2)
        if @types.grid_is_walkable(grid, sx, sy) &&
          !(sx == 1 && sy == 1) &&
          !(sx == w - 2 && sy == h - 2) {
          @types.grid_set_kind(grid, sx, sy, Spike)
        }
      }
    }
    BossArena | FinalArena => ()
  }
}

///|
/// Get themed enemy roster for a floor.
fn themed_enemy_kinds(
  floor_num : Int,
  theme : @types.FloorTheme,
) -> Array[@types.EnemyKind] {
  match theme {
    Meadow => [Slime, Bat]
    Cave => [Slime, Bat, Skeleton, Mimic]
    IceDungeon => [Skeleton, Wraith, Golem]
    Volcano => [Dragon, Wraith, Golem]
    _ => floor_enemy_kinds(floor_num)
  }
}

///|
/// Place a weapon item pickup on the floor.
fn place_weapon_item(
  grid : @types.Grid,
  rng : Ref[Int],
  w : Int,
  h : Int,
  exit_x : Int,
  exit_y : Int,
) -> Unit {
  for _ in 0..<20 {
    let ix = @types.rand_range(rng, 1, w - 2)
    let iy = @types.rand_range(rng, 1, h - 2)
    let idx = @types.grid_index(ix, iy, w)
    let tile = grid.tiles[idx]
    if tile.kind == Floor && !(tile.has_item) &&
      !(ix == 1 && iy == 1) &&
      !(ix == exit_x && iy == exit_y) {
      tile.has_item = true
      tile.item = Some(WeaponUpgrade)
      tile.item_kind = 99
      break
    }
  }
}

///|
/// Place varied items on a grid.
fn place_items(
  grid : @types.Grid,
  rng : Ref[Int],
  count : Int,
  w : Int,
  h : Int,
  exit_x : Int,
  exit_y : Int,
) -> Unit {
  let item_kinds : Array[@types.ItemKind] = [
    Gold(15), Gold(10), Gold(20), HealthPotion, ShieldOrb, SpeedBoost,
    WeaponUpgrade, BeatFreeze, SpecialCharge, Bomb,
  ]
  for _ in 0..<count {
    let ix = @types.rand_range(rng, 1, w - 2)
    let iy = @types.rand_range(rng, 1, h - 2)
    let idx = @types.grid_index(ix, iy, w)
    let tile = grid.tiles[idx]
    if tile.kind == Floor && !(tile.has_item) &&
      !(ix == 1 && iy == 1) &&
      !(ix == exit_x && iy == exit_y) {
      tile.has_item = true
      let kind_idx = @types.rand_range(rng, 0, item_kinds.length() - 1)
      tile.item = Some(item_kinds[kind_idx])
      // Keep item_kind for backward compat
      tile.item_kind = kind_idx + 1
    }
  }
}

///|
/// Generate a boss floor with special arena layout.
fn generate_boss_floor(game : @types.Game, floor_num : Int) -> @types.Floor {
  let w = @types.boss_arena_size
  let h = @types.boss_arena_size
  let grid = @types.Grid::new(w, h)
  let rng = @types.game_rng(game)
  // Lava borders (use Spike to represent lava)
  for x in 0..<w {
    @types.grid_set_kind(grid, x, 0, Spike)
    @types.grid_set_kind(grid, x, h - 1, Spike)
  }
  for y in 0..<h {
    @types.grid_set_kind(grid, 0, y, Spike)
    @types.grid_set_kind(grid, w - 1, y, Spike)
  }
  // Place exit (locked until boss dies)
  let exit_x = w / 2
  let exit_y = 1
  @types.grid_set_kind(grid, exit_x, exit_y, Exit)
  // Spawn the boss
  let enemies : Array[@types.Enemy] = []
  let boss_x = w / 2
  let boss_y = h / 2
  if floor_num == 5 {
    enemies.push(make_beat_dragon(0, boss_x, boss_y))
  } else {
    enemies.push(make_rhythm_lich(0, boss_x, boss_y))
  }
  @types.sync_rng(game, rng)
  game.is_boss_floor = true
  { grid, enemies, floor_num, exit_x, exit_y }
}

///|
/// Compute enemy intents for the upcoming beat.
pub fn compute_enemy_intents(
  floor : @types.Floor,
  px : Int,
  py : Int,
  rng : Ref[Int],
  beat_count : Int,
) -> Unit {
  for enemy in floor.enemies {
    if !(enemy.active) {
      continue
    }
    // Boss-specific AI
    match enemy.kind {
      BeatDragon => {
        compute_beat_dragon_intent(enemy, floor, px, py, rng, beat_count)
        continue
      }
      RhythmLich => {
        compute_rhythm_lich_intent(enemy, floor, px, py, rng, beat_count)
        continue
      }
      _ => ()
    }
    let dist = @types.manhattan_dist(enemy.x, enemy.y, px, py)
    // If adjacent to player, attack
    if dist == 1 {
      let dir = @types.direction_from_to(enemy.x, enemy.y, px, py)
      enemy.intent = Attack(dir, enemy.damage)
    } else {
      // Move toward player
      let dir = @types.direction_from_to(enemy.x, enemy.y, px, py)
      let nx = enemy.x + @types.dir_dx(dir)
      let ny = enemy.y + @types.dir_dy(dir)
      if @types.grid_is_walkable(floor.grid, nx, ny) &&
        !(@types.has_enemy_at(floor.enemies, nx, ny)) &&
        !(nx == px && ny == py) {
        enemy.intent = Move(dir)
      } else {
        // Try a random perpendicular direction
        let dirs : Array[@types.Direction] = [North, South, East, West]
        let start = @types.rand_range(rng, 0, 3)
        let mut moved = false
        for di in 0..<4 {
          let d = dirs[(start + di) % 4]
          let mx = enemy.x + @types.dir_dx(d)
          let my = enemy.y + @types.dir_dy(d)
          if @types.grid_is_walkable(floor.grid, mx, my) &&
            !(@types.has_enemy_at(floor.enemies, mx, my)) &&
            !(mx == px && my == py) {
            enemy.intent = Move(d)
            moved = true
            break
          }
        }
        if !(moved) {
          enemy.intent = Wait
        }
      }
    }
  }
}

///|
/// Beat Dragon boss AI.
/// Phase 1: Moves every beat, breathes fire every 3 beats.
/// Phase 2 (<50% HP): double-time, fire every 2 beats.
fn compute_beat_dragon_intent(
  enemy : @types.Enemy,
  floor : @types.Floor,
  px : Int,
  py : Int,
  rng : Ref[Int],
  beat_count : Int,
) -> Unit {
  let hp_frac = Float::from_int(enemy.hp) / Float::from_int(enemy.max_hp)
  let phase2 = hp_frac < 0.5
  let fire_interval = if phase2 { 2 } else { 3 }
  let dist = @types.manhattan_dist(enemy.x, enemy.y, px, py)
  // Fire breath on interval
  if beat_count % fire_interval == 0 {
    let dir = @types.direction_from_to(enemy.x, enemy.y, px, py)
    enemy.intent = BreathFire(dir, enemy.damage)
  } else if dist == 1 {
    let dir = @types.direction_from_to(enemy.x, enemy.y, px, py)
    enemy.intent = Attack(dir, enemy.damage)
  } else {
    // Move toward player
    let dir = @types.direction_from_to(enemy.x, enemy.y, px, py)
    let nx = enemy.x + @types.dir_dx(dir)
    let ny = enemy.y + @types.dir_dy(dir)
    if @types.grid_is_walkable(floor.grid, nx, ny) &&
      !(@types.has_enemy_at(floor.enemies, nx, ny)) &&
      !(nx == px && ny == py) {
      enemy.intent = Move(dir)
    } else {
      let dirs : Array[@types.Direction] = [North, South, East, West]
      let start = @types.rand_range(rng, 0, 3)
      let mut moved = false
      for di in 0..<4 {
        let d = dirs[(start + di) % 4]
        let mx = enemy.x + @types.dir_dx(d)
        let my = enemy.y + @types.dir_dy(d)
        if @types.grid_is_walkable(floor.grid, mx, my) &&
          !(@types.has_enemy_at(floor.enemies, mx, my)) &&
          !(mx == px && my == py) {
          enemy.intent = Move(d)
          moved = true
          break
        }
      }
      if !(moved) {
        enemy.intent = Wait
      }
    }
  }
}

///|
/// Rhythm Lich boss AI.
/// Summons skeleton minions every 4 beats, AoE freeze every 6 beats.
/// Phase 2 (<30% HP): Minions act on every beat.
fn compute_rhythm_lich_intent(
  enemy : @types.Enemy,
  floor : @types.Floor,
  px : Int,
  py : Int,
  rng : Ref[Int],
  beat_count : Int,
) -> Unit {
  let hp_frac = Float::from_int(enemy.hp) / Float::from_int(enemy.max_hp)
  let _phase2 = hp_frac < 0.3
  // AoE freeze every 6 beats takes priority
  if beat_count % 6 == 0 && beat_count > 0 {
    // Freeze radius of 2 around player
    enemy.intent = AoeFreeze(2)
  } else if beat_count % 4 == 0 && beat_count > 0 {
    // Summon skeleton nearby
    let sx = enemy.x + @types.rand_range(rng, -2, 2)
    let sy = enemy.y + @types.rand_range(rng, -2, 2)
    let csx = @types.clampi(sx, 1, floor.grid.width - 2)
    let csy = @types.clampi(sy, 1, floor.grid.height - 2)
    enemy.intent = Summon(Skeleton, csx, csy)
  } else {
    let dist = @types.manhattan_dist(enemy.x, enemy.y, px, py)
    if dist == 1 {
      let dir = @types.direction_from_to(enemy.x, enemy.y, px, py)
      enemy.intent = Attack(dir, enemy.damage)
    } else {
      let dir = @types.direction_from_to(enemy.x, enemy.y, px, py)
      let nx = enemy.x + @types.dir_dx(dir)
      let ny = enemy.y + @types.dir_dy(dir)
      if @types.grid_is_walkable(floor.grid, nx, ny) &&
        !(@types.has_enemy_at(floor.enemies, nx, ny)) &&
        !(nx == px && ny == py) {
        enemy.intent = Move(dir)
      } else {
        enemy.intent = Wait
      }
    }
  }
}
