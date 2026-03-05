// Block color definitions (r, g, b) for each block type
// Expanded to cover all 24 block types

///|
/// Returns red channel for top-face color of a block id.
pub fn block_color_r(kind : Int) -> Int {
  if kind == @types.block_dirt {
    139
  } else if kind == @types.block_grass {
    76
  } else if kind == @types.block_stone {
    128
  } else if kind == @types.block_wood {
    139
  } else if kind == @types.block_leaves {
    34
  } else if kind == @types.block_water {
    64
  } else if kind == @types.block_sand {
    210
  } else if kind == @types.block_glass {
    200
  } else if kind == @types.block_brick {
    178
  } else if kind == @types.block_ore_iron {
    140
  } else if kind == @types.block_ore_gold {
    180
  } else if kind == @types.block_ore_diamond {
    100
  } else if kind == @types.block_snow {
    240
  } else if kind == @types.block_gravel {
    130
  } else if kind == @types.block_planks {
    180
  } else if kind == @types.block_cobblestone {
    110
  } else if kind == @types.block_torch {
    255
  } else if kind == @types.block_bedrock {
    50
  } else if kind == @types.block_flower_red {
    220
  } else if kind == @types.block_flower_yellow {
    255
  } else if kind == @types.block_tall_grass {
    60
  } else if kind == @types.block_cactus {
    30
  } else if kind == @types.block_clay {
    160
  } else {
    255
  }
}

///|
/// Returns green channel for top-face color of a block id.
pub fn block_color_g(kind : Int) -> Int {
  if kind == @types.block_dirt {
    90
  } else if kind == @types.block_grass {
    153
  } else if kind == @types.block_stone {
    128
  } else if kind == @types.block_wood {
    90
  } else if kind == @types.block_leaves {
    139
  } else if kind == @types.block_water {
    164
  } else if kind == @types.block_sand {
    180
  } else if kind == @types.block_glass {
    220
  } else if kind == @types.block_brick {
    90
  } else if kind == @types.block_ore_iron {
    130
  } else if kind == @types.block_ore_gold {
    160
  } else if kind == @types.block_ore_diamond {
    200
  } else if kind == @types.block_snow {
    245
  } else if kind == @types.block_gravel {
    125
  } else if kind == @types.block_planks {
    140
  } else if kind == @types.block_cobblestone {
    110
  } else if kind == @types.block_torch {
    200
  } else if kind == @types.block_bedrock {
    50
  } else if kind == @types.block_flower_red {
    40
  } else if kind == @types.block_flower_yellow {
    220
  } else if kind == @types.block_tall_grass {
    140
  } else if kind == @types.block_cactus {
    130
  } else if kind == @types.block_clay {
    155
  } else {
    255
  }
}

///|
/// Returns blue channel for top-face color of a block id.
pub fn block_color_b(kind : Int) -> Int {
  if kind == @types.block_dirt {
    43
  } else if kind == @types.block_grass {
    0
  } else if kind == @types.block_stone {
    128
  } else if kind == @types.block_wood {
    43
  } else if kind == @types.block_leaves {
    34
  } else if kind == @types.block_water {
    223
  } else if kind == @types.block_sand {
    140
  } else if kind == @types.block_glass {
    240
  } else if kind == @types.block_brick {
    60
  } else if kind == @types.block_ore_iron {
    150
  } else if kind == @types.block_ore_gold {
    50
  } else if kind == @types.block_ore_diamond {
    240
  } else if kind == @types.block_snow {
    250
  } else if kind == @types.block_gravel {
    120
  } else if kind == @types.block_planks {
    80
  } else if kind == @types.block_cobblestone {
    105
  } else if kind == @types.block_torch {
    50
  } else if kind == @types.block_bedrock {
    50
  } else if kind == @types.block_flower_red {
    50
  } else if kind == @types.block_flower_yellow {
    50
  } else if kind == @types.block_tall_grass {
    30
  } else if kind == @types.block_cactus {
    50
  } else if kind == @types.block_clay {
    145
  } else {
    255
  }
}

// Darker shade for block sides

