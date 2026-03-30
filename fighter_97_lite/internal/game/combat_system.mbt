///|
fn defender_holding_away(
  attacker : @types.Fighter,
  defender : @types.Fighter,
) -> Bool {
  let dx = attacker.x - defender.x
  if dx.abs() <= 1.0 {
    defender.input.hold_back
  } else if dx > 0.0 {
    defender.input.x < 0
  } else {
    defender.input.x > 0
  }
}

///|
fn can_defender_block(
  attacker : @types.Fighter,
  defender : @types.Fighter,
  mv : @types.MoveSpec,
) -> Bool {
  if !defender.on_ground {
    return false
  }

  if defender.action == ActionHitstun ||
    defender.action == ActionBlockstun ||
    defender.action == ActionThrow ||
    defender.action == ActionKnockdown ||
    defender.action == ActionWakeup ||
    defender.action == ActionIntro ||
    defender.action == ActionVictory {
    return false
  }

  if !defender_holding_away(attacker, defender) {
    return false
  }

  if mv.low_attack {
    defender.input.hold_down
  } else if mv.overhead_attack {
    !defender.input.hold_down
  } else {
    true
  }
}

///|
fn attacker_remaining_recovery(
  attacker : @types.Fighter,
  mv : @types.MoveSpec,
) -> Int {
  (mv.total_frames - attacker.action_frame).clamp(min=0, max=999)
}

///|
fn compute_damage(
  _attacker : @types.Fighter,
  defender : @types.Fighter,
  attacker_archetype : @types.CharacterArchetype,
  defender_archetype : @types.CharacterArchetype,
  mv : @types.MoveSpec,
) -> (Int, Bool) {
  let counter_hit = defender.action == ActionAttack &&
    defender.action_frame < defender.current_move.startup_frames

  let mut scale = @types.f(1.0) -
    Float::from_int(defender.combo_counter) * @types.combo_decay_step
  if scale < @types.f(0.45) {
    scale = @types.f(0.45)
  }

  let mut damage = Float::from_int(mv.damage)
  damage = damage * attacker_archetype.offense_mul
  damage = damage / defender_archetype.defense_mul
  damage = damage * scale
  if counter_hit {
    damage = damage * @types.counter_hit_bonus
  }

  let d = damage.to_int().clamp(min=1, max=999)
  (d, counter_hit)
}

