///|
test "grid_is_walkable for various tile types" {
  let grid = Grid::new(5, 5)
  grid_set_kind(grid, 1, 1, Floor)
  grid_set_kind(grid, 2, 2, Wall)
  grid_set_kind(grid, 3, 3, Pit)
  grid_set_kind(grid, 4, 1, Ice)
  grid_set_kind(grid, 1, 4, Lava)
  inspect!(grid_is_walkable(grid, 1, 1), content="true")
  inspect!(grid_is_walkable(grid, 2, 2), content="false")
  inspect!(grid_is_walkable(grid, 3, 3), content="false")
  inspect!(grid_is_walkable(grid, 4, 1), content="true")
  inspect!(grid_is_walkable(grid, 1, 4), content="true")
}

///|
test "grid out of bounds returns false for walkable" {
  let grid = Grid::new(3, 3)
  inspect!(grid_is_walkable(grid, -1, 0), content="false")
  inspect!(grid_is_walkable(grid, 3, 0), content="false")
  inspect!(grid_is_walkable(grid, 0, -1), content="false")
}

///|
test "weapon_attack_cells Sword returns 1 cell" {
  let cells = weapon_attack_cells(Sword, East)
  inspect!(cells.length(), content="1")
  inspect!(cells[0], content="(1, 0)")
}

///|
test "weapon_attack_cells Spear returns 2 cells" {
  let cells = weapon_attack_cells(Spear, East)
  inspect!(cells.length(), content="2")
  inspect!(cells[0], content="(1, 0)")
  inspect!(cells[1], content="(2, 0)")
}

///|
test "weapon_attack_cells Whip returns 3 cells" {
  let cells = weapon_attack_cells(Whip, North)
  inspect!(cells.length(), content="3")
}

///|
test "weapon_attack_cells Staff returns 9 cells (3x3)" {
  let cells = weapon_attack_cells(Staff, South)
  inspect!(cells.length(), content="9")
}

///|
test "weapon_attack_cells Bow returns 3 cells" {
  let cells = weapon_attack_cells(Bow, West)
  inspect!(cells.length(), content="3")
  inspect!(cells[0], content="(-1, 0)")
  inspect!(cells[1], content="(-2, 0)")
  inspect!(cells[2], content="(-3, 0)")
}

///|
test "weapon_can_attack respects beat_cost" {
  // Sword has beat_cost=1, should always fire
  inspect!(weapon_can_attack(Sword, 0), content="true")
  inspect!(weapon_can_attack(Sword, 1), content="true")
  // Hammer has beat_cost=2, fires every other beat
  inspect!(weapon_can_attack(Hammer, 0), content="true")
  inspect!(weapon_can_attack(Hammer, 1), content="false")
  inspect!(weapon_can_attack(Hammer, 2), content="true")
  // Staff has beat_cost=3
  inspect!(weapon_can_attack(Staff, 0), content="true")
  inspect!(weapon_can_attack(Staff, 1), content="false")
  inspect!(weapon_can_attack(Staff, 2), content="false")
  inspect!(weapon_can_attack(Staff, 3), content="true")
}

///|
test "check_combo_milestone returns correct milestones" {
  inspect!(check_combo_milestone(5), content="NoMilestone")
  inspect!(check_combo_milestone(10), content="Fever")
  inspect!(check_combo_milestone(25), content="Frenzy")
  inspect!(check_combo_milestone(50), content="PerfectStorm")
  inspect!(check_combo_milestone(30), content="NoMilestone")
}

///|
test "combo_visual_level scaling" {
  inspect!(combo_visual_level(0), content="0")
  inspect!(combo_visual_level(4), content="0")
  inspect!(combo_visual_level(5), content="1")
  inspect!(combo_visual_level(14), content="1")
  inspect!(combo_visual_level(15), content="2")
  inspect!(combo_visual_level(29), content="2")
  inspect!(combo_visual_level(30), content="3")
  inspect!(combo_visual_level(99), content="3")
}

///|
test "floor_theme mapping" {
  inspect!(floor_theme(1), content="Meadow")
  inspect!(floor_theme(2), content="Meadow")
  inspect!(floor_theme(3), content="Cave")
  inspect!(floor_theme(4), content="Cave")
  inspect!(floor_theme(5), content="BossArena")
  inspect!(floor_theme(6), content="IceDungeon")
  inspect!(floor_theme(7), content="IceDungeon")
  inspect!(floor_theme(8), content="Volcano")
  inspect!(floor_theme(9), content="Volcano")
  inspect!(floor_theme(10), content="FinalArena")
}

///|
test "has_ability checks player abilities" {
  let player = Player::new()
  inspect!(has_ability(player, DoubleStep), content="false")
  player.abilities.push(DoubleStep)
  inspect!(has_ability(player, DoubleStep), content="true")
  inspect!(has_ability(player, CounterAttack), content="false")
}

///|
test "is_boss_floor returns correct floors" {
  inspect!(is_boss_floor(1), content="false")
  inspect!(is_boss_floor(5), content="true")
  inspect!(is_boss_floor(7), content="false")
  inspect!(is_boss_floor(10), content="true")
}

///|
test "compute_score_grade thresholds" {
  inspect!(compute_score_grade(6000), content="GradeS")
  inspect!(compute_score_grade(5000), content="GradeS")
  inspect!(compute_score_grade(4000), content="GradeA")
  inspect!(compute_score_grade(3000), content="GradeA")
  inspect!(compute_score_grade(2000), content="GradeB")
  inspect!(compute_score_grade(1000), content="GradeC")
}

///|
test "manhattan_dist calculation" {
  inspect!(manhattan_dist(0, 0, 3, 4), content="7")
  inspect!(manhattan_dist(5, 5, 5, 5), content="0")
  inspect!(manhattan_dist(1, 1, 4, 1), content="3")
}

///|
test "direction_from_to basic directions" {
  inspect!(direction_from_to(0, 0, 1, 0), content="East")
  inspect!(direction_from_to(1, 0, 0, 0), content="West")
  inspect!(direction_from_to(0, 0, 0, 1), content="South")
  inspect!(direction_from_to(0, 1, 0, 0), content="North")
}

///|
test "meta progress weapon unlocks" {
  let meta = MetaProgress::new()
  inspect!(meta.unlocked_weapons.length(), content="1")
  check_weapon_unlocks(meta, 2)
  inspect!(meta.unlocked_weapons.length(), content="2")
  check_weapon_unlocks(meta, 10)
  inspect!(meta.unlocked_weapons.length(), content="6")
}

///|
test "mastery_rating thresholds" {
  inspect!(mastery_rating(95), content="S")
  inspect!(mastery_rating(90), content="S")
  inspect!(mastery_rating(75), content="A")
  inspect!(mastery_rating(55), content="B")
  inspect!(mastery_rating(30), content="C")
}