// Even darker shade for block bottom

// Block alpha (water and glass are semi-transparent)

///|
/// Returns alpha channel for a block id (`255` opaque, lower for translucency).
pub fn block_alpha(kind : Int) -> Int {
  if kind == @types.block_water {
    160
  } else if kind == @types.block_glass {
    120
  } else if kind == @types.block_leaves {
    230
  } else {
    255
  }
}

// ========== Biome Definitions ==========

// ========== Fog colors per time of day ==========

///|
/// Returns fog red channel for day/night state.
pub fn fog_color_r(is_night : Bool) -> Int {
  if is_night {
    15
  } else {
    180
  }
}

///|
/// Returns fog green channel for day/night state.
pub fn fog_color_g(is_night : Bool) -> Int {
  if is_night {
    15
  } else {
    200
  }
}

///|
/// Returns fog blue channel for day/night state.
pub fn fog_color_b(is_night : Bool) -> Int {
  if is_night {
    40
  } else {
    220
  }
}

// ========== Crafting Recipes ==========

///|
/// Returns full crafting recipe catalog used by crafting UI and execution.
pub fn get_crafting_recipes() -> Array[@types.CraftingRecipe] {
  let recipes : Array[@types.CraftingRecipe] = []
  // Wood -> Planks (1 wood = 4 planks)
  recipes.push(
    @types.CraftingRecipe::new(
      @types.block_wood, 1, 0, 0, @types.block_planks, 4, "Wood -> Planks",
    ),
  )
  // Planks -> Sticks (not a block, but stored as item)
  // Stone + Cobblestone -> Brick
  recipes.push(
    @types.CraftingRecipe::new(
      @types.block_cobblestone, 4, 0, 0, @types.block_brick, 1, "Cobblestone -> Brick",
    ),
  )
  // Sand -> Glass (smelting)
  recipes.push(
    @types.CraftingRecipe::new(
      @types.block_sand, 4, 0, 0, @types.block_glass, 1, "Sand -> Glass",
    ),
  )
  // Cobblestone -> Stone (smelting)
  recipes.push(
    @types.CraftingRecipe::new(
      @types.block_cobblestone, 1, 0, 0, @types.block_stone, 1, "Cobblestone -> Stone",
    ),
  )
  // Clay -> Brick
  recipes.push(
    @types.CraftingRecipe::new(
      @types.block_clay, 4, 0, 0, @types.block_brick, 2, "Clay -> Bricks",
    ),
  )
  // Dirt + Sand -> Gravel
  recipes.push(
    @types.CraftingRecipe::new(
      @types.block_dirt, 2, @types.block_sand, 2, @types.block_gravel, 4, "Dirt+Sand -> Gravel",
    ),
  )
  // Planks -> Torch (simplified)
  recipes.push(
    @types.CraftingRecipe::new(
      @types.block_planks, 1, @types.block_wood, 1, @types.block_torch, 4, "Planks+Wood -> Torches",
    ),
  )
  // Snow -> Ice (represented as glass-like block)
  recipes.push(
    @types.CraftingRecipe::new(
      @types.block_snow, 4, 0, 0, @types.block_glass, 1, "Snow -> Ice",
    ),
  )
  // Gravel + Sand -> Cobblestone
  recipes.push(
    @types.CraftingRecipe::new(
      @types.block_gravel, 2, @types.block_sand, 2, @types.block_cobblestone, 4,
      "Gravel+Sand -> Cobblestone",
    ),
  )
  // Dirt -> Grass Block (with sunlight, simplified)
  recipes.push(
    @types.CraftingRecipe::new(
      @types.block_dirt, 4, @types.block_leaves, 1, @types.block_grass, 4, "Dirt+Leaves -> Grass",
    ),
  )
  // Stone + Sand -> Brick Wall
  recipes.push(
    @types.CraftingRecipe::new(
      @types.block_stone, 2, @types.block_sand, 1, @types.block_brick, 2, "Stone+Sand -> Bricks",
    ),
  )
  // Leaves -> Tall Grass (decoration crafting)
  recipes.push(
    @types.CraftingRecipe::new(
      @types.block_leaves, 4, 0, 0, @types.block_tall_grass, 2, "Leaves -> Tall Grass",
    ),
  )
  // Wood -> Torch (simple recipe)
  recipes.push(
    @types.CraftingRecipe::new(
      @types.block_wood, 2, 0, 0, @types.block_torch, 2, "Wood -> Torches",
    ),
  )
  // Cobblestone + Dirt -> Gravel
  recipes.push(
    @types.CraftingRecipe::new(
      @types.block_cobblestone, 2, @types.block_dirt, 1, @types.block_gravel, 3,
      "Cobble+Dirt -> Gravel",
    ),
  )
  // Sand + Glass -> Decorative Glass
  recipes.push(
    @types.CraftingRecipe::new(
      @types.block_sand, 2, @types.block_glass, 1, @types.block_glass, 3, "Sand+Glass -> More Glass",
    ),
  )
  // Clay + Sand -> Brick (alternate)
  recipes.push(
    @types.CraftingRecipe::new(
      @types.block_clay, 2, @types.block_sand, 2, @types.block_brick, 3, "Clay+Sand -> Bricks",
    ),
  )
  recipes
}

