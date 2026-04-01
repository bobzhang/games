///|
test "grid_is_walkable for various tile types" {
  let grid = Grid::new(5, 5)
  grid_set_kind(grid, 1, 1, Floor)
  grid_set_kind(grid, 2, 2, Wall)
  grid_set_kind(grid, 3, 3, Pit)
  grid_set_kind(grid, 4, 1, Ice)
  grid_set_kind(grid, 1, 4, Lava)
  inspect(grid_is_walkable(grid, 1, 1), content="true")
  inspect(grid_is_walkable(grid, 2, 2), content="false")
  inspect(grid_is_walkable(grid, 3, 3), content="false")
  inspect(grid_is_walkable(grid, 4, 1), content="true")
  inspect(grid_is_walkable(grid, 1, 4), content="true")
}

///|
test "grid out of bounds returns false for walkable" {
  let grid = Grid::new(3, 3)
  inspect(grid_is_walkable(grid, -1, 0), content="false")
  inspect(grid_is_walkable(grid, 3, 0), content="false")
  inspect(grid_is_walkable(grid, 0, -1), content="false")
}

///|
test "weapon_attack_cells Sword returns 1 cell" {
  let cells = weapon_attack_cells(Sword, East)
  inspect(cells.length(), content="1")
  inspect(cells[0], content="(1, 0)")
}

///|
test "weapon_attack_cells Spear returns 2 cells" {
  let cells = weapon_attack_cells(Spear, East)
  inspect(cells.length(), content="2")
  inspect(cells[0], content="(1, 0)")
  inspect(cells[1], content="(2, 0)")
}

///|
test "weapon_attack_cells Whip returns 3 cells" {
  let cells = weapon_attack_cells(Whip, North)
  inspect(cells.length(), content="3")
}

///|
test "weapon_attack_cells Staff returns 9 cells (3x3)" {
  let cells = weapon_attack_cells(Staff, South)
  inspect(cells.length(), content="9")
}

///|
test "weapon_attack_cells Bow returns 3 cells" {
  let cells = weapon_attack_cells(Bow, West)
  inspect(cells.length(), content="3")
  inspect(cells[0], content="(-1, 0)")
  inspect(cells[1], content="(-2, 0)")
  inspect(cells[2], content="(-3, 0)")
}

///|
test "weapon_can_attack respects beat_cost" {
  // Sword has beat_cost=1, should always fire
  inspect(weapon_can_attack(Sword, 0), content="true")
  inspect(weapon_can_attack(Sword, 1), content="true")
  // Hammer has beat_cost=2, fires every other beat
  inspect(weapon_can_attack(Hammer, 0), content="true")
  inspect(weapon_can_attack(Hammer, 1), content="false")
  inspect(weapon_can_attack(Hammer, 2), content="true")
  // Staff has beat_cost=3
  inspect(weapon_can_attack(Staff, 0), content="true")
  inspect(weapon_can_attack(Staff, 1), content="false")
  inspect(weapon_can_attack(Staff, 2), content="false")
  inspect(weapon_can_attack(Staff, 3), content="true")
}

///|
test "check_combo_milestone returns correct milestones" {
  inspect(check_combo_milestone(5), content="NoMilestone")
  inspect(check_combo_milestone(10), content="Fever")
  inspect(check_combo_milestone(25), content="Frenzy")
  inspect(check_combo_milestone(50), content="PerfectStorm")
  inspect(check_combo_milestone(30), content="NoMilestone")
}

///|
test "combo_visual_level scaling" {
  inspect(combo_visual_level(0), content="0")
  inspect(combo_visual_level(4), content="0")
  inspect(combo_visual_level(5), content="1")
  inspect(combo_visual_level(14), content="1")
  inspect(combo_visual_level(15), content="2")
  inspect(combo_visual_level(29), content="2")
  inspect(combo_visual_level(30), content="3")
  inspect(combo_visual_level(99), content="3")
}

///|
test "floor_theme mapping" {
  inspect(floor_theme(1), content="Meadow")
  inspect(floor_theme(2), content="Meadow")
  inspect(floor_theme(3), content="Cave")
  inspect(floor_theme(4), content="Cave")
  inspect(floor_theme(5), content="BossArena")
  inspect(floor_theme(6), content="IceDungeon")
  inspect(floor_theme(7), content="IceDungeon")
  inspect(floor_theme(8), content="Volcano")
  inspect(floor_theme(9), content="Volcano")
  inspect(floor_theme(10), content="FinalArena")
}

///|
test "has_ability checks player abilities" {
  let player = Player::new()
  inspect(has_ability(player, DoubleStep), content="false")
  player.abilities.push(DoubleStep)
  inspect(has_ability(player, DoubleStep), content="true")
  inspect(has_ability(player, CounterAttack), content="false")
}

