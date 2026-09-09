///|
/// Checks all joints in the world for material combo synergies.
/// Returns the list of active combos that apply bonuses.
pub fn check_combos(world : @types.World) -> Array[@types.ActiveCombo] {
  let combos : Array[@types.ActiveCombo] = Array(capacity=32)
  // Track which body pairs we have already evaluated to avoid duplicates
  let checked : Array[(Int, Int)] = Array(capacity=64)
  for joint in world.joints {
    if !joint.active || joint.broken {
      continue
    }
    let id_a = joint.body_a
    let id_b = joint.body_b
    // Skip if already checked this pair
    let mut already = false
    for pair in checked {
      let (pa, pb) = pair
      if (pa == id_a && pb == id_b) || (pa == id_b && pb == id_a) {
        already = true
        break
      }
    }
    if already {
      continue
    }
    checked.push((id_a, id_b))
    // Find both bodies
    let body_a_opt = @physics.find_body(world, id_a)
    let body_b_opt = @physics.find_body(world, id_b)
    match (body_a_opt, body_b_opt) {
      (Some(body_a), Some(body_b)) => {
        if !body_a.active || body_a.broken || !body_b.active || body_b.broken {
          continue
        }
        let combo = detect_combo(body_a.material, body_b.material, id_a, id_b)
        match combo {
          Some(c) => combos.push(c)
          None => ()
        }
      }
      _ => ()
    }
  }
  combos
}

///|
/// Detects which combo, if any, applies between two materials.
fn detect_combo(
  mat_a : @types.Material,
  mat_b : @types.Material,
  id_a : Int,
  id_b : Int,
) -> @types.ActiveCombo? {
  match (mat_a, mat_b) {
    // Wood+Steel or Steel+Wood: flex bonus (joint strength *1.5)
    (Wood, Steel) | (Steel, Wood) =>
      Some({
        kind: FlexCombo,
        body_a_id: id_a,
        body_b_id: id_b,
        bonus_value: 1.5,
      })
    // Stone+Stone: monolith bonus (stress tolerance *1.3)
    (Stone, Stone) =>
      Some({
        kind: MonolithCombo,
        body_a_id: id_a,
        body_b_id: id_b,
        bonus_value: 1.3,
      })
    // Steel+Steel: reinforced bonus (mass -20%)
    (Steel, Steel) =>
      Some({
        kind: ReinforcedCombo,
        body_a_id: id_a,
        body_b_id: id_b,
        bonus_value: 0.8,
      })
    // Wood+Wood: lightweight bonus (cost -1)
    (Wood, Wood) =>
      Some({
        kind: LightweightCombo,
        body_a_id: id_a,
        body_b_id: id_b,
        bonus_value: 1.0,
      })
    _ => None
  }
}

///|
/// Applies combo bonuses to the physics world.
/// Call this after pieces are placed or during test setup.
pub fn apply_combo_bonuses(
  world : @types.World,
  combos : Array[@types.ActiveCombo],
) -> Unit {
  for combo in combos {
    match combo.kind {
      FlexCombo =>
        // Strengthen joints between wood and steel bodies
        apply_flex_combo(
          world,
          combo.body_a_id,
          combo.body_b_id,
          combo.bonus_value,
        )
      MonolithCombo =>
        // Increase stress tolerance on stone-stone pairs
        apply_monolith_combo(
          world,
          combo.body_a_id,
          combo.body_b_id,
          combo.bonus_value,
        )
      ReinforcedCombo =>
        // Reduce mass on steel-steel pairs
        apply_reinforced_combo(
          world,
          combo.body_a_id,
          combo.body_b_id,
          combo.bonus_value,
        )
      LightweightCombo =>
        // Wood-wood pairs get mass reduction
        apply_lightweight_combo(world, combo.body_a_id, combo.body_b_id)
    }
  }
}

