# Dungeon Crawler 3D

A first-person 3D dungeon crawler with BSP-generated dungeons, 10 themed floors, RPG progression, and real-time combat. You choose from three character classes (Warrior, Rogue, Mage) and descend through increasingly dangerous floors populated with 11 enemy types, 6 trap varieties, shops, shrines, and two boss encounters. The game uses a tile-based 32x32 grid with 3D rendering via raylib Camera3D.

Combat combines melee weapons (sword, axe, mace, dagger, staff) and ranged attacks (bow) with a 6-spell magic system (Fireball, Ice Bolt, Heal, Shield, Lightning, Teleport). Enemies have distinct AI behaviors: skeletons and golems chase and melee, archers maintain distance and shoot, wraiths move fast, slimes bounce in hops, bats move erratically, spiders shoot slowing webs, minotaurs charge in straight lines, lichs cast bolts and summon skeletons, and dragon bosses breathe fire in cone patterns. Loot drops with 5 rarity tiers, and the inventory supports 20 items. Each floor has a unique visual theme (Crypt, Sewer, Cavern, Library, Prison, Throne Room, Mine, Temple, Abyss, Final Chamber) with distinct wall, floor, and ceiling colors.

Progression includes leveling with class-specific stat bonuses, equipment upgrades from shops, shrine blessings for permanent stat boosts, and scaling enemy stats. The player must defeat all enemies on a floor before descending the stairs to the next level.

## Build and Run

```bash
moon build --target native dungeon_crawler_3d/
./_build/native/debug/build/dungeon_crawler_3d/dungeon_crawler_3d.exe
```

## Controls

- **W/A/S/D**: Move forward/left/backward/right
- **Mouse**: Look around (yaw and pitch)
- **Left Shift**: Sprint (1.5x speed)
- **Left Mouse Button / Space**: Attack with equipped weapon
- **Right Mouse Button / Q**: Cast selected spell
- **Tab**: Cycle weapon (Sword -> Axe -> Mace -> Dagger -> Staff -> Bow)
- **1-6**: Select spell slot
- **E**: Interact (open chests, unlock doors, enter shop/shrine)
- **Escape**: Pause / exit shop / exit shrine
- **P**: Unpause
- **M**: Return to main menu (from pause or game over)
- **Enter / Space**: Confirm (menu selections, level up, floor complete)
- **Up/Down Arrows**: Navigate menus

## How to Play

1. **Choose a class**: At the start, select Warrior (bonus HP/STR per level), Rogue (bonus DEX/ATK per level), or Mage (bonus INT/Mana per level) using arrow keys and Enter.
2. **Explore the dungeon**: Each floor is a BSP-generated 32x32 tile grid with 4-9 rooms connected by corridors. Move with WASD and look with the mouse. A minimap in the top-right corner shows explored tiles.
3. **Fight enemies**: Use melee weapons or the bow with LMB/Space. Each weapon has different range, cooldown, and damage multipliers. Melee hits enemies in a ~90-degree forward cone within weapon range. Critical hits based on DEX deal double damage.
4. **Cast spells**: Press RMB or Q to cast the selected spell (choose with 1-6 keys). Spells cost mana, which regenerates at 1.5/sec. Fireball deals AoE damage, Ice Bolt slows enemies for 3 seconds, Heal restores HP, Shield adds temporary defense, Lightning chains between nearby enemies, and Teleport blinks you forward.
5. **Collect loot**: Walk over dropped items to auto-pickup. Health/Mana potions restore stats, Damage/Armor scrolls permanently boost ATK/DEF, Speed/Strength potions grant temporary buffs, Gold adds to your purse, and Keys unlock locked doors.
6. **Open chests**: Face a chest and press E. Chests give random rewards (HP, ATK, DEF, Gold, or spell scrolls). Beware of mimics on floor 3+, which spring to life when opened.
7. **Use shops**: On floors 3, 6, and 8, find the shop tile and press E to browse. Buy Health Potions (25g), Mana Potions (30g), ATK Scrolls (80g), DEF Scrolls (100g), Keys (40g), or Speed Potions (60g).
8. **Visit shrines**: On floors 2, 4, 7, and 9, find the shrine tile and press E. Choose one permanent bonus: +20 Max HP, +15 Max Mana, or +5 ATK. Each shrine can only be used once.
9. **Watch for traps**: Traps are hidden until your DEX-based perception reveals them. Spike traps (15 dmg), Arrow traps (20 dmg), Flame traps (25 dmg), Poison traps (5 dmg/sec for 5 sec), and Pitfall traps (30 dmg). Traps have a 3-second cooldown between triggers.
10. **Level up**: Gain XP by defeating enemies. Each level grants +15 Max HP, +8 Max Mana, +3 ATK, +2 DEF, full HP/Mana restore, plus class-specific bonuses. XP required scales as 100 + (level-1) x 50.
11. **Descend floors**: Defeat all enemies on a floor, then walk onto the stairs tile to advance. Boss floors (5 and 10) feature named bosses with special attacks.

**Lose condition**: HP reaches zero. Press Enter to restart or M to return to the menu.

**Win condition**: Clear all 10 floors including the final dragon boss on Floor 10.

## Public API Reference

### Package `dungeon_crawler_3d`