///|
test "is_boss_floor returns correct floors" {
  inspect(is_boss_floor(1), content="false")
  inspect(is_boss_floor(5), content="true")
  inspect(is_boss_floor(7), content="false")
  inspect(is_boss_floor(10), content="true")
}

///|
test "compute_score_grade thresholds" {
  inspect(compute_score_grade(6000), content="GradeS")
  inspect(compute_score_grade(5000), content="GradeS")
  inspect(compute_score_grade(4000), content="GradeA")
  inspect(compute_score_grade(3000), content="GradeA")
  inspect(compute_score_grade(2000), content="GradeB")
  inspect(compute_score_grade(1000), content="GradeC")
}

///|
test "manhattan_dist calculation" {
  inspect(manhattan_dist(0, 0, 3, 4), content="7")
  inspect(manhattan_dist(5, 5, 5, 5), content="0")
  inspect(manhattan_dist(1, 1, 4, 1), content="3")
}

///|
test "direction_from_to basic directions" {
  inspect(direction_from_to(0, 0, 1, 0), content="East")
  inspect(direction_from_to(1, 0, 0, 0), content="West")
  inspect(direction_from_to(0, 0, 0, 1), content="South")
  inspect(direction_from_to(0, 1, 0, 0), content="North")
}

///|
test "meta progress weapon unlocks" {
  let meta = MetaProgress::new()
  inspect(meta.unlocked_weapons.length(), content="1")
  check_weapon_unlocks(meta, 2)
  inspect(meta.unlocked_weapons.length(), content="2")
  check_weapon_unlocks(meta, 10)
  inspect(meta.unlocked_weapons.length(), content="6")
}

///|
test "mastery_rating thresholds" {
  inspect(mastery_rating(95), content="S")
  inspect(mastery_rating(90), content="S")
  inspect(mastery_rating(75), content="A")
  inspect(mastery_rating(55), content="B")
  inspect(mastery_rating(30), content="C")
}

// === Spell System Tests ===

///|
test "spell_data returns correct data for all spells" {
  let fb = spell_data(Fireball)
  inspect(fb.name, content="Fireball")
  inspect(fb.damage, content="3")
  inspect(fb.mana_cost, content="3")
  inspect(fb.element, content="Fire")
  let fn_ = spell_data(FrostNova)
  inspect(fn_.name, content="Frost Nova")
  inspect(fn_.damage, content="1")
  inspect(fn_.element, content="Ice")
  let cl = spell_data(ChainLightning)
  inspect(cl.name, content="Chain Lightning")
  inspect(cl.damage, content="2")
  inspect(cl.element, content="Lightning")
  let ss = spell_data(ShadowStep)
  inspect(ss.name, content="Shadow Step")
  inspect(ss.damage, content="0")
  inspect(ss.element, content="Dark")
  let inf = spell_data(Inferno)
  inspect(inf.name, content="Inferno")
  inspect(inf.aoe_radius, content="1")
  let blz = spell_data(Blizzard)
  inspect(blz.name, content="Blizzard")
  inspect(blz.mana_cost, content="7")
  let ts = spell_data(ThunderStrike)
  inspect(ts.name, content="Thunder Strike")
  inspect(ts.damage, content="5")
  let vp = spell_data(VoidPulse)
  inspect(vp.name, content="Void Pulse")
  inspect(vp.damage, content="1")
}

///|
test "can_cast_spell checks mana and cooldown" {
  let player = Player::new()
  // No spell in slot
  inspect(can_cast_spell(player, 0), content="false")
  // Add fireball (mana cost 3)
  player.spell_slots.spells[0] = Some(Fireball)
  player.mana = 10
  player.spell_slots.cooldowns[0] = 0
  inspect(can_cast_spell(player, 0), content="true")
  // Not enough mana
  player.mana = 2
  inspect(can_cast_spell(player, 0), content="false")
  // On cooldown
  player.mana = 10
  player.spell_slots.cooldowns[0] = 2
  inspect(can_cast_spell(player, 0), content="false")
  // Invalid slot
  inspect(can_cast_spell(player, -1), content="false")
  inspect(can_cast_spell(player, 4), content="false")
}

///|
test "equip_spell fills first empty slot" {
  let player = Player::new()
  let ok1 = equip_spell(player, Fireball)
  inspect(ok1, content="true")
  inspect(player.spell_slots.spells[0] is Some(_), content="true")
  let ok2 = equip_spell(player, FrostNova)
  inspect(ok2, content="true")
  inspect(player.spell_slots.spells[1] is Some(_), content="true")
  let ok3 = equip_spell(player, ChainLightning)
  inspect(ok3, content="true")
  let ok4 = equip_spell(player, ShadowStep)
  inspect(ok4, content="true")
  // All 4 slots full
  let ok5 = equip_spell(player, Inferno)
  inspect(ok5, content="false")
}

///|
test "has_spell checks learned spells" {
  let player = Player::new()
  inspect(has_spell(player, Fireball), content="false")
  player.learned_spells.push(Fireball)
  inspect(has_spell(player, Fireball), content="true")
  inspect(has_spell(player, FrostNova), content="false")
}

