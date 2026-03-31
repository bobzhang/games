// anim.mbt - Animation system for turn resolution visuals.
// Queues animations during turn resolution, plays them in sequence.

///|
/// Update all active animations and effects each frame.
pub fn update_animations(battle : @types.BattleState, dt : Float) -> Bool {
  // Update screen effects
  update_screen_fx(battle.screen_fx, dt)
  // Update floating texts
  update_floating_texts(battle, dt)
  // Update particles
  update_particles(battle, dt)
  // Process animation queue
  match battle.anim_current {
    Some(anim) => {
      if anim.playing {
        anim.timer += dt
        let duration = anim_duration(anim.kind)
        if anim.timer >= duration {
          anim.playing = false
          battle.anim_current = None
          // Try to advance to next in queue
          return advance_anim_queue(battle)
        }
        return true // still playing
      }
      false
    }
    None => advance_anim_queue(battle)
  }
}

///|
fn anim_duration(kind : @types.AnimKind) -> Float {
  match kind {
    AnimNone => 0.0F
    AnimMove => @types.anim_move_duration
    AnimAttack => @types.anim_attack_duration
    AnimPush => @types.anim_push_duration
    AnimDeath => @types.anim_death_duration
    AnimIntentReveal => @types.anim_intent_duration
  }
}

///|
fn advance_anim_queue(battle : @types.BattleState) -> Bool {
  if battle.anim_queue.length() > 0 {
    let next = battle.anim_queue.remove(0)
    next.playing = true
    next.timer = 0.0F
    battle.anim_current = Some(next)
    true
  } else {
    false
  }
}

///|
fn update_screen_fx(fx : @types.ScreenFX, dt : Float) -> Unit {
  if fx.shake_timer > 0.0F {
    fx.shake_timer -= dt
    if fx.shake_timer < 0.0F {
      fx.shake_timer = 0.0F
    }
  }
  if fx.flash_timer > 0.0F {
    fx.flash_timer -= dt
    if fx.flash_timer < 0.0F {
      fx.flash_timer = 0.0F
      fx.flash_alpha = 0
    }
  }
  if fx.slowmo_timer > 0.0F {
    fx.slowmo_timer -= dt
    if fx.slowmo_timer < 0.0F {
      fx.slowmo_timer = 0.0F
    }
  }
  if fx.pulse_timer > 0.0F {
    fx.pulse_timer -= dt
    if fx.pulse_timer < 0.0F {
      fx.pulse_timer = 0.0F
    }
  }
}

///|
fn update_floating_texts(battle : @types.BattleState, dt : Float) -> Unit {
  let mut i = 0
  while i < battle.floating_texts.length() {
    let ft = battle.floating_texts[i]
    ft.timer += dt
    ft.y -= 30.0F * dt // float upward
    if ft.timer >= ft.duration {
      let _ = battle.floating_texts.remove(i)
    } else {
      i += 1
    }
  }
}

///|
fn update_particles(battle : @types.BattleState, dt : Float) -> Unit {
  let mut i = 0
  while i < battle.particles.length() {
    let p = battle.particles[i]
    p.life -= dt
    p.x += p.vx * dt
    p.y += p.vy * dt
    p.vy += 120.0F * dt // gravity
    if p.life <= 0.0F {
      let _ = battle.particles.remove(i)
    } else {
      i += 1
    }
  }
}

// ============================================================================
// Animation queueing helpers (called from game logic)
// ============================================================================

///|
pub fn queue_move_anim(battle : @types.BattleState, unit_id : Int, sx : Int, sy : Int, tx : Int, ty : Int) -> Unit {
  let anim = @types.new_anim(AnimMove, unit_id, sx, sy, tx, ty)
  battle.anim_queue.push(anim)
}

///|
pub fn queue_attack_anim(battle : @types.BattleState, unit_id : Int, tx : Int, ty : Int) -> Unit {
  let anim = @types.new_anim(AnimAttack, unit_id, tx, ty, tx, ty)
  battle.anim_queue.push(anim)
}

///|
pub fn queue_push_anim(battle : @types.BattleState, unit_id : Int, sx : Int, sy : Int, tx : Int, ty : Int) -> Unit {
  let anim = @types.new_anim(AnimPush, unit_id, sx, sy, tx, ty)
  battle.anim_queue.push(anim)
}

///|
pub fn queue_death_anim(battle : @types.BattleState, unit_id : Int, x : Int, y : Int) -> Unit {
  let anim = @types.new_anim(AnimDeath, unit_id, x, y, x, y)
  battle.anim_queue.push(anim)
}