> Main entry point.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `main` | `() -> Unit` | Entry point: creates 1024x768 window with MSAA 4x, 60 FPS, runs update/render loop |

### Package `dungeon_crawler_3d/internal/types`

> Core type definitions, constants, and utility functions.

#### Structs

| Struct | Key Fields | Description |
|--------|-----------|-------------|
| `Enemy` | `active`, `kind`, `x`, `z`, `hp`, `max_hp`, `atk`, `def`, `attack_timer`, `move_timer`, `alerted`, `hit_flash`, `ai_state`, `patrol_x/z`, `speed_mult`, `ability_cooldown`, `stun_timer`, `slow_timer`, `xp_value`, `facing_angle` | Enemy entity with type, position, stats, AI state, and status effects |
| `Projectile` | `active`, `kind`, `x`, `z`, `vx`, `vz`, `damage`, `lifetime`, `from_enemy`, `aoe_radius`, `slow_on_hit` | Moving projectile from enemies or player spells with damage, lifetime, and status effects |
| `Particle` | `active`, `x`, `y`, `z`, `vx`, `vy`, `vz`, `life`, `max_life`, `r`, `g`, `b`, `size` | Visual particle effect with 3D position, velocity, color, and lifetime |
| `Loot` | `active`, `kind`, `x`, `z`, `bob_phase`, `rarity`, `value` | Ground loot item with type, rarity tier, and bobbing animation phase |
| `InvItem` | `kind`, `active`, `rarity`, `stat_bonus`, `name_idx` | Inventory item with rarity and stat bonus |
| `Trap` | `active`, `kind`, `gx`, `gz`, `armed`, `cooldown`, `triggered`, `visible` | Floor trap on grid with armed state, cooldown timer, and visibility (perception-based) |
| `Torch` | `active`, `gx`, `gz`, `flicker_phase` | Wall-mounted light source with flicker animation |
| `MessageEntry` | `text`, `timer`, `r`, `g`, `b` | Timed message log entry with color |
| `ShopItem` | `active`, `kind`, `price`, `name_idx`, `stat_bonus` | Purchasable shop item with price |
| `Room` | `x`, `y`, `w`, `h`, `kind`, `explored`, `enemies_cleared` | BSP-generated room with position, dimensions, and type (normal/treasure/boss/shop/shrine) |
| `FloorInfo` | `cleared`, `enemies_killed`, `enemies_total` | Per-floor progress tracking |
| `SpellSlot` | `spell_type`, `active` | Player spell inventory slot |
| `Buff` | `kind`, `timer`, `value`, `active` | Active timed buff on the player (speed/strength/shield/poison) |
| `Game` | `state`, `player_*` (position, stats, equipment, class), `camera_*`, `tiles`, `explored`, `rooms`, `enemies`, `projectiles`, `particles`, `loot`, `traps`, `torches`, `floor_info`, `inventory`, `spells`, `buffs`, `shop_items`, `shrine_*`, `messages`, `rng_state`, etc. | Main game state containing all entity pools, player data, dungeon state, UI state, and RNG |

#### Room Type Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `room_normal` | `Int` | `0` | Standard room |
| `room_treasure` | `Int` | `1` | Treasure room with extra loot |
| `room_boss` | `Int` | `2` | Boss encounter room |
| `room_shop` | `Int` | `3` | Shop room |
| `room_shrine` | `Int` | `4` | Shrine room |

#### Buff Kind Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `buff_speed` | `Int` | `0` | Movement speed buff |
| `buff_strength` | `Int` | `1` | Attack damage buff |
| `buff_shield` | `Int` | `2` | Defense bonus buff |
| `buff_poison` | `Int` | `3` | Poison damage-over-time |
| `max_buffs` | `Int` | `4` | Maximum simultaneous buffs |

#### Screen and Grid Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `screen_width` | `Int` | `1024` | Window width |
| `screen_height` | `Int` | `768` | Window height |
| `grid_w` | `Int` | `32` | Dungeon grid width |
| `grid_h` | `Int` | `32` | Dungeon grid height |
| `grid_total` | `Int` | `1024` | Total grid cells (32x32) |
| `cell_size` | `Float` | `2.0` | World units per grid cell |
| `wall_height` | `Float` | `3.0` | Height of wall cubes |

#### Tile Type Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `tile_empty` | `Int` | `0` | Empty/void tile |
| `tile_wall` | `Int` | `1` | Solid wall |
| `tile_floor` | `Int` | `2` | Walkable floor |
| `tile_door` | `Int` | `3` | Openable door |
| `tile_stairs` | `Int` | `4` | Descent stairs |
| `tile_chest` | `Int` | `5` | Loot chest |
| `tile_trap` | `Int` | `6` | Hidden trap |
| `tile_shrine` | `Int` | `7` | Blessing shrine |
| `tile_shop` | `Int` | `8` | Shop tile |
| `tile_locked_door` | `Int` | `9` | Key-locked door |
| `tile_boss_door` | `Int` | `10` | Boss-key-locked door |
| `tile_secret_door` | `Int` | `11` | Secret door |