///|
test "tick_spell_cooldowns decrements" {
  let player = Player::new()
  player.spell_slots.cooldowns[0] = 3
  player.spell_slots.cooldowns[1] = 1
  player.spell_slots.cooldowns[2] = 0
  player.spell_slots.cooldowns[3] = 5
  tick_spell_cooldowns(player)
  inspect(player.spell_slots.cooldowns[0], content="2")
  inspect(player.spell_slots.cooldowns[1], content="0")
  inspect(player.spell_slots.cooldowns[2], content="0")
  inspect(player.spell_slots.cooldowns[3], content="4")
}

///|
test "all_spell_kinds returns 8 spells" {
  let kinds = all_spell_kinds()
  inspect(kinds.length(), content="8")
}

// === Curse System Tests ===

///|
test "curse_name returns correct names" {
  inspect(curse_name(DoubleTime), content="Double Time")
  inspect(curse_name(GlassCannon), content="Glass Cannon")
  inspect(curse_name(BlindBeat), content="Blind Beat")
  inspect(curse_name(Swarm), content="Swarm")
}

///|
test "curse_desc returns descriptions" {
  let desc = curse_desc(DoubleTime)
  inspect(desc.length() > 0, content="true")
}

///|
test "has_curse checks active curses" {
  let cs = CurseState::new()
  inspect(has_curse(cs, DoubleTime), content="false")
  cs.active_curses.push(DoubleTime)
  inspect(has_curse(cs, DoubleTime), content="true")
  inspect(has_curse(cs, GlassCannon), content="false")
}

///|
test "all_curse_kinds returns 4 curses" {
  let kinds = all_curse_kinds()
  inspect(kinds.length(), content="4")
}

// === Achievement System Tests ===

///|
test "check_achievement unlocks and creates toast" {
  let state = AchievementState::new()
  inspect(is_achievement_unlocked(state, FirstBlood), content="false")
  let unlocked = check_achievement(state, FirstBlood)
  inspect(unlocked, content="true")
  inspect(is_achievement_unlocked(state, FirstBlood), content="true")
  inspect(state.toasts.length(), content="1")
  // Second call should not unlock again
  let unlocked2 = check_achievement(state, FirstBlood)
  inspect(unlocked2, content="false")
  inspect(state.toasts.length(), content="1")
}

///|
test "update_achievement_toasts removes expired" {
  let state = AchievementState::new()
  state.toasts.push({ text: "Test", timer: 0.5 })
  state.toasts.push({ text: "Test2", timer: 2.0 })
  update_achievement_toasts(state, 1.0)
  // First toast should be removed (0.5 - 1.0 < 0)
  inspect(state.toasts.length(), content="1")
}

///|
test "AchievementState::new has 6 achievements" {
  let state = AchievementState::new()
  inspect(state.achievements.length(), content="6")
}

// === Elite Enemy Tests ===

///|
test "should_spawn_elite respects floor threshold" {
  let rng : Ref[Int] = { val: 12345 }
  // Below threshold
  inspect(should_spawn_elite(2, rng), content="false")
  inspect(should_spawn_elite(3, rng), content="false")
  // At or above threshold - depends on RNG
  let _ = should_spawn_elite(10, rng)
}

///|
test "elite_suffix returns descriptions" {
  inspect(elite_suffix(Slime), content="Splits on death")
  inspect(elite_suffix(Skeleton), content="Cross attack")
  inspect(elite_suffix(Bat), content="Double move")
  inspect(elite_suffix(Dragon), content="Line breath")
  inspect(elite_suffix(Golem), content="Enhanced")
}

///|
test "make_elite doubles HP" {
  let enemy = Enemy::new(0, Slime, 1, 1, hp=4, damage=1, beat_pattern=[true])
  inspect(enemy.is_elite, content="false")
  inspect(enemy.hp, content="4")
  make_elite(enemy)
  inspect(enemy.is_elite, content="true")
  inspect(enemy.hp, content="8")
}

// === Damage Number Tests ===

///|
test "spawn_damage_number adds to array" {
  let game = Game::new()
  inspect(game.damage_numbers.length(), content="0")
  spawn_damage_number(game, 100.0, 200.0, 5, Perfect)
  inspect(game.damage_numbers.length(), content="1")
  inspect(game.damage_numbers[0].value, content="5")
}

///|
test "update_damage_numbers removes expired" {
  let game = Game::new()
  spawn_damage_number(game, 100.0, 200.0, 3, Good)
  inspect(game.damage_numbers.length(), content="1")
  update_damage_numbers(game, 2.0) // Large dt to expire
  inspect(game.damage_numbers.length(), content="0")
}

// === Visual Utility Tests ===

