///|
/// All 25 levels. Returns the level definition by index (0-24).
pub fn get_level(index : Int) -> @types.Level {
  match index {
    // === Tier 1: Apprentice (8 levels) - Single reactions ===
    // Level 1: Make Steam (Fire + Water)
    0 =>
      {
        tier: Apprentice,
        target: Steam,
        budget: @types.new_budget(2, 2, 0, 0, 0, 0),
        par_steps: 2,
        hint: "Fire and Water create something gaseous...",
      }
    // Level 2: Make Mud (Water + Earth)
    1 =>
      {
        tier: Apprentice,
        target: Mud,
        budget: @types.new_budget(0, 2, 2, 0, 0, 0),
        par_steps: 2,
        hint: "Water soaks into Earth...",
      }
    // Level 3: Make Magma (Fire + Earth)
    2 =>
      {
        tier: Apprentice,
        target: Magma,
        budget: @types.new_budget(2, 0, 2, 0, 0, 0),
        par_steps: 2,
        hint: "Fire melts the Earth itself...",
      }
    // Level 4: Make Ice (Air + Water)
    3 =>
      {
        tier: Apprentice,
        target: Ice,
        budget: @types.new_budget(0, 2, 0, 2, 0, 0),
        par_steps: 2,
        hint: "Cold Air freezes Water...",
      }
    // Level 5: Make Lightning (Fire + Air)
    4 =>
      {
        tier: Apprentice,
        target: Lightning,
        budget: @types.new_budget(2, 0, 0, 2, 0, 0),
        par_steps: 2,
        hint: "Heat rises through the Air...",
      }
    // Level 6: Make Dust (Earth + Air)
    5 =>
      {
        tier: Apprentice,
        target: Dust,
        budget: @types.new_budget(0, 0, 2, 2, 0, 0),
        par_steps: 2,
        hint: "Wind erodes the Earth...",
      }
    // Level 7: Make Void (Light + Shadow)
    6 =>
      {
        tier: Apprentice,
        target: Void,
        budget: @types.new_budget(0, 0, 0, 0, 2, 2),
        par_steps: 2,
        hint: "When Light meets Shadow, nothing remains...",
      }
    // Level 8: Make Steam again but with distractors
    7 =>
      {
        tier: Apprentice,
        target: Steam,
        budget: @types.new_budget(2, 2, 2, 1, 0, 0),
        par_steps: 2,
        hint: "Not all elements are needed. Choose wisely.",
      }
    // === Tier 2: Journeyman (9 levels) - Multi-step chains ===
    // Level 9: Make Clay (Fire+Water->Steam, Steam+Earth->Clay)
    8 =>
      {
        tier: Journeyman,
        target: Clay,
        budget: @types.new_budget(2, 2, 2, 0, 0, 0),
        par_steps: 3,
        hint: "Steam and Earth have an affinity...",
      }
    // Level 10: Make Storm (Fire+Air->Lightning, Lightning+Water->Storm)
    9 =>
      {
        tier: Journeyman,
        target: Storm,
        budget: @types.new_budget(2, 2, 0, 2, 0, 0),
        par_steps: 3,
        hint: "Lightning seeks Water...",
      }
    // Level 11: Make Obsidian (Fire+Earth->Magma, Magma+Water->Obsidian)
    10 =>
      {
        tier: Journeyman,
        target: Obsidian,
        budget: @types.new_budget(2, 2, 2, 0, 0, 0),
        par_steps: 3,
        hint: "Cool the molten rock...",
      }
    // Level 12: Make Clay with limited budget
    11 =>
      {
        tier: Journeyman,
        target: Clay,
        budget: @types.new_budget(1, 1, 1, 0, 0, 0),
        par_steps: 3,
        hint: "Every element counts! No room for error.",
      }
    // Level 13: Make Storm with distractors
    12 =>
      {
        tier: Journeyman,
        target: Storm,
        budget: @types.new_budget(2, 2, 2, 2, 1, 1),
        par_steps: 3,
        hint: "Many paths, but only one leads to the Storm.",
      }
    // Level 14: Make Mud via Dust (Earth+Air->Dust, Dust+Water->Mud)
    13 =>
      {
        tier: Journeyman,
        target: Mud,
        budget: @types.new_budget(0, 2, 2, 2, 0, 0),
        par_steps: 3,
        hint: "Sometimes the indirect path is the only way.",
      }
    // Level 15: Make Steam via Ice (Air+Water->Ice, Ice+Fire->Steam)
    14 =>
      {
        tier: Journeyman,
        target: Steam,
        budget: @types.new_budget(1, 1, 0, 1, 0, 0),
        par_steps: 3,
        hint: "First freeze, then thaw with extreme heat.",
      }
    // Level 16: Make Obsidian with tight budget
    15 =>
      {
        tier: Journeyman,
        target: Obsidian,
        budget: @types.new_budget(1, 1, 1, 0, 0, 0),
        par_steps: 3,
        hint: "Forge, then quench. No wasted elements.",
      }
    // Level 17: Make Clay via alternative path
    16 =>
      {
        tier: Journeyman,
        target: Clay,
        budget: @types.new_budget(1, 1, 1, 1, 0, 0),
        par_steps: 3,
        hint: "Multiple paths exist. Find the right one.",
      }
    // === Tier 3: Master (8 levels) - Complex chains, tight budgets ===
    // Level 18: Make Clay with many distractors, tight budget
    17 =>
      {
        tier: Master,
        target: Clay,
        budget: @types.new_budget(1, 1, 1, 1, 1, 1),
        par_steps: 3,
        hint: "Ignore the exotic elements. Focus on basics.",
      }
    // Level 19: Make Storm, only 1 of each needed element
    18 =>
      {
        tier: Master,
        target: Storm,
        budget: @types.new_budget(1, 1, 0, 1, 0, 0),
        par_steps: 3,
        hint: "Perfect execution required.",
      }
    // Level 20: Make Obsidian with all elements available but minimal useful
    19 =>
      {
        tier: Master,
        target: Obsidian,
        budget: @types.new_budget(1, 1, 1, 2, 2, 2),
        par_steps: 3,
        hint: "Resist temptation. Use only what you need.",
      }
    // Level 21: Make Void, but Fire and Water distract
    20 =>
      {
        tier: Master,
        target: Void,
        budget: @types.new_budget(2, 2, 0, 0, 1, 1),
        par_steps: 2,
        hint: "The answer lies beyond the physical elements.",
      }
    // Level 22: Make Storm with max 1 attempt (budget = exact)
    21 =>
      {
        tier: Master,
        target: Storm,
        budget: @types.new_budget(1, 1, 0, 1, 0, 0),
        par_steps: 3,
        hint: "No second chances. Plan your chain carefully.",
      }
    // Level 23: Make Clay then (represented as Clay target with very tight)
    22 =>
      {
        tier: Master,
        target: Clay,
        budget: @types.new_budget(1, 1, 1, 0, 0, 0),
        par_steps: 3,
        hint: "Three elements. Three steps. One solution.",
      }
    // Level 24: Make Obsidian with only what you need + 1 trap element
    23 =>
      {
        tier: Master,
        target: Obsidian,
        budget: @types.new_budget(1, 1, 1, 1, 0, 0),
        par_steps: 3,
        hint: "Air is a trap. Don't use it.",
      }
    // Level 25: Grand finale - Make Storm with all elements, tight budget
    24 =>
      {
        tier: Master,
        target: Storm,
        budget: @types.new_budget(1, 1, 1, 1, 1, 1),
        par_steps: 3,
        hint: "The final test. Master the Crucible.",
      }
    _ =>
      // Fallback - should never happen
      {
        tier: Apprentice,
        target: Steam,
        budget: @types.new_budget(3, 3, 0, 0, 0, 0),
        par_steps: 2,
        hint: "Default level",
      }
  }
}

///|
/// Get all levels for a given tier.
pub fn get_tier_levels(tier : @types.Tier) -> Array[@types.Level] {
  let start = @types.tier_start_index(tier)
  let count = @types.tier_level_count(tier)
  let result : Array[@types.Level] = []
  for i in start..<(start + count) {
    result.push(get_level(i))
  }
  result
}

///|
/// Check if a tier is unlocked (first tier always unlocked, others need previous tier completed).
pub fn is_tier_unlocked(
  tier : @types.Tier,
  scores : Array[@types.LevelScore],
) -> Bool {
  match tier {
    Apprentice => true
    Journeyman => {
      // Need at least 5 of 8 Apprentice levels completed
      let mut completed = 0
      for i in 0..<8 {
        if scores[i].completed {
          completed += 1
        }
      }
      completed >= 5
    }
    Master => {
      // Need at least 6 of 9 Journeyman levels completed
      let mut completed = 0
      for i in 8..<17 {
        if scores[i].completed {
          completed += 1
        }
      }
      completed >= 6
    }
  }
}