///|
pub fn queue_intent_reveal(battle : @types.BattleState) -> Unit {
  let anim = @types.new_anim(AnimIntentReveal, -1, 0, 0, 0, 0)
  battle.anim_queue.push(anim)
}

// ============================================================================
// Screen effect triggers
// ============================================================================

///|
pub fn trigger_shake(battle : @types.BattleState, intensity : Float) -> Unit {
  battle.screen_fx.shake_timer = @types.shake_duration
  battle.screen_fx.shake_intensity = intensity
}

///|
pub fn trigger_flash(battle : @types.BattleState, r : Int, g : Int, b : Int, alpha : Int) -> Unit {
  battle.screen_fx.flash_timer = @types.flash_duration
  battle.screen_fx.flash_r = r
  battle.screen_fx.flash_g = g
  battle.screen_fx.flash_b = b
  battle.screen_fx.flash_alpha = alpha
}

///|
pub fn trigger_slowmo(battle : @types.BattleState, duration : Float) -> Unit {
  battle.screen_fx.slowmo_timer = duration
}

///|
pub fn trigger_pulse(battle : @types.BattleState) -> Unit {
  battle.screen_fx.pulse_timer = 0.5
}

// ============================================================================
// Floating text spawning
// ============================================================================

///|
pub fn spawn_damage_text(battle : @types.BattleState, x : Int, y : Int, amount : Int) -> Unit {
  let sx = Float::from_int(@types.tile_center_x(x))
  let sy = Float::from_int(@types.tile_center_y(y)) - 20.0F
  let ft : @types.FloatingText = {
    text: "-\{amount}",
    x: sx,
    y: sy,
    timer: 0.0F,
    duration: @types.float_text_duration,
    color_r: 255,
    color_g: 60,
    color_b: 60,
  }
  battle.floating_texts.push(ft)
}

///|
pub fn spawn_shield_text(battle : @types.BattleState, x : Int, y : Int) -> Unit {
  let sx = Float::from_int(@types.tile_center_x(x))
  let sy = Float::from_int(@types.tile_center_y(y)) - 20.0F
  let ft : @types.FloatingText = {
    text: "+SHIELD",
    x: sx,
    y: sy,
    timer: 0.0F,
    duration: @types.float_text_duration,
    color_r: 80,
    color_g: 220,
    color_b: 255,
  }
  battle.floating_texts.push(ft)
}

///|
pub fn spawn_chain_text(battle : @types.BattleState, x : Int, y : Int) -> Unit {
  let sx = Float::from_int(@types.tile_center_x(x))
  let sy = Float::from_int(@types.tile_center_y(y)) - 20.0F
  let ft : @types.FloatingText = {
    text: "CHAIN!",
    x: sx,
    y: sy,
    timer: 0.0F,
    duration: @types.float_text_duration,
    color_r: 255,
    color_g: 200,
    color_b: 40,
  }
  battle.floating_texts.push(ft)
}

///|
pub fn spawn_stun_text(battle : @types.BattleState, x : Int, y : Int) -> Unit {
  let sx = Float::from_int(@types.tile_center_x(x))
  let sy = Float::from_int(@types.tile_center_y(y)) - 20.0F
  let ft : @types.FloatingText = {
    text: "STUNNED",
    x: sx,
    y: sy,
    timer: 0.0F,
    duration: @types.float_text_duration,
    color_r: 255,
    color_g: 255,
    color_b: 80,
  }
  battle.floating_texts.push(ft)
}

// ============================================================================
// Particle spawning
// ============================================================================

///|
pub fn spawn_death_particles(battle : @types.BattleState, x : Int, y : Int, r : Int, g : Int, b : Int) -> Unit {
  let cx = Float::from_int(@types.tile_center_x(x))
  let cy = Float::from_int(@types.tile_center_y(y))
  let seed : Ref[UInt] = { val: (x * 31 + y * 97 + 42).reinterpret_as_uint() }
  for i = 0; i < 12; i = i + 1 {
    ignore(i)
    let angle = Float::from_int(@types.rand_range(seed, 0, 628)) / 100.0F
    let speed = Float::from_int(@types.rand_range(seed, 40, 160))
    let vx = Float::from_double(@math.cos(angle.to_double())) * speed
    let vy = Float::from_double(@math.sin(angle.to_double())) * speed - 60.0F
    let p : @types.Particle = {
      x: cx,
      y: cy,
      vx,
      vy,
      life: @types.particle_life,
      max_life: @types.particle_life,
      color_r: r,
      color_g: g,
      color_b: b,
    }
    battle.particles.push(p)
  }
}

