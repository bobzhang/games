///|
pub fn get_level(id : Int) -> @types.LevelDef {
  if id >= 0 && id < all_levels.length() {
    all_levels[id]
  } else {
    all_levels[0]
  }
}

///|
pub fn level_count() -> Int {
  all_levels.length()
}

///|
let all_levels : Array[@types.LevelDef] = make_all_levels()

///|
fn make_all_levels() -> Array[@types.LevelDef] {
  let levels : Array[@types.LevelDef] = []
  // Tier 1: 2-3 species, generous space (levels 0-6)
  levels.push(
    {
      id: 0,
      tier: 1,
      species: [Lion, Snake],
      par_tiles: 25,
      bonus_space: 4,
      description: "Welcome! Place habitats for a lion and snake.",
      preset_terrain: [(4, 3, Water), (5, 3, Water)],
      preset_fences: [],
    },
  )
  levels.push(
    {
      id: 1,
      tier: 1,
      species: [Monkey, Snake],
      par_tiles: 22,
      bonus_space: 3,
      description: "Monkeys need trees and water nearby.",
      preset_terrain: [(1, 1, Water)],
      preset_fences: [],
    },
  )
  levels.push(
    {
      id: 2,
      tier: 1,
      species: [Bear, Lion],
      par_tiles: 28,
      bonus_space: 4,
      description: "Two predators need separate enclosures.",
      preset_terrain: [],
      preset_fences: [(5, 0, false, true)],
    },
  )
  levels.push(
    {
      id: 3,
      tier: 1,
      species: [Elephant, Monkey],
      par_tiles: 30,
      bonus_space: 5,
      description: "Elephants need lots of grass and water.",
      preset_terrain: [(2, 4, Water), (3, 4, Water)],
      preset_fences: [],
    },
  )
  levels.push(
    {
      id: 4,
      tier: 1,
      species: [Penguin, Snake],
      par_tiles: 20,
      bonus_space: 3,
      description: "Penguins love water and rock.",
      preset_terrain: [],
      preset_fences: [],
    },
  )
  levels.push(
    {
      id: 5,
      tier: 1,
      species: [Lion, Monkey, Snake],
      par_tiles: 32,
      bonus_space: 5,
      description: "Three species! Plan your fences carefully.",
      preset_terrain: [(0, 0, Water)],
      preset_fences: [],
    },
  )
  levels.push(
    {
      id: 6,
      tier: 1,
      species: [Bear, Elephant, Snake],
      par_tiles: 35,
      bonus_space: 5,
      description: "Large animals need large spaces.",
      preset_terrain: [],
      preset_fences: [],
    },
  )
  // Tier 2: 4-5 species, tighter layouts (levels 7-13)
  levels.push(
    {
      id: 7,
      tier: 2,
      species: [Lion, Penguin, Snake, Monkey],
      par_tiles: 40,
      bonus_space: 6,
      description: "Four species! Keep penguins away from lions.",
      preset_terrain: [(1, 2, Water), (2, 2, Water)],
      preset_fences: [],
    },
  )
  levels.push(
    {
      id: 8,
      tier: 2,
      species: [Bear, Elephant, Lion, Snake],
      par_tiles: 42,
      bonus_space: 6,
      description: "Two predators among four species.",
      preset_terrain: [],
      preset_fences: [(5, 0, false, true)],
    },
  )
  levels.push(
    {
      id: 9,
      tier: 2,
      species: [Monkey, Bear, Penguin, Snake],
      par_tiles: 38,
      bonus_space: 5,
      description: "Bears are predators too!",
      preset_terrain: [(7, 1, Water)],
      preset_fences: [],
    },
  )
  levels.push(
    {
      id: 10,
      tier: 2,
      species: [
        Lion, Elephant, Snake, Monkey, Bear,
      ],
      par_tiles: 50,
      bonus_space: 8,
      description: "Five species, tight quarters.",
      preset_terrain: [(3, 3, Water), (4, 3, Water)],
      preset_fences: [],
    },
  )
  levels.push(
    {
      id: 11,
      tier: 2,
      species: [
        Penguin, Elephant, Snake, Monkey,
      ],
      par_tiles: 44,
      bonus_space: 7,
      description: "Water management is key.",
      preset_terrain: [],
      preset_fences: [],
    },
  )
  levels.push(
    {
      id: 12,
      tier: 2,
      species: [
        Lion, Penguin, Bear, Monkey,
      ],
      par_tiles: 46,
      bonus_space: 7,
      description: "Predator placement puzzle.",
      preset_terrain: [(0, 7, Water), (1, 7, Water)],
      preset_fences: [],
    },
  )
  levels.push(
    {
      id: 13,
      tier: 2,
      species: [
        Lion, Snake, Monkey, Elephant,
        Penguin,
      ],
      par_tiles: 52,
      bonus_space: 8,
      description: "All but the bear. Tight fit!",
      preset_terrain: [],
      preset_fences: [(3, 0, false, true), (7, 0, false, true)],
    },
  )
  // Tier 3: 5-6 species, predator spacing constraints (levels 14-19)
  levels.push(
    {
      id: 14,
      tier: 3,
      species: [
        Lion, Penguin, Elephant, Snake,
        Monkey,
      ],
      par_tiles: 48,
      bonus_space: 6,
      description: "Predator spacing is critical.",
      preset_terrain: [],
      preset_fences: [],
    },
  )
  levels.push(
    {
      id: 15,
      tier: 3,
      species: [
        Lion, Penguin, Elephant, Snake,
        Monkey, Bear,
      ],
      par_tiles: 58,
      bonus_space: 8,
      description: "All six species! The ultimate challenge.",
      preset_terrain: [(4, 4, Water), (5, 4, Water)],
      preset_fences: [],
    },
  )
  levels.push(
    {
      id: 16,
      tier: 3,
      species: [
        Bear, Penguin, Elephant, Snake,
        Monkey,
      ],
      par_tiles: 46,
      bonus_space: 5,
      description: "Bears near penguins? Careful!",
      preset_terrain: [],
      preset_fences: [(5, 4, true, false)],
    },
  )
  levels.push(
    {
      id: 17,
      tier: 3,
      species: [
        Lion, Bear, Penguin, Elephant,
        Snake, Monkey,
      ],
      par_tiles: 55,
      bonus_space: 7,
      description: "Two predators, six species, minimal space.",
      preset_terrain: [],
      preset_fences: [],
    },
  )
  levels.push(
    {
      id: 18,
      tier: 3,
      species: [
        Lion, Bear, Penguin, Snake, Monkey,
      ],
      par_tiles: 44,
      bonus_space: 5,
      description: "Expert puzzle: efficiency matters.",
      preset_terrain: [(8, 0, Water)],
      preset_fences: [],
    },
  )
  levels.push(
    {
      id: 19,
      tier: 3,
      species: [
        Lion, Penguin, Elephant, Snake,
        Monkey, Bear,
      ],
      par_tiles: 54,
      bonus_space: 10,
      description: "Master zookeeper: all species, maximum stars.",
      preset_terrain: [],
      preset_fences: [],
    },
  )
  levels
}
