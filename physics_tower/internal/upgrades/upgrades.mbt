///|
/// Attempts to purchase an upgrade. Returns true if successful.
pub fn purchase_upgrade(game : @types.Game, index : Int) -> Bool {
  if index < 0 || index >= game.upgrades.length() {
    return false
  }
  let upgrade = game.upgrades[index]
  if upgrade.purchased {
    return false
  }
  if game.total_score < upgrade.cost {
    return false
  }
  game.total_score = game.total_score - upgrade.cost
  upgrade.purchased = true
  apply_upgrade_effect(game, upgrade.kind)
  true
}

///|
/// Applies the effect of an upgrade to the game state.
fn apply_upgrade_effect(game : @types.Game, kind : @types.UpgradeKind) -> Unit {
  match kind {
    Reinforce(Wood) => game.reinforce_wood = true
    Reinforce(Stone) => game.reinforce_stone = true
    Reinforce(Steel) => game.reinforce_steel = true
    Lightweight(Wood) => game.lightweight_wood = true
    Lightweight(Stone) => game.lightweight_stone = true
    Lightweight(Steel) => game.lightweight_steel = true
    FlexJoints => game.flex_joints = true
    DeepFoundation => game.deep_foundation = true
  }
}

///|
/// Returns the effective stress threshold for a material,
/// accounting for reinforcement upgrades.
pub fn effective_strength(game : @types.Game, mat : @types.Material) -> Float {
  let base = @types.material_strength(mat)
  let reinforced = match mat {
    Wood => game.reinforce_wood
    Stone => game.reinforce_stone
    Steel => game.reinforce_steel
  }
  if reinforced {
    base * @types.reinforce_bonus
  } else {
    base
  }
}

///|
/// Returns the effective mass for a material,
/// accounting for lightweight upgrades.
pub fn effective_mass(game : @types.Game, mat : @types.Material) -> Float {
  let base = @types.material_mass(mat)
  let lightweight = match mat {
    Wood => game.lightweight_wood
    Stone => game.lightweight_stone
    Steel => game.lightweight_steel
  }
  if lightweight {
    base * @types.lightweight_factor
  } else {
    base
  }
}

///|
/// Returns the effective joint strength multiplier for hinge joints.
pub fn effective_joint_strength(game : @types.Game, kind : @types.JointKind) -> Float {
  match kind {
    Hinge =>
      if game.flex_joints {
        @types.flex_joint_bonus
      } else {
        1.0
      }
    _ => 1.0
  }
}

///|
/// Returns whether a grounded body should be immovable (deep foundation).
pub fn is_immovable(game : @types.Game, body : @types.Body) -> Bool {
  game.deep_foundation && body.grounded
}

///|
/// Applies upgrade effects to a newly placed body.
pub fn apply_body_upgrades(game : @types.Game, body : @types.Body) -> Unit {
  // Apply lightweight mass reduction
  let lightweight = match body.material {
    Wood => game.lightweight_wood
    Stone => game.lightweight_stone
    Steel => game.lightweight_steel
  }
  if lightweight {
    body.mass = body.mass * @types.lightweight_factor
  }
}

///|
/// Applies upgrade effects to a newly created joint.
pub fn apply_joint_upgrades(game : @types.Game, joint : @types.Joint) -> Unit {
  // Flex joints: hinges get strength bonus
  if game.flex_joints {
    match joint.kind {
      Hinge => {
        // We can't change strength directly since it's immutable,
        // but we track this in the check_breaks logic
        ignore(joint)
      }
      _ => ()
    }
  }
  ignore(game)
}

///|
/// Returns the number of unpurchased upgrades.
pub fn available_upgrade_count(game : @types.Game) -> Int {
  let mut count = 0
  for upgrade in game.upgrades {
    if !(upgrade.purchased) {
      count = count + 1
    }
  }
  count
}

///|
/// Returns the total number of purchased upgrades.
pub fn purchased_upgrade_count(game : @types.Game) -> Int {
  let mut count = 0
  for upgrade in game.upgrades {
    if upgrade.purchased {
      count = count + 1
    }
  }
  count
}

///|
/// Returns upgrade info formatted for display.
pub fn upgrade_display_info(
  upgrade : @types.Upgrade,
  total_score : Int
) -> (String, String, Bool) {
  let name_with_cost = upgrade.name + " [" + upgrade.cost.to_string() + "]"
  let can_buy = !(upgrade.purchased) && total_score >= upgrade.cost
  (name_with_cost, upgrade.description, can_buy)
}

///|
/// Checks if the given upgrade modifies stress thresholds.
pub fn is_stress_upgrade(kind : @types.UpgradeKind) -> Bool {
  match kind {
    Reinforce(_) => true
    _ => false
  }
}

///|
/// Checks if the given upgrade modifies mass.
pub fn is_mass_upgrade(kind : @types.UpgradeKind) -> Bool {
  match kind {
    Lightweight(_) => true
    _ => false
  }
}

///|
/// Resets all upgrades (for new game).
pub fn reset_upgrades(game : @types.Game) -> Unit {
  for upgrade in game.upgrades {
    upgrade.purchased = false
  }
  game.reinforce_wood = false
  game.reinforce_stone = false
  game.reinforce_steel = false
  game.lightweight_wood = false
  game.lightweight_stone = false
  game.lightweight_steel = false
  game.flex_joints = false
  game.deep_foundation = false
}