#### Enemy Type Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `enemy_none` | `Int` | `0` | No enemy |
| `enemy_skeleton` | `Int` | `1` | Melee fighter |
| `enemy_archer` | `Int` | `2` | Ranged attacker maintaining distance |
| `enemy_golem` | `Int` | `3` | Slow, tough melee fighter |
| `enemy_wraith` | `Int` | `4` | Fast melee attacker |
| `enemy_dragon_boss` | `Int` | `5` | Boss with fire breath cone attack |
| `enemy_slime` | `Int` | `6` | Bouncing melee attacker |
| `enemy_bat` | `Int` | `7` | Fast erratic swooping attacker |
| `enemy_spider` | `Int` | `8` | Melee with slowing web ranged attack |
| `enemy_minotaur` | `Int` | `9` | Charges in straight lines at high speed |
| `enemy_lich` | `Int` | `10` | Ranged caster that summons skeletons |
| `enemy_mimic` | `Int` | `11` | Disguised as chest, activates on interaction |

#### AI State Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `ai_idle` | `Int` | `0` | Standing still |
| `ai_patrol` | `Int` | `1` | Random patrol movement |
| `ai_chase` | `Int` | `2` | Chasing the player |
| `ai_attack` | `Int` | `3` | Attacking |
| `ai_flee` | `Int` | `4` | Running away |
| `ai_dead` | `Int` | `5` | Dead |
| `ai_special` | `Int` | `6` | Special ability (e.g., minotaur charge) |

#### Loot Type Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `loot_none` | `Int` | `0` | No loot |
| `loot_health_potion` | `Int` | `1` | Restores 40 HP |
| `loot_damage_boost` | `Int` | `2` | Permanent +5 ATK |
| `loot_armor` | `Int` | `3` | Permanent +3 DEF |
| `loot_mana_potion` | `Int` | `4` | Restores 30 Mana |
| `loot_speed_potion` | `Int` | `5` | Speed buff for 10 seconds |
| `loot_strength_potion` | `Int` | `6` | +8 ATK buff for 10 seconds |
| `loot_gold_pile` | `Int` | `7` | 10-50 Gold |
| `loot_key` | `Int` | `8` | Unlocks locked doors |
| `loot_boss_key` | `Int` | `9` | Unlocks boss doors |

#### Weapon Type Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `weapon_sword` | `Int` | `0` | Range 2.5, cooldown 0.4s, 1.0x damage |
| `weapon_axe` | `Int` | `1` | Range 2.2, cooldown 0.7s, 1.4x damage |
| `weapon_mace` | `Int` | `2` | Range 2.0, cooldown 0.6s, 1.2x damage |
| `weapon_dagger` | `Int` | `3` | Range 1.8, cooldown 0.25s, 0.7x damage |
| `weapon_staff` | `Int` | `4` | Range 2.8, cooldown 0.5s, 0.5x damage |
| `weapon_bow` | `Int` | `5` | Range 15.0, cooldown 0.8s, 0.9x damage (ranged) |

#### Armor Type Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `armor_none` | `Int` | `0` | No armor (0 DEF) |
| `armor_robes` | `Int` | `1` | +2 DEF |
| `armor_leather` | `Int` | `2` | +5 DEF |
| `armor_chain` | `Int` | `3` | +8 DEF |
| `armor_plate` | `Int` | `4` | +12 DEF |

#### Spell Type Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `spell_none` | `Int` | `0` | No spell |
| `spell_fireball` | `Int` | `1` | 15 mana, 25 base damage, 2.5 AoE radius |
| `spell_ice_bolt` | `Int` | `2` | 10 mana, 15 base damage, 3s slow |
| `spell_heal` | `Int` | `3` | 20 mana, restores 40 HP |
| `spell_shield` | `Int` | `4` | 12 mana, +10 DEF for 8 seconds |
| `spell_lightning` | `Int` | `5` | 25 mana, 35 base damage, chains to nearby enemies within 4 units |
| `spell_teleport` | `Int` | `6` | 8 mana, blinks forward up to 8 units |

#### Trap Type Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `trap_spike` | `Int` | `0` | 15 damage |
| `trap_arrow` | `Int` | `1` | 20 damage |
| `trap_flame` | `Int` | `2` | 25 damage |
| `trap_poison` | `Int` | `3` | 5 damage/sec for 5 seconds |
| `trap_pitfall` | `Int` | `4` | 30 damage |
| `trap_teleporter` | `Int` | `5` | Teleports the player |

#### Rarity Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `rarity_common` | `Int` | `0` | Common rarity |
| `rarity_uncommon` | `Int` | `1` | Uncommon rarity |
| `rarity_rare` | `Int` | `2` | Rare rarity |
| `rarity_epic` | `Int` | `3` | Epic rarity |
| `rarity_legendary` | `Int` | `4` | Legendary rarity |

#### Floor Theme Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `theme_crypt` | `Int` | `0` | Dark blue-purple tones |
| `theme_sewer` | `Int` | `1` | Green-tinted walls |
| `theme_cavern` | `Int` | `2` | Warm brown tones |
| `theme_library` | `Int` | `3` | Dark wood tones |
| `theme_prison` | `Int` | `4` | Grey steel tones |
| `theme_throne_room` | `Int` | `5` | Dark red tones |
| `theme_mine` | `Int` | `6` | Earthy brown tones |
| `theme_temple` | `Int` | `7` | Blue-grey stone |
| `theme_abyss` | `Int` | `8` | Very dark purple |
| `theme_final_chamber` | `Int` | `9` | Deep red tones |