///|
/// Flex combo: joints between body_a and body_b get strength multiplied.
fn apply_flex_combo(
  world : @types.World,
  id_a : Int,
  id_b : Int,
  mult : Float,
) -> Unit {
  for joint in world.joints {
    if !joint.active || joint.broken {
      continue
    }
    if (joint.body_a == id_a && joint.body_b == id_b) ||
      (joint.body_a == id_b && joint.body_b == id_a) {
      // Reduce stress by dividing effective stress (simulates stronger joint)
      joint.stress = joint.stress / mult
    }
  }
}

///|
/// Monolith combo: stone bodies adjacent get stress tolerance boost.
fn apply_monolith_combo(
  world : @types.World,
  id_a : Int,
  id_b : Int,
  mult : Float,
) -> Unit {
  for body in world.bodies {
    if body.id == id_a || body.id == id_b {
      if body.active && !body.broken {
        // Reduce effective stress (simulates higher tolerance)
        body.stress = body.stress / mult
      }
    }
  }
}

///|
/// Reinforced combo: steel-steel pairs get mass reduction.
fn apply_reinforced_combo(
  world : @types.World,
  id_a : Int,
  id_b : Int,
  mass_mult : Float,
) -> Unit {
  for body in world.bodies {
    if body.id == id_a || body.id == id_b {
      if body.active && !body.broken && body.material == Steel {
        // Apply mass reduction only if not already reduced
        let base_mass = @types.material_mass(body.material) *
          body.width *
          body.height *
          0.001
        let target = base_mass * mass_mult
        if body.mass > target {
          body.mass = target
        }
      }
    }
  }
}

///|
/// Lightweight combo: wood-wood pairs get slight mass reduction.
fn apply_lightweight_combo(
  world : @types.World,
  id_a : Int,
  id_b : Int,
) -> Unit {
  for body in world.bodies {
    if body.id == id_a || body.id == id_b {
      if body.active && !body.broken && body.material == Wood {
        let base_mass = @types.material_mass(body.material) *
          body.width *
          body.height *
          0.001
        let target = base_mass * 0.85
        if body.mass > target {
          body.mass = target
        }
      }
    }
  }
}

///|
/// Returns the display name for a combo kind.
pub fn combo_name(kind : @types.ComboKind) -> String {
  match kind {
    FlexCombo => "Flex Bond"
    MonolithCombo => "Monolith"
    ReinforcedCombo => "Reinforced"
    LightweightCombo => "Lightweight"
  }
}

///|
/// Returns the display description for a combo kind.
pub fn combo_description(kind : @types.ComboKind) -> String {
  match kind {
    FlexCombo => "Wood+Steel: joint strength x1.5"
    MonolithCombo => "Stone+Stone: stress tolerance x1.3"
    ReinforcedCombo => "Steel+Steel: mass -20%"
    LightweightCombo => "Wood+Wood: cost -1"
  }
}

///|
/// Returns the highlight color for a combo kind as (r, g, b).
pub fn combo_color(kind : @types.ComboKind) -> (Int, Int, Int) {
  match kind {
    FlexCombo => (100, 255, 180) // green-cyan
    MonolithCombo => (200, 200, 255) // light purple
    ReinforcedCombo => (100, 180, 255) // blue
    LightweightCombo => (255, 220, 100) // golden
  }
}

///|
/// Counts the number of active combos of each type.
pub fn count_combos(combos : Array[@types.ActiveCombo]) -> (Int, Int, Int, Int) {
  let mut flex = 0
  let mut mono = 0
  let mut rein = 0
  let mut light = 0
  for c in combos {
    match c.kind {
      FlexCombo => flex = flex + 1
      MonolithCombo => mono = mono + 1
      ReinforcedCombo => rein = rein + 1
      LightweightCombo => light = light + 1
    }
  }
  (flex, mono, rein, light)
}

///|
/// Updates the active combos on the game state.
pub fn update_game_combos(game : @types.Game) -> Unit {
  game.active_combos.clear()
  let combos = check_combos(game.world)
  for c in combos {
    game.active_combos.push(c)
  }
}
