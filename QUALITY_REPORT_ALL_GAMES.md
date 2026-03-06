# Portfolio Quality Report: All Independent Games

Date: 2026-03-05

## Scope

- Analyzed 330 top-level independent game/packages (directories with `moon.pkg`).
- Static analysis only: architecture/layout, maintainability, testability, docs, robustness proxies.
- Scoring is comparative for this repository and intended to prioritize engineering work.

## Portfolio Summary

- Average score: 47.5/100
- Median score: 47.0/100
- Excellent: 0
- Good: 1
- Fair: 53
- Needs Attention: 276
- No tests/doctests: 328
- Missing README: 1
- Missing ARCHITECTURE.md: 329
- Games with very long functions (>120 LOC): 239

## Systemic Findings (Highest Impact)

1. Test coverage is the dominant gap across the portfolio; many games rely on manual play validation only.
2. Documentation quality varies significantly; README and architecture docs are inconsistent.
3. A subset of games has concentrated complexity in long update/render functions, reducing change safety.
4. Core architectural patterns (`internal/types`, `internal/game`, `internal/render`) correlate with higher maintainability scores.

## Prioritized Improvement Program

1. P0: Add one smoke test per game (or doctest) to establish minimum regression safety.
2. P0: For low-score games, split longest function first and add local tests around that behavior.
3. P1: Standardize README template (controls, objective, run command, known limitations).
4. P1: Add ARCHITECTURE.md for games with >=40 functions or multiple packages.
5. P2: Continue style modernization and module decomposition where file/function size remains high.

## Top 20 Strongest Games (Current Snapshot)

| Game | Score | Rating | Key Strength |
|---|---:|---|---|
| super_mario_1985_lite | 76 | Good | Good docs+tests balance |
| 2048 | 69 | Fair | Good docs+tests balance |
| asteroid_salvage_2026 | 67 | Fair | Strong architecture/layout |
| xiaoxiaole | 63 | Fair | Strong architecture/layout |
| pac_dash_2026 | 62 | Fair | Strong architecture/layout |
| peking_opera_duel_2026 | 62 | Fair | Strong architecture/layout |
| dragon_scroll_keeper_2026 | 61 | Fair | Strong architecture/layout |
| bamboo_forest_sentinel_2026 | 60 | Fair | Strong architecture/layout |
| bowling_alley_2026 | 60 | Fair | Strong architecture/layout |
| festival_lion_dance_defense_2026 | 60 | Fair | Strong architecture/layout |
| ink_scroll_detective_2026 | 60 | Fair | Strong architecture/layout |
| night_market_chef_duel_2026 | 60 | Fair | Strong architecture/layout |
| skyline_parkour_trials_2026 | 60 | Fair | Strong architecture/layout |
| tetris_meteor_fall_2026 | 60 | Fair | Strong architecture/layout |
| wuxia_rooftop_duel_2026 | 60 | Fair | Strong architecture/layout |
| celestial_kite_festival_2026 | 59 | Fair | Strong architecture/layout |
| dungeon_courier_escape_2026 | 59 | Fair | Strong architecture/layout |
| moon_gate_defense_2026 | 59 | Fair | Strong architecture/layout |
| candy_crush_2026 | 58 | Fair | Strong architecture/layout |
| flappy_sky_ruins_2026 | 58 | Fair | Strong architecture/layout |

## 20 Highest-Priority Games for Quality Investment

| Game | Score | Primary Gap | Recommended First Action |
|---|---:|---|---|
| raygui_demo | 33 | No tests | Add README.mbt.md with controls, game loop, and run instructions |
| text_unicode | 34 | No tests | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| ninja_rooftop_chase_2026 | 36 | No tests | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| archery_tournament_2026 | 37 | No tests | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| core_automation_events | 37 | No tests | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| core_window_flags | 37 | No tests | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| shapes_pie_chart | 37 | No tests | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| orbital_shield_command_2026 | 38 | No tests | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| reactor_siege_2026 | 38 | No tests | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| rhythm_street_beats_2026 | 38 | No tests | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| skyforge_mining_convoy_2026 | 38 | No tests | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| spellforge_arena_2026 | 38 | No tests | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| street_basketball_duel_2026 | 38 | No tests | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| core_3d_camera_first_person | 39 | No tests | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| core_input_gamepad | 39 | No tests | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| fishing_tycoon_2026 | 39 | No tests | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| rts_skirmish_2026 | 39 | No tests | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| rush_hour_escape_2026 | 39 | No tests | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| text_draw_3d | 39 | No tests | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| text_rectangle_bounds | 39 | No tests | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |

## Per-Game Quality Matrix (All Games)