#### Game State Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `state_menu` | `Int` | `0` | Main menu |
| `state_playing` | `Int` | `1` | Active gameplay |
| `state_paused` | `Int` | `2` | Paused |
| `state_game_over` | `Int` | `3` | Player dead |
| `state_level_up` | `Int` | `4` | Level up notification |
| `state_floor_complete` | `Int` | `5` | Floor cleared transition |
| `state_inventory` | `Int` | `6` | Inventory screen |
| `state_shop` | `Int` | `7` | Shop interface |
| `state_shrine` | `Int` | `8` | Shrine interface |
| `state_boss_intro` | `Int` | `9` | Boss introduction cutscene |
| `state_spellbook` | `Int` | `10` | Spellbook screen |
| `state_class_select` | `Int` | `11` | Class selection screen |

#### Player Class Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `class_warrior` | `Int` | `0` | +2 STR, +5 Max HP per level |
| `class_rogue` | `Int` | `1` | +2 DEX, +1 ATK per level |
| `class_mage` | `Int` | `2` | +2 INT, +5 Max Mana per level |

#### Pool Size Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `max_enemies` | `Int` | `64` | Maximum enemy pool |
| `max_projectiles` | `Int` | `128` | Maximum projectile pool |
| `max_particles` | `Int` | `256` | Maximum particle pool |
| `max_loot` | `Int` | `32` | Maximum loot pool |
| `max_floors` | `Int` | `10` | Total dungeon floors |
| `max_inventory` | `Int` | `20` | Maximum inventory slots |
| `max_spells` | `Int` | `6` | Maximum spell slots |
| `max_messages` | `Int` | `8` | Maximum message log entries |
| `max_traps` | `Int` | `24` | Maximum trap pool |
| `max_shop_items` | `Int` | `6` | Maximum shop inventory |
| `max_torches` | `Int` | `32` | Maximum torch pool |
| `max_rooms` | `Int` | `12` | Maximum rooms per floor |

#### Player Default Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `player_speed` | `Float` | `6.0` | Base movement speed |
| `player_sprint_mult` | `Float` | `1.5` | Sprint speed multiplier |
| `player_start_hp` | `Int` | `100` | Starting HP |
| `player_start_mana` | `Int` | `50` | Starting mana |
| `player_start_atk` | `Int` | `10` | Starting attack |
| `player_start_def` | `Int` | `5` | Starting defense |
| `player_start_str` | `Int` | `8` | Starting strength |
| `player_start_dex` | `Int` | `8` | Starting dexterity |
| `player_start_int_stat` | `Int` | `8` | Starting intelligence |
| `player_eye_height` | `Float` | `1.6` | Camera eye height |

#### Combat Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `sword_range` / `axe_range` / `mace_range` / `dagger_range` / `staff_range` / `bow_range` | `Float` | `2.5` / `2.2` / `2.0` / `1.8` / `2.8` / `15.0` | Weapon reach distances |
| `sword_cooldown` / `axe_cooldown` / `mace_cooldown` / `dagger_cooldown` / `staff_cooldown` / `bow_cooldown` | `Float` | `0.4` / `0.7` / `0.6` / `0.25` / `0.5` / `0.8` | Weapon attack cooldowns |
| `sword_damage_mult` / `axe_damage_mult` / `mace_damage_mult` / `dagger_damage_mult` / `staff_damage_mult` / `bow_damage_mult` | `Float` | `1.0` / `1.4` / `1.2` / `0.7` / `0.5` / `0.9` | Weapon damage multipliers |
| `enemy_melee_range` | `Float` | `2.0` | Enemy melee attack range |
| `enemy_attack_cooldown` | `Float` | `1.2` | Enemy attack cooldown |
| `enemy_sight_range` | `Float` | `10.0` | Distance at which enemies detect the player |
| `enemy_move_speed` | `Float` | `2.0` | Base enemy movement speed |
| `projectile_speed` | `Float` | `8.0` | Base projectile velocity |
| `projectile_lifetime` | `Float` | `3.0` | Projectile maximum lifetime |
| `mana_regen_rate` | `Float` | `1.5` | Mana regenerated per second |

#### Leveling Constants

| Constant | Type | Value | Description |
|----------|------|-------|-------------|
| `xp_per_level` | `Int` | `100` | Base XP for first level |
| `hp_per_level` | `Int` | `15` | Max HP gained per level |
| `mana_per_level` | `Int` | `8` | Max Mana gained per level |
| `atk_per_level` | `Int` | `3` | ATK gained per level |
| `def_per_level` | `Int` | `2` | DEF gained per level |