///|
test "screen_pulse_for_bpm scales correctly" {
  let low = screen_pulse_for_bpm(100.0)
  let high = screen_pulse_for_bpm(160.0)
  inspect(high > low, content="true")
  let very_low = screen_pulse_for_bpm(80.0)
  inspect(very_low, content="0.30000001192092896")
}

///|
test "element_color returns distinct colors" {
  let fire = element_color(Fire)
  let ice = element_color(Ice)
  inspect(fire.r.to_int() > ice.r.to_int(), content="true")
  inspect(ice.b.to_int() > fire.b.to_int(), content="true")
}

///|
test "trail particles spawn and update" {
  let game = Game::new()
  inspect(game.trail_particles.length(), content="0")
  spawn_trail_particles(game, 100.0, 200.0)
  inspect(game.trail_particles.length() > 0, content="true")
  let count = game.trail_particles.length()
  update_trail_particles(game, 1.0) // Expire all
  inspect(game.trail_particles.length() < count, content="true")
}

///|
test "death explosion queue and flush" {
  let game = Game::new()
  let c = @raylib.Color::new(255, 0, 0, 255)
  queue_death_explosion(game, 100.0, 200.0, c)
  inspect(game.pending_death_explosions.length(), content="1")
  flush_death_explosions(game)
  inspect(game.pending_death_explosions.length(), content="0")
  inspect(game.particles.length() > 0, content="true")
}

// === Spell-related utility tests ===

///|
test "spell_color matches element" {
  let fc = spell_color(Fireball)
  let ec = element_color(Fire)
  inspect(fc.r.to_int() == ec.r.to_int(), content="true")
}

///|
test "enemy_threat_level categorizes correctly" {
  let weak = Enemy::new(0, Slime, 0, 0, hp=2, damage=1, beat_pattern=[true])
  inspect(enemy_threat_level(weak), content="")
  let strong = Enemy::new(1, Dragon, 0, 0, hp=5, damage=3, beat_pattern=[true])
  inspect(enemy_threat_level(strong), content="!!")
  let elite_strong = Enemy::new(2, Dragon, 0, 0, hp=5, damage=3, beat_pattern=[
    true,
  ])
  make_elite(elite_strong)
  inspect(enemy_threat_level(elite_strong), content="!!!")
}

///|
test "direction_arrow returns correct symbols" {
  inspect(direction_arrow(North), content="^")
  inspect(direction_arrow(South), content="v")
  inspect(direction_arrow(East), content=">")
  inspect(direction_arrow(West), content="<")
}

///|
test "combo_encouragement thresholds" {
  inspect(combo_encouragement(0), content="")
  inspect(combo_encouragement(4), content="")
  inspect(combo_encouragement(5), content="NICE!")
  inspect(combo_encouragement(10), content="GREAT!")
  inspect(combo_encouragement(20), content="INCREDIBLE!")
  inspect(combo_encouragement(30), content="LEGENDARY!")
  inspect(combo_encouragement(40), content="UNSTOPPABLE!")
}

///|
test "theme_ambient_text returns non-empty for all themes" {
  inspect(theme_ambient_text(Meadow).length() > 0, content="true")
  inspect(theme_ambient_text(Cave).length() > 0, content="true")
  inspect(theme_ambient_text(BossArena).length() > 0, content="true")
  inspect(theme_ambient_text(IceDungeon).length() > 0, content="true")
  inspect(theme_ambient_text(Volcano).length() > 0, content="true")
  inspect(theme_ambient_text(FinalArena).length() > 0, content="true")
}

///|
test "mana_cost_affordable checks correctly" {
  let player = Player::new()
  player.mana = 5
  inspect(mana_cost_affordable(player, 3), content="true")
  inspect(mana_cost_affordable(player, 5), content="true")
  inspect(mana_cost_affordable(player, 6), content="false")
}

///|
test "spell_border_flash sets game state" {
  let game = Game::new()
  spell_border_flash(game, Fire)
  inspect(game.border_flash_color is Some(_), content="true")
  inspect(game.border_flash_timer > 0.0, content="true")
}

///|
test "spawn_spell_particles creates particles" {
  let game = Game::new()
  let initial = game.particles.length()
  spawn_spell_particles(game, 100.0, 100.0, Fire)
  inspect(game.particles.length() > initial, content="true")
}

///|
test "spawn_boss_death_particles creates many particles" {
  let game = Game::new()
  let c = @raylib.Color::new(255, 0, 0, 255)
  spawn_boss_death_particles(game, 100.0, 100.0, c)
  inspect(game.particles.length() >= 30, content="true")
}

///|
test "shop_item_name handles all kinds" {
  inspect(shop_item_name(ShopHealthPotion), content="Health Potion")
  inspect(shop_item_name(ShopShield), content="Shield Orb")
  inspect(shop_item_name(ShopManaPotion), content="Mana Potion")
  inspect(shop_item_name(ShopSpell(Fireball)), content="Fireball")
  inspect(shop_item_name(ShopWeapon(Sword)), content="Sword")
}

