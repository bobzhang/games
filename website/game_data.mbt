///|
/// Game data with descriptions and emoji icons for thumbnails
pub(all) struct GameInfo {
  id : String
  title : String
  genre : String
  desc : String
  icon : String
  featured : Bool
}

///|
pub fn get_all_games() -> Array[GameInfo] {
  [
    // Featured games (quality-improved)
    {
      id: "abyssal_rift", title: "Abyssal Rift", genre: "roguelite", featured: true,
      icon: "\u{2694}\u{FE0F}",
      desc: "Top-down roguelite dungeon crawler. 12 item synergies, 2 multi-phase bosses, procedural dungeons, meta-progression with Abyss Tokens.",
    },
    {
      id: "fighter_97_lite", title: "Fighter '97", genre: "fighting", featured: true,
      icon: "\u{1F94A}",
      desc: "6-character fighting game with motion-input specials, guard meter, throw techs, combo scaling, and 3-tier AI difficulty.",
    },
    {
      id: "kart_racing_3d", title: "Kart Racing 3D", genre: "racing", featured: true,
      icon: "\u{1F3CE}\u{FE0F}",
      desc: "Arcade kart racer with drift boost mechanics, 8 power-ups, 16 tracks across 4 themed cups, and 8 AI racers.",
    },
    {
      id: "tower_defense_3d", title: "Tower Defense 3D", genre: "strategy", featured: true,
      icon: "\u{1F3F0}",
      desc: "Strategic tower defense with 8 tower types, tower synergies (Frost+Lightning, Sniper+Splash), upgrades, and 6 maps.",
    },
    {
      id: "space_combat_3d", title: "Space Combat 3D", genre: "action", featured: true,
      icon: "\u{1F680}",
      desc: "6DOF space combat with 12 missions, wing-pair formations, evasion AI, 4 weapon types, and patrol/survive objectives.",
    },
    {
      id: "naval_combat_3d", title: "Naval Combat 3D", genre: "simulation", featured: true,
      icon: "\u{26F5}",
      desc: "Wind-based sailing warfare with broadside cannons, fleet tactics, convoy escorts, and dynamic weather across an archipelago.",
    },
    {
      id: "dungeon_crawler_3d", title: "Dungeon Crawler 3D", genre: "rpg", featured: true,
      icon: "\u{1F9D9}",
      desc: "First-person roguelite with 5 spell types, equipment system (5 rarities), 3-phase dragon boss, shops, shrines, and 3 classes.",
    },
    {
      id: "survival_arena_3d", title: "Survival Arena 3D", genre: "shooter", featured: true,
      icon: "\u{1F52B}",
      desc: "Wave-based survival shooter with 6 weapons, per-weapon upgrades, recoil mechanics, hit markers, and 30 escalating waves.",
    },
    // Classic ports
    {
      id: "bomberman_1983_lite", title: "Bomberman 1983", genre: "classic", featured: false,
      icon: "\u{1F4A3}",
      desc: "96-stage bomb-laying action with 4 enemy types, 6 powerups, 2-player co-op, blast preview, and smart pathfinding AI.",
    },
    {
      id: "tank_1990", title: "Tank 1990", genre: "classic", featured: false,
      icon: "\u{1F3AF}",
      desc: "NES-inspired tank battle across 96 stages. 4 enemy types, combo scoring, spawn warnings, and demo AI.",
    },
    {
      id: "contra_1987_lite", title: "Contra 1987", genre: "classic", featured: false,
      icon: "\u{1F52B}",
      desc: "Top-down tank combat with destructible terrain, 96 themed stages, power-ups, and co-op play.",
    },
    {
      id: "jackal_1988_lite", title: "Jackal 1988", genre: "classic", featured: false,
      icon: "\u{1F6E1}\u{FE0F}",
      desc: "Tank combat with hostage rescue. Navigate 96 stages, rescue captives, and defend your base.",
    },
    {
      id: "super_mario_1985_lite", title: "Super Mario 1985", genre: "classic", featured: false,
      icon: "\u{1F344}",
      desc: "Classic side-scrolling platformer with power-ups, enemies, and multi-level progression.",
    },
    {
      id: "mario", title: "Mario", genre: "platformer", featured: false,
      icon: "\u{2B50}",
      desc: "Platformer with sprite rendering, coyote-time jumping, enemy stomping, and 4 themed levels.",
    },
    // 3D games
    {
      id: "platformer_3d", title: "Platformer 3D", genre: "platformer", featured: false,
      icon: "\u{1F3C3}",
      desc: "3D platformer across 4 themed worlds with 20+ levels, gems, hazards, and star ratings.",
    },
    {
      id: "flight_sim_3d", title: "Flight Sim 3D", genre: "simulation", featured: false,
      icon: "\u{2708}\u{FE0F}",
      desc: "Arcade flight simulator with 15 missions, 4 aircraft, procedural terrain, and weather systems.",
    },
    {
      id: "voxel_world_3d", title: "Voxel World 3D", genre: "sandbox", featured: false,
      icon: "\u{1F9CA}",
      desc: "Minecraft-inspired voxel sandbox with building, crafting, day/night cycle, biomes, and caves.",
    },
    {
      id: "puzzle_dungeon_3d", title: "Puzzle Dungeon 3D", genre: "puzzle", featured: false,
      icon: "\u{1F9E9}",
      desc: "Isometric puzzle game with block pushing, switches, and 5 themed puzzle worlds.",
    },
    // Puzzle & casual
    {
      id: "2048", title: "2048", genre: "puzzle", featured: false,
      icon: "\u{1F522}",
      desc: "Classic number merging puzzle with smooth animations, undo support, and best-score tracking.",
    },
    {
      id: "minesweeper", title: "Minesweeper", genre: "puzzle", featured: false,
      icon: "\u{1F4A5}",
      desc: "Classic minesweeper with flood-fill reveal, flagging, and safe first-click guarantee.",
    },
    {
      id: "demo", title: "Demo", genre: "example", featured: false,
      icon: "\u{1F4BB}",
      desc: "Basic raylib demo showcasing MoonBit + raylib rendering capabilities.",
    },
  ]
}