#### Constructor Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `Enemy::inactive` | `() -> Enemy` | Creates an inactive enemy |
| `Projectile::inactive` | `() -> Projectile` | Creates an inactive projectile |
| `Particle::inactive` | `() -> Particle` | Creates an inactive particle |
| `Loot::inactive` | `() -> Loot` | Creates an inactive loot item |
| `InvItem::empty` | `() -> InvItem` | Creates an empty inventory slot |
| `Trap::inactive` | `() -> Trap` | Creates an inactive trap |
| `Torch::inactive` | `() -> Torch` | Creates an inactive torch |
| `MessageEntry::empty` | `() -> MessageEntry` | Creates an empty message entry |
| `ShopItem::empty` | `() -> ShopItem` | Creates an empty shop item |
| `Room::new` | `(Int, Int, Int, Int) -> Room` | Creates a room with position (x, y) and dimensions (w, h) |
| `FloorInfo::new` | `() -> FloorInfo` | Creates a new floor info tracker |
| `SpellSlot::empty` | `() -> SpellSlot` | Creates an empty spell slot |
| `Buff::inactive` | `() -> Buff` | Creates an inactive buff |
| `Game::new` | `() -> Game` | Creates a new game with all entity pools pre-allocated |

#### Room Methods

| Method | Signature | Description |
|--------|-----------|-------------|
| `Room::center_x` | `(Room) -> Int` | Returns the horizontal center of the room |
| `Room::center_y` | `(Room) -> Int` | Returns the vertical center of the room |

#### Math Utility Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `absf` | `(Float) -> Float` | Absolute value of a float |
| `absi` | `(Int) -> Int` | Absolute value of an integer |
| `clampf` | `(Float, Float, Float) -> Float` | Clamps a float between bounds |
| `clampi` | `(Int, Int, Int) -> Int` | Clamps an integer between bounds |
| `mini` | `(Int, Int) -> Int` | Minimum of two integers |
| `maxi` | `(Int, Int) -> Int` | Maximum of two integers |
| `minf` | `(Float, Float) -> Float` | Minimum of two floats |
| `maxf` | `(Float, Float) -> Float` | Maximum of two floats |
| `lerpf` | `(Float, Float, Float) -> Float` | Linear interpolation between two floats |
| `signf` | `(Float) -> Float` | Sign of a float (-1.0, 0.0, or 1.0) |
| `normalize_angle` | `(Float) -> Float` | Normalizes angle to [-pi, pi] |

#### Grid Utility Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `in_bounds` | `(Int, Int) -> Bool` | Checks if grid coordinates are within bounds |
| `tile_index` | `(Int, Int) -> Int` | Converts 2D grid coordinates to flat array index |
| `get_tile` | `(Game, Int, Int) -> Int` | Gets tile type at grid position (returns wall if out of bounds) |
| `set_tile` | `(Game, Int, Int, Int) -> Unit` | Sets tile type at grid position |
| `is_walkable` | `(Int) -> Bool` | Returns true for floor, door, stairs, chest, trap, shrine, shop tiles |
| `is_door_tile` | `(Int) -> Bool` | Returns true for any door variant |
| `world_to_grid_x` | `(Float) -> Int` | Converts world X to grid column |
| `world_to_grid_z` | `(Float) -> Int` | Converts world Z to grid row |
| `grid_to_world_x` | `(Int) -> Float` | Converts grid column to world X center |
| `grid_to_world_z` | `(Int) -> Float` | Converts grid row to world Z center |
| `is_blocked` | `(Game, Float, Float, Float) -> Bool` | Checks if a world position with radius is blocked by non-walkable tiles |
| `is_blocked_strict` | `(Game, Float, Float, Float) -> Bool` | Like is_blocked but also blocks locked/boss doors |

#### Distance and Pathfinding Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `dist2d` | `(Float, Float, Float, Float) -> Float` | Euclidean distance between two XZ points |
| `dist2d_sq` | `(Float, Float, Float, Float) -> Float` | Squared distance (avoids sqrt) |
| `has_line_of_sight` | `(Game, Int, Int, Int, Int) -> Bool` | Bresenham line-of-sight check between two grid cells |
| `pathfind_step` | `(Game, Float, Float, Float, Float) -> (Float, Float)` | Returns normalized direction toward target with wall sliding |
| `find_walkable_in_room` | `(Game, Room) -> (Int, Int)` | Finds a random walkable grid cell within a room |

#### RNG Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `rand_next` | `(Game) -> Int` | Xorshift PRNG next value |
| `rand_range` | `(Game, Int, Int) -> Int` | Random integer in [low, high] |
| `rand_rangef` | `(Game, Float, Float) -> Float` | Random float in [low, high] |
| `rand_weighted` | `(Game, Array[Int]) -> Int` | Weighted random index selection |

#### Entity Pool Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `alloc_enemy` | `(Game) -> Int` | Finds first inactive enemy slot (-1 if full) |
| `alloc_projectile` | `(Game) -> Int` | Finds first inactive projectile slot |
| `alloc_particle` | `(Game) -> Int` | Finds first inactive particle slot |
| `alloc_loot` | `(Game) -> Int` | Finds first inactive loot slot |
| `alloc_trap` | `(Game) -> Int` | Finds first inactive trap slot |
| `alloc_torch` | `(Game) -> Int` | Finds first inactive torch slot |
| `alloc_inventory` | `(Game) -> Int` | Finds first inactive inventory slot |

#### Particle Spawning Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `spawn_particles` | `(Game, Float, Float, Float, Int, Int, Int, Int) -> Unit` | Spawns count particles at world position with color |
| `spawn_directional_particles` | `(Game, Float, Float, Float, Float, Float, Int, Int, Int, Int, Float) -> Unit` | Spawns particles with directional velocity bias |

