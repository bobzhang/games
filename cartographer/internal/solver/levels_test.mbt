///|
/// Helper: set up a grid with the given solution and verify all clues are satisfied.
fn verify_solution(
  level : @types.Level,
  placements : Array[(@types.FeatureKind, Int, Int)]
) -> Bool {
  let grid : Array[@types.FeatureKind?] = Array::make(
    level.grid_size * level.grid_size, None,
  )
  for i in 0..<placements.length() {
    let (feat, x, y) = placements[i]
    grid[y * level.grid_size + x] = Some(feat)
  }
  @solver.validate_all_clues(level.clues, grid, level.grid_size)
  let satisfied = @solver.all_clues_satisfied(level.clues)
  // Reset clue statuses
  for i in 0..<level.clues.length() {
    level.clues[i].status = Pending
  }
  satisfied
}

///|
test "level_01_solution_valid" {
  let levels = @levels.create_all_levels()
  let ok = verify_solution(levels[0], [(Mountain, 2, 2), (Town, 5, 2)])
  inspect(ok, content="true")
}

///|
test "level_01_wrong_solution_invalid" {
  let levels = @levels.create_all_levels()
  let bad = verify_solution(levels[0], [(Mountain, 0, 0), (Town, 1, 1)])
  inspect(bad, content="false")
}

///|
test "level_02_solution_valid" {
  let levels = @levels.create_all_levels()
  let ok = verify_solution(levels[1], [(Forest, 1, 1), (Lake, 1, 4)])
  inspect(ok, content="true")
}

///|
test "level_03_solution_valid" {
  let levels = @levels.create_all_levels()
  let ok = verify_solution(
    levels[2], [(Mountain, 3, 1), (River, 3, 4), (Town, 6, 1)],
  )
  inspect(ok, content="true")
}

///|
test "level_04_solution_valid" {
  let levels = @levels.create_all_levels()
  let ok = verify_solution(
    levels[3], [(Town, 2, 2), (Forest, 5, 2), (Mountain, 2, 5)],
  )
  inspect(ok, content="true")
}

///|
test "level_05_solution_valid" {
  let levels = @levels.create_all_levels()
  let ok = verify_solution(
    levels[4], [(Lake, 4, 1), (Desert, 4, 5), (Mountain, 1, 3)],
  )
  inspect(ok, content="true")
}

///|
test "level_06_solution_valid" {
  let levels = @levels.create_all_levels()
  let ok = verify_solution(
    levels[5],
    [(Town, 2, 1), (Forest, 5, 1), (River, 2, 4), (Mountain, 5, 4)],
  )
  inspect(ok, content="true")
}

///|
test "level_07_solution_valid" {
  let levels = @levels.create_all_levels()
  let ok = verify_solution(
    levels[6],
    [
      (Mountain, 3, 0),
      (Town, 3, 3),
      (Lake, 6, 3),
      (Forest, 0, 3),
      (Desert, 3, 6),
    ],
  )
  inspect(ok, content="true")
}

///|
test "level_08_solution_valid" {
  let levels = @levels.create_all_levels()
  let ok = verify_solution(
    levels[7],
    [
      (Town, 1, 2),
      (Mountain, 4, 2),
      (River, 4, 5),
      (Forest, 1, 5),
      (Lake, 7, 2),
    ],
  )
  inspect(ok, content="true")
}

///|
test "level_09_solution_valid" {
  let levels = @levels.create_all_levels()
  let ok = verify_solution(
    levels[8],
    [
      (Mountain, 0, 0),
      (Forest, 4, 0),
      (Town, 1, 1),
      (River, 2, 1),
      (Lake, 3, 1),
    ],
  )
  inspect(ok, content="true")
}

///|
test "level_10_solution_valid" {
  let levels = @levels.create_all_levels()
  let ok = verify_solution(
    levels[9],
    [
      (Town, 2, 3),
      (Mountain, 5, 3),
      (Forest, 2, 0),
      (River, 5, 6),
      (Desert, 2, 6),
    ],
  )
  inspect(ok, content="true")
}