| Game | Score | Rating | Arch | Maint | Test | Docs | Robust | LOC | Fns | Tests+Doctests | Priority Improvements |
|---|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|---|
| super_mario_1985_lite | 76 | Good | 23 | 19 | 8 | 15 | 11 | 2303 | 52 | 2 | Split long function in `super_mario_1985_lite/internal/game/game_test.mbt` (max ~199 lines) |
| 2048 | 69 | Fair | 19 | 20 | 8 | 11 | 11 | 1114 | 28 | 1 | Split long function in `2048/internal/game/logic.mbt` (max ~139 lines) |
| asteroid_salvage_2026 | 67 | Fair | 20 | 25 | 0 | 11 | 11 | 564 | 14 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| xiaoxiaole | 63 | Fair | 18 | 21 | 0 | 11 | 13 | 1127 | 24 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| pac_dash_2026 | 62 | Fair | 19 | 23 | 0 | 11 | 9 | 654 | 16 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| peking_opera_duel_2026 | 62 | Fair | 17 | 21 | 0 | 11 | 13 | 1371 | 32 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| dragon_scroll_keeper_2026 | 61 | Fair | 16 | 21 | 0 | 11 | 13 | 2169 | 55 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| bamboo_forest_sentinel_2026 | 60 | Fair | 17 | 21 | 0 | 11 | 11 | 1960 | 47 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `bamboo_forest_sentinel_2026/internal/render/render.mbt` (max ~144 lines) |
| bowling_alley_2026 | 60 | Fair | 17 | 21 | 0 | 11 | 11 | 2105 | 48 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `bowling_alley_2026/internal/game/input.mbt` (max ~140 lines) |
| festival_lion_dance_defense_2026 | 60 | Fair | 17 | 21 | 0 | 11 | 11 | 1775 | 46 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `festival_lion_dance_defense_2026/internal/render/render.mbt` (max ~142 lines) |
| ink_scroll_detective_2026 | 60 | Fair | 17 | 21 | 0 | 11 | 11 | 1840 | 58 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `ink_scroll_detective_2026/internal/render/render.mbt` (max ~125 lines) |
| night_market_chef_duel_2026 | 60 | Fair | 17 | 21 | 0 | 11 | 11 | 1732 | 57 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `night_market_chef_duel_2026/internal/render/render.mbt` (max ~139 lines) |
| skyline_parkour_trials_2026 | 60 | Fair | 17 | 21 | 0 | 11 | 11 | 2095 | 50 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Break large files (>300 LOC) into feature-focused modules |
| tetris_meteor_fall_2026 | 60 | Fair | 19 | 21 | 0 | 11 | 9 | 777 | 17 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `tetris_meteor_fall_2026/internal/render/render.mbt` (max ~129 lines) |
| wuxia_rooftop_duel_2026 | 60 | Fair | 17 | 21 | 0 | 11 | 11 | 1811 | 45 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `wuxia_rooftop_duel_2026/internal/render/render.mbt` (max ~127 lines) |
| celestial_kite_festival_2026 | 59 | Fair | 16 | 21 | 0 | 11 | 11 | 2937 | 74 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `celestial_kite_festival_2026/internal/render/render.mbt` (max ~136 lines) |
| dungeon_courier_escape_2026 | 59 | Fair | 16 | 21 | 0 | 11 | 11 | 2113 | 47 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `dungeon_courier_escape_2026/internal/render/render.mbt` (max ~131 lines) |
| moon_gate_defense_2026 | 59 | Fair | 16 | 21 | 0 | 11 | 11 | 2195 | 54 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `moon_gate_defense_2026/internal/render/render.mbt` (max ~134 lines) |
| candy_crush_2026 | 58 | Fair | 17 | 19 | 0 | 11 | 11 | 1841 | 48 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `candy_crush_2026/internal/render/render.mbt` (max ~156 lines) |
| flappy_sky_ruins_2026 | 58 | Fair | 17 | 19 | 0 | 11 | 11 | 1700 | 41 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `flappy_sky_ruins_2026/internal/render/render.mbt` (max ~187 lines) |
| gomoku_street_duel_2026 | 58 | Fair | 17 | 19 | 0 | 11 | 11 | 2038 | 49 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `gomoku_street_duel_2026/internal/render/render.mbt` (max ~202 lines) |
| hotpot_empire_rush_2026 | 58 | Fair | 17 | 19 | 0 | 11 | 11 | 2094 | 56 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `hotpot_empire_rush_2026/internal/render/render.mbt` (max ~224 lines) |
| martial_arts_school_manager_2026 | 58 | Fair | 17 | 19 | 0 | 11 | 11 | 1483 | 42 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `martial_arts_school_manager_2026/internal/render/render.mbt` (max ~186 lines) |
| minesweeper_neon_ops_2026 | 58 | Fair | 17 | 19 | 0 | 11 | 11 | 1923 | 52 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `minesweeper_neon_ops_2026/internal/render/render.mbt` (max ~192 lines) |
| neon_2048_storm_2026 | 58 | Fair | 17 | 19 | 0 | 11 | 11 | 1940 | 42 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `neon_2048_storm_2026/internal/render/render.mbt` (max ~199 lines) |
| shadow_puppet_theater_2026 | 58 | Fair | 17 | 19 | 0 | 11 | 11 | 1333 | 31 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `shadow_puppet_theater_2026/internal/render/render.mbt` (max ~172 lines) |
| snake_battle_arena_2026 | 58 | Fair | 17 | 19 | 0 | 11 | 11 | 2147 | 62 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `snake_battle_arena_2026/internal/render/render.mbt` (max ~201 lines) |
| submarine_sonar_hunt_2026 | 58 | Fair | 17 | 21 | 0 | 11 | 9 | 2047 | 40 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `submarine_sonar_hunt_2026/internal/render/render.mbt` (max ~148 lines) |
| tea_mountain_express_2026 | 58 | Fair | 17 | 19 | 0 | 11 | 11 | 1508 | 24 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `tea_mountain_express_2026/internal/game/logic.mbt` (max ~204 lines) |
| ancient_temple_trap_run_2026 | 57 | Fair | 16 | 21 | 0 | 11 | 9 | 2312 | 52 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `ancient_temple_trap_run_2026/internal/render/render.mbt` (max ~124 lines) |
| arctic_signal_relay_2026 | 57 | Fair | 16 | 19 | 0 | 11 | 11 | 2010 | 42 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `arctic_signal_relay_2026/internal/game/logic.mbt` (max ~165 lines) |
| clockwork_train_heist_2026 | 57 | Fair | 16 | 19 | 0 | 11 | 11 | 2397 | 61 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `clockwork_train_heist_2026/internal/render/render.mbt` (max ~193 lines) |
| dragon_boat_sprint_2026 | 57 | Fair | 16 | 19 | 0 | 11 | 11 | 1623 | 38 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `dragon_boat_sprint_2026/internal/render/render.mbt` (max ~277 lines) |
| paper_lantern_patrol_2026 | 57 | Fair | 16 | 19 | 0 | 11 | 11 | 2265 | 57 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `paper_lantern_patrol_2026/internal/render/render.mbt` (max ~165 lines) |
| polar_train_heist_2026 | 57 | Fair | 16 | 21 | 0 | 11 | 9 | 3518 | 85 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `polar_train_heist_2026/internal/render/render.mbt` (max ~130 lines) |
| portal_blackout_escape_2026 | 57 | Fair | 16 | 19 | 0 | 11 | 11 | 2462 | 67 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `portal_blackout_escape_2026/internal/render/render.mbt` (max ~195 lines) |
| quantum_skater_2026 | 57 | Fair | 16 | 21 | 0 | 11 | 9 | 2313 | 59 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `quantum_skater_2026/internal/render/render.mbt` (max ~137 lines) |
| raft_rapids_escape_2026 | 57 | Fair | 16 | 19 | 0 | 11 | 11 | 2166 | 48 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `raft_rapids_escape_2026/internal/render/render.mbt` (max ~172 lines) |
| silkroad_caravan_guard_2026 | 57 | Fair | 16 | 21 | 0 | 11 | 9 | 2438 | 67 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `silkroad_caravan_guard_2026/internal/render/render.mbt` (max ~141 lines) |
| solar_rail_breaker_2026 | 57 | Fair | 16 | 21 | 0 | 11 | 9 | 2874 | 73 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `solar_rail_breaker_2026/internal/render/render.mbt` (max ~144 lines) |
| subway_signal_saboteur_2026 | 57 | Fair | 16 | 19 | 0 | 11 | 11 | 2369 | 54 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `subway_signal_saboteur_2026/internal/render/render.mbt` (max ~218 lines) |
| teahouse_midnight_service_2026 | 57 | Fair | 16 | 21 | 0 | 11 | 9 | 3075 | 77 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `teahouse_midnight_service_2026/internal/render/render.mbt` (max ~139 lines) |
| museum_heist_puzzle_2026 | 56 | Fair | 17 | 21 | 0 | 11 | 7 | 1900 | 46 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `museum_heist_puzzle_2026/internal/render/render.mbt` (max ~125 lines) |
| sokoban_warehouse_master_2026 | 56 | Fair | 17 | 19 | 0 | 11 | 9 | 1991 | 38 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `sokoban_warehouse_master_2026/internal/game/logic.mbt` (max ~178 lines) |
| abyss_signal_runner_2026 | 55 | Fair | 16 | 21 | 0 | 11 | 7 | 2758 | 67 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `abyss_signal_runner_2026/internal/render/render.mbt` (max ~141 lines) |
| arctic_outpost_survival_2026 | 55 | Fair | 16 | 19 | 0 | 11 | 9 | 2655 | 56 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `arctic_outpost_survival_2026/internal/render/render.mbt` (max ~189 lines) |
| haunted_library_puzzle_2026 | 55 | Fair | 16 | 19 | 0 | 11 | 9 | 2367 | 56 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `haunted_library_puzzle_2026/internal/render/render.mbt` (max ~194 lines) |
| ice_fishing_blitz_2026 | 55 | Fair | 16 | 19 | 0 | 11 | 9 | 2574 | 50 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `ice_fishing_blitz_2026/internal/render/render.mbt` (max ~186 lines) |
| jade_temple_bellkeeper_2026 | 55 | Fair | 16 | 19 | 0 | 11 | 9 | 3301 | 78 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `jade_temple_bellkeeper_2026/internal/game/logic.mbt` (max ~180 lines) |
| matchlink_festival_2026 | 55 | Fair | 16 | 19 | 0 | 11 | 9 | 2481 | 53 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `matchlink_festival_2026/internal/render/render.mbt` (max ~246 lines) |
| neon_rooftop_rush_2026 | 55 | Fair | 16 | 19 | 0 | 11 | 9 | 2942 | 71 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `neon_rooftop_rush_2026/internal/render/render.mbt` (max ~154 lines) |
| pizza_delivery_mayhem_2026 | 55 | Fair | 16 | 19 | 0 | 11 | 9 | 2510 | 52 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `pizza_delivery_mayhem_2026/internal/render/render.mbt` (max ~176 lines) |
| skyhook_cargo_rescue_2026 | 55 | Fair | 16 | 19 | 0 | 11 | 9 | 2597 | 56 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `skyhook_cargo_rescue_2026/internal/render/render.mbt` (max ~189 lines) |
| volcano_rescue_ops_2026 | 55 | Fair | 16 | 19 | 0 | 11 | 9 | 2352 | 72 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `volcano_rescue_ops_2026/internal/render/render.mbt` (max ~262 lines) |
| audio_mixed_processor | 53 | Needs Attention | 6 | 25 | 0 | 11 | 11 | 101 | 2 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| audio_sound_loading | 53 | Needs Attention | 6 | 25 | 0 | 11 | 11 | 39 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| audio_sound_multi | 53 | Needs Attention | 6 | 25 | 0 | 11 | 11 | 49 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| bomberman_1983_lite | 53 | Needs Attention | 16 | 19 | 0 | 11 | 7 | 5900 | 105 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `bomberman_1983_lite/internal/levels/profiles.mbt` (max ~977 lines) |
| clockwork_city_chase_2026 | 53 | Needs Attention | 16 | 19 | 0 | 11 | 7 | 3360 | 77 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `clockwork_city_chase_2026/internal/render/render.mbt` (max ~173 lines) |
| contra_1987_lite | 53 | Needs Attention | 16 | 19 | 0 | 11 | 7 | 5848 | 106 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `contra_1987_lite/internal/render/render_ui.mbt` (max ~203 lines) |
| core_3d_camera_free | 53 | Needs Attention | 6 | 25 | 0 | 11 | 11 | 57 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| core_3d_camera_mode | 53 | Needs Attention | 6 | 25 | 0 | 11 | 11 | 37 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| core_basic_window | 53 | Needs Attention | 6 | 25 | 0 | 11 | 11 | 24 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| core_drop_files | 53 | Needs Attention | 6 | 25 | 0 | 11 | 11 | 63 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| core_input_keys | 53 | Needs Attention | 6 | 25 | 0 | 11 | 11 | 52 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| core_input_mouse_wheel | 53 | Needs Attention | 6 | 25 | 0 | 11 | 11 | 41 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| core_input_multitouch | 53 | Needs Attention | 6 | 25 | 0 | 11 | 11 | 50 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| core_random_values | 53 | Needs Attention | 6 | 25 | 0 | 11 | 11 | 32 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| core_storage_values | 53 | Needs Attention | 6 | 25 | 0 | 11 | 11 | 75 | 3 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| fighter_97_lite | 53 | Needs Attention | 16 | 19 | 0 | 11 | 7 | 5850 | 115 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `fighter_97_lite/internal/render/render_fighter.mbt` (max ~188 lines) |
| jackal_1988_lite | 53 | Needs Attention | 16 | 19 | 0 | 11 | 7 | 5823 | 103 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `jackal_1988_lite/internal/render/render_ui.mbt` (max ~204 lines) |
| mahjong_solitaire_pavilion_2026 | 53 | Needs Attention | 16 | 19 | 0 | 11 | 7 | 2435 | 46 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `mahjong_solitaire_pavilion_2026/internal/render/render.mbt` (max ~263 lines) |
| neon_drift_bounty_2026 | 53 | Needs Attention | 16 | 19 | 0 | 11 | 7 | 3406 | 78 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `neon_drift_bounty_2026/internal/render/render.mbt` (max ~179 lines) |
| picross_harbor_2026 | 53 | Needs Attention | 16 | 19 | 0 | 11 | 7 | 2586 | 53 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `picross_harbor_2026/internal/render/render.mbt` (max ~265 lines) |
| platformer_3d | 53 | Needs Attention | 16 | 19 | 0 | 11 | 7 | 7079 | 106 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `platformer_3d/internal/levels/levels.mbt` (max ~354 lines) |
| shaders_eratosthenes | 53 | Needs Attention | 6 | 25 | 0 | 11 | 11 | 49 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| shaders_model_shader | 53 | Needs Attention | 6 | 25 | 0 | 11 | 11 | 63 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| shaders_texture_drawing | 53 | Needs Attention | 6 | 25 | 0 | 11 | 11 | 61 | 2 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| shapes_logo_raylib | 53 | Needs Attention | 6 | 25 | 0 | 11 | 11 | 41 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| tank_1990 | 53 | Needs Attention | 16 | 19 | 0 | 11 | 7 | 5630 | 93 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `tank_1990/internal/render/render_ui.mbt` (max ~178 lines) |
| text_font_spritefont | 53 | Needs Attention | 6 | 25 | 0 | 11 | 11 | 58 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| text_format_text | 53 | Needs Attention | 6 | 25 | 0 | 11 | 11 | 34 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| text_writing_anim | 53 | Needs Attention | 6 | 25 | 0 | 11 | 11 | 54 | 2 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| textures_image_loading | 53 | Needs Attention | 6 | 25 | 0 | 11 | 11 | 36 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| textures_image_rotate | 53 | Needs Attention | 6 | 25 | 0 | 11 | 11 | 65 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| textures_image_text | 53 | Needs Attention | 6 | 25 | 0 | 11 | 11 | 58 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| textures_logo_raylib | 53 | Needs Attention | 6 | 25 | 0 | 11 | 11 | 32 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| textures_raw_data | 53 | Needs Attention | 6 | 25 | 0 | 11 | 11 | 57 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| textures_to_image | 53 | Needs Attention | 6 | 25 | 0 | 11 | 11 | 40 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| core_input_mouse | 52 | Needs Attention | 6 | 24 | 0 | 11 | 11 | 43 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| core_window_should_close | 52 | Needs Attention | 6 | 24 | 0 | 11 | 11 | 47 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| dungeon_crawler_3d | 52 | Needs Attention | 16 | 18 | 0 | 11 | 7 | 6424 | 87 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `dungeon_crawler_3d/internal/render/render_ui.mbt` (max ~162 lines) |
| puzzle_dungeon_3d | 52 | Needs Attention | 16 | 18 | 0 | 11 | 7 | 5395 | 71 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `puzzle_dungeon_3d/internal/types/utils.mbt` (max ~264 lines) |
| survival_arena_3d | 52 | Needs Attention | 16 | 18 | 0 | 11 | 7 | 7067 | 76 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `survival_arena_3d/internal/render/render_ui.mbt` (max ~200 lines) |
| tower_defense_3d | 52 | Needs Attention | 16 | 18 | 0 | 11 | 7 | 6990 | 98 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `tower_defense_3d/internal/render/render_ui.mbt` (max ~211 lines) |
| audio_music_stream | 51 | Needs Attention | 6 | 23 | 0 | 11 | 11 | 67 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| audio_stream_effects | 51 | Needs Attention | 6 | 23 | 0 | 11 | 11 | 166 | 3 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| core_directory_files | 51 | Needs Attention | 6 | 23 | 0 | 11 | 11 | 85 | 2 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| core_input_gamepad_info | 51 | Needs Attention | 6 | 23 | 0 | 11 | 11 | 70 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| core_scissor_test | 51 | Needs Attention | 6 | 23 | 0 | 11 | 11 | 63 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| core_world_screen | 51 | Needs Attention | 6 | 23 | 0 | 11 | 11 | 65 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| models_animation | 51 | Needs Attention | 6 | 23 | 0 | 11 | 11 | 79 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| models_billboard | 51 | Needs Attention | 6 | 23 | 0 | 11 | 11 | 79 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| models_cubicmap | 51 | Needs Attention | 6 | 23 | 0 | 11 | 11 | 65 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| models_gpu_skinning | 51 | Needs Attention | 6 | 23 | 0 | 11 | 11 | 78 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| models_heightmap | 51 | Needs Attention | 6 | 23 | 0 | 11 | 11 | 64 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| models_loading_gltf | 51 | Needs Attention | 6 | 23 | 0 | 11 | 11 | 74 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| models_rlgl_solar_system | 51 | Needs Attention | 6 | 23 | 0 | 11 | 11 | 146 | 2 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| models_waving_cubes | 51 | Needs Attention | 6 | 23 | 0 | 11 | 11 | 80 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| shaders_multi_sample2d | 51 | Needs Attention | 6 | 23 | 0 | 11 | 11 | 82 | 2 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| shaders_palette_switch | 51 | Needs Attention | 6 | 23 | 0 | 11 | 11 | 100 | 2 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| shaders_shapes_textures | 51 | Needs Attention | 6 | 23 | 0 | 11 | 11 | 62 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| shaders_simple_mask | 51 | Needs Attention | 6 | 23 | 0 | 11 | 11 | 86 | 2 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| shaders_texture_outline | 51 | Needs Attention | 6 | 23 | 0 | 11 | 11 | 146 | 4 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| shaders_texture_tiling | 51 | Needs Attention | 6 | 23 | 0 | 11 | 11 | 93 | 2 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| shaders_vertex_displacement | 51 | Needs Attention | 6 | 23 | 0 | 11 | 11 | 86 | 2 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| shaders_write_depth | 51 | Needs Attention | 6 | 23 | 0 | 11 | 11 | 83 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| shapes_bouncing_ball | 51 | Needs Attention | 6 | 23 | 0 | 11 | 11 | 67 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| shapes_colors_palette | 51 | Needs Attention | 6 | 23 | 0 | 11 | 11 | 94 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| shapes_easings_ball_anim | 51 | Needs Attention | 6 | 23 | 0 | 11 | 11 | 120 | 4 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| text_font_loading | 51 | Needs Attention | 6 | 23 | 0 | 11 | 11 | 76 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| text_raylib_fonts | 51 | Needs Attention | 6 | 23 | 0 | 11 | 11 | 86 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| textures_blend_modes | 51 | Needs Attention | 6 | 23 | 0 | 11 | 11 | 79 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| textures_image_drawing | 51 | Needs Attention | 6 | 23 | 0 | 11 | 11 | 82 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| textures_image_kernel | 51 | Needs Attention | 6 | 23 | 0 | 11 | 11 | 99 | 3 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| textures_polygon | 51 | Needs Attention | 6 | 23 | 0 | 11 | 11 | 109 | 2 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| textures_sprite_button | 51 | Needs Attention | 6 | 23 | 0 | 11 | 11 | 75 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| textures_srcrec_dstrec | 51 | Needs Attention | 6 | 23 | 0 | 11 | 11 | 82 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| core_basic_screen_manager | 50 | Needs Attention | 6 | 22 | 0 | 11 | 11 | 86 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| flight_sim_3d | 50 | Needs Attention | 16 | 16 | 0 | 11 | 7 | 6653 | 53 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `flight_sim_3d/internal/types/types.mbt` (max ~304 lines) |
| kart_racing_3d | 50 | Needs Attention | 16 | 16 | 0 | 11 | 7 | 7317 | 64 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `kart_racing_3d/internal/render/render_ui.mbt` (max ~580 lines) |
| naval_combat_3d | 50 | Needs Attention | 16 | 16 | 0 | 11 | 7 | 6239 | 60 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `naval_combat_3d/internal/game/player_system.mbt` (max ~345 lines) |
| space_combat_3d | 50 | Needs Attention | 16 | 16 | 0 | 11 | 7 | 6668 | 66 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `space_combat_3d/internal/render/render_world.mbt` (max ~244 lines) |
| textures_sprite_anim | 50 | Needs Attention | 6 | 22 | 0 | 11 | 11 | 93 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| textures_sprite_explosion | 50 | Needs Attention | 6 | 22 | 0 | 11 | 11 | 78 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| voxel_world_3d | 50 | Needs Attention | 16 | 16 | 0 | 11 | 7 | 6490 | 68 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `voxel_world_3d/internal/types/utils.mbt` (max ~913 lines) |
| core_random_sequence | 49 | Needs Attention | 6 | 21 | 0 | 11 | 11 | 195 | 4 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| models_mesh_generation | 49 | Needs Attention | 6 | 21 | 0 | 11 | 11 | 110 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| models_point_rendering | 49 | Needs Attention | 6 | 21 | 0 | 11 | 11 | 166 | 2 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| models_skybox | 49 | Needs Attention | 6 | 21 | 0 | 11 | 11 | 107 | 2 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| shaders_raymarching | 49 | Needs Attention | 6 | 21 | 0 | 11 | 11 | 149 | 4 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| shaders_texture_waves | 49 | Needs Attention | 6 | 21 | 0 | 11 | 11 | 119 | 3 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| shapes_basic_shapes | 49 | Needs Attention | 6 | 21 | 0 | 11 | 11 | 92 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| shapes_easings_box_anim | 49 | Needs Attention | 6 | 21 | 0 | 11 | 11 | 156 | 6 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| shapes_easings_rectangle_array | 49 | Needs Attention | 6 | 21 | 0 | 11 | 11 | 104 | 3 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| shapes_following_eyes | 49 | Needs Attention | 6 | 21 | 0 | 11 | 11 | 98 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| shapes_hilbert_curve | 49 | Needs Attention | 6 | 21 | 0 | 11 | 11 | 154 | 3 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| text_codepoints_loading | 49 | Needs Attention | 6 | 21 | 0 | 11 | 11 | 111 | 2 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| textures_bunnymark | 49 | Needs Attention | 6 | 21 | 0 | 11 | 11 | 105 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| textures_image_generation | 49 | Needs Attention | 6 | 21 | 0 | 11 | 11 | 101 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| core_input_virtual_controls | 48 | Needs Attention | 6 | 20 | 0 | 11 | 11 | 100 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| models_draw_cube_texture | 48 | Needs Attention | 5 | 21 | 0 | 11 | 11 | 242 | 3 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| shapes_lines_bezier | 48 | Needs Attention | 6 | 20 | 0 | 11 | 11 | 67 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| text_input_box | 48 | Needs Attention | 6 | 20 | 0 | 11 | 11 | 125 | 2 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| textures_gif_player | 48 | Needs Attention | 6 | 20 | 0 | 11 | 11 | 109 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| core_smooth_pixelperfect | 47 | Needs Attention | 6 | 21 | 0 | 11 | 9 | 121 | 2 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `core_smooth_pixelperfect/main.mbt` (max ~137 lines) |
| core_window_letterbox | 47 | Needs Attention | 6 | 19 | 0 | 11 | 11 | 152 | 2 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `core_window_letterbox/main.mbt` (max ~154 lines) |
| models_geometric_shapes | 47 | Needs Attention | 6 | 21 | 0 | 11 | 9 | 120 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `models_geometric_shapes/main.mbt` (max ~123 lines) |
| models_orthographic_projection | 47 | Needs Attention | 6 | 21 | 0 | 11 | 9 | 138 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `models_orthographic_projection/main.mbt` (max ~143 lines) |
| raymath_vector_angle | 47 | Needs Attention | 6 | 21 | 0 | 11 | 9 | 162 | 6 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `raymath_vector_angle/main.mbt` (max ~150 lines) |
| shaders_custom_uniform | 47 | Needs Attention | 6 | 21 | 0 | 11 | 9 | 126 | 2 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `shaders_custom_uniform/main.mbt` (max ~139 lines) |
| shaders_hot_reloading | 47 | Needs Attention | 6 | 21 | 0 | 11 | 9 | 122 | 3 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `shaders_hot_reloading/main.mbt` (max ~124 lines) |
| shaders_postprocessing | 47 | Needs Attention | 6 | 21 | 0 | 11 | 9 | 113 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `shaders_postprocessing/main.mbt` (max ~127 lines) |
| shapes_rounded_rectangle_drawing | 47 | Needs Attention | 6 | 21 | 0 | 11 | 9 | 137 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `shapes_rounded_rectangle_drawing/main.mbt` (max ~149 lines) |
| shapes_triangle_strip | 47 | Needs Attention | 6 | 21 | 0 | 11 | 9 | 110 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `shapes_triangle_strip/main.mbt` (max ~122 lines) |
| textures_background_scrolling | 47 | Needs Attention | 6 | 21 | 0 | 11 | 9 | 111 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `textures_background_scrolling/main.mbt` (max ~123 lines) |
| textures_image_channel | 47 | Needs Attention | 6 | 21 | 0 | 11 | 9 | 129 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `textures_image_channel/main.mbt` (max ~144 lines) |
| audio_raw_stream | 46 | Needs Attention | 6 | 20 | 0 | 11 | 9 | 111 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `audio_raw_stream/main.mbt` (max ~130 lines) |
| core_3d_picking | 46 | Needs Attention | 6 | 20 | 0 | 11 | 9 | 131 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `core_3d_picking/main.mbt` (max ~148 lines) |
| models_box_collisions | 46 | Needs Attention | 6 | 20 | 0 | 11 | 9 | 130 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `models_box_collisions/main.mbt` (max ~146 lines) |
| models_loading | 46 | Needs Attention | 6 | 20 | 0 | 11 | 9 | 120 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `models_loading/main.mbt` (max ~128 lines) |
| models_yaw_pitch_roll | 46 | Needs Attention | 6 | 18 | 0 | 11 | 11 | 118 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| pinball_workshop_2026 | 46 | Needs Attention | 5 | 19 | 0 | 11 | 11 | 326 | 7 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `pinball_workshop_2026/main.mbt` (max ~207 lines) |
| shapes_rectangle_scaling | 46 | Needs Attention | 6 | 18 | 0 | 11 | 11 | 86 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| text_font_filters | 46 | Needs Attention | 6 | 20 | 0 | 11 | 9 | 107 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `text_font_filters/main.mbt` (max ~124 lines) |
| textures_particles_blending | 46 | Needs Attention | 6 | 20 | 0 | 11 | 9 | 139 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `textures_particles_blending/main.mbt` (max ~147 lines) |
| core_compute_hash | 45 | Needs Attention | 6 | 19 | 0 | 11 | 9 | 175 | 4 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `core_compute_hash/main.mbt` (max ~163 lines) |
| core_vr_simulator | 45 | Needs Attention | 6 | 19 | 0 | 11 | 9 | 156 | 2 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `core_vr_simulator/main.mbt` (max ~157 lines) |
| shaders_color_correction | 45 | Needs Attention | 6 | 19 | 0 | 11 | 9 | 211 | 2 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `shaders_color_correction/main.mbt` (max ~226 lines) |
| shaders_hybrid_render | 45 | Needs Attention | 6 | 19 | 0 | 11 | 9 | 154 | 4 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `shaders_hybrid_render/main.mbt` (max ~161 lines) |
| shaders_lightmap | 45 | Needs Attention | 6 | 19 | 0 | 11 | 9 | 149 | 2 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `shaders_lightmap/main.mbt` (max ~155 lines) |
| shapes_kaleidoscope | 45 | Needs Attention | 6 | 19 | 0 | 11 | 9 | 178 | 3 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `shapes_kaleidoscope/main.mbt` (max ~186 lines) |
| shapes_math_sine_cosine | 45 | Needs Attention | 4 | 19 | 0 | 11 | 11 | 384 | 3 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `shapes_math_sine_cosine/main.mbt` (max ~382 lines) |
| shapes_recursive_tree | 45 | Needs Attention | 6 | 19 | 0 | 11 | 9 | 164 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `shapes_recursive_tree/main.mbt` (max ~167 lines) |
| shapes_rlgl_color_wheel | 45 | Needs Attention | 5 | 18 | 0 | 11 | 11 | 314 | 5 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `shapes_rlgl_color_wheel/main.mbt` (max ~328 lines) |
| text_font_sdf | 45 | Needs Attention | 6 | 19 | 0 | 11 | 9 | 145 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `text_font_sdf/main.mbt` (max ~164 lines) |
| audio_module_playing | 44 | Needs Attention | 6 | 18 | 0 | 11 | 9 | 164 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `audio_module_playing/main.mbt` (max ~190 lines) |
| castle_siege_artillery_2026 | 44 | Needs Attention | 3 | 19 | 0 | 11 | 11 | 676 | 10 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `castle_siege_artillery_2026/main.mbt` (max ~608 lines) |
| city_builder_mini_2026 | 44 | Needs Attention | 5 | 19 | 0 | 11 | 9 | 287 | 8 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `city_builder_mini_2026/main.mbt` (max ~214 lines) |
| city_crossing_2026 | 44 | Needs Attention | 3 | 19 | 0 | 11 | 11 | 646 | 14 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `city_crossing_2026/main.mbt` (max ~504 lines) |
| core_3d_camera_split_screen | 44 | Needs Attention | 5 | 19 | 0 | 11 | 9 | 236 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `core_3d_camera_split_screen/main.mbt` (max ~258 lines) |
| demo | 44 | Needs Attention | 6 | 18 | 0 | 11 | 9 | 140 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `demo/main.mbt` (max ~157 lines) |
| lunar_lander_ops_2026 | 44 | Needs Attention | 3 | 19 | 0 | 11 | 11 | 763 | 11 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `lunar_lander_ops_2026/main.mbt` (max ~618 lines) |
| models_first_person_maze | 44 | Needs Attention | 6 | 18 | 0 | 11 | 9 | 137 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `models_first_person_maze/main.mbt` (max ~152 lines) |
| models_mesh_picking | 44 | Needs Attention | 6 | 18 | 0 | 11 | 9 | 236 | 2 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `models_mesh_picking/main.mbt` (max ~223 lines) |
| network_curl | 44 | Needs Attention | 6 | 18 | 0 | 11 | 9 | 177 | 2 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `network_curl/main.mbt` (max ~137 lines) |
| portal_billiards_2026 | 44 | Needs Attention | 3 | 19 | 0 | 11 | 11 | 738 | 20 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `portal_billiards_2026/main.mbt` (max ~503 lines) |
| shaders_julia_set | 44 | Needs Attention | 5 | 19 | 0 | 11 | 9 | 255 | 3 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `shaders_julia_set/main.mbt` (max ~265 lines) |
| shaders_mesh_instancing | 44 | Needs Attention | 5 | 19 | 0 | 11 | 9 | 260 | 4 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `shaders_mesh_instancing/main.mbt` (max ~164 lines) |
| shaders_shadowmap | 44 | Needs Attention | 5 | 19 | 0 | 11 | 9 | 259 | 3 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `shaders_shadowmap/main.mbt` (max ~243 lines) |
| shapes_rectangle_advanced | 44 | Needs Attention | 5 | 19 | 0 | 11 | 9 | 237 | 2 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `shapes_rectangle_advanced/main.mbt` (max ~170 lines) |
| textures_npatch_drawing | 44 | Needs Attention | 6 | 18 | 0 | 11 | 9 | 158 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `textures_npatch_drawing/main.mbt` (max ~171 lines) |
| core_2d_camera_platformer | 43 | Needs Attention | 4 | 19 | 0 | 11 | 9 | 429 | 7 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `core_2d_camera_platformer/main.mbt` (max ~187 lines) |
| core_2d_camera_split_screen | 43 | Needs Attention | 5 | 18 | 0 | 11 | 9 | 245 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `core_2d_camera_split_screen/main.mbt` (max ~262 lines) |
| easings_testbed | 43 | Needs Attention | 4 | 21 | 0 | 11 | 7 | 431 | 31 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `easings_testbed/main.mbt` (max ~148 lines) |
| metro_repair_dispatch_2026 | 43 | Needs Attention | 2 | 19 | 0 | 11 | 11 | 2077 | 43 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `metro_repair_dispatch_2026/main.mbt` (max ~606 lines) |
| neon_air_hockey_2026 | 43 | Needs Attention | 2 | 19 | 0 | 11 | 11 | 929 | 15 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `neon_air_hockey_2026/main.mbt` (max ~795 lines) |
| skyline_fire_rescue_2026 | 43 | Needs Attention | 2 | 19 | 0 | 11 | 11 | 1763 | 29 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `skyline_fire_rescue_2026/main.mbt` (max ~739 lines) |
| aftershock_rescue_convoy_2026 | 42 | Needs Attention | 2 | 18 | 0 | 11 | 11 | 2626 | 49 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `aftershock_rescue_convoy_2026/main.mbt` (max ~1046 lines) |
| arcade_factory_defense_2026 | 42 | Needs Attention | 2 | 18 | 0 | 11 | 11 | 2161 | 23 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `arcade_factory_defense_2026/main.mbt` (max ~1655 lines) |
| card_duel_2026 | 42 | Needs Attention | 5 | 19 | 0 | 11 | 7 | 293 | 7 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `card_duel_2026/main.mbt` (max ~211 lines) |
| chrono_rail_shooter_2026 | 42 | Needs Attention | 2 | 18 | 0 | 11 | 11 | 1974 | 19 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `chrono_rail_shooter_2026/main.mbt` (max ~1538 lines) |
| clocktower_heist_2026 | 42 | Needs Attention | 2 | 18 | 0 | 11 | 11 | 1533 | 19 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `clocktower_heist_2026/main.mbt` (max ~1202 lines) |
| core_2d_camera | 42 | Needs Attention | 6 | 16 | 0 | 11 | 9 | 150 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `core_2d_camera/main.mbt` (max ~171 lines) |
| core_clipboard_text | 42 | Needs Attention | 6 | 16 | 0 | 11 | 9 | 132 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `core_clipboard_text/main.mbt` (max ~151 lines) |
| core_custom_frame_control | 42 | Needs Attention | 6 | 16 | 0 | 11 | 9 | 132 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `core_custom_frame_control/main.mbt` (max ~151 lines) |
| core_input_gestures | 42 | Needs Attention | 6 | 16 | 0 | 11 | 9 | 125 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `core_input_gestures/main.mbt` (max ~127 lines) |
| deep_tunnel_drill_rescue_2026 | 42 | Needs Attention | 2 | 18 | 0 | 11 | 11 | 1721 | 36 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `deep_tunnel_drill_rescue_2026/main.mbt` (max ~669 lines) |
| desert_train_robbery_2026 | 42 | Needs Attention | 2 | 18 | 0 | 11 | 11 | 1273 | 16 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `desert_train_robbery_2026/main.mbt` (max ~1057 lines) |
| fog_ferry_rescue_2026 | 42 | Needs Attention | 2 | 18 | 0 | 11 | 11 | 2189 | 42 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `fog_ferry_rescue_2026/main.mbt` (max ~920 lines) |
| food_truck_frenzy_2026 | 42 | Needs Attention | 2 | 18 | 0 | 11 | 11 | 2104 | 49 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `food_truck_frenzy_2026/main.mbt` (max ~629 lines) |
| ghost_mansion_investigation_2026 | 42 | Needs Attention | 2 | 18 | 0 | 11 | 11 | 1230 | 17 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `ghost_mansion_investigation_2026/main.mbt` (max ~955 lines) |
| harbor_defense_2026 | 42 | Needs Attention | 2 | 18 | 0 | 11 | 11 | 1527 | 18 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `harbor_defense_2026/main.mbt` (max ~1127 lines) |
| icebreaker_convoy_command_2026 | 42 | Needs Attention | 2 | 18 | 0 | 11 | 11 | 2314 | 43 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `icebreaker_convoy_command_2026/main.mbt` (max ~836 lines) |
| lighthouse_supply_run_2026 | 42 | Needs Attention | 2 | 18 | 0 | 11 | 11 | 2196 | 43 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `lighthouse_supply_run_2026/main.mbt` (max ~905 lines) |
| magnet_lab_escape_2026 | 42 | Needs Attention | 2 | 18 | 0 | 11 | 11 | 2537 | 25 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `magnet_lab_escape_2026/main.mbt` (max ~1895 lines) |
| match3_garden_2026 | 42 | Needs Attention | 5 | 19 | 0 | 11 | 7 | 360 | 8 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `match3_garden_2026/main.mbt` (max ~195 lines) |
| meteor_miner_convoy_2026 | 42 | Needs Attention | 2 | 18 | 0 | 11 | 11 | 1282 | 18 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `meteor_miner_convoy_2026/main.mbt` (max ~1000 lines) |
| minesweeper | 42 | Needs Attention | 5 | 19 | 0 | 11 | 7 | 360 | 9 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `minesweeper/main.mbt` (max ~221 lines) |
| models_bone_socket | 42 | Needs Attention | 6 | 16 | 0 | 11 | 9 | 172 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `models_bone_socket/main.mbt` (max ~196 lines) |
| models_loading_m3d | 42 | Needs Attention | 6 | 16 | 0 | 11 | 9 | 159 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `models_loading_m3d/main.mbt` (max ~181 lines) |
| mountain_bike_downhill_2026 | 42 | Needs Attention | 2 | 18 | 0 | 11 | 11 | 1259 | 14 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `mountain_bike_downhill_2026/main.mbt` (max ~1057 lines) |
| neon_heist_extraction_2026 | 42 | Needs Attention | 2 | 18 | 0 | 11 | 11 | 2518 | 31 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `neon_heist_extraction_2026/main.mbt` (max ~1797 lines) |
| neon_taxi_rush_2026 | 42 | Needs Attention | 2 | 18 | 0 | 11 | 11 | 1475 | 18 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `neon_taxi_rush_2026/main.mbt` (max ~1116 lines) |
| platformer_precision_2026 | 42 | Needs Attention | 6 | 16 | 0 | 11 | 9 | 216 | 2 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `platformer_precision_2026/main.mbt` (max ~205 lines) |
| powerline_repair_patrol_2026 | 42 | Needs Attention | 2 | 18 | 0 | 11 | 11 | 2372 | 49 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `powerline_repair_patrol_2026/main.mbt` (max ~729 lines) |
| rocket_arena_soccer_2026 | 42 | Needs Attention | 2 | 18 | 0 | 11 | 11 | 1432 | 22 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `rocket_arena_soccer_2026/main.mbt` (max ~1009 lines) |
| rogue_dungeon_2026 | 42 | Needs Attention | 5 | 19 | 0 | 11 | 7 | 303 | 10 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `rogue_dungeon_2026/main.mbt` (max ~180 lines) |
| rooftop_mail_glider_2026 | 42 | Needs Attention | 2 | 18 | 0 | 11 | 11 | 2125 | 44 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `rooftop_mail_glider_2026/main.mbt` (max ~653 lines) |
| rooftop_volleyball_2026 | 42 | Needs Attention | 2 | 18 | 0 | 11 | 11 | 1212 | 17 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `rooftop_volleyball_2026/main.mbt` (max ~888 lines) |
| shaders_basic_lighting | 42 | Needs Attention | 5 | 19 | 0 | 11 | 7 | 273 | 6 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `shaders_basic_lighting/main.mbt` (max ~163 lines) |
| shaders_fog | 42 | Needs Attention | 5 | 19 | 0 | 11 | 7 | 334 | 8 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `shaders_fog/main.mbt` (max ~209 lines) |
| shaders_game_of_life | 42 | Needs Attention | 6 | 15 | 0 | 10 | 11 | 0 | 0 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt) |
| shaders_spotlight | 42 | Needs Attention | 5 | 19 | 0 | 11 | 7 | 277 | 6 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `shaders_spotlight/main.mbt` (max ~211 lines) |
| shapes_collision_area | 42 | Needs Attention | 6 | 16 | 0 | 11 | 9 | 126 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `shapes_collision_area/main.mbt` (max ~152 lines) |
| sky_convoy_defense_2026 | 42 | Needs Attention | 2 | 18 | 0 | 11 | 11 | 930 | 14 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `sky_convoy_defense_2026/main.mbt` (max ~798 lines) |
| snowboard_slalom_2026 | 42 | Needs Attention | 2 | 18 | 0 | 11 | 11 | 1124 | 13 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `snowboard_slalom_2026/main.mbt` (max ~956 lines) |
| textures_image_processing | 42 | Needs Attention | 6 | 16 | 0 | 11 | 9 | 144 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `textures_image_processing/main.mbt` (max ~163 lines) |
| time_loop_arena_2026 | 42 | Needs Attention | 2 | 18 | 0 | 11 | 11 | 1647 | 21 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `time_loop_arena_2026/main.mbt` (max ~1318 lines) |
| topdown_survivor_2026 | 42 | Needs Attention | 4 | 16 | 0 | 11 | 11 | 403 | 4 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `topdown_survivor_2026/main.mbt` (max ~328 lines) |
| treasure_map_expedition_2026 | 42 | Needs Attention | 5 | 19 | 0 | 11 | 7 | 287 | 5 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `treasure_map_expedition_2026/main.mbt` (max ~245 lines) |
| ufo_cow_rescue_2026 | 42 | Needs Attention | 2 | 18 | 0 | 11 | 11 | 1413 | 16 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `ufo_cow_rescue_2026/main.mbt` (max ~1196 lines) |
| urban_flood_evacuation_2026 | 42 | Needs Attention | 2 | 18 | 0 | 11 | 11 | 2186 | 42 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `urban_flood_evacuation_2026/main.mbt` (max ~923 lines) |
| void_anchor_raid_2026 | 42 | Needs Attention | 2 | 18 | 0 | 11 | 11 | 2232 | 28 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `void_anchor_raid_2026/main.mbt` (max ~1682 lines) |
| volcano_airlift_2026 | 42 | Needs Attention | 2 | 18 | 0 | 11 | 11 | 905 | 10 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `volcano_airlift_2026/main.mbt` (max ~818 lines) |
| warehouse_forklift_2026 | 42 | Needs Attention | 5 | 19 | 0 | 11 | 7 | 306 | 7 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `warehouse_forklift_2026/main.mbt` (max ~222 lines) |
| wildfire_airlift_command_2026 | 42 | Needs Attention | 2 | 18 | 0 | 11 | 11 | 2578 | 49 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `wildfire_airlift_command_2026/main.mbt` (max ~1032 lines) |
| air_traffic_control_2026 | 41 | Needs Attention | 5 | 18 | 0 | 11 | 7 | 272 | 4 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `air_traffic_control_2026/main.mbt` (max ~251 lines) |
| auto_chess_micro_2026 | 41 | Needs Attention | 4 | 19 | 0 | 11 | 7 | 422 | 13 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `auto_chess_micro_2026/main.mbt` (max ~269 lines) |
| battle_kart_arena_2026 | 41 | Needs Attention | 2 | 19 | 0 | 11 | 9 | 1014 | 20 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `battle_kart_arena_2026/main.mbt` (max ~657 lines) |
| breakout_lab_2026 | 41 | Needs Attention | 5 | 18 | 0 | 11 | 7 | 282 | 5 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `breakout_lab_2026/main.mbt` (max ~237 lines) |
| chef_rush_2026 | 41 | Needs Attention | 5 | 18 | 0 | 11 | 7 | 347 | 7 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `chef_rush_2026/main.mbt` (max ~288 lines) |
| circuit_grid_operator_2026 | 41 | Needs Attention | 2 | 19 | 0 | 11 | 9 | 1776 | 37 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `circuit_grid_operator_2026/main.mbt` (max ~613 lines) |
| dice_roguelite_arena_2026 | 41 | Needs Attention | 2 | 17 | 0 | 11 | 11 | 1645 | 33 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `dice_roguelite_arena_2026/main.mbt` (max ~861 lines) |
| firefighting_command_2026 | 41 | Needs Attention | 5 | 18 | 0 | 11 | 7 | 345 | 6 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `firefighting_command_2026/main.mbt` (max ~307 lines) |
| gravity_golf_2026 | 41 | Needs Attention | 5 | 18 | 0 | 11 | 7 | 293 | 4 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `gravity_golf_2026/main.mbt` (max ~260 lines) |
| mine_cart_mayhem_2026 | 41 | Needs Attention | 5 | 18 | 0 | 11 | 7 | 303 | 4 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `mine_cart_mayhem_2026/main.mbt` (max ~286 lines) |
| models_loading_vox | 41 | Needs Attention | 4 | 19 | 0 | 11 | 7 | 354 | 6 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `models_loading_vox/main.mbt` (max ~257 lines) |
| port_logistics_empire_2026 | 41 | Needs Attention | 2 | 19 | 0 | 11 | 9 | 2070 | 43 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `port_logistics_empire_2026/main.mbt` (max ~666 lines) |
| post_office_sorter_2026 | 41 | Needs Attention | 5 | 18 | 0 | 11 | 7 | 319 | 6 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `post_office_sorter_2026/main.mbt` (max ~271 lines) |
| power_grid_operator_2026 | 41 | Needs Attention | 5 | 18 | 0 | 11 | 7 | 322 | 5 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `power_grid_operator_2026/main.mbt` (max ~297 lines) |
| radio_station_manager_2026 | 41 | Needs Attention | 5 | 18 | 0 | 11 | 7 | 304 | 5 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `radio_station_manager_2026/main.mbt` (max ~274 lines) |
| shapes_top_down_lights | 41 | Needs Attention | 4 | 19 | 0 | 11 | 7 | 425 | 9 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `shapes_top_down_lights/main.mbt` (max ~184 lines) |
| ski_rescue_2026 | 41 | Needs Attention | 5 | 18 | 0 | 11 | 7 | 290 | 4 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `ski_rescue_2026/main.mbt` (max ~279 lines) |
| space_trader_2026 | 41 | Needs Attention | 5 | 14 | 0 | 11 | 11 | 316 | 3 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `space_trader_2026/main.mbt` (max ~289 lines) |
| stealth_heist_2026 | 41 | Needs Attention | 4 | 19 | 0 | 11 | 7 | 468 | 12 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `stealth_heist_2026/main.mbt` (max ~302 lines) |
| arcade_hacker_infiltration_2026 | 40 | Needs Attention | 2 | 16 | 0 | 11 | 11 | 1962 | 26 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `arcade_hacker_infiltration_2026/main.mbt` (max ~1578 lines) |
| bomber_grid_2026 | 40 | Needs Attention | 4 | 18 | 0 | 11 | 7 | 424 | 8 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `bomber_grid_2026/main.mbt` (max ~258 lines) |
| core_2d_camera_mouse_zoom | 40 | Needs Attention | 6 | 14 | 0 | 11 | 9 | 154 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `core_2d_camera_mouse_zoom/main.mbt` (max ~167 lines) |
| cyber_firewall_breach_2026 | 40 | Needs Attention | 2 | 18 | 0 | 11 | 9 | 926 | 16 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `cyber_firewall_breach_2026/main.mbt` (max ~682 lines) |
| deep_sea_salvage_2026 | 40 | Needs Attention | 4 | 18 | 0 | 11 | 7 | 386 | 5 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `deep_sea_salvage_2026/main.mbt` (max ~350 lines) |
| drift_police_chase_2026 | 40 | Needs Attention | 2 | 16 | 0 | 11 | 11 | 1339 | 13 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `drift_police_chase_2026/main.mbt` (max ~1073 lines) |
| drone_delivery_2026 | 40 | Needs Attention | 4 | 18 | 0 | 11 | 7 | 366 | 5 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `drone_delivery_2026/main.mbt` (max ~348 lines) |
| drone_show_director_2026 | 40 | Needs Attention | 2 | 18 | 0 | 11 | 9 | 2202 | 46 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `drone_show_director_2026/main.mbt` (max ~713 lines) |
| glacier_rescue_2026 | 40 | Needs Attention | 2 | 16 | 0 | 11 | 11 | 1490 | 14 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `glacier_rescue_2026/main.mbt` (max ~1166 lines) |
| grappling_tower_climb_2026 | 40 | Needs Attention | 2 | 16 | 0 | 11 | 11 | 1765 | 18 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `grappling_tower_climb_2026/main.mbt` (max ~1404 lines) |
| harbor_smuggler_run_2026 | 40 | Needs Attention | 2 | 16 | 0 | 11 | 11 | 1221 | 13 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `harbor_smuggler_run_2026/main.mbt` (max ~1024 lines) |
| hospital_triage_2026 | 40 | Needs Attention | 4 | 18 | 0 | 11 | 7 | 396 | 8 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `hospital_triage_2026/main.mbt` (max ~330 lines) |
| jetpack_cavern_rush_2026 | 40 | Needs Attention | 2 | 16 | 0 | 11 | 11 | 1571 | 15 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `jetpack_cavern_rush_2026/main.mbt` (max ~1186 lines) |
| magnet_maze_2026 | 40 | Needs Attention | 3 | 19 | 0 | 11 | 7 | 757 | 17 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `magnet_maze_2026/main.mbt` (max ~481 lines) |
| mech_arena_duel_2026 | 40 | Needs Attention | 4 | 18 | 0 | 11 | 7 | 397 | 5 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `mech_arena_duel_2026/main.mbt` (max ~354 lines) |
| monsoon_bridge_rescue_2026 | 40 | Needs Attention | 2 | 18 | 0 | 11 | 9 | 2414 | 51 | 0 | Add ARCHITECTURE.md documenting package boundaries and update flow; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `monsoon_bridge_rescue_2026/main.mbt` (max ~764 lines) |
| neon_subway_sprint_2026 | 40 | Needs Attention | 2 | 18 | 0 | 11 | 9 | 1427 | 19 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `neon_subway_sprint_2026/main.mbt` (max ~1147 lines) |
| orbital_salvage_ops_2026 | 40 | Needs Attention | 2 | 16 | 0 | 11 | 11 | 2528 | 22 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `orbital_salvage_ops_2026/main.mbt` (max ~2057 lines) |
| river_raid_2026 | 40 | Needs Attention | 4 | 18 | 0 | 11 | 7 | 453 | 8 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `river_raid_2026/main.mbt` (max ~404 lines) |
| shaders_basic_pbr | 40 | Needs Attention | 3 | 19 | 0 | 11 | 7 | 561 | 9 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `shaders_basic_pbr/main.mbt` (max ~420 lines) |
| shaders_deferred_render | 40 | Needs Attention | 3 | 19 | 0 | 11 | 7 | 576 | 6 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `shaders_deferred_render/main.mbt` (max ~463 lines) |
| shapes_draw_circle_sector | 40 | Needs Attention | 6 | 14 | 0 | 11 | 9 | 161 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `shapes_draw_circle_sector/main.mbt` (max ~173 lines) |
| shapes_draw_rectangle_rounded | 40 | Needs Attention | 6 | 14 | 0 | 11 | 9 | 196 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `shapes_draw_rectangle_rounded/main.mbt` (max ~210 lines) |
| shapes_draw_ring | 40 | Needs Attention | 6 | 14 | 0 | 11 | 9 | 234 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `shapes_draw_ring/main.mbt` (max ~249 lines) |
| shapes_logo_raylib_anim | 40 | Needs Attention | 6 | 14 | 0 | 11 | 9 | 170 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `shapes_logo_raylib_anim/main.mbt` (max ~182 lines) |
| shapes_splines_drawing | 40 | Needs Attention | 6 | 14 | 0 | 11 | 9 | 224 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `shapes_splines_drawing/main.mbt` (max ~246 lines) |
| submarine_hunter_2026 | 40 | Needs Attention | 4 | 18 | 0 | 11 | 7 | 367 | 6 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `submarine_hunter_2026/main.mbt` (max ~336 lines) |
| temple_relic_run_2026 | 40 | Needs Attention | 2 | 16 | 0 | 11 | 11 | 1684 | 19 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `temple_relic_run_2026/main.mbt` (max ~1532 lines) |
| textures_draw_tiled | 40 | Needs Attention | 4 | 18 | 0 | 11 | 7 | 422 | 3 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `textures_draw_tiled/main.mbt` (max ~232 lines) |
| textures_fog_of_war | 40 | Needs Attention | 6 | 14 | 0 | 11 | 9 | 166 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `textures_fog_of_war/main.mbt` (max ~184 lines) |
| train_dispatch_2026 | 40 | Needs Attention | 4 | 18 | 0 | 11 | 7 | 433 | 8 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `train_dispatch_2026/main.mbt` (max ~350 lines) |
| zombie_safehouse_siege_2026 | 40 | Needs Attention | 2 | 16 | 0 | 11 | 11 | 1746 | 16 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `zombie_safehouse_siege_2026/main.mbt` (max ~1516 lines) |
| core_3d_camera_first_person | 39 | Needs Attention | 5 | 14 | 0 | 11 | 9 | 228 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `core_3d_camera_first_person/main.mbt` (max ~251 lines) |
| core_input_gamepad | 39 | Needs Attention | 5 | 14 | 0 | 11 | 9 | 277 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `core_input_gamepad/main.mbt` (max ~289 lines) |
| fishing_tycoon_2026 | 39 | Needs Attention | 5 | 16 | 0 | 11 | 7 | 341 | 5 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `fishing_tycoon_2026/main.mbt` (max ~302 lines) |
| rts_skirmish_2026 | 39 | Needs Attention | 5 | 16 | 0 | 11 | 7 | 338 | 4 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `rts_skirmish_2026/main.mbt` (max ~286 lines) |
| rush_hour_escape_2026 | 39 | Needs Attention | 3 | 18 | 0 | 11 | 7 | 640 | 12 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `rush_hour_escape_2026/main.mbt` (max ~451 lines) |
| text_draw_3d | 39 | Needs Attention | 3 | 18 | 0 | 11 | 7 | 871 | 7 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `text_draw_3d/main.mbt` (max ~519 lines) |
| text_rectangle_bounds | 39 | Needs Attention | 5 | 16 | 0 | 11 | 7 | 314 | 3 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `text_rectangle_bounds/main.mbt` (max ~165 lines) |
| textures_mouse_painting | 39 | Needs Attention | 5 | 14 | 0 | 11 | 9 | 238 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `textures_mouse_painting/main.mbt` (max ~268 lines) |
| tower_defense_frontier_2026 | 39 | Needs Attention | 5 | 16 | 0 | 11 | 7 | 283 | 3 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `tower_defense_frontier_2026/main.mbt` (max ~258 lines) |
| orbital_shield_command_2026 | 38 | Needs Attention | 2 | 18 | 0 | 11 | 7 | 902 | 16 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `orbital_shield_command_2026/main.mbt` (max ~660 lines) |
| reactor_siege_2026 | 38 | Needs Attention | 2 | 14 | 0 | 11 | 11 | 1579 | 13 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `reactor_siege_2026/main.mbt` (max ~1250 lines) |
| rhythm_street_beats_2026 | 38 | Needs Attention | 2 | 16 | 0 | 11 | 9 | 1082 | 13 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `rhythm_street_beats_2026/main.mbt` (max ~961 lines) |
| skyforge_mining_convoy_2026 | 38 | Needs Attention | 2 | 14 | 0 | 11 | 11 | 1583 | 13 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `skyforge_mining_convoy_2026/main.mbt` (max ~1295 lines) |
| spellforge_arena_2026 | 38 | Needs Attention | 2 | 14 | 0 | 11 | 11 | 1471 | 13 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `spellforge_arena_2026/main.mbt` (max ~1124 lines) |
| street_basketball_duel_2026 | 38 | Needs Attention | 2 | 16 | 0 | 11 | 9 | 1253 | 14 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `street_basketball_duel_2026/main.mbt` (max ~995 lines) |
| archery_tournament_2026 | 37 | Needs Attention | 5 | 14 | 0 | 11 | 7 | 346 | 2 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `archery_tournament_2026/main.mbt` (max ~338 lines) |
| core_automation_events | 37 | Needs Attention | 5 | 14 | 0 | 11 | 7 | 343 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `core_automation_events/main.mbt` (max ~363 lines) |
| core_window_flags | 37 | Needs Attention | 5 | 14 | 0 | 11 | 7 | 275 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `core_window_flags/main.mbt` (max ~301 lines) |
| shapes_pie_chart | 37 | Needs Attention | 5 | 14 | 0 | 11 | 7 | 342 | 1 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `shapes_pie_chart/main.mbt` (max ~379 lines) |
| ninja_rooftop_chase_2026 | 36 | Needs Attention | 2 | 16 | 0 | 11 | 7 | 1477 | 15 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `ninja_rooftop_chase_2026/main.mbt` (max ~1217 lines) |
| text_unicode | 34 | Needs Attention | 3 | 13 | 0 | 11 | 7 | 595 | 3 | 0 | Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `text_unicode/main.mbt` (max ~231 lines) |
| raygui_demo | 33 | Needs Attention | 6 | 18 | 0 | 0 | 9 | 191 | 1 | 0 | Add README.mbt.md with controls, game loop, and run instructions; Add at least one smoke test (README.mbt.md doctest or *_test.mbt); Split long function in `raygui_demo/main.mbt` (max ~190 lines) |

## Methodology Notes and Limitations

- This report is static-analysis based and does not evaluate gameplay feel, art/audio quality, or runtime UX.
- Scores are relative and should be used for prioritization, not as absolute pass/fail judgments.
- For production hardening, pair this report with playtesting, profiling, and bug-triage data.