#### Game State Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `update_explored` | `(Game) -> Unit` | Marks tiles within radius 4 of the player as explored |
| `count_active_enemies` | `(Game) -> Int` | Counts active enemies |
| `count_inventory_items` | `(Game) -> Int` | Counts active inventory items |

#### Message Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `add_message` | `(Game, String, Int, Int, Int) -> Unit` | Pushes a colored message to the log (shifts existing down) |
| `update_messages` | `(Game, Float) -> Unit` | Decrements message display timers |

#### Buff Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `has_buff` | `(Game, Int) -> Bool` | Checks if player has an active buff of given kind |
| `add_buff` | `(Game, Int, Float, Int) -> Unit` | Adds or refreshes a buff (kind, duration, value) |
| `update_buffs` | `(Game, Float) -> Unit` | Decrements buff timers and deactivates expired buffs |

#### Stat Lookup Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `get_weapon_range` | `(Int) -> Float` | Returns weapon range by type |
| `get_weapon_cooldown` | `(Int) -> Float` | Returns weapon cooldown by type |
| `get_weapon_damage_mult` | `(Int) -> Float` | Returns weapon damage multiplier by type |
| `get_weapon_name` | `(Int) -> String` | Returns weapon name string |
| `get_armor_defense` | `(Int) -> Int` | Returns armor defense bonus by type |
| `get_armor_name` | `(Int) -> String` | Returns armor name string |
| `get_spell_name` | `(Int) -> String` | Returns spell name string |
| `get_spell_mana_cost` | `(Int) -> Int` | Returns spell mana cost |
| `get_enemy_name` | `(Int) -> String` | Returns enemy type name |
| `get_enemy_xp` | `(Int) -> Int` | Returns XP value for enemy type |
| `get_rarity_name` | `(Int) -> String` | Returns rarity tier name |
| `get_class_name` | `(Int) -> String` | Returns class name string |
| `get_trap_name` | `(Int) -> String` | Returns trap type name |
| `get_loot_name` | `(Int) -> String` | Returns loot type name |
| `get_theme_name` | `(Int) -> String` | Returns floor theme name |

#### Combat Calculation Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `calc_player_defense` | `(Game) -> Int` | Total defense: base DEF + armor bonus + shield buff |
| `calc_player_attack` | `(Game) -> Int` | Total attack: (base ATK + STR/3) x weapon mult + strength buff |

### Package `dungeon_crawler_3d/internal/game`

> Game logic, input handling, enemy AI, and dungeon generation.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `update_game` | `(Game, Float) -> Unit` | Top-level update dispatcher: routes to state-specific handlers (menu/playing/paused/game_over/level_up/floor_complete/class_select/shop/shrine), updates message and level-up timers |
| `generate_dungeon` | `(Game) -> Unit` | BSP dungeon generation: clears tiles, generates rooms with retry placement, connects with corridors, assigns room types, places player/stairs/enemies/loot/doors/locked doors/chests/traps/torches/shops/shrines |
| `update_enemies` | `(Game, Float) -> Unit` | Updates all enemy AI: patrol, chase, attack based on type (melee/archer/slime/bat/spider/minotaur/lich/boss), handles stun/slow timers |
| `update_projectiles` | `(Game, Float) -> Unit` | Moves projectiles, checks wall collisions, handles enemy-to-player and player-to-enemy hit detection with damage and status effects |
| `update_particles` | `(Game, Float) -> Unit` | Updates particle positions with velocity, gravity, and drag |
| `update_loot_bob` | `(Game, Float) -> Unit` | Advances loot bobbing animation phase |
| `update_player` | `(Game, Float) -> Unit` | Full player update: mouse look, WASD movement with sprint/collision, weapon attacks, spell casting, weapon cycling, mana regen, loot pickup, stairs check, chest/door/shop/shrine interaction, trap detection, buff/poison/message updates, death/level-up checks |
| `kill_enemy` | `(Game, Int) -> Unit` | Handles enemy death: awards XP, spawns death particles, drops loot with rarity weighting, awards gold, updates floor kill count |
| `damage_player` | `(Game, Int) -> Unit` | Applies damage to player after defense calculation (minimum 1), triggers hit/damage flash |

### Package `dungeon_crawler_3d/internal/levels`