///|
test "shop_item_price handles new kinds" {
  inspect(shop_item_price(ShopSpell(Fireball)), content="35")
  inspect(shop_item_price(ShopManaPotion), content="15")
}

///|
test "shop_item_desc handles new kinds" {
  let desc = shop_item_desc(ShopSpell(Fireball))
  inspect(desc.length() > 0, content="true")
  let mana_desc = shop_item_desc(ShopManaPotion)
  inspect(mana_desc, content="Restore 5 Mana")
}

///|
test "CurseState::new starts empty" {
  let cs = CurseState::new()
  inspect(cs.active_curses.length(), content="0")
}

///|
test "SpellSlots::new starts empty" {
  let ss = SpellSlots::new()
  inspect(ss.spells[0] is None, content="true")
  inspect(ss.spells[1] is None, content="true")
  inspect(ss.spells[2] is None, content="true")
  inspect(ss.spells[3] is None, content="true")
  inspect(ss.cooldowns[0], content="0")
}

///|
test "Player::new has correct spell/mana defaults" {
  let p = Player::new()
  inspect(p.mana, content="10")
  inspect(p.max_mana, content="10")
  inspect(p.learned_spells.length(), content="0")
  inspect(p.floor_attacks, content="0")
}

///|
test "Enemy::new has correct elite/status defaults" {
  let e = Enemy::new(0, Slime, 1, 1, hp=3, damage=1, beat_pattern=[true])
  inspect(e.is_elite, content="false")
  inspect(e.frozen_beats, content="0")
  inspect(e.stunned_beats, content="0")
}

///|
test "Game::new has correct new field defaults" {
  let g = Game::new()
  inspect(g.damage_numbers.length(), content="0")
  inspect(g.trail_particles.length(), content="0")
  inspect(g.pending_death_explosions.length(), content="0")
  inspect(g.curse_offers.length(), content="0")
  inspect(g.showing_curse_offer, content="false")
  inspect(g.bpm_anim_timer, content="0")
}

///|
test "spell_slot_summary with empty slots" {
  let player = Player::new()
  let summary = spell_slot_summary(player)
  inspect(summary.length() > 0, content="true")
}

///|
test "spell_slot_summary with equipped spells" {
  let player = Player::new()
  let _ = equip_spell(player, Fireball)
  player.mana = 10
  let summary = spell_slot_summary(player)
  inspect(summary.length() > 0, content="true")
}

///|
test "curse_risk_text for all curses" {
  let dt = curse_risk_text(DoubleTime)
  inspect(dt.length() > 0, content="true")
  let gc = curse_risk_text(GlassCannon)
  inspect(gc.length() > 0, content="true")
  let bb = curse_risk_text(BlindBeat)
  inspect(bb.length() > 0, content="true")
  let sw = curse_risk_text(Swarm)
  inspect(sw.length() > 0, content="true")
}

///|
test "floor_difficulty_text covers all ranges" {
  inspect(floor_difficulty_text(1), content="Easy")
  inspect(floor_difficulty_text(2), content="Easy")
  inspect(floor_difficulty_text(3), content="Normal")
  inspect(floor_difficulty_text(5), content="BOSS")
  inspect(floor_difficulty_text(7), content="Hard")
  inspect(floor_difficulty_text(9), content="Very Hard")
  inspect(floor_difficulty_text(10), content="EXTREME")
}

///|
test "run_stats_summary formats correctly" {
  let summary = run_stats_summary(5, 20, 30, 15, 4000)
  inspect(summary.length() > 0, content="true")
}

// ============================================================
// === Phase 5: New Tests ===
// ============================================================

// --- Spell Damage Calculation Tests ---

///|
test "spell_data Fireball has correct damage and mana" {
  let sd = spell_data(Fireball)
  inspect(sd.damage, content="3")
  inspect(sd.mana_cost, content="3")
  inspect(sd.beat_cooldown, content="2")
  inspect(sd.range, content="1")
}

///|
test "spell_data FrostNova is AoE with freeze" {
  let sd = spell_data(FrostNova)
  inspect(sd.damage, content="1")
  inspect(sd.aoe_radius, content="1")
  inspect(sd.element, content="Ice")
}

///|
test "spell_data ChainLightning chains at range 3" {
  let sd = spell_data(ChainLightning)
  inspect(sd.damage, content="2")
  inspect(sd.range, content="3")
  inspect(sd.element, content="Lightning")
}

///|
test "spell_data ShadowStep has zero damage" {
  let sd = spell_data(ShadowStep)
  inspect(sd.damage, content="0")
  inspect(sd.mana_cost, content="2")
  inspect(sd.element, content="Dark")
}

///|
test "spell_data Inferno is fire AoE" {
  let sd = spell_data(Inferno)
  inspect(sd.damage, content="2")
  inspect(sd.aoe_radius, content="1")
  inspect(sd.mana_cost, content="6")
}