///|
test "level_11_solution_valid" {
  let levels = @levels.create_all_levels()
  let ok = verify_solution(
    levels[10],
    [
      (Mountain, 1, 1),
      (Town, 4, 1),
      (Lake, 4, 4),
      (Forest, 1, 4),
      (River, 2, 1),
    ],
  )
  inspect(ok, content="true")
}

///|
test "level_12_solution_valid" {
  let levels = @levels.create_all_levels()
  let ok = verify_solution(
    levels[11],
    [
      (Town, 3, 2),
      (Forest, 3, 5),
      (Mountain, 6, 2),
      (Lake, 0, 5),
      (Desert, 6, 5),
    ],
  )
  inspect(ok, content="true")
}

///|
test "level_13_solution_valid" {
  let levels = @levels.create_all_levels()
  let ok = verify_solution(
    levels[12],
    [
      (Mountain, 2, 1),
      (Town, 5, 1),
      (Forest, 2, 4),
      (Lake, 5, 4),
      (River, 2, 7),
      (Desert, 5, 7),
    ],
  )
  inspect(ok, content="true")
}

///|
test "level_14_solution_valid" {
  let levels = @levels.create_all_levels()
  let ok = verify_solution(
    levels[13],
    [
      (Mountain, 0, 0),
      (Desert, 3, 0),
      (Lake, 4, 0),
      (Town, 2, 1),
      (River, 0, 2),
      (Forest, 1, 3),
    ],
  )
  inspect(ok, content="true")
}

///|
test "level_15_solution_valid" {
  let levels = @levels.create_all_levels()
  let ok = verify_solution(
    levels[14],
    [
      (Mountain, 0, 0),
      (River, 1, 0),
      (Lake, 2, 0),
      (Road, 1, 1),
      (Town, 2, 1),
      (Forest, 0, 2),
    ],
  )
  inspect(ok, content="true")
}

///|
test "level_16_solution_valid" {
  let levels = @levels.create_all_levels()
  let ok = verify_solution(
    levels[15],
    [
      (Mountain, 1, 1),
      (Town, 4, 1),
      (Forest, 7, 1),
      (Lake, 1, 4),
      (River, 4, 4),
      (Desert, 7, 4),
    ],
  )
  inspect(ok, content="true")
}

///|
test "level_17_solution_valid" {
  let levels = @levels.create_all_levels()
  let ok = verify_solution(
    levels[16],
    [
      (Desert, 0, 0),
      (Mountain, 1, 0),
      (River, 2, 0),
      (Road, 3, 0),
      (Town, 0, 2),
      (Lake, 3, 2),
      (Forest, 2, 3),
    ],
  )
  inspect(ok, content="true")
}

///|
test "level_18_solution_valid" {
  let levels = @levels.create_all_levels()
  let ok = verify_solution(
    levels[17],
    [
      (Desert, 0, 0),
      (Mountain, 1, 0),
      (River, 2, 0),
      (Road, 0, 1),
      (Lake, 3, 1),
      (Town, 0, 2),
      (Forest, 2, 3),
    ],
  )
  inspect(ok, content="true")
}

///|
test "level_19_solution_valid" {
  let levels = @levels.create_all_levels()
  let ok = verify_solution(
    levels[18],
    [
      (River, 0, 0),
      (Mountain, 1, 0),
      (Desert, 2, 0),
      (Lake, 4, 0),
      (Town, 0, 2),
      (Road, 1, 2),
      (Forest, 2, 3),
    ],
  )
  inspect(ok, content="true")
}

///|
test "level_20_solution_valid" {
  let levels = @levels.create_all_levels()
  let ok = verify_solution(
    levels[19],
    [
      (Town, 3, 1),
      (Mountain, 3, 4),
      (Forest, 6, 1),
      (Lake, 6, 4),
      (River, 0, 1),
      (Desert, 0, 4),
      (Road, 3, 7),
    ],
  )
  inspect(ok, content="true")
}

///|
test "level_21_solution_valid" {
  let levels = @levels.create_all_levels()
  let ok = verify_solution(
    levels[20],
    [
      (Road, 0, 0),
      (Mountain, 1, 0),
      (River, 2, 0),
      (Desert, 4, 0),
      (Lake, 3, 1),
      (Town, 0, 2),
      (Forest, 2, 3),
    ],
  )
  inspect(ok, content="true")
}

