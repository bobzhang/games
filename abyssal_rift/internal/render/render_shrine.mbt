///|
pub fn draw_shrine(game : @types.Game) -> Unit {
  if !game.shrine_active {
    return
  }
  match game.floor {
    Some(floor) => {
      let room = floor.rooms[floor.current_room]
      if room.kind != Shrine {
        return
      }
      let ts = @types.tile_sizef
      let cx = Float::from_int(room.x) * ts + Float::from_int(room.w) * ts / 2.0
      let cy = Float::from_int(room.y) * ts + Float::from_int(room.h) * ts / 2.0
      if game.shrine_used {
        // Dim, used shrine
        @raylib.draw_poly(
          @raylib.Vector2::new(cx, cy),
          6,
          20.0,
          0.0,
          @raylib.Color::new(60, 60, 60, 150),
        )
        let text = "USED"
        let tw = @raylib.measure_text(text, 14)
        @raylib.draw_text(
          text,
          cx.to_int() - tw / 2,
          cy.to_int() - 35,
          14,
          @raylib.Color::new(120, 120, 120, 150),
        )
      } else {
        // Active shrine with glow
        let pulse = Float::from_double(
            @math.sin(game.frame_count.to_double() * 0.05),
          ) *
          5.0 +
          22.0
        let (shrine_color, shrine_name, shrine_desc) = get_shrine_info(
          game.shrine_kind,
        )
        @raylib.draw_circle(
          cx.to_int(),
          cy.to_int(),
          pulse + 8.0,
          @raylib.Color::new(
            shrine_color.r.to_int(),
            shrine_color.g.to_int(),
            shrine_color.b.to_int(),
            30,
          ),
        )
        @raylib.draw_poly(
          @raylib.Vector2::new(cx, cy),
          6,
          pulse,
          0.0,
          shrine_color,
        )
        // Name
        let tw = @raylib.measure_text(shrine_name, 16)
        @raylib.draw_text(
          shrine_name,
          cx.to_int() - tw / 2,
          cy.to_int() - 45,
          16,
          shrine_color,
        )
        // Description
        let dw = @raylib.measure_text(shrine_desc, 12)
        @raylib.draw_text(
          shrine_desc,
          cx.to_int() - dw / 2,
          cy.to_int() - 28,
          12,
          @raylib.Color::new(200, 200, 200, 200),
        )
        // Proximity hint
        let d2 = @types.dist2(game.player.x, game.player.y, cx, cy)
        if d2 < 60.0 * 60.0 {
          let hint = "[E] Activate"
          let hw = @raylib.measure_text(hint, 14)
          @raylib.draw_text(
            hint,
            cx.to_int() - hw / 2,
            cy.to_int() + 25,
            14,
            @raylib.Color::new(255, 215, 0, 255),
          )
        }
      }
    }
    None => ()
  }
}

///|
fn get_shrine_info(kind : @types.ShrineKind) -> (@raylib.Color, String, String) {
  match kind {
    BloodAltar =>
      (
        @raylib.Color::new(200, 30, 30, 255),
        "Blood Altar",
        "Sacrifice 20 HP for +25% damage",
      )
    HealingSpring =>
      (
        @raylib.Color::new(30, 200, 80, 255),
        "Healing Spring",
        "Restore full HP and Shield",
      )
    GambleShrine =>
      (
        @raylib.Color::new(255, 215, 0, 255),
        "Gamble Shrine",
        "Pay 30 gold for random passive",
      )
    CursedChest =>
      (
        @raylib.Color::new(150, 50, 200, 255),
        "Cursed Chest",
        "Take 15 damage, get weapon upgrade",
      )
    ReforgeAnvil =>
      (
        @raylib.Color::new(180, 180, 220, 255),
        "Reforge Anvil",
        "Swap weapon for random new one",
      )
  }
}
