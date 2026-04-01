///|
let tier1_ops : Array[@types.OpKind] = [Cut, Insert]

///|
let tier2_ops : Array[@types.OpKind] = [Cut, Insert, Duplicate, Delete]

///|
let tier3_ops : Array[@types.OpKind] = [Cut, Insert, Duplicate, Invert, Delete]

///|
pub fn get_level(index : Int) -> @types.Level {
  match index {
    // === TIER 1: Lab Basics (levels 0-7) ===
    // Level 1: Hello Gene - Just verify an existing correct sequence
    0 =>
      {
        start_sequence: [A, T, G, A, A, A, T, G, A],
        target_traits: [Start, Strength, Stop],
        edit_budget: 3,
        par_edits: 1,
        min_edits: 0,
        available_ops: tier1_ops,
        name: "Hello Gene",
        description: "Verify the sequence as-is. It already matches!",
      }
    // Level 2: Single Insert - Need to insert one base
    1 =>
      {
        start_sequence: [A, T, G, A, A, T, G, A],
        target_traits: [Start, Strength, Stop],
        edit_budget: 3,
        par_edits: 2,
        min_edits: 1,
        available_ops: tier1_ops,
        name: "Missing Link",
        description: "Insert a base to complete the Strength codon.",
      }
    // Level 3: Single Cut - Remove an extra base
    2 =>
      {
        start_sequence: [A, T, G, A, A, C, A, T, G, A],
        target_traits: [Start, Strength, Stop],
        edit_budget: 3,
        par_edits: 2,
        min_edits: 1,
        available_ops: tier1_ops,
        name: "Trim the Fat",
        description: "Cut out the extra base disrupting the sequence.",
      }
    // Level 4: Build Speed - Insert T's
    3 =>
      {
        start_sequence: [A, T, G, T, T, G, A],
        target_traits: [Start, Speed, Stop],
        edit_budget: 3,
        par_edits: 2,
        min_edits: 1,
        available_ops: tier1_ops,
        name: "Need for Speed",
        description: "Add a base to form the Speed codon (TTT).",
      }
    // Level 5: Shield Up - Build GGG
    4 =>
      {
        start_sequence: [A, T, G, G, G, T, G, A],
        target_traits: [Start, Shield, Stop],
        edit_budget: 3,
        par_edits: 2,
        min_edits: 1,
        available_ops: tier1_ops,
        name: "Shield Protocol",
        description: "Insert a base to activate the Shield gene.",
      }
    // Level 6: Fix Start - ATG is broken
    5 =>
      {
        start_sequence: [A, G, A, A, A, T, G, A],
        target_traits: [Start, Strength, Stop],
        edit_budget: 4,
        par_edits: 3,
        min_edits: 2,
        available_ops: tier1_ops,
        name: "Broken Start",
        description: "Fix the start codon so the gene can be read.",
      }
    // Level 7: Two traits
    6 =>
      {
        start_sequence: [A, T, G, A, A, A, T, T, T, G, A],
        target_traits: [Start, Strength, Speed, Stop],
        edit_budget: 4,
        par_edits: 2,
        min_edits: 1,
        available_ops: tier1_ops,
        name: "Double Helix",
        description: "Fix the sequence to produce both Strength and Speed.",
      }
    // Level 8: Stealth insert
    7 =>
      {
        start_sequence: [A, T, G, C, C, T, G, A],
        target_traits: [Start, Stealth, Stop],
        edit_budget: 3,
        par_edits: 2,
        min_edits: 1,
        available_ops: tier1_ops,
        name: "Going Dark",
        description: "Complete the Stealth codon (CCC).",
      }
    // === TIER 2: Gene Editing (levels 8-16) ===
    // Level 9: First Duplicate
    8 =>
      {
        start_sequence: [A, T, G, A, A, A, T, G, A],
        target_traits: [Start, Strength, Strength, Stop],
        edit_budget: 4,
        par_edits: 2,
        min_edits: 1,
        available_ops: tier2_ops,
        name: "Copy That",
        description: "Duplicate the Strength codon to get two.",
      }
    // Level 10: Delete junk
    9 =>
      {
        start_sequence: [A, T, G, A, A, A, C, G, T, T, T, T, T, G, A],
        target_traits: [Start, Strength, Speed, Stop],
        edit_budget: 4,
        par_edits: 2,
        min_edits: 1,
        available_ops: tier2_ops,
        name: "Junk DNA",
        description: "Delete the junk bases between Strength and Speed.",
      }
    // Level 11: Heal sequence
    10 =>
      {
        start_sequence: [A, T, G, A, T, T, G, A],
        target_traits: [Start, Heal, Stop],
        edit_budget: 4,
        par_edits: 2,
        min_edits: 1,
        available_ops: tier2_ops,
        name: "First Aid",
        description: "Transform the sequence to produce the Heal trait (ATC).",
      }
    // Level 12: Poison + Armor
    11 =>
      {
        start_sequence: [A, T, G, G, A, T, T, C, A, G, A],
        target_traits: [Start, Poison, Armor, Stop],
        edit_budget: 5,
        par_edits: 3,
        min_edits: 1,
        available_ops: tier2_ops,
        name: "Toxic Armor",
        description: "Fix the reading frame: Poison (GAT) then Armor (TCA).",
      }
    // Level 13: Triple trait
    12 =>
      {
        start_sequence: [A, T, G, A, A, A, G, G, G, T, T, T, T, G, A],
        target_traits: [Start, Strength, Shield, Speed, Stop],
        edit_budget: 4,
        par_edits: 2,
        min_edits: 0,
        available_ops: tier2_ops,
        name: "Triple Threat",
        description: "This sequence already has three traits. Verify it!",
      }
    // Level 14: Duplicate and modify
    13 =>
      {
        start_sequence: [A, T, G, G, G, G, T, G, A],
        target_traits: [Start, Shield, Shield, Stop],
        edit_budget: 4,
        par_edits: 2,
        min_edits: 1,
        available_ops: tier2_ops,
        name: "Double Shield",
        description: "Duplicate the Shield codon for double protection.",
      }
    // Level 15: Vision quest
    14 =>
      {
        start_sequence: [A, T, G, A, C, G, T, G, A],
        target_traits: [Start, Vision, Stop],
        edit_budget: 5,
        par_edits: 3,
        min_edits: 2,
        available_ops: tier2_ops,
        name: "Vision Quest",
        description: "Rearrange bases to form the Vision codon (AGC).",
      }
    // Level 16: Long sequence cleanup
    15 =>
      {
        start_sequence: [
          A,
          T,
          G,
          A,
          A,
          A,
          C,
          T,
          G,
          G,
          G,
          T,
          T,
          T,
          A,
          T,
          C,
          T,
          G,
          A,
        ],
        target_traits: [Start, Strength, Shield, Speed, Heal, Stop],
        edit_budget: 5,
        par_edits: 3,
        min_edits: 1,
        available_ops: tier2_ops,
        name: "Gene Therapy",
        description: "Remove junk to reveal the correct trait sequence.",
      }
    // Level 17: Build from scratch
    16 =>
      {
        start_sequence: [A, T, G, T, G, A],
        target_traits: [Start, Poison, Stop],
        edit_budget: 5,
        par_edits: 4,
        min_edits: 3,
        available_ops: tier2_ops,
        name: "Poison Craft",
        description: "Insert bases to build the Poison trait (GAT).",
      }
    // === TIER 3: Mastery (levels 17-24) ===
    // Level 18: First Invert
    17 =>
      {
        start_sequence: [A, T, G, G, T, A, T, G, A],
        target_traits: [Start, Poison, Stop],
        edit_budget: 3,
        par_edits: 2,
        min_edits: 1,
        available_ops: tier3_ops,
        name: "Mirror Gene",
        description: "Invert a range to form the Poison codon (GAT).",
      }
    // Level 19: Invert to fix start
    18 =>
      {
        start_sequence: [G, T, A, A, A, A, T, G, A],
        target_traits: [Start, Strength, Stop],
        edit_budget: 3,
        par_edits: 2,
        min_edits: 1,
        available_ops: tier3_ops,
        name: "Flip Start",
        description: "Invert the broken start codon to read correctly.",
      }
    // Level 20: Complex invert
    19 =>
      {
        start_sequence: [A, T, G, T, T, T, A, A, A, T, G, A],
        target_traits: [Start, Strength, Speed, Stop],
        edit_budget: 3,
        par_edits: 2,
        min_edits: 1,
        available_ops: tier3_ops,
        name: "Swap Meet",
        description: "Invert the two codons to swap their positions.",
      }
    // Level 21: Tight budget
    20 =>
      {
        start_sequence: [A, T, G, C, C, C, G, G, G, T, G, A],
        target_traits: [Start, Shield, Stealth, Stop],
        edit_budget: 3,
        par_edits: 2,
        min_edits: 1,
        available_ops: tier3_ops,
        name: "Swap Shield",
        description: "Swap Shield and Stealth positions with an invert.",
      }
    // Level 22: Multi-operation puzzle
    21 =>
      {
        start_sequence: [A, T, G, A, A, A, C, G, T, T, T, T, G, A],
        target_traits: [Start, Strength, Speed, Heal, Stop],
        edit_budget: 5,
        par_edits: 3,
        min_edits: 2,
        available_ops: tier3_ops,
        name: "Gene Surgeon",
        description: "Use multiple operations to fix this complex sequence.",
      }
    // Level 23: Duplicate + Invert combo
    22 =>
      {
        start_sequence: [A, T, G, G, A, T, T, G, A],
        target_traits: [Start, Poison, Poison, Stop],
        edit_budget: 4,
        par_edits: 2,
        min_edits: 1,
        available_ops: tier3_ops,
        name: "Double Poison",
        description: "Duplicate the Poison codon for a lethal combo.",
      }
    // Level 24: Full challenge
    23 =>
      {
        start_sequence: [A, T, G, T, T, T, C, C, C, A, A, A, G, G, G, T, G, A],
        target_traits: [Start, Strength, Speed, Shield, Stealth, Stop],
        edit_budget: 5,
        par_edits: 3,
        min_edits: 2,
        available_ops: tier3_ops,
        name: "Master Splice",
        description: "Reorder all four traits into the correct sequence.",
      }
    // Level 25: Ultimate puzzle
    _ =>
      {
        start_sequence: [A, T, G, A, G, C, G, A, T, A, T, C, T, C, A, T, G, A],
        target_traits: [Start, Vision, Poison, Heal, Armor, Stop],
        edit_budget: 4,
        par_edits: 2,
        min_edits: 0,
        available_ops: tier3_ops,
        name: "Perfect Gene",
        description: "The sequence is already perfect. Can you see it?",
      }
  }
}

