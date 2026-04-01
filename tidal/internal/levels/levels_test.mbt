///|
test "all 30 levels load without panic" {
  let levels = @levels.get_all_levels()
  inspect(levels.length(), content="30")
}

///|
test "correct number of levels per tier" {
  let levels = @levels.get_all_levels()
  let mut tier0 = 0
  let mut tier1 = 0
  let mut tier2 = 0
  for level in levels {
    match level.tier {
      0 => tier0 += 1
      1 => tier1 += 1
      2 => tier2 += 1
      _ => ()
    }
  }
  inspect(tier0, content="10")
  inspect(tier1, content="10")
  inspect(tier2, content="10")
}

///|
test "level indices within tier are sequential" {
  let levels = @levels.get_all_levels()
  for t in 0..<3 {
    let mut expected_idx = 0
    for level in levels {
      if level.tier == t {
        inspect(level.index, content=expected_idx.to_string())
        expected_idx += 1
      }
    }
  }
}

///|
test "all levels have at least one target" {
  let levels = @levels.get_all_levels()
  for level in levels {
    assert_true(level.targets.length() > 0)
  }
}

///|
test "all targets within grid bounds" {
  let levels = @levels.get_all_levels()
  for level in levels {
    for target in level.targets {
      assert_true(@types.grid_in_bounds(target.x, target.y))
    }
  }
}

///|
test "all pre-placed objects within grid bounds" {
  let levels = @levels.get_all_levels()
  for level in levels {
    for pp in level.pre_placed {
      assert_true(@types.grid_in_bounds(pp.x, pp.y))
    }
  }
}

///|
test "target amplitude ranges are valid" {
  let levels = @levels.get_all_levels()
  for level in levels {
    for target in level.targets {
      assert_true(target.min_amp >= 0.0)
      assert_true(target.max_amp <= 1.0)
      assert_true(target.min_amp <= target.max_amp)
    }
  }
}

///|
test "target phases are valid" {
  let levels = @levels.get_all_levels()
  for level in levels {
    for target in level.targets {
      // phase: -1 means any, 0-3 are valid phases
      assert_true(target.phase >= -1 && target.phase <= 3)
    }
  }
}

///|
test "all levels have at least one budget slot" {
  let levels = @levels.get_all_levels()
  for level in levels {
    assert_true(level.budget.length() > 0)
  }
}

///|
test "budget totals are positive" {
  let levels = @levels.get_all_levels()
  for level in levels {
    for b in level.budget {
      assert_true(b.total > 0)
    }
  }
}

///|
test "budget used starts at zero" {
  let levels = @levels.get_all_levels()
  for level in levels {
    for b in level.budget {
      inspect(b.used, content="0")
    }
  }
}

///|
test "par values are positive" {
  let levels = @levels.get_all_levels()
  for level in levels {
    assert_true(level.par_objects > 0)
    assert_true(level.par_ticks > 0)
  }
}

///|
test "par objects does not exceed total budget" {
  let levels = @levels.get_all_levels()
  for level in levels {
    let mut total_budget = 0
    for b in level.budget {
      total_budget += b.total
    }
    assert_true(level.par_objects <= total_budget)
  }
}

///|
test "par ticks within max tick limit" {
  let levels = @levels.get_all_levels()
  for level in levels {
    assert_true(level.par_ticks <= @types.max_ticks)
  }
}

///|
test "targets do not overlap with pre-placed walls" {
  let levels = @levels.get_all_levels()
  for level in levels {
    for target in level.targets {
      for pp in level.pre_placed {
        if target.x == pp.x && target.y == pp.y {
          // Target should not share position with a wall
          match pp.kind {
            Wall => assert_true(false)
            _ => ()
          }
        }
      }
    }
  }
}

///|
test "level names are not empty" {
  let levels = @levels.get_all_levels()
  for level in levels {
    assert_true(level.name.length() > 0)
  }
}

///|
test "tier names are valid" {
  inspect(@levels.tier_name(0), content="Propagation")
  inspect(@levels.tier_name(1), content="Reflection")
  inspect(@levels.tier_name(2), content="Phase")
  inspect(@levels.tier_name(3), content="Unknown")
}

///|
test "get_level matches get_all_levels" {
  let levels = @levels.get_all_levels()
  for i in 0..<30 {
    let level = @levels.get_level(i)
    inspect(level.name, content=levels[i].name)
    inspect(level.tier, content=levels[i].tier.to_string())
    inspect(level.index, content=levels[i].index.to_string())
  }
}

///|
test "tier 1 levels only have emitter budget" {
  let levels = @levels.get_all_levels()
  for i in 0..<10 {
    let level = levels[i]
    for b in level.budget {
      assert_true(b.kind == PlaceEmitter)
    }
  }
}

///|
test "pre-placed emitters do not overlap with targets" {
  let levels = @levels.get_all_levels()
  for level in levels {
    for pp in level.pre_placed {
      match pp.kind {
        Emitter(_) =>
          for target in level.targets {
            let same = pp.x == target.x && pp.y == target.y
            assert_true(!same)
          }
        _ => ()
      }
    }
  }
}