///|
test "spell_data Blizzard freezes all at max range" {
  let sd = spell_data(Blizzard)
  inspect(sd.damage, content="0")
  inspect(sd.range, content="99")
  inspect(sd.aoe_radius, content="99")
  inspect(sd.mana_cost, content="7")
}

///|
test "spell_data ThunderStrike is highest single damage" {
  let sd = spell_data(ThunderStrike)
  inspect(sd.damage, content="5")
  inspect(sd.range, content="2")
  inspect(sd.element, content="Lightning")
}

///|
test "spell_data VoidPulse pushes enemies" {
  let sd = spell_data(VoidPulse)
  inspect(sd.damage, content="1")
  inspect(sd.aoe_radius, content="1")
  inspect(sd.element, content="Dark")
}

// --- Spell Mana/Cooldown Deduction Tests ---

///|
test "can_cast_spell rejects when no spell" {
  let p = Player::new()
  inspect(can_cast_spell(p, 0), content="false")
  inspect(can_cast_spell(p, 3), content="false")
}

///|
test "can_cast_spell checks mana exactly" {
  let p = Player::new()
  p.spell_slots.spells[0] = Some(Fireball)
  p.mana = 3 // Fireball costs exactly 3
  p.spell_slots.cooldowns[0] = 0
  inspect(can_cast_spell(p, 0), content="true")
  p.mana = 2 // One less
  inspect(can_cast_spell(p, 0), content="false")
}

///|
test "can_cast_spell rejects when on cooldown" {
  let p = Player::new()
  p.spell_slots.spells[1] = Some(ChainLightning)
  p.mana = 10
  p.spell_slots.cooldowns[1] = 1
  inspect(can_cast_spell(p, 1), content="false")
  p.spell_slots.cooldowns[1] = 0
  inspect(can_cast_spell(p, 1), content="true")
}

///|
test "tick_spell_cooldowns decrements all slots" {
  let p = Player::new()
  p.spell_slots.cooldowns[0] = 5
  p.spell_slots.cooldowns[1] = 1
  p.spell_slots.cooldowns[2] = 0
  p.spell_slots.cooldowns[3] = 3
  tick_spell_cooldowns(p)
  inspect(p.spell_slots.cooldowns[0], content="4")
  inspect(p.spell_slots.cooldowns[1], content="0")
  inspect(p.spell_slots.cooldowns[2], content="0")
  inspect(p.spell_slots.cooldowns[3], content="2")
  // Tick again
  tick_spell_cooldowns(p)
  inspect(p.spell_slots.cooldowns[0], content="3")
  inspect(p.spell_slots.cooldowns[1], content="0")
}

// --- Boss Phase Transition Tests ---

///|
test "boss_phase_from_hp BeatDragon phase transitions" {
  // Phase 1: > 75%
  inspect(boss_phase_from_hp(BeatDragon, 30, 30), content="Phase1")
  inspect(boss_phase_from_hp(BeatDragon, 24, 30), content="Phase1")
  // Phase 2: 50-75%
  inspect(boss_phase_from_hp(BeatDragon, 22, 30), content="Phase2")
  inspect(boss_phase_from_hp(BeatDragon, 16, 30), content="Phase2")
  // Phase 3: < 50%
  inspect(boss_phase_from_hp(BeatDragon, 14, 30), content="Phase3")
  inspect(boss_phase_from_hp(BeatDragon, 1, 30), content="Phase3")
}

///|
test "boss_phase_from_hp RhythmLich phase transitions" {
  // Phase 1: > 75%
  inspect(boss_phase_from_hp(RhythmLich, 40, 40), content="Phase1")
  inspect(boss_phase_from_hp(RhythmLich, 31, 40), content="Phase1")
  // Phase 2: 50-75%
  inspect(boss_phase_from_hp(RhythmLich, 29, 40), content="Phase2")
  inspect(boss_phase_from_hp(RhythmLich, 21, 40), content="Phase2")
  // Phase 3: < 50%
  inspect(boss_phase_from_hp(RhythmLich, 19, 40), content="Phase3")
  inspect(boss_phase_from_hp(RhythmLich, 1, 40), content="Phase3")
}

///|
test "boss_phase_from_hp non-boss returns Phase1" {
  inspect(boss_phase_from_hp(Slime, 1, 2), content="Phase1")
  inspect(boss_phase_from_hp(Skeleton, 1, 3), content="Phase1")
}

///|
test "check_boss_phase_transition detects phase change" {
  let game = Game::new()
  // Start in Phase1
  inspect(game.boss_phases.dragon_phase, content="Phase1")
  // Transition to Phase2
  let changed = check_boss_phase_transition(game, BeatDragon, 20, 30)
  inspect(changed, content="true")
  inspect(game.boss_phases.dragon_phase, content="Phase2")
  // Same phase - no transition
  let changed2 = check_boss_phase_transition(game, BeatDragon, 18, 30)
  inspect(changed2, content="false")
  // Transition to Phase3
  let changed3 = check_boss_phase_transition(game, BeatDragon, 10, 30)
  inspect(changed3, content="true")
  inspect(game.boss_phases.dragon_phase, content="Phase3")
}

