///|
/// Pure reaction engine. Given current substance + added element, return result.
/// This encodes all 12 key reactions plus destruction rules.
pub fn react(current : @types.Element, added : @types.Element) -> @types.ReactionResult {
  // 12 key reactions (order-dependent: added is the new element, current is in cauldron)
  match (current, added) {
    // Fire + Water -> Steam
    (Fire, Water) => Transform(Steam)
    (Water, Fire) => Transform(Steam)
    // Water + Earth -> Mud
    (Water, Earth) => Transform(Mud)
    (Earth, Water) => Transform(Mud)
    // Fire + Earth -> Magma
    (Fire, Earth) => Transform(Magma)
    (Earth, Fire) => Transform(Magma)
    // Air + Water -> Ice
    (Air, Water) => Transform(Ice)
    (Water, Air) => Transform(Ice)
    // Fire + Air -> Lightning
    (Fire, Air) => Transform(Lightning)
    (Air, Fire) => Transform(Lightning)
    // Earth + Air -> Dust
    (Earth, Air) => Transform(Dust)
    (Air, Earth) => Transform(Dust)
    // Light + Shadow -> Void
    (Light, Shadow) => Transform(Void)
    (Shadow, Light) => Transform(Void)
    // Fire + Ice -> Steam
    (Ice, Fire) => Transform(Steam)
    (Fire, Ice) => Transform(Steam)
    // Lightning + Water -> Storm
    (Lightning, Water) => Transform(Storm)
    (Water, Lightning) => Transform(Storm)
    // Magma + Water -> Obsidian
    (Magma, Water) => Transform(Obsidian)
    (Water, Magma) => Transform(Obsidian)
    // Steam + Earth -> Clay
    (Steam, Earth) => Transform(Clay)
    (Earth, Steam) => Transform(Clay)
    // Dust + Water -> Mud
    (Dust, Water) => Transform(Mud)
    (Water, Dust) => Transform(Mud)
    // Destruction rules: adding incompatible element to compound
    _ =>
      if @types.is_base_element(current) && @types.is_base_element(added) {
        // Two base elements with no reaction: no reaction (shouldn't happen
        // since all base combos are covered, but just in case)
        NoReaction
      } else if @types.is_base_element(current) {
        // Adding compound to base - no reaction
        NoReaction
      } else {
        // Adding something to a compound with no matching reaction -> destroy
        Destroy
      }
  }
}

///|
/// Get the expected result for a specific pair (for recipe book display).
/// Returns None if no known reaction.
pub fn get_reaction_result(
  substance : @types.Element,
  input : @types.Element
) -> @types.ReactionResult {
  react(substance, input)
}

///|
/// All known valid reactions as (substance, input, result) tuples
pub fn all_reactions() -> Array[(@types.Element, @types.Element, @types.Element)] {
  [
    (Fire, Water, Steam),
    (Water, Fire, Steam),
    (Water, Earth, Mud),
    (Earth, Water, Mud),
    (Fire, Earth, Magma),
    (Earth, Fire, Magma),
    (Air, Water, Ice),
    (Water, Air, Ice),
    (Fire, Air, Lightning),
    (Air, Fire, Lightning),
    (Earth, Air, Dust),
    (Air, Earth, Dust),
    (Light, Shadow, Void),
    (Shadow, Light, Void),
    (Ice, Fire, Steam),
    (Fire, Ice, Steam),
    (Lightning, Water, Storm),
    (Water, Lightning, Storm),
    (Magma, Water, Obsidian),
    (Water, Magma, Obsidian),
    (Steam, Earth, Clay),
    (Earth, Steam, Clay),
    (Dust, Water, Mud),
    (Water, Dust, Mud),
  ]
}