///|
test "level_22_solution_valid" {
  let levels = @levels.create_all_levels()
  let ok = verify_solution(
    levels[21],
    [
      (Town, 1, 1),
      (Mountain, 4, 1),
      (Forest, 7, 1),
      (Lake, 1, 4),
      (River, 4, 4),
      (Desert, 7, 4),
      (Road, 1, 7),
      (Forest, 4, 7),
    ],
  )
  inspect(ok, content="true")
}

///|
test "level_23_solution_valid" {
  let levels = @levels.create_all_levels()
  let ok = verify_solution(
    levels[22],
    [
      (Town, 3, 0),
      (Desert, 4, 0),
      (Mountain, 1, 1),
      (River, 4, 1),
      (Lake, 3, 2),
      (Road, 4, 2),
      (Forest, 0, 3),
    ],
  )
  inspect(ok, content="true")
}

///|
test "level_24_solution_valid" {
  let levels = @levels.create_all_levels()
  let ok = verify_solution(
    levels[23],
    [
      (Mountain, 0, 0),
      (Town, 1, 0),
      (Desert, 2, 0),
      (Lake, 3, 0),
      (Road, 6, 0),
      (Town, 7, 0),
      (River, 1, 1),
      (Forest, 2, 1),
    ],
  )
  inspect(ok, content="true")
}

///|
test "level_25_solution_valid" {
  let levels = @levels.create_all_levels()
  let ok = verify_solution(
    levels[24],
    [
      (Town, 1, 1),
      (Mountain, 4, 1),
      (Forest, 7, 1),
      (Lake, 1, 4),
      (River, 4, 4),
      (Desert, 7, 4),
      (Road, 1, 7),
      (Town, 4, 7),
      (Mountain, 7, 7),
      (Forest, 0, 0),
    ],
  )
  inspect(ok, content="true")
}

///|
test "all_levels_have_correct_feature_count" {
  let levels = @levels.create_all_levels()
  inspect(levels.length(), content="25")
  for i in 0..<levels.length() {
    let level = levels[i]
    // Each level must have at least 2 features and at least 2 clues
    assert_true(level.features_to_place.length() >= 2)
    assert_true(level.clues.length() >= 2)
    // Par should be >= feature count
    assert_true(level.par_placements >= level.features_to_place.length())
  }
}

///|
test "all_levels_tiers_correct" {
  let levels = @levels.create_all_levels()
  for i in 0..<8 {
    assert_eq(levels[i].tier, Surveyor)
  }
  for i in 8..<17 {
    assert_eq(levels[i].tier, Explorer)
  }
  for i in 17..<25 {
    assert_eq(levels[i].tier, Master)
  }
}

///|
test "all_levels_have_nonempty_names" {
  let levels = @levels.create_all_levels()
  for i in 0..<levels.length() {
    assert_true(levels[i].name.length() > 0)
  }
}

///|
test "all_clue_texts_nonempty" {
  let levels = @levels.create_all_levels()
  for i in 0..<levels.length() {
    for j in 0..<levels[i].clues.length() {
      assert_true(levels[i].clues[j].text.length() > 0)
    }
  }
}

///|
test "level_01_feature_counts_match" {
  let levels = @levels.create_all_levels()
  let l = levels[0]
  inspect(l.features_to_place.length(), content="2")
  // Should have Mountain and Town
  let mut has_mountain = false
  let mut has_town = false
  for i in 0..<l.features_to_place.length() {
    if l.features_to_place[i] == Mountain {
      has_mountain = true
    }
    if l.features_to_place[i] == Town {
      has_town = true
    }
  }
  inspect(has_mountain, content="true")
  inspect(has_town, content="true")
}

///|
test "level_clue_features_in_feature_list" {
  // Every feature referenced in clues should be in the features_to_place list
  let levels = @levels.create_all_levels()
  for i in 0..<levels.length() {
    let level = levels[i]
    for j in 0..<level.clues.length() {
      let clue = level.clues[j]
      // feature_a should be in features_to_place
      let mut found_a = false
      for k in 0..<level.features_to_place.length() {
        if level.features_to_place[k] == clue.feature_a {
          found_a = true
          break
        }
      }
      assert_true(found_a)
    }
  }
}
