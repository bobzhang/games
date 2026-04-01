///|
fn draw_ui_panel(game : @types.Game, battle : @types.Battle) -> Unit {
  let px = @types.ui_panel_x
  let pw = @types.ui_panel_width
  let h = @types.screen_height
  // Panel background
  @raylib.draw_rectangle(px, 0, pw, h, @types.color_hud_bg)
  @raylib.draw_line(px, 0, px, h, @raylib.Color::new(60, 70, 90, 200))
  // Turn info
  let turn_text = "Turn " + battle.turn.to_string()
  @draw.draw_text(turn_text, px + 15, 15, 28, @types.color_gold)
  // Phase
  let phase_text = match battle.phase {
    Select => "Select a Unit"
    Move => "Choose Move Target"
    Attack => "Choose Attack Target"
    EnemyTurn => "Enemy Turn..."
    Animating => "..."
  }
  @draw.draw_text(phase_text, px + 15, 50, 18, @types.color_hud_text)
  // Team indicator
  let team_text = if battle.phase == EnemyTurn || battle.phase == Animating {
    "RED TEAM"
  } else {
    "BLUE TEAM"
  }
  let team_color = if battle.phase == EnemyTurn || battle.phase == Animating {
    @types.color_enemy
  } else {
    @types.color_player
  }
  @draw.draw_text(team_text, px + 15, 78, 16, team_color)
  // Divider
  @raylib.draw_line(
    px + 10,
    100,
    px + pw - 10,
    100,
    @raylib.Color::new(60, 70, 90, 200),
  )
  // Selected unit info
  let mut info_y = 110
  if battle.selected_unit >= 0 {
    match @types.get_unit(battle, battle.selected_unit) {
      Some(unit) => {
        let kind_text = @types.unit_kind_name(unit.kind)
        let tc = if unit.team == Player {
          @types.color_player
        } else {
          @types.color_enemy
        }
        @draw.draw_text(kind_text, px + 15, info_y, 24, tc)
        info_y = info_y + 32
        // Stats
        let hp_text = "HP: " +
          unit.hp.to_string() +
          "/" +
          unit.max_hp.to_string()
        @draw.draw_text(hp_text, px + 15, info_y, 18, @types.color_hp_bar)
        info_y = info_y + 24
        let atk_text = "ATK: " + unit.atk.to_string()
        @draw.draw_text(
          atk_text,
          px + 15,
          info_y,
          18,
          @raylib.Color::new(220, 100, 100, 255),
        )
        info_y = info_y + 24
        let move_text = "Move: " +
          @types.effective_move_range(battle, unit).to_string()
        @draw.draw_text(
          move_text,
          px + 15,
          info_y,
          18,
          @raylib.Color::new(100, 150, 220, 255),
        )
        info_y = info_y + 24
        let range_text = "Range: " +
          @types.effective_attack_range(battle, unit).to_string()
        @draw.draw_text(
          range_text,
          px + 15,
          info_y,
          18,
          @raylib.Color::new(220, 150, 50, 255),
        )
        info_y = info_y + 24
        // Status
        if unit.moved {
          @draw.draw_text(
            "MOVED",
            px + 15,
            info_y,
            14,
            @raylib.Color::new(150, 150, 150, 200),
          )
          info_y = info_y + 18
        }
        if unit.attacked {
          @draw.draw_text(
            "ATTACKED",
            px + 15,
            info_y,
            14,
            @raylib.Color::new(150, 150, 150, 200),
          )
          info_y = info_y + 18
        }
      }
      None => ()
    }
  }
  // Divider
  @raylib.draw_line(
    px + 10,
    info_y + 10,
    px + pw - 10,
    info_y + 10,
    @raylib.Color::new(60, 70, 90, 200),
  )
  info_y = info_y + 20
  // Hover terrain info
  match game.hover_hex {
    Some(hc) =>
      if @types.hex_valid(hc, battle.map.width, battle.map.height) {
        let idx = @types.hex_index(hc, battle.map.width)
        let tile = battle.map.tiles[idx]
        if tile.fog_player != Hidden {
          let tname = @types.terrain_name(tile.terrain)
          @draw.draw_text(
            tname,
            px + 15,
            info_y,
            18,
            terrain_color(tile.terrain),
          )
          info_y = info_y + 24
          let coord_text = "(" +
            hc.col.to_string() +
            ", " +
            hc.row.to_string() +
            ")"
          @draw.draw_text(
            coord_text,
            px + 15,
            info_y,
            14,
            @raylib.Color::new(120, 120, 140, 200),
          )
          info_y = info_y + 20
          // Terrain bonuses
          match tile.terrain {
            Forest => {
              @draw.draw_text(
                "+1 DEF (all), +2 DEF (Infantry)",
                px + 15,
                info_y,
                14,
                @raylib.Color::new(100, 180, 100, 200),
              )
              info_y = info_y + 18
              @draw.draw_text(
                "-1 Move (Cavalry), Blocks LOS",
                px + 15,
                info_y,
                14,
                @raylib.Color::new(180, 100, 100, 200),
              )
            }
            Hills => {
              @draw.draw_text(
                "+1 ATK (height), +1 Range (Arty)",
                px + 15,
                info_y,
                14,
                @raylib.Color::new(100, 180, 100, 200),
              )
              info_y = info_y + 18
              @draw.draw_text(
                "+1 Sight Range",
                px + 15,
                info_y,
                14,
                @raylib.Color::new(100, 180, 100, 200),
              )
            }
            Water =>
              @draw.draw_text(
                "Impassable",
                px + 15,
                info_y,
                14,
                @raylib.Color::new(180, 100, 100, 200),
              )
            _ => ()
          }
        }
      }
    None => ()
  }
  // Bottom: Unit count and controls
  let bottom_y = h - 140
  @raylib.draw_line(
    px + 10,
    bottom_y,
    px + pw - 10,
    bottom_y,
    @raylib.Color::new(60, 70, 90, 200),
  )
  // Army status
  let player_count = @types.count_team_units(battle, Player)
  let enemy_count = @types.count_team_units(battle, Enemy)
  @draw.draw_text(
    "Blue: " + player_count.to_string() + " units",
    px + 15,
    bottom_y + 10,
    16,
    @types.color_player,
  )
  @draw.draw_text(
    "Red: " + enemy_count.to_string() + " units",
    px + 15,
    bottom_y + 30,
    16,
    @types.color_enemy,
  )
  // Controls
  let controls_y = bottom_y + 60
  @draw.draw_text(
    "[CLICK] Select/Act",
    px + 15,
    controls_y,
    14,
    @raylib.Color::new(140, 150, 170, 180),
  )
  @draw.draw_text(
    "[SPACE] End Turn  [ESC] Menu",
    px + 15,
    controls_y + 18,
    14,
    @raylib.Color::new(140, 150, 170, 180),
  )
  @draw.draw_text(
    "[TAB] Next Unit  [R] Deselect",
    px + 15,
    controls_y + 36,
    14,
    @raylib.Color::new(140, 150, 170, 180),
  )
}