///|
pub fn spawn_explosion_particles(battle : @types.BattleState, x : Int, y : Int) -> Unit {
  spawn_death_particles(battle, x, y, 255, 140, 40)
}

///|
pub fn spawn_lava_particles(battle : @types.BattleState, x : Int, y : Int) -> Unit {
  spawn_death_particles(battle, x, y, 255, 80, 20)
}

// ============================================================================
// Drawing animations and effects
// ============================================================================

///|
pub fn draw_screen_effects(battle : @types.BattleState) -> Unit {
  let fx = battle.screen_fx
  // Screen flash overlay
  if fx.flash_timer > 0.0F {
    let fade = fx.flash_timer / @types.flash_duration
    let alpha = (Float::from_int(fx.flash_alpha) * fade).to_int()
    @raylib.draw_rectangle(
      0, 0, @types.screen_w, @types.screen_h,
      @raylib.Color::new(fx.flash_r, fx.flash_g, fx.flash_b, alpha),
    )
  }
  // Background pulse
  if fx.pulse_timer > 0.0F {
    let pulse_alpha = (fx.pulse_timer / 0.5F * 30.0F).to_int()
    @raylib.draw_rectangle(
      0, 0, @types.screen_w, @types.screen_h,
      @raylib.Color::new(80, 120, 200, pulse_alpha),
    )
  }
}

///|
pub fn draw_floating_texts(battle : @types.BattleState) -> Unit {
  for i = 0; i < battle.floating_texts.length(); i = i + 1 {
    let ft = battle.floating_texts[i]
    let progress = ft.timer / ft.duration
    let alpha = ((1.0F - progress) * 255.0F).to_int().clamp(min=0, max=255)
    let color = @raylib.Color::new(ft.color_r, ft.color_g, ft.color_b, alpha)
    let ix = ft.x.to_int()
    let iy = ft.y.to_int()
    @types.draw_shadow_text(ft.text, ix, iy, @types.font_body, color)
  }
}

///|
pub fn draw_particles(battle : @types.BattleState) -> Unit {
  for i = 0; i < battle.particles.length(); i = i + 1 {
    let p = battle.particles[i]
    let alpha = ((p.life / p.max_life) * 255.0).to_int().clamp(min=0, max=255)
    let size = (p.life / p.max_life) * 4.0 + 1.0
    @raylib.draw_circle(
      p.x.to_int(), p.y.to_int(), size,
      @raylib.Color::new(p.color_r, p.color_g, p.color_b, alpha),
    )
  }
}

///|
pub fn draw_current_anim(battle : @types.BattleState) -> Unit {
  match battle.anim_current {
    None => ()
    Some(anim) => {
      if !anim.playing {
        return
      }
      let duration = anim_duration(anim.kind)
      let t = if duration > 0.0F { anim.timer / duration } else { 1.0F }
      match anim.kind {
        AnimMove | AnimPush => draw_anim_slide(anim, t)
        AnimAttack => draw_anim_attack(anim, t)
        AnimDeath => draw_anim_death(anim, t)
        AnimIntentReveal => draw_anim_intent_fade(t)
        AnimNone => ()
      }
    }
  }
}

///|
fn draw_anim_slide(anim : @types.AnimState, t : Float) -> Unit {
  // Draw a ghost of the unit sliding from source to target
  let sx = Float::from_int(@types.tile_center_x(anim.source_x))
  let sy = Float::from_int(@types.tile_center_y(anim.source_y))
  let tx = Float::from_int(@types.tile_center_x(anim.target_x))
  let ty = Float::from_int(@types.tile_center_y(anim.target_y))
  let eased = ease_out_quad(t)
  let cx = @types.lerpf(sx, tx, eased)
  let cy = @types.lerpf(sy, ty, eased)
  let alpha = ((1.0F - t * 0.5F) * 200.0F).to_int()
  let color = if anim.kind == AnimPush {
    @raylib.Color::new(255, 140, 40, alpha)
  } else {
    @raylib.Color::new(80, 180, 255, alpha)
  }
  @raylib.draw_circle(cx.to_int(), cy.to_int(), 14.0, color)
}

///|
fn draw_anim_attack(anim : @types.AnimState, t : Float) -> Unit {
  // Flash on target tile
  let tx = @types.tile_to_screen_x(anim.target_x)
  let ty = @types.tile_to_screen_y(anim.target_y)
  let flash_t = if t < 0.5F { t * 2.0F } else { (1.0F - t) * 2.0F }
  let alpha = (flash_t * 200.0F).to_int()
  @raylib.draw_rectangle(
    tx, ty, @types.tile_size, @types.tile_size,
    @raylib.Color::new(255, 255, 200, alpha),
  )
}