///|
test "check_boss_phase_transition Lich enables double summon" {
  let game = Game::new()
  let _ = check_boss_phase_transition(game, RhythmLich, 29, 40)
  inspect(game.boss_phases.lich_double_summon, content="false")
  let _ = check_boss_phase_transition(game, RhythmLich, 15, 40)
  inspect(game.boss_phases.lich_double_summon, content="true")
}

// --- Weapon Effect Lifetime Tests ---

///|
test "weapon_effect creation and update" {
  let game = Game::new()
  inspect(game.weapon_effects.length(), content="0")
  spawn_weapon_effect(game, Sword, 100.0, 200.0, East)
  inspect(game.weapon_effects.length(), content="1")
  // Effect should still be alive after small dt
  update_weapon_effects(game, 0.05)
  inspect(game.weapon_effects.length(), content="1")
  // Effect should be removed after full lifetime
  update_weapon_effects(game, 0.2)
  inspect(game.weapon_effects.length(), content="0")
}

///|
test "weapon_effect_color returns distinct colors" {
  let sword_c = weapon_effect_color(Sword)
  let bow_c = weapon_effect_color(Bow)
  inspect(sword_c.r.to_int() > bow_c.r.to_int(), content="true")
}

// --- Sound Event Queue Tests ---

///|
test "sound queue push and clear" {
  let game = Game::new()
  inspect(game.sound_queue.length(), content="0")
  push_sound(game, BeatTick)
  push_sound(game, PlayerAttack)
  inspect(game.sound_queue.length(), content="2")
  clear_sound_queue(game)
  inspect(game.sound_queue.length(), content="0")
}

///|
test "sound queue drain" {
  let game = Game::new()
  push_sound(game, BeatPerfect)
  push_sound(game, EnemyDeath)
  push_sound(game, ItemPickup)
  let events = drain_sound_queue(game)
  inspect(events.length(), content="3")
  inspect(game.sound_queue.length(), content="0")
}

///|
test "sound queue handles spell cast element" {
  let game = Game::new()
  push_sound(game, SpellCast(Fire))
  push_sound(game, SpellCast(Ice))
  inspect(game.sound_queue.length(), content="2")
  clear_sound_queue(game)
}

///|
test "sound queue handles combo milestone" {
  let game = Game::new()
  push_sound(game, ComboMilestoneSound(Fever))
  push_sound(game, ComboMilestoneSound(PerfectStorm))
  inspect(game.sound_queue.length(), content="2")
  clear_sound_queue(game)
}

// --- Curse Modifier Application Tests ---

///|
test "DoubleTime curse increases BPM constant" {
  // The curse_bpm_bonus_pct is 0.2 (20% increase)
  inspect(curse_bpm_bonus_pct > 0.0, content="true")
  let base_bpm = 120.0F
  let boosted = base_bpm * (1.0F + curse_bpm_bonus_pct)
  inspect(boosted > base_bpm, content="true")
  // 120 * 1.2 = 144
  inspect(boosted.to_int(), content="144")
}

///|
test "GlassCannon curse applies to HP" {
  let game = Game::new()
  inspect(game.player.hp, content="6")
  inspect(game.player.max_hp, content="6")
  // Simulating GlassCannon curse effect:
  game.player.max_hp = 1
  game.player.hp = 1
  inspect(game.player.hp, content="1")
  inspect(game.player.max_hp, content="1")
}

// --- Score Grade Boundary Tests ---

///|
test "score grade boundaries exact values" {
  // S threshold is 5000
  inspect(compute_score_grade(5000), content="GradeS")
  inspect(compute_score_grade(4999), content="GradeA")
  // A threshold is 3000
  inspect(compute_score_grade(3000), content="GradeA")
  inspect(compute_score_grade(2999), content="GradeB")
  // B threshold is 1500
  inspect(compute_score_grade(1500), content="GradeB")
  inspect(compute_score_grade(1499), content="GradeC")
  // Below B
  inspect(compute_score_grade(0), content="GradeC")
}

///|
test "grade_distance_text shows correct distances" {
  let t1 = grade_distance_text(6000)
  inspect(t1, content="MAX GRADE!")
  let t2 = grade_distance_text(5000)
  inspect(t2, content="MAX GRADE!")
  let t3 = grade_distance_text(4000)
  inspect(t3, content="1000 pts to S")
  let t4 = grade_distance_text(2000)
  inspect(t4, content="1000 pts to A")
  let t5 = grade_distance_text(500)
  inspect(t5, content="1000 pts to B")
}

// --- Run Statistics Tests ---