///|
fn @types.Game::apply_successful_hit(
  game : @types.Game,
  attacker_slot : Int,
  defender_slot : Int,
  hitbox_center_x : Float,
  hitbox_center_y : Float,
) -> Unit {
  let attacker = game.fighters[attacker_slot]
  let defender = game.fighters[defender_slot]
  let mv = attacker.current_move
  let attacker_archetype = @types.fighter_archetype(game, attacker)
  let defender_archetype = @types.fighter_archetype(game, defender)
  // Capture defender state BEFORE applying hit for punish detection
  let defender_was_in_recovery = defender.action == ActionAttack &&
    defender.action_frame >=
    defender.current_move.startup_frames + defender.current_move.active_frames

  let (damage, counter_hit) = compute_damage(
    attacker, defender, attacker_archetype, defender_archetype, mv,
  )

  defender.health = (defender.health - damage).clamp(
    min=0,
    max=@types.health_max,
  )

  if mv.knockdown {
    defender.action = ActionKnockdown
    defender.knockdown = mv.hitstun_frames + 26
    defender.hitstun = 0
    defender.blockstun = 0
  } else {
    defender.action = ActionHitstun
    let bonus = if counter_hit { 4 } else { 0 }
    defender.hitstun = mv.hitstun_frames + bonus
    defender.blockstun = 0
    defender.knockdown = 0
  }

  let fx = @types.facing_sign(attacker.facing)
  defender.vx = mv.launch_x * 0.06 * fx
  defender.vy = mv.launch_y * 0.06

  if mv.launch_y < -60.0 || mv.knockdown {
    defender.on_ground = false
    defender.crouching = false
  }

  defender.flash_timer = 0.16
  defender.shake_timer = 0.12
  defender.hurt_shake_x = @types.rand_rangef(game, -5.0, 5.0)
  defender.hurt_shake_y = @types.rand_rangef(game, -4.0, 4.0)

  attacker.hitstop = mv.hitstop_frames
  defender.hitstop = mv.hitstop_frames

  attacker.move_connected = true
  attacker.move_cancel_enabled = mv.cancel_on_hit

  defender.combo_counter += 1
  defender.combo_timer = @types.combo_timeout_frames

  @types.add_meter(attacker, mv.meter_gain_on_hit, attacker_archetype)
  @types.add_meter(defender, @types.meter_gain_hit_taken, defender_archetype)

  let spark_kind = match mv.move_kind {
    MoveKindSuper => @types.SparkKindSuper
    _ => SparkKindHit
  }

  // Bigger sparks on heavy/special hits
  let spark_count = if mv.move_kind == MoveKindSuper {
    48
  } else if mv.move_kind == MoveKindSpecial {
    34
  } else if mv.attack_id == AttackHp || mv.attack_id == AttackHk {
    28
  } else {
    18
  }

  @effects.spawn_hit_spark(
    game, hitbox_center_x, hitbox_center_y, spark_kind, spark_count,
  )

  // Detect punish: hitting during recovery frames (uses pre-mutation snapshot)
  let is_punish = defender_was_in_recovery && !counter_hit

  if mv.move_kind == MoveKindSuper {
    @effects.push_camera_shake(game, 6.4)
    game.announcer_text = if counter_hit {
      "SUPER COUNTER!"
    } else {
      "SUPER HIT!"
    }
    game.announcer_timer = 0.7
    // SUPER badge: gold with glow
    @types.set_combat_badge(game, "SUPER!", 255, 215, 0, 0.7)
  } else {
    @effects.push_camera_shake(game, if counter_hit { 4.6 } else { 3.2 })
    if counter_hit {
      game.announcer_text = "COUNTER!"
      game.announcer_timer = 0.32
      // COUNTER badge: yellow
      @types.set_combat_badge(game, "COUNTER!", 255, 230, 50, 0.5)
    } else if is_punish {
      // PUNISH badge: orange
      @types.set_combat_badge(game, "PUNISH!", 255, 165, 50, 0.5)
    }
  }

  // Stronger hit effects: bigger sparks and shake for heavy/special attacks
  if mv.move_kind == MoveKindSpecial {
    @effects.push_camera_shake(game, 2.0)
    defender.flash_timer = 0.22
  }
  if mv.attack_id == AttackHp || mv.attack_id == AttackHk {
    defender.flash_timer = 0.2
  }

  // Damage trail for heavy hits
  if mv.move_kind == MoveKindSpecial ||
    mv.move_kind == MoveKindSuper ||
    mv.attack_id == AttackHp ||
    mv.attack_id == AttackHk {
    @types.start_damage_trail(defender)
  }

  // Slow-motion on killing blow
  if defender.health <= 0 {
    game.slowmo_timer = 0.45
    @effects.push_camera_shake(game, 4.0)
  }

  if mv.move_kind != MoveKindSuper {
    @effects.spawn_ground_skid(game, defender)
  }

  if mv.knockdown {
    @types.set_training_note(
      game,
      "P\{attacker_slot + 1} on hit: hard knockdown",
    )
  } else {
    let advantage = defender.hitstun - attacker_remaining_recovery(attacker, mv)
    @types.set_training_frame_adv(game, attacker_slot, "on hit", advantage)
  }

  game.hud_flash = 0.16
}

///|
fn @types.Game::apply_blocked_hit(
  game : @types.Game,
  attacker_slot : Int,
  defender_slot : Int,
  hitbox_center_x : Float,
  hitbox_center_y : Float,
) -> Unit {
  let attacker = game.fighters[attacker_slot]
  let defender = game.fighters[defender_slot]
  let mv = attacker.current_move
  let attacker_archetype = @types.fighter_archetype(game, attacker)
  let defender_archetype = @types.fighter_archetype(game, defender)

  let mut chip = mv.chip_damage
  if mv.move_kind == MoveKindSuper {
    chip = chip + 3
  }

  if chip > 0 && defender.health > 1 {
    defender.health = (defender.health - chip).clamp(
      min=1,
      max=@types.health_max,
    )
  }

  let guard_damage = (mv.damage / 12 + 2).clamp(min=2, max=16)
  defender.guard_meter -= guard_damage

  if defender.guard_meter <= 0 {
    defender.guard_meter = @types.fighter_total_guard(defender_archetype) / 2
    defender.action = ActionHitstun
    defender.hitstun = mv.hitstun_frames + 12
    defender.blockstun = 0
    defender.knockdown = 0

    game.announcer_text = "GUARD BREAK!"
    game.announcer_timer = 0.55
    game.guard_break_flash = 0.7
    // GUARD BREAK badge: red
    @types.set_combat_badge(game, "GUARD BREAK!", 255, 60, 60, 0.65)
    @effects.spawn_hit_spark(
      game,
      hitbox_center_x,
      hitbox_center_y,
      SparkKindSuper,
      30,
    )
    @effects.push_camera_shake(game, 5.2)
    @types.set_training_note(game, "P\{attacker_slot + 1} guard break")
  } else {
    defender.action = ActionBlockstun
    defender.blockstun = mv.blockstun_frames
    defender.hitstun = 0
    defender.knockdown = 0
    defender.vx = mv.pushback * 0.04 * @types.facing_sign(attacker.facing)
    @effects.spawn_hit_spark(
      game,
      hitbox_center_x,
      hitbox_center_y,
      SparkKindBlock,
      18,
    )
    @effects.push_camera_shake(game, 2.2)
    let advantage = defender.blockstun -
      attacker_remaining_recovery(attacker, mv)
    @types.set_training_frame_adv(game, attacker_slot, "on block", advantage)
  }

  attacker.hitstop = mv.hitstop_frames / 2 + 2
  defender.hitstop = mv.hitstop_frames / 2 + 2

  attacker.move_connected = true
  attacker.move_cancel_enabled = false

  @types.add_meter(
    attacker,
    @types.meter_gain_blocked + mv.meter_gain_on_hit / 2,
    attacker_archetype,
  )
  @types.add_meter(defender, @types.meter_gain_blocked + 2, defender_archetype)

  game.hud_flash = 0.08
}