///|
pub fn genre_gradient(genre : String) -> String {
  match genre {
    "roguelite" => "linear-gradient(135deg, #1a0a2e 0%, #3d1f6d 50%, #6b21a8 100%)"
    "fighting" => "linear-gradient(135deg, #2d0a0a 0%, #7f1d1d 50%, #dc2626 100%)"
    "racing" => "linear-gradient(135deg, #0a1a2e 0%, #1e3a5f 50%, #2563eb 100%)"
    "strategy" => "linear-gradient(135deg, #0a2e1a 0%, #1f6d3d 50%, #16a34a 100%)"
    "action" => "linear-gradient(135deg, #2e1a0a 0%, #6d3d1f 50%, #ea580c 100%)"
    "simulation" => "linear-gradient(135deg, #0a2e2e 0%, #1f5f6d 50%, #0891b2 100%)"
    "rpg" => "linear-gradient(135deg, #1a0a2e 0%, #4c1d95 50%, #7c3aed 100%)"
    "shooter" => "linear-gradient(135deg, #1a1a0a 0%, #4a4a1f 50%, #ca8a04 100%)"
    "classic" => "linear-gradient(135deg, #1a1a1a 0%, #404040 50%, #6b7280 100%)"
    "platformer" => "linear-gradient(135deg, #0a2e0a 0%, #1f6d1f 50%, #22c55e 100%)"
    "puzzle" => "linear-gradient(135deg, #2e0a2e 0%, #6d1f6d 50%, #d946ef 100%)"
    "sandbox" => "linear-gradient(135deg, #1a2e0a 0%, #3d6d1f 50%, #65a30d 100%)"
    _ => "linear-gradient(135deg, #111827 0%, #1f2937 50%, #374151 100%)"
  }
}

///|
pub fn genre_color(genre : String) -> String {
  match genre {
    "roguelite" => "#a855f7"
    "fighting" => "#ef4444"
    "racing" => "#3b82f6"
    "strategy" => "#22c55e"
    "action" => "#f97316"
    "simulation" => "#06b6d4"
    "rpg" => "#8b5cf6"
    "shooter" => "#eab308"
    "classic" => "#9ca3af"
    "platformer" => "#4ade80"
    "puzzle" => "#d946ef"
    "sandbox" => "#84cc16"
    _ => "#6b7280"
  }
}
