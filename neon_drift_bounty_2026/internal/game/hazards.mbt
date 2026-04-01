///|
/// Resets all hazard slots to inactive.
fn @types.Game::clear_hazards(game : @types.Game) -> Unit {
  for h in game.hazards {
    h.active = false
    h.kind = OilSlick
    h.x = 0.0
    h.y = 0.0
    h.w = 0.0
    h.h = 0.0
    h.timer = 0.0
    h.warn_t = 0.0
  }
}

///|
/// Allocates a hazard slot, returning its index.
fn @types.Game::alloc_hazard(game : @types.Game) -> Int {
  for i, slot in game.hazards {
    if !slot.active {
      break i
    }
  } nobreak {
    // Evict the hazard closest to the bottom of the screen
    let best = @utils.max_index_by(game.hazards, fn(a, b) { a.y > b.y })
    if best >= 0 {
      best
    } else {
      0
    }
  }
}

///|
/// Spawns a hazard at the given position.
fn @types.Game::spawn_hazard(
  game : @types.Game,
  kind : @types.HazardKind,
  x : Float,
  y : Float,
  w : Float,
  h : Float,
  timer : Float,
) -> Unit {
  let i = game.alloc_hazard()
  game.hazards[i].active = true
  game.hazards[i].kind = kind
  game.hazards[i].x = x
  game.hazards[i].y = y
  game.hazards[i].w = w
  game.hazards[i].h = h
  game.hazards[i].timer = timer
  game.hazards[i].warn_t = @types.hazard_warn_time
}

///|
/// Spawns road hazards based on current stage and distance progression.
fn @types.Game::spawn_hazard_pack(game : @types.Game, y : Float) -> Unit {
  // No hazards in early stages
  if game.stage <= 2 {
    return
  }
  // Hazard chance increases with stage
  let hazard_pct = 8 + (game.stage - 3) * 4
  if !@types.chance(hazard_pct.clamp(min=0, max=40)) {
    return
  }
  let x = @types.road_spawn_x(game.distance, game.time_s, game.stage, y)
  let roll = @types.randi(0, 99)
  if roll < 40 {
    // Oil slick
    game.spawn_hazard(
      OilSlick,
      x,
      y,
      @types.oil_slick_w,
      @types.oil_slick_h,
      @types.oil_slick_duration,
    )
  } else if roll < 70 {
    // Barrier gate
    game.spawn_hazard(
      BarrierGate,
      x,
      y,
      @types.barrier_gate_w,
      @types.barrier_gate_h,
      0.0,
    )
  } else {
    // Blast zone
    game.spawn_hazard(
      BlastZone,
      x,
      y,
      @types.blast_zone_w,
      @types.blast_zone_h,
      @types.blast_zone_fuse,
    )
  }
}

///|
/// Updates all active hazards: moves them, checks player collision, and handles timed effects.
fn @types.Game::update_hazards(game : @types.Game, dt : Float) -> Unit {
  let pr = @types.player_hit_radius(game.hero) * 0.8
  for h in game.hazards {
    if !h.active {
      continue
    }
    // Scroll hazards with the road
    h.y = h.y + game.scroll_speed * dt
    // Deactivate if off screen
    if h.y > Float::from_int(@types.screen_h) + 100.0 {
      h.active = false
      continue
    }
    // Reduce warning telegraph
    if h.warn_t > 0.0 {
      h.warn_t = h.warn_t - dt
    }
    // Check player collision
    let overlaps = @types.rect_overlap(
      game.hero.x,
      game.hero.y,
      pr * 2.0,
      pr * 2.0,
      h.x,
      h.y,
      h.w,
      h.h,
    )
    match h.kind {
      OilSlick =>
        if overlaps {
          game.oil_t = @types.maxf(game.oil_t, @types.oil_slick_duration)
        }
      BarrierGate =>
        if overlaps && game.hero.invuln <= 0.0 {
          game.damage_player(@types.barrier_gate_dmg)
          game.shake_t = @types.maxf(game.shake_t, 0.4)
          h.active = false
          game.burst(h.x, h.y, 12, 1)
        }
      BlastZone => {
        h.timer = h.timer - dt
        if h.timer <= 0.0 {
          // Explosion
          if overlaps {
            game.damage_player(@types.blast_zone_dmg)
          }
          game.burst(h.x, h.y, 20, 1)
          game.spawn_ring(h.x, h.y, 16.0, 0.6, 1)
          game.shake_t = @types.maxf(game.shake_t, 0.3)
          h.active = false
        }
      }
    }
  }
}