///|
pub fn get_tier_levels(tier : Int) -> Array[Int] {
  let offset = @types.tier_level_offset(tier)
  let count = @types.tier_level_count(tier)
  let result : Array[Int] = Array::new(capacity=count)
  for i in 0..<count {
    result.push(offset + i)
  }
  result
}

///|
pub fn is_tier_unlocked(tier : Int, scores : Array[@types.LevelScore]) -> Bool {
  if tier == 0 {
    return true
  }
  // Need at least half the previous tier completed
  let prev_offset = @types.tier_level_offset(tier - 1)
  let prev_count = @types.tier_level_count(tier - 1)
  let mut completed = 0
  for i in 0..<prev_count {
    if scores[prev_offset + i].completed {
      completed += 1
    }
  }
  completed >= prev_count / 2
}

///|
pub fn tier_stars(tier : Int, scores : Array[@types.LevelScore]) -> Int {
  let offset = @types.tier_level_offset(tier)
  let count = @types.tier_level_count(tier)
  let mut total = 0
  for i in 0..<count {
    total += scores[offset + i].stars
  }
  total
}

///|
pub fn tier_completed(tier : Int, scores : Array[@types.LevelScore]) -> Int {
  let offset = @types.tier_level_offset(tier)
  let count = @types.tier_level_count(tier)
  let mut total = 0
  for i in 0..<count {
    if scores[offset + i].completed {
      total += 1
    }
  }
  total
}