// ========== Mob spawn tables ==========

// Returns a mob type suitable for this biome; 0 = no spawn

///|
/// Chooses spawn mob type for biome/night context from RNG roll.
pub fn get_spawn_type_for_biome(
  biome : @types.Biome,
  is_night : Bool,
  rng_val : Int,
) -> Int {
  let r = rng_val % 100
  if is_night {
    // Hostile mobs at night
    if r < 40 {
      @types.entity_zombie
    } else if r < 65 {
      @types.entity_skeleton
    } else if r < 80 {
      @types.entity_spider
    } else {
      0
    }
    // Passive mobs during day, biome-dependent
  } else {
    match biome {
      Plains =>
        if r < 35 {
          @types.entity_cow
        } else if r < 65 {
          @types.entity_pig
        } else if r < 85 {
          @types.entity_chicken
        } else {
          0
        }
      Forest =>
        if r < 30 {
          @types.entity_pig
        } else if r < 55 {
          @types.entity_chicken
        } else if r < 70 {
          @types.entity_cow
        } else {
          0
        }
      Desert =>
        // Very few spawns in desert
        if r < 10 {
          @types.entity_chicken
        } else {
          0
        }
      Mountains =>
        if r < 25 {
          @types.entity_cow
        } else {
          0
        }
      Tundra =>
        if r < 20 {
          @types.entity_cow
        } else if r < 35 {
          @types.entity_pig
        } else {
          0
        }
      Swamp =>
        if r < 20 {
          @types.entity_pig
        } else if r < 40 {
          @types.entity_chicken
        } else {
          0
        }
    }
  }
}

// ========== Ore distribution ==========

// ========== Structure templates ==========

// Simple house dimensions

// Get block for a house at relative position

// ========== Biome parameters definitions ==========

// ========== Ore distribution tables per depth ==========

// Get ore spawn chance at a given depth for each ore type

// Get ore vein maximum size at given depth

// ========== Structure templates ==========

// Large tree template: oak tree with wider canopy

// Ruin structure template: small ruined stone walls

// Watchtower template

// ========== Mob spawn tables per biome and time of day ==========

// Get the spawn rate modifier for a biome

// Night-specific spawn multiplier

// Get the hostile mob pool for a biome at night

// ========== Damage amounts for weapons ==========

///|
/// Returns melee damage dealt by a tool when used as a weapon.
pub fn get_weapon_damage(tool : Int) -> Int {
  if tool == @types.tool_wooden_sword {
    4
  } else if tool == @types.tool_stone_sword {
    5
  } else if tool == @types.tool_iron_sword {
    7
  } else if tool == @types.tool_wooden_axe {
    3
  } else if tool == @types.tool_stone_axe {
    4
  } else if tool == @types.tool_iron_axe {
    5
  } else {
    1
  }
}

// ========== Light emitting blocks ==========

// ========== Block hardness (for explosion/damage resistance) ==========