///|
fn @types.Game::process_attack_contact(
  game : @types.Game,
  attacker_slot : Int,
  defender_slot : Int,
) -> Unit {
  let attacker = game.fighters[attacker_slot]
  let defender = game.fighters[defender_slot]

  if attacker.health <= 0 || defender.health <= 0 {
    return
  }

  if !attack_is_active(attacker) {
    return
  }

  if attacker.move_connected {
    return
  }

  if defender.invuln > 0 {
    return
  }

  let mv = attacker.current_move
  let hitbox = @types.attack_hitbox_for(attacker, mv)
  let hurtbox = @types.hurtbox_for(defender)

  if !@raylib.check_collision_recs(hitbox, hurtbox) {
    return
  }

  let hit_x = hitbox.x + hitbox.width * 0.5
  let hit_y = hitbox.y + hitbox.height * 0.5

  if can_defender_block(attacker, defender, mv) {
    game.apply_blocked_hit(attacker_slot, defender_slot, hit_x, hit_y)
  } else {
    game.apply_successful_hit(attacker_slot, defender_slot, hit_x, hit_y)
  }
}

///|
fn check_attack_will_connect(
  attacker : @types.Fighter,
  defender : @types.Fighter,
) -> Bool {
  if attacker.health <= 0 || defender.health <= 0 {
    return false
  }
  if !attack_is_active(attacker) {
    return false
  }
  if attacker.move_connected {
    return false
  }
  if defender.invuln > 0 {
    return false
  }
  let mv = attacker.current_move
  let hitbox = @types.attack_hitbox_for(attacker, mv)
  let hurtbox = @types.hurtbox_for(defender)
  @raylib.check_collision_recs(hitbox, hurtbox)
}

///|
/// Apply a hit using pre-snapshotted data, without re-checking attack_is_active.
/// Used for simultaneous trades so that neither side's state mutation
/// invalidates the other side's hit.
fn @types.Game::apply_trade_hit(
  game : @types.Game,
  attacker_slot : Int,
  defender_slot : Int,
) -> Unit {
  let attacker = game.fighters[attacker_slot]
  let defender = game.fighters[defender_slot]
  let mv = attacker.current_move
  let hitbox = @types.attack_hitbox_for(attacker, mv)
  let hit_x = hitbox.x + hitbox.width * 0.5
  let hit_y = hitbox.y + hitbox.height * 0.5
  if can_defender_block(attacker, defender, mv) {
    game.apply_blocked_hit(attacker_slot, defender_slot, hit_x, hit_y)
  } else {
    game.apply_successful_hit(attacker_slot, defender_slot, hit_x, hit_y)
  }
}

///|
fn @types.Game::update_combat(game : @types.Game) -> Unit {
  // Check both directions before applying either, so trades are possible.
  let p1 = game.fighters[0]
  let p2 = game.fighters[1]
  let p1_hits_p2 = check_attack_will_connect(p1, p2)
  let p2_hits_p1 = check_attack_will_connect(p2, p1)
  if p1_hits_p2 && p2_hits_p1 {
    // True trade: apply both hits simultaneously using pre-snapshotted data,
    // bypassing attack_is_active re-checks that would fail after state mutation.
    game.apply_trade_hit(0, 1)
    game.apply_trade_hit(1, 0)
  } else if p1_hits_p2 {
    game.process_attack_contact(0, 1)
  } else if p2_hits_p1 {
    game.process_attack_contact(1, 0)
  }
}