///|
fn draw_anim_death(anim : @types.AnimState, t : Float) -> Unit {
  // Shrinking circle that fades
  let cx = @types.tile_center_x(anim.source_x)
  let cy = @types.tile_center_y(anim.source_y)
  let scale = 1.0F - ease_in_quad(t)
  let radius = 16.0F * scale
  let alpha = ((1.0F - t) * 255.0F).to_int()
  @raylib.draw_circle(
    cx, cy, radius,
    @raylib.Color::new(220, 60, 60, alpha),
  )
  @raylib.draw_circle_lines(
    cx, cy, radius + 4.0F,
    @raylib.Color::new(255, 200, 80, alpha / 2),
  )
}

///|
fn draw_anim_intent_fade(t : Float) -> Unit {
  // Draw a subtle text overlay that fades in
  let alpha = (t * 180.0F).to_int().clamp(min=0, max=180)
  let color = @raylib.Color::new(255, 120, 60, alpha)
  @types.draw_center_text(
    "Enemy intents revealed",
    @types.grid_offset_x + @types.grid_w * @types.tile_size / 2,
    @types.grid_offset_y - 24,
    @types.font_small,
    color,
  )
}

// ============================================================================
// Easing functions
// ============================================================================

///|
fn ease_out_quad(t : Float) -> Float {
  1.0F - (1.0F - t) * (1.0F - t)
}

///|
fn ease_in_quad(t : Float) -> Float {
  t * t
}

///|
/// Get screen shake offset for this frame.
pub fn get_shake_offset(fx : @types.ScreenFX) -> (Int, Int) {
  if fx.shake_timer <= 0.0F {
    return (0, 0)
  }
  let intensity = fx.shake_intensity * (fx.shake_timer / @types.shake_duration)
  // Simple pseudo-random shake using timer as seed
  let t = (fx.shake_timer * 100.0F).to_int()
  let ox = Float::from_int((t * 7 + 3) % 5 - 2) * intensity
  let oy = Float::from_int((t * 13 + 7) % 5 - 2) * intensity
  (ox.to_int(), oy.to_int())
}

// ============================================================================
// Objective HUD helpers
// ============================================================================

///|
pub fn draw_objective_progress_bar(battle : @types.BattleState, x : Int, y : Int, w : Int) -> Unit {
  let (current, target) = match battle.objective {
    DefendGrid(n) => (battle.turn, n)
    Survive(n) => (battle.turn, n)
    Assassinate(_) => {
      let mut alive = 0
      let mut total = 0
      for i = 0; i < battle.units.length(); i = i + 1 {
        if battle.units[i].team == Enemy {
          total += 1
          if battle.units[i].active && battle.units[i].hp > 0 {
            alive += 1
          }
        }
      }
      (total - alive, total)
    }
    CapturePoints(n) => (battle.objective_progress, n)
    Escort(_, _) => (battle.objective_progress, 1)
  }
  let bar_h = 8
  // Background
  @raylib.draw_rectangle(x, y, w, bar_h, @types.color_hp_bg)
  // Fill
  let fill_w = if target > 0 { w * current / target } else { 0 }
  let clamped = if fill_w > w { w } else { fill_w }
  @raylib.draw_rectangle(x, y, clamped, bar_h, @raylib.Color::new(80, 200, 120, 220))
  // Border
  @raylib.draw_rectangle_lines(x, y, w, bar_h, @raylib.Color::new(100, 200, 100, 120))
  // Progress text
  @types.draw_shadow_text(
    "\{current}/\{target}",
    x + w + 6, y - 2,
    @types.font_small - 4,
    @raylib.Color::new(100, 200, 100, 220),
  )
}

///|
pub fn draw_turn_countdown(battle : @types.BattleState, x : Int, y : Int) -> Unit {
  let remaining = match battle.objective {
    DefendGrid(n) => n - battle.turn + 1
    Survive(n) => n - battle.turn + 1
    _ => -1
  }
  if remaining >= 0 {
    let text = if remaining <= 2 {
      "Turns left: \{remaining} !"
    } else {
      "Turns left: \{remaining}"
    }
    let color = if remaining <= 2 {
      @raylib.Color::new(255, 80, 80, 255)
    } else {
      @raylib.Color::new(200, 200, 100, 200)
    }
    @types.draw_shadow_text(text, x, y, @types.font_small, color)
  }
}
