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

// Check if the equipped tool matches the best tool class for a block

// Get the effective mining speed multiplier when using the correct tool

// ========== Crafting recipe matching ==========

// Check if inventory has enough of a specific item

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
