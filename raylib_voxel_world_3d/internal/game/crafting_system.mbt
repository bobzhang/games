// Crafting system: recipe matching, crafting execution, tool durability,
// workbench and furnace logic

// ========== Tool durability tracking ==========

// Maximum durability for each tool tier

// Get the tier level of a tool (0=hand, 1=wood, 2=stone, 3=iron)

///|
/// Returns mining tier for a tool id (`0` hand, higher is stronger).
pub fn get_tool_tier(tool : Int) -> Int {
  if tool == @types.tool_hand {
    0
  } else if tool == @types.tool_wooden_pickaxe ||
    tool == @types.tool_wooden_axe ||
    tool == @types.tool_wooden_shovel ||
    tool == @types.tool_wooden_sword {
    1
  } else if tool == @types.tool_stone_pickaxe ||
    tool == @types.tool_stone_axe ||
    tool == @types.tool_stone_shovel ||
    tool == @types.tool_stone_sword {
    2
  } else if tool == @types.tool_iron_pickaxe ||
    tool == @types.tool_iron_axe ||
    tool == @types.tool_iron_shovel ||
    tool == @types.tool_iron_sword {
    3
  } else {
    0
  }
}

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

///|
/// Returns whether a tool class matches the block's preferred class.
pub fn is_correct_tool_for_block(tool : Int, block : Int) -> Bool {
  let best_class = get_best_tool_class_for_block(block)
  if best_class == 0 {
    true
  } else if best_class == 1 {
    is_pickaxe(tool)
  } else if best_class == 2 {
    is_axe(tool)
  } else if best_class == 3 {
    is_shovel(tool)
  } else {
    false
  }
}

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

///|
/// Returns whether current inventory contains all ingredients for a recipe.
pub fn can_craft_recipe(
  game : @types.Game,
  recipe : @types.CraftingRecipe,
) -> Bool {
  let has_input1 : Bool = if recipe.input1_id > 0 && recipe.input1_count > 0 {
    count_item_in_inventory(game, recipe.input1_id) >= recipe.input1_count
  } else {
    true
  }
  let has_input2 : Bool = if recipe.input2_id > 0 && recipe.input2_count > 0 {
    count_item_in_inventory(game, recipe.input2_id) >= recipe.input2_count
  } else {
    true
  }
  has_input1 && has_input2
}

// Remove a specific amount of an item from inventory

///|
/// Removes up to `count` of `item_id` from inventory and returns amount removed.
pub fn remove_item_from_inventory(
  game : @types.Game,
  item_id : Int,
  amount : Int,
) -> Bool {
  let inv = game.player.inventory
  let mut remaining = amount
  for i in 0..<@types.inventory_slots {
    if remaining <= 0 {
      return true
    }
    if inv.slots[i].item_id == item_id && inv.slots[i].count > 0 {
      let can_take : Int = if inv.slots[i].count < remaining {
        inv.slots[i].count
      } else {
        remaining
      }
      inv.slots[i].count -= can_take
      remaining -= can_take
      if inv.slots[i].count <= 0 {
        inv.slots[i].item_id = 0
        inv.slots[i].count = 0
      }
    }
  }
  remaining <= 0
}

// Execute a crafting recipe: consume inputs and produce outputs

// ========== Tool equip cycling ==========

// Cycle through tools the player owns (simplified: just cycle equipped_tool)

///|
/// Cycles equipped tool forward through available tools.
pub fn cycle_tool_forward(game : @types.Game) -> Unit {
  let mut next = game.player.equipped_tool + 1
  if next >= @types.tool_count {
    next = 0
  }
  game.player.equipped_tool = next
  let tname = @types.tool_name(next)
  @types.show_message(game, "Equipped: \{tname}", 1.5)
}

///|
/// Cycles equipped tool backward through available tools.
pub fn cycle_tool_backward(game : @types.Game) -> Unit {
  let mut prev = game.player.equipped_tool - 1
  if prev < 0 {
    prev = @types.tool_count - 1
  }
  game.player.equipped_tool = prev
  let tname = @types.tool_name(prev)
  @types.show_message(game, "Equipped: \{tname}", 1.5)
}

// Handle tool equip keys (T to cycle, number + T for specific)

// ========== Furnace smelting logic ==========

// Smelting converts raw ores to ingots (simplified as block items)
// Iron ore -> Iron Ingot (represented as block_ore_iron processed)
// Gold ore -> Gold Ingot (represented as block_ore_gold processed)

// Get smelting result for a given input block (0 if not smeltable)

///|
/// Returns smelting output item id for a given input id.
pub fn get_smelting_result(input : Int) -> Int {
  if input == @types.block_sand {
    @types.block_glass
  } else if input == @types.block_cobblestone {
    @types.block_stone
  } else if input == @types.block_clay {
    @types.block_brick
  } else if input == @types.block_wood {
    // Wood -> charcoal (represented as torch ingredient)
    @types.block_torch
  } else {
    0
  }
}

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
