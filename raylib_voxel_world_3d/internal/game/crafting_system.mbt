// Crafting system: recipe matching, crafting execution, tool durability,
// workbench and furnace logic

// ========== Tool durability tracking ==========

// Maximum durability for each tool tier

// Get the tier level of a tool (0=hand, 1=wood, 2=stone, 3=iron)

// Check if a tool is a pickaxe type

///|
/// Returns whether a tool id is any pickaxe variant.
pub fn is_pickaxe(tool : Int) -> Bool {
  tool == @types.tool_wooden_pickaxe ||
  tool == @types.tool_stone_pickaxe ||
  tool == @types.tool_iron_pickaxe
}

// Check if a tool is an axe type

///|
/// Returns whether a tool id is any axe variant.
pub fn is_axe(tool : Int) -> Bool {
  tool == @types.tool_wooden_axe ||
  tool == @types.tool_stone_axe ||
  tool == @types.tool_iron_axe
}

// Check if a tool is a shovel type

///|
/// Returns whether a tool id is any shovel variant.
pub fn is_shovel(tool : Int) -> Bool {
  tool == @types.tool_wooden_shovel ||
  tool == @types.tool_stone_shovel ||
  tool == @types.tool_iron_shovel
}

// Check if a tool is a sword type

///|
/// Returns whether a tool id is any sword variant.
pub fn is_sword(tool : Int) -> Bool {
  tool == @types.tool_wooden_sword ||
  tool == @types.tool_stone_sword ||
  tool == @types.tool_iron_sword
}

// Get the best tool type for breaking a given block

///|
/// Returns preferred tool class for efficiently mining a block id.
pub fn get_best_tool_class_for_block(block : Int) -> Int {
  // Returns: 0=any, 1=pickaxe, 2=axe, 3=shovel, 4=sword
  if block == @types.block_stone ||
    block == @types.block_cobblestone ||
    block == @types.block_ore_iron ||
    block == @types.block_ore_gold ||
    block == @types.block_ore_diamond ||
    block == @types.block_brick {
    1
  } else if block == @types.block_wood ||
    block == @types.block_planks ||
    block == @types.block_leaves {
    2
  } else if block == @types.block_dirt ||
    block == @types.block_grass ||
    block == @types.block_sand ||
    block == @types.block_gravel ||
    block == @types.block_clay ||
    block == @types.block_snow {
    3
  } else {
    0
  }
}

// Check if the equipped tool matches the best tool class for a block

// Get the effective mining speed multiplier when using the correct tool

// ========== Crafting recipe matching ==========

// Check if inventory has enough of a specific item

///|
/// Counts total quantity of `item_id` across player inventory slots.
pub fn count_item_in_inventory(game : @types.Game, item_id : Int) -> Int {
  let inv = game.player.inventory
  let mut total = 0
  for i in 0..<@types.inventory_slots {
    if inv.slots[i].item_id == item_id && inv.slots[i].count > 0 {
      total += inv.slots[i].count
    }
  }
  total
}

// Check if a recipe can be crafted with current inventory

// Remove a specific amount of an item from inventory

// Execute a crafting recipe: consume inputs and produce outputs

// ========== Tool equip cycling ==========

// Cycle through tools the player owns (simplified: just cycle equipped_tool)

// Handle tool equip keys (T to cycle, number + T for specific)

// ========== Furnace smelting logic ==========

// Smelting converts raw ores to ingots (simplified as block items)
// Iron ore -> Iron Ingot (represented as block_ore_iron processed)
// Gold ore -> Gold Ingot (represented as block_ore_gold processed)

// Get smelting result for a given input block (0 if not smeltable)

// Get smelting time in seconds for a given input

// Check if a block is smeltable

// ========== Quick-craft helpers ==========

// Find the first available recipe the player can craft

// Count how many recipes the player can currently craft

// ========== Tool crafting requirement check ==========

// Check if the player has the required tool tier to mine certain ores

// Get bonus drops when using correct tool

// ========== Workbench interaction ==========

// When player interacts with a workbench block, open crafting UI

// ========== Crafting category helpers ==========

// Get the category of a recipe for UI grouping

// Get category name