///|
test "RunStats new starts empty" {
  let rs = RunStats::new()
  inspect(rs.floor_history.length(), content="0")
  inspect(rs.total_items, content="0")
  inspect(rs.total_spells_cast, content="0")
  inspect(rs.total_damage_dealt, content="0")
  inspect(rs.total_damage_taken, content="0")
  inspect(rs.weapon_usage.length(), content="6")
}

///|
test "FloorStats new has correct defaults" {
  let fs = FloorStats::new(3)
  inspect(fs.floor_num, content="3")
  inspect(fs.enemies_killed, content="0")
  inspect(fs.perfects_hit, content="0")
  inspect(fs.items_collected, content="0")
}

///|
test "start_floor_stats initializes correctly" {
  let game = Game::new()
  start_floor_stats(game, 5)
  inspect(game.current_floor_stats.floor_num, content="5")
  inspect(game.current_floor_stats.enemies_killed, content="0")
}

///|
test "finalize_floor_stats adds to history" {
  let game = Game::new()
  start_floor_stats(game, 1)
  game.current_floor_stats.enemies_killed = 5
  game.current_floor_stats.perfects_hit = 10
  finalize_floor_stats(game)
  inspect(game.run_stats.floor_history.length(), content="1")
  inspect(game.run_stats.floor_history[0].enemies_killed, content="5")
  inspect(game.run_stats.floor_history[0].perfects_hit, content="10")
}

///|
test "record_weapon_usage tracks correctly" {
  let game = Game::new()
  record_weapon_usage(game, Sword)
  record_weapon_usage(game, Sword)
  record_weapon_usage(game, Bow)
  let (best, count) = most_used_weapon(game.run_stats)
  inspect(best, content="Sword")
  inspect(count, content="2")
}

///|
test "record_spell_usage tracks correctly" {
  let game = Game::new()
  record_spell_usage(game, Fireball)
  record_spell_usage(game, Fireball)
  record_spell_usage(game, FrostNova)
  inspect(game.run_stats.total_spells_cast, content="3")
  inspect(game.run_stats.spell_usage.length(), content="2")
}

///|
test "reset_run_stats clears everything" {
  let game = Game::new()
  record_weapon_usage(game, Sword)
  record_spell_usage(game, Fireball)
  game.run_stats.total_damage_dealt = 100
  reset_run_stats(game)
  inspect(game.run_stats.total_damage_dealt, content="0")
  inspect(game.run_stats.spell_usage.length(), content="0")
  inspect(game.run_stats.floor_history.length(), content="0")
}

// --- Boss Phase State Tests ---

///|
test "BossPhaseState new defaults" {
  let bps = BossPhaseState::new()
  inspect(bps.dragon_phase, content="Phase1")
  inspect(bps.lich_phase, content="Phase1")
  inspect(bps.lich_double_summon, content="false")
}

///|
test "reset_boss_phases resets all" {
  let game = Game::new()
  game.boss_phases.dragon_phase = Phase3
  game.boss_phases.lich_double_summon = true
  reset_boss_phases(game)
  inspect(game.boss_phases.dragon_phase, content="Phase1")
  inspect(game.boss_phases.lich_double_summon, content="false")
}

///|
test "boss_phase_name returns correct names" {
  inspect(boss_phase_name(Phase1), content="Phase 1")
  inspect(boss_phase_name(Phase2), content="Phase 2")
  inspect(boss_phase_name(Phase3), content="Phase 3")
}

// --- Weapon Switch Flash Tests ---

///|
test "weapon_switch_flash triggers and decays" {
  let game = Game::new()
  inspect(game.weapon_switch_flash, content="0")
  trigger_weapon_switch_flash(game)
  inspect(game.weapon_switch_flash > 0.0, content="true")
  // Sound event should have been pushed
  inspect(game.sound_queue.length() > 0, content="true")
  // Decay
  update_weapon_switch_flash(game, 0.1)
  inspect(game.weapon_switch_flash > 0.0, content="true")
  update_weapon_switch_flash(game, 0.3)
  inspect(game.weapon_switch_flash, content="0")
}

// --- Milestone Burst Tests ---

///|
test "spawn_milestone_burst creates particles" {
  let game = Game::new()
  let initial = game.particles.length()
  spawn_milestone_burst(game, Fever)
  inspect(game.particles.length() > initial, content="true")
  inspect(game.particles.length() >= initial + 16, content="true")
}

///|
test "Game::new has correct Phase 5 defaults" {
  let g = Game::new()
  inspect(g.sound_queue.length(), content="0")
  inspect(g.weapon_effects.length(), content="0")
  inspect(g.boss_phases.dragon_phase, content="Phase1")
  inspect(g.run_stats.total_items, content="0")
  inspect(g.weapon_switch_flash, content="0")
  inspect(g.floor_wipe_progress, content="0")
  inspect(g.boss_intro_pulse, content="0")
}