> Floor configuration, difficulty scaling, theme definitions, and progression data.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `get_floor_config` | `(Int) -> (Int, Int, Int, Int, Int, Bool, Int)` | Returns (rooms, skeletons, archers, golems, wraiths, has_boss, loot_count) for a floor |
| `get_extended_enemy_config` | `(Int) -> (Int, Int, Int, Int, Int)` | Returns (slimes, bats, spiders, minotaurs, lichs) for a floor |
| `get_floor_theme` | `(Int) -> Int` | Returns theme constant for a floor (floor index maps directly) |
| `get_floor_name` | `(Int) -> String` | Returns display name for a floor (e.g., "The Crypt", "Dragon's Sanctum") |
| `get_enemy_hp_scale` | `(Int) -> Int` | HP scaling: 10 + floor x 5 |
| `get_enemy_atk_scale` | `(Int) -> Int` | ATK scaling: 3 + floor x 2 |
| `get_enemy_def_scale` | `(Int) -> Int` | DEF scaling: 1 + floor |
| `get_theme_wall_color` | `(Int) -> (Int, Int, Int)` | Returns RGB wall color for theme |
| `get_theme_floor_color` | `(Int) -> (Int, Int, Int)` | Returns RGB floor color for theme |
| `get_theme_ceiling_color` | `(Int) -> (Int, Int, Int)` | Returns RGB ceiling color for theme |
| `get_floor_trap_count` | `(Int) -> Int` | Returns number of traps for a floor (1-6, scaling with depth) |
| `get_available_trap_type` | `(Int, Int) -> Int` | Returns trap type based on floor (early floors: spikes only; later: all types) |
| `get_rarity_weight_common` | `(Int) -> Int` | Common loot weight by floor (60/45/30) |
| `get_rarity_weight_uncommon` | `(Int) -> Int` | Uncommon loot weight by floor (30/30/25) |
| `get_rarity_weight_rare` | `(Int) -> Int` | Rare loot weight by floor (8/18/25) |
| `get_rarity_weight_epic` | `(Int) -> Int` | Epic loot weight by floor (2/6/15) |
| `get_rarity_weight_legendary` | `(Int) -> Int` | Legendary loot weight by floor (0/1/5) |
| `get_boss_name` | `(Int) -> String` | Returns boss name ("Warden of Iron" on floor 5, "Azhrakul the Undying" on floor 10) |
| `get_boss_hp` | `(Int) -> Int` | Returns boss HP with scaling |
| `get_boss_atk` | `(Int) -> Int` | Returns boss ATK with scaling |
| `get_boss_def` | `(Int) -> Int` | Returns boss DEF with scaling |
| `get_shop_item_type` | `(Int) -> Int` | Returns loot type for shop slot index |
| `get_shop_item_price` | `(Int) -> Int` | Returns price for shop slot index |
| `get_shop_item_name` | `(Int) -> String` | Returns display name for shop slot |
| `get_shrine_buff_name` | `(Int) -> String` | Returns shrine option display name |
| `get_xp_for_level` | `(Int) -> Int` | Returns XP required: 100 + (level-1) x 50 |
| `get_locked_door_count` | `(Int) -> Int` | Returns locked doors per floor (0/1/2/3) |
| `floor_has_shop` | `(Int) -> Bool` | Returns true for floors 3, 6, 8 |
| `floor_has_shrine` | `(Int) -> Bool` | Returns true for floors 2, 4, 7, 9 |
| `get_torches_per_room` | `(Int) -> Int` | Returns torch count per room by theme (1-4) |

### Package `dungeon_crawler_3d/internal/render`

> 3D world rendering and 2D UI overlay.

#### Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `draw_world` | `(Game) -> Unit` | Renders the 3D scene: builds perspective camera from player position/yaw/pitch, draws dungeon tiles, enemies, loot, projectiles, particles, and sword swing animation |
| `draw_ui` | `(Game) -> Unit` | Renders 2D overlays: dispatches to state-specific UI (menu/HUD+minimap/pause/game over/level up/floor complete/class select/shop/shrine), draws damage flash, message overlay, and level-up glow |

## Architecture

### Package Structure

```
dungeon_crawler_3d/
├── main.mbt                       — Entry point: window init with MSAA, game loop
├── moon.pkg                       — Package config, imports game/render/types
└── internal/
    ├── types/
    │   ├── types.mbt              — All structs (Enemy, Projectile, Particle, Loot, Trap, Room, Game, etc.) and constructors
    │   ├── constants.mbt          — Extensive constants: grid, tiles (12), enemies (12), AI states (7), loot (10), weapons (6), armor (5), spells (7), traps (6), rarities (5), themes (10), game states (12), classes (3), pools, combat, leveling, UI
    │   └── utils.mbt             — Math utilities, grid helpers, collision, distance, RNG (xorshift), entity allocators, particle spawning, pathfinding, line-of-sight (Bresenham), buff/message management, stat lookups
    ├── game/
    │   ├── game_update.mbt        — State machine dispatcher (12 states), menu/pause/game over/level up/floor complete/class select/shop/shrine handlers
    │   ├── player_system.mbt      — Player movement (WASD+mouse look), melee/bow attacks, spell casting (6 spells), loot pickup, chest/door/shop/shrine interaction, trap detection, leveling with class bonuses
    │   ├── enemy_system.mbt       — Enemy AI per type (11 types): patrol, melee chase, archer kiting, slime bouncing, bat erratic, spider web, minotaur charge, lich summoning, dragon fire breath; projectile/particle/loot-bob updates
    │   └── dungeon_gen.mbt        — BSP dungeon generation: room placement with overlap checks, corridor carving, room type assignment, enemy/loot/door/locked door/chest/mimic/trap/torch/shop/shrine placement
    ├── levels/
    │   └── levels.mbt             — 10-floor difficulty progression: enemy counts/types per floor, stat scaling formulas, theme colors (wall/floor/ceiling RGB), trap availability, loot rarity weights, boss definitions, shop inventory, shrine buffs, XP scaling
    └── render/
        ├── render_world.mbt       — 3D rendering: camera construction, dungeon tiles (walls/floors/doors/stairs/chests with frustum culling), enemy models by type, loot with bobbing, projectiles, particles with gravity, sword swing arc
        └── render_ui.mbt          — 2D UI: main menu with torch effects, HUD (HP/Mana bars, stats, weapon/spell info, message log), minimap with explored tiles, crosshair, pause/game over/level up/floor complete/class select/shop/shrine overlays, damage/level-up flash effects
```

