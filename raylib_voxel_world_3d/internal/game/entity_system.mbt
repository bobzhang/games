// Entity system: advanced AI, pathfinding, mob spawning, mob interactions

// ========== Animal AI: random wandering ==========

// Get a random wander target near the entity's current position

// ========== Flee behavior ==========

// Calculate flee direction away from player

// ========== Hostile mob chase with simple pathfinding ==========

// Simple pathfinding: try to move toward target, avoiding walls

// ========== Mob damage and death drops ==========

// Get item drops when a mob dies

///|
/// Returns inventory drop item id for a mob kind.
pub fn get_mob_drop_id(kind : Int) -> Int {
  if kind == @types.entity_pig {
    // Pigs drop food (represented as special healing)
    @types.block_brick // cooked porkchop placeholder
  } else if kind == @types.entity_cow {
    // Cows drop leather (represented as block)
    @types.block_dirt // leather placeholder
  } else if kind == @types.entity_chicken {
    // Chickens drop feathers
    @types.block_snow // feather placeholder
  } else if kind == @types.entity_zombie {
    // Zombies drop rotten flesh (not useful, but collectible)
    @types.block_clay
  } else if kind == @types.entity_skeleton {
    // Skeletons drop bones
    @types.block_gravel
  } else if kind == @types.entity_spider {
    // Spiders drop string
    @types.block_cobblestone
  } else {
    0
  }
}

// Get number of items dropped

///|
/// Returns random drop count for a mob kind.
pub fn get_mob_drop_count(kind : Int) -> Int {
  if kind == @types.entity_pig {
    2
  } else if kind == @types.entity_cow {
    2
  } else if kind == @types.entity_chicken {
    1
  } else if kind == @types.entity_zombie {
    1
  } else if kind == @types.entity_skeleton {
    1
  } else if kind == @types.entity_spider {
    1
  } else {
    0
  }
}

// Process mob death: spawn particles, drop items, restore hunger

// ========== Mob-player collision ==========

// Check if an entity is colliding with the player

// Push entity away from player when colliding

// ========== Mob spawning logic ==========

// Get the maximum number of mobs that should be active based on time of day

// Get spawn weight for a mob type in a given biome

// ========== Entity-entity collision avoidance ==========

// Check if two entities are colliding and push them apart

// ========== Night aggression update ==========

// Update hostile mob aggression based on time of day

// ========== Entity awareness system ==========

// Check if entity can "see" the player (simple line of sight)

// ========== Entity group behavior ==========

// Passive mobs stay near each other (simple herding)

// ========== Spider special abilities ==========

// Spiders can climb walls (simplified: extra high jump near walls)

// ========== Skeleton ranged behavior ==========

// Skeletons try to maintain distance from the player