The `types` package is the shared foundation with no game logic. The `game` package imports `types` and `levels` and handles all simulation. The `levels` package imports nothing (pure data). The `render` package imports `types` and `levels` (but not `game`) and performs read-only rendering from the `Game` struct.

### Data Flow

1. **Main Loop**: `main.mbt` creates the window with MSAA 4x hint, constructs the Game, and runs update then render each frame. Delta time is capped at 0.05 to prevent physics explosions.
2. **State Machine**: `update_game` dispatches based on `game.state` (12 possible states). The primary gameplay state `state_playing` sequences: player update, enemy AI, projectile physics, particle simulation, loot bobbing.
3. **Player System**: `update_player` processes mouse look (yaw/pitch), WASD movement with sprint and wall sliding collision, weapon attacks (melee cone check or bow projectile), spell casting (6 spell types with INT-scaled damage), loot auto-pickup by proximity, E-key interactions (chests with mimic detection, locked doors with key consumption, shop/shrine entry), trap detection (DEX-based perception reveals hidden traps), buff/poison tick updates, and death/level-up checks.
4. **Enemy AI**: Each of the 11 enemy types has specialized behavior. Unalerted enemies patrol randomly. Once the player enters sight range (10 units), enemies switch to type-specific chase/attack patterns. Special abilities (spider web, minotaur charge, lich summon, dragon fire breath) use ability cooldowns separate from attack cooldowns.
5. **Dungeon Generation**: `generate_dungeon` clears all tiles to wall, attempts to place rooms (up to max_rooms, with retry for non-overlap), connects them with L-shaped corridors, assigns room types (treasure/boss/shop/shrine), then populates with enemies, loot, doors, locked doors, chests (with mimic chance), traps, torches, and shop/shrine tiles.
6. **Render**: The 3D pass builds a perspective Camera3D from player position and camera angles, draws dungeon tiles within a 16-cell radius (frustum culling), renders enemy models by type, loot with bobbing animation, projectiles, particles with gravity, and the sword swing arc. The 2D pass overlays the HUD, minimap, message log, and state-specific screens.

### Key Design Patterns

- **Object pool pattern**: All entity arrays (enemies[64], projectiles[128], particles[256], loot[32], traps[24], torches[32]) are pre-allocated with `active` flags and linear-scan allocation.
- **Integer-coded enumerations**: All game concepts (tile types, enemy types, AI states, loot types, weapons, armor, spells, traps, rarities, themes, game states, classes) use integer constants rather than sum types, enabling simple comparison and switch-like dispatch.
- **State machine**: 12-state FSM with clean transitions. The `state_playing` state is the hub; other states overlay or interrupt it (pause returns to playing, shop/shrine restore previous state).
- **Separation of concerns**: Types/constants/utilities are in `types`, floor progression data is in `levels`, all simulation logic is in `game`, and all rendering is in `render`. The render package only reads the Game struct.
- **BSP room placement**: Rooms are placed with random size and position, checking for overlap with a 2-cell margin. Corridors connect rooms sequentially using L-shaped horizontal-then-vertical paths.
- **Frustum culling**: The 3D renderer only draws tiles within a configurable radius (16 cells) of the player, and interior walls (not adjacent to any walkable tile) are skipped entirely.
- **Xorshift RNG**: A simple deterministic PRNG seeded with a fixed value, supporting integer ranges, float ranges, and weighted random selection for loot rarity.
- **Damage formula**: Damage = max(1, attacker_ATK - defender_DEF). Critical hits (DEX/2 percent chance) deal double damage. Spells scale with INT stat.

## Improvement & Refinement Plan

1. **Replace integer constants with sum types**: All 12+ categories of integer-coded enumerations (tile types, enemy types, AI states, etc.) would benefit from proper MoonBit enums. This would enable exhaustive match checking and eliminate magic number bugs.
2. **Add proper FOV/visibility culling for rendering**: The current 16-cell radius draw check is simple but draws walls behind the player. A proper view frustum test against camera direction would reduce draw calls significantly.
3. **Implement A* pathfinding**: The current `pathfind_step` uses direct-line movement with wall sliding. A proper A* on the grid would allow enemies to navigate around obstacles and L-shaped corridors more intelligently.
4. **Add save/load system**: The game has no persistence. Serializing the Game struct (or at least floor/stats/inventory) would allow mid-run saves across sessions.
5. **Add sound effects**: The game has no audio. Adding raylib sound effects for attacks, spell casting, loot pickup, trap triggers, and enemy deaths would greatly improve the experience.
6. **Improve mimic detection**: Currently mimics are placed at chest tiles but the detection relies on matching grid coordinates. A more robust approach would use a flag on the chest tile itself or store mimic associations in a separate map.
7. **Add inventory management UI**: The `state_inventory` state and `InvItem` struct exist but the inventory screen interaction (equipping, using, dropping items) is not fully implemented in the update logic.
