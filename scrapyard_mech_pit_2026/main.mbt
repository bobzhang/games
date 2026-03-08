///|
let screen_w : Int = 1280

///|
let screen_h : Int = 840

///|
let arena_x : Int = 90

///|
let arena_y : Int = 90

///|
let arena_w : Int = 920

///|
let arena_h : Int = 660

///|
let max_bullets : Int = 360

///|
let max_enemies : Int = 80

///|
let max_scrap : Int = 128

///|
let salvage_heal : Float = 24.0F

///|
let scrap_heal : Float = 3.0F

///|
struct Bullet {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut life : Float
  mut dmg : Float
  mut friendly : Bool
  mut r : Float
}

///|
struct Enemy {
  mut active : Bool
  mut kind : Int
  mut x : Float
  mut y : Float
  mut hp : Float
  mut fire_cd : Float
  mut pulse : Float
}

///|
struct Scrap {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut value : Int
}

///|
fn clampf(v : Float, lo : Float, hi : Float) -> Float {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
fn inside_rect(px : Float, py : Float, rx : Float, ry : Float, rw : Float, rh : Float) -> Bool {
  px >= rx && px <= rx + rw && py >= ry && py <= ry + rh
}

///|
fn dist2(x1 : Float, y1 : Float, x2 : Float, y2 : Float) -> Float {
  let dx = x1 - x2
  let dy = y1 - y2
  dx * dx + dy * dy
}

///|
fn weapon_name(kind : Int) -> String {
  if kind == 0 {
    "Rivet Cannon"
  } else if kind == 1 {
    "Scatter Saw"
  } else {
    "Arc Welder"
  }
}

///|
fn chassis_name(kind : Int) -> String {
  if kind == 0 {
    "Balanced Hull"
  } else if kind == 1 {
    "Bastion Frame"
  } else {
    "Skirmisher Rig"
  }
}

///|
fn booster_name(kind : Int) -> String {
  if kind == 0 {
    "Dash Jets"
  } else if kind == 1 {
    "Overdrive Nozzles"
  } else {
    "Magnet Coil"
  }
}

///|
fn weapon_fire_cd(kind : Int, overclock : Int) -> Float {
  let base = if kind == 0 { 0.22F } else if kind == 1 { 0.32F } else { 0.12F }
  clampf(base - Float::from_int(overclock) * 0.015F, 0.08F, 0.45F)
}

///|
fn weapon_damage(kind : Int, overclock : Int) -> Float {
  let base = if kind == 0 { 18.0F } else if kind == 1 { 10.0F } else { 8.0F }
  base + Float::from_int(overclock) * 2.5F
}

///|
fn move_speed(chassis : Int, booster : Int) -> Float {
  let base = if chassis == 1 { 180.0F } else if chassis == 2 { 255.0F } else { 220.0F }
  if booster == 1 { base + 32.0F } else { base }
}

///|
fn max_hp(chassis : Int, plating : Int) -> Float {
  let base = if chassis == 1 { 180.0F } else if chassis == 2 { 112.0F } else { 140.0F }
  base + Float::from_int(plating) * 12.0F
}

///|
fn dash_force(booster : Int) -> Float {
  if booster == 0 { 240.0F } else if booster == 1 { 320.0F } else { 200.0F }
}

///|
fn magnet_range(booster : Int) -> Float {
  if booster == 2 { 210.0F } else { 84.0F }
}

///|
fn enemy_color(kind : Int) -> @raylib.Color {
  if kind == 0 {
    @raylib.Color::new(244, 112, 90, 255)
  } else if kind == 1 {
    @raylib.Color::new(128, 214, 255, 255)
  } else {
    @raylib.Color::new(255, 196, 92, 255)
  }
}

///|
fn choice_name(choice : Int) -> String {
  if choice == 0 {
    "Weapon: Rivet Cannon"
  } else if choice == 1 {
    "Weapon: Scatter Saw"
  } else if choice == 2 {
    "Weapon: Arc Welder"
  } else if choice == 3 {
    "Chassis: Balanced Hull"
  } else if choice == 4 {
    "Chassis: Bastion Frame"
  } else if choice == 5 {
    "Chassis: Skirmisher Rig"
  } else if choice == 6 {
    "Booster: Dash Jets"
  } else if choice == 7 {
    "Booster: Overdrive Nozzles"
  } else if choice == 8 {
    "Booster: Magnet Coil"
  } else if choice == 9 {
    "Patch Plating +12 HP"
  } else {
    "Overclock + rate + damage"
  }
}

///|
fn choice_desc(choice : Int) -> String {
  if choice == 0 {
    "Balanced single-shot cannon with heavy impact."
  } else if choice == 1 {
    "Three-rivet spread for close-range clearing."
  } else if choice == 2 {
    "Rapid light shots with high pressure output."
  } else if choice == 3 {
    "Steady all-round chassis."
  } else if choice == 4 {
    "Heavy armor, slower stride, much larger hull."
  } else if choice == 5 {
    "Fast hull, lighter plating, constant motion playstyle."
  } else if choice == 6 {
    "Reliable short dash bursts."
  } else if choice == 7 {
    "Highest mobility and faster recovery."
  } else if choice == 8 {
    "Vacuum scrap from farther away for snowball runs."
  } else if choice == 9 {
    "Permanent plating increase."
  } else {
    "Higher fire rate and stronger rounds."
  }
}

///|
fn choice_color(choice : Int) -> @raylib.Color {
  if choice <= 2 {
    @raylib.Color::new(104, 176, 255, 255)
  } else if choice <= 5 {
    @raylib.Color::new(130, 232, 176, 255)
  } else if choice <= 8 {
    @raylib.Color::new(255, 202, 104, 255)
  } else {
    @raylib.Color::new(230, 136, 255, 255)
  }
}

///|
fn spawn_bullet(bullets : Array[Bullet], x : Float, y : Float, vx : Float, vy : Float, life : Float, dmg : Float, friendly : Bool, r : Float) -> Unit {
  for bullet in bullets {
    if bullet.active {
      continue
    }
    bullet.active = true
    bullet.x = x
    bullet.y = y
    bullet.vx = vx
    bullet.vy = vy
    bullet.life = life
    bullet.dmg = dmg
    bullet.friendly = friendly
    bullet.r = r
    return
  }
}

///|
fn spawn_enemy(enemies : Array[Enemy], wave : Int) -> Unit {
  for enemy in enemies {
    if enemy.active {
      continue
    }
    let edge = @raylib.get_random_value(0, 3)
    let x = if edge == 0 {
      Float::from_int(arena_x + 10)
    } else if edge == 1 {
      Float::from_int(arena_x + arena_w - 10)
    } else {
      Float::from_int(@raylib.get_random_value(arena_x + 10, arena_x + arena_w - 10))
    }
    let y = if edge == 2 {
      Float::from_int(arena_y + 10)
    } else if edge == 3 {
      Float::from_int(arena_y + arena_h - 10)
    } else {
      Float::from_int(@raylib.get_random_value(arena_y + 10, arena_y + arena_h - 10))
    }
    let roll = @raylib.get_random_value(0, 9)
    let kind = if wave >= 4 && roll > 6 {
      2
    } else if wave >= 2 && roll > 3 {
      1
    } else {
      0
    }
    let hp = if kind == 0 { 24.0F + Float::from_int(wave) * 4.0F } else if kind == 1 { 18.0F + Float::from_int(wave) * 3.0F } else { 42.0F + Float::from_int(wave) * 7.0F }
    enemy.active = true
    enemy.kind = kind
    enemy.x = x
    enemy.y = y
    enemy.hp = hp
    enemy.fire_cd = 1.0F
    enemy.pulse = Float::from_int(@raylib.get_random_value(0, 1000)) / 100.0F
    return
  }
}

///|
fn spawn_scrap(scraps : Array[Scrap], x : Float, y : Float, value : Int) -> Unit {
  for scrap in scraps {
    if scrap.active {
      continue
    }
    scrap.active = true
    scrap.x = x
    scrap.y = y
    scrap.value = value
    return
  }
}

///|
fn gen_choices(choices : Array[Int]) -> Unit {
  for i in 0..<choices.length() {
    let mut c = @raylib.get_random_value(0, 10)
    let mut tries = 0
    while tries < 20 {
      let mut dup = false
      for j in 0..<i {
        if choices[j] == c {
          dup = true
        }
      }
      if !dup {
        break
      }
      c = @raylib.get_random_value(0, 10)
      tries = tries + 1
    }
    choices[i] = c
  }
}

///|
fn apply_choice(choice : Int, weapon : Int, chassis : Int, booster : Int, plating : Int, overclock : Int) -> (Int, Int, Int, Int, Int) {
  if choice <= 2 {
    (choice, chassis, booster, plating, overclock)
  } else if choice <= 5 {
    (weapon, choice - 3, booster, plating, overclock)
  } else if choice <= 8 {
    (weapon, chassis, choice - 6, plating, overclock)
  } else if choice == 9 {
    (weapon, chassis, booster, plating + 1, overclock)
  } else {
    (weapon, chassis, booster, plating, overclock + 1)
  }
}

///|
fn main {
  @raylib.init_window(screen_w, screen_h, "Scrapyard Mech Pit 2026")
  @raylib.set_target_fps(60)
  @draw.init_font()

  let bullets : Array[Bullet] = Array::makei(max_bullets, fn(_i) {
    { active: false, x: 0.0F, y: 0.0F, vx: 0.0F, vy: 0.0F, life: 0.0F, dmg: 0.0F, friendly: true, r: 3.0F }
  })
  let enemies : Array[Enemy] = Array::makei(max_enemies, fn(_i) {
    { active: false, kind: 0, x: 0.0F, y: 0.0F, hp: 0.0F, fire_cd: 0.0F, pulse: 0.0F }
  })
  let scraps : Array[Scrap] = Array::makei(max_scrap, fn(_i) {
    { active: false, x: 0.0F, y: 0.0F, value: 0 }
  })
  let choices : Array[Int] = Array::make(3, 0)

  let mut title = true
  let mut over = false
  let mut won = false
  let mut choosing = false
  let mut wave = 1
  let mut spawn_left = 0
  let mut spawn_timer = 0.0F
  let mut scrap_bank = 0
  let mut message = ""

  let mut weapon = 0
  let mut chassis = 0
  let mut booster = 0
  let mut plating = 0
  let mut overclock = 0

  let mut px = Float::from_int(arena_x + arena_w / 2)
  let mut py = Float::from_int(arena_y + arena_h / 2)
  let mut hp = 140.0F
  let mut fire_cd = 0.0F
  let mut dash_cd = 0.0F
  let mut dash_flash = 0.0F

  let reset_run = fn() {
    for bullet in bullets {
      bullet.active = false
    }
    for enemy in enemies {
      enemy.active = false
    }
    for scrap in scraps {
      scrap.active = false
    }
    title = false
    over = false
    won = false
    choosing = false
    wave = 1
    spawn_left = 10
    spawn_timer = 0.8F
    scrap_bank = 0
    weapon = 0
    chassis = 0
    booster = 0
    plating = 0
    overclock = 0
    px = Float::from_int(arena_x + arena_w / 2)
    py = Float::from_int(arena_y + arena_h / 2)
    hp = max_hp(chassis, plating)
    fire_cd = 0.0F
    dash_cd = 0.0F
    dash_flash = 0.0F
    message = "Wave 1. Scavenge upgrades between rounds."
  }

  while !@raylib.window_should_close() {
    let frame_dt = @raylib.get_frame_time()
    let dt = if frame_dt > 0.05F { 0.05F } else { frame_dt }
    let mouse = @raylib.get_mouse_position()

    if title {
      if @raylib.is_key_pressed(@raylib.KeyEnter) || @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
        reset_run()
      }
    } else if over {
      if @raylib.is_key_pressed(@raylib.KeyR) {
        reset_run()
      }
    } else if choosing {
      if @raylib.is_key_pressed(@raylib.KeyOne) || (inside_rect(mouse.x, mouse.y, 1045.0F, 180.0F, 200.0F, 150.0F) && @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft)) {
        let parts = apply_choice(choices[0], weapon, chassis, booster, plating, overclock)
        weapon = parts.0
        chassis = parts.1
        booster = parts.2
        plating = parts.3
        overclock = parts.4
        hp = clampf(hp + salvage_heal, 0.0F, max_hp(chassis, plating))
        choosing = false
        if wave >= 6 {
          over = true
          won = true
          message = "The pit bosses are scrap now."
        } else {
          wave = wave + 1
          spawn_left = 8 + wave * 3
          spawn_timer = 0.7F
          message = "Wave \{wave} online."
        }
      } else if @raylib.is_key_pressed(@raylib.KeyTwo) || (inside_rect(mouse.x, mouse.y, 1045.0F, 360.0F, 200.0F, 150.0F) && @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft)) {
        let parts = apply_choice(choices[1], weapon, chassis, booster, plating, overclock)
        weapon = parts.0
        chassis = parts.1
        booster = parts.2
        plating = parts.3
        overclock = parts.4
        hp = clampf(hp + salvage_heal, 0.0F, max_hp(chassis, plating))
        choosing = false
        if wave >= 6 {
          over = true
          won = true
          message = "The pit bosses are scrap now."
        } else {
          wave = wave + 1
          spawn_left = 8 + wave * 3
          spawn_timer = 0.7F
          message = "Wave \{wave} online."
        }
      } else if @raylib.is_key_pressed(@raylib.KeyThree) || (inside_rect(mouse.x, mouse.y, 1045.0F, 540.0F, 200.0F, 150.0F) && @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft)) {
        let parts = apply_choice(choices[2], weapon, chassis, booster, plating, overclock)
        weapon = parts.0
        chassis = parts.1
        booster = parts.2
        plating = parts.3
        overclock = parts.4
        hp = clampf(hp + salvage_heal, 0.0F, max_hp(chassis, plating))
        choosing = false
        if wave >= 6 {
          over = true
          won = true
          message = "The pit bosses are scrap now."
        } else {
          wave = wave + 1
          spawn_left = 8 + wave * 3
          spawn_timer = 0.7F
          message = "Wave \{wave} online."
        }
      }
    } else {
      let speed = move_speed(chassis, booster)
      let mut mvx = 0.0F
      let mut mvy = 0.0F
      if @raylib.is_key_down(@raylib.KeyW) {
        mvy = mvy - 1.0F
      }
      if @raylib.is_key_down(@raylib.KeyS) {
        mvy = mvy + 1.0F
      }
      if @raylib.is_key_down(@raylib.KeyA) {
        mvx = mvx - 1.0F
      }
      if @raylib.is_key_down(@raylib.KeyD) {
        mvx = mvx + 1.0F
      }
      let len = (mvx * mvx + mvy * mvy).sqrt()
      if len > 0.0F {
        mvx = mvx / len
        mvy = mvy / len
      }
      px = clampf(px + mvx * speed * dt, Float::from_int(arena_x + 20), Float::from_int(arena_x + arena_w - 20))
      py = clampf(py + mvy * speed * dt, Float::from_int(arena_y + 20), Float::from_int(arena_y + arena_h - 20))
      fire_cd = fire_cd - dt
      dash_cd = dash_cd - dt
      dash_flash = dash_flash - dt

      if @raylib.is_key_pressed(@raylib.KeySpace) && dash_cd <= 0.0F && len > 0.0F {
        px = clampf(px + mvx * dash_force(booster), Float::from_int(arena_x + 20), Float::from_int(arena_x + arena_w - 20))
        py = clampf(py + mvy * dash_force(booster), Float::from_int(arena_y + 20), Float::from_int(arena_y + arena_h - 20))
        dash_cd = if booster == 1 { 1.1F } else { 1.6F }
        dash_flash = 0.2F
      }

      let aim_dx = mouse.x - px
      let aim_dy = mouse.y - py
      let aim_len = (aim_dx * aim_dx + aim_dy * aim_dy).sqrt()
      let dir_x = if aim_len > 0.001F { aim_dx / aim_len } else { 1.0F }
      let dir_y = if aim_len > 0.001F { aim_dy / aim_len } else { 0.0F }
      if @raylib.is_mouse_button_down(@raylib.MouseButtonLeft) && fire_cd <= 0.0F {
        let dmg = weapon_damage(weapon, overclock)
        if weapon == 0 {
          spawn_bullet(bullets, px + dir_x * 18.0F, py + dir_y * 18.0F, dir_x * 540.0F, dir_y * 540.0F, 1.4F, dmg, true, 5.0F)
        } else if weapon == 1 {
          let lx = dir_x * 0.95F - dir_y * 0.30F
          let ly = dir_y * 0.95F + dir_x * 0.30F
          let rx = dir_x * 0.95F + dir_y * 0.30F
          let ry = dir_y * 0.95F - dir_x * 0.30F
          spawn_bullet(bullets, px + lx * 18.0F, py + ly * 18.0F, lx * 500.0F, ly * 500.0F, 0.9F, dmg, true, 4.0F)
          spawn_bullet(bullets, px + dir_x * 18.0F, py + dir_y * 18.0F, dir_x * 500.0F, dir_y * 500.0F, 0.9F, dmg, true, 4.0F)
          spawn_bullet(bullets, px + rx * 18.0F, py + ry * 18.0F, rx * 500.0F, ry * 500.0F, 0.9F, dmg, true, 4.0F)
        } else {
          spawn_bullet(bullets, px + dir_x * 18.0F, py + dir_y * 18.0F, dir_x * 640.0F, dir_y * 640.0F, 0.55F, dmg, true, 3.5F)
        }
        fire_cd = weapon_fire_cd(weapon, overclock)
      }

      if spawn_left > 0 {
        spawn_timer = spawn_timer - dt
        if spawn_timer <= 0.0F {
          spawn_enemy(enemies, wave)
          spawn_left = spawn_left - 1
          spawn_timer = clampf(0.82F - Float::from_int(wave) * 0.05F, 0.22F, 1.0F)
        }
      }

      for bullet in bullets {
        if !bullet.active {
          continue
        }
        bullet.x = bullet.x + bullet.vx * dt
        bullet.y = bullet.y + bullet.vy * dt
        bullet.life = bullet.life - dt
        if bullet.life <= 0.0F || bullet.x < Float::from_int(arena_x) || bullet.x > Float::from_int(arena_x + arena_w) || bullet.y < Float::from_int(arena_y) || bullet.y > Float::from_int(arena_y + arena_h) {
          bullet.active = false
        }
      }

      for enemy in enemies {
        if !enemy.active {
          continue
        }
        enemy.pulse = enemy.pulse + dt * 4.0F
        let dx = px - enemy.x
        let dy = py - enemy.y
        let d = (dx * dx + dy * dy).sqrt()
        let nx = if d > 0.001F { dx / d } else { 0.0F }
        let ny = if d > 0.001F { dy / d } else { 0.0F }
        if enemy.kind == 0 {
          enemy.x = enemy.x + nx * (88.0F + Float::from_int(wave) * 5.0F) * dt
          enemy.y = enemy.y + ny * (88.0F + Float::from_int(wave) * 5.0F) * dt
        } else if enemy.kind == 1 {
          enemy.fire_cd = enemy.fire_cd - dt
          if d > 180.0F {
            enemy.x = enemy.x + nx * 74.0F * dt
            enemy.y = enemy.y + ny * 74.0F * dt
          }
          if enemy.fire_cd <= 0.0F && d > 0.001F {
            spawn_bullet(bullets, enemy.x, enemy.y, nx * 280.0F, ny * 280.0F, 2.0F, 9.0F + Float::from_int(wave), false, 4.0F)
            enemy.fire_cd = 1.3F
          }
        } else {
          enemy.x = enemy.x + nx * (52.0F + Float::from_int(wave) * 4.0F) * dt
          enemy.y = enemy.y + ny * (52.0F + Float::from_int(wave) * 4.0F) * dt
          if d < 28.0F {
            hp = hp - (20.0F + Float::from_int(wave) * 3.0F) * dt
          }
        }
        if d < 22.0F && enemy.kind != 2 {
          hp = hp - (14.0F + Float::from_int(wave) * 2.0F) * dt
        }
      }

      for bullet in bullets {
        if !bullet.active {
          continue
        }
        if bullet.friendly {
          for enemy in enemies {
            if !enemy.active {
              continue
            }
            if dist2(bullet.x, bullet.y, enemy.x, enemy.y) <= (14.0F + bullet.r) * (14.0F + bullet.r) {
              enemy.hp = enemy.hp - bullet.dmg
              bullet.active = false
              if enemy.hp <= 0.0F {
                enemy.active = false
                scrap_bank = scrap_bank + 8 + wave
                spawn_scrap(scraps, enemy.x, enemy.y, 3 + wave)
              }
              break
            }
          }
        } else if dist2(bullet.x, bullet.y, px, py) <= (15.0F + bullet.r) * (15.0F + bullet.r) {
          hp = hp - bullet.dmg
          bullet.active = false
        }
      }

      for scrap in scraps {
        if !scrap.active {
          continue
        }
        let dx = px - scrap.x
        let dy = py - scrap.y
        let d = (dx * dx + dy * dy).sqrt()
        if d <= magnet_range(booster) && d > 0.001F {
          scrap.x = scrap.x + dx / d * 280.0F * dt
          scrap.y = scrap.y + dy / d * 280.0F * dt
        }
        if d < 18.0F {
          scrap.active = false
          scrap_bank = scrap_bank + scrap.value
          hp = clampf(hp + scrap_heal, 0.0F, max_hp(chassis, plating))
        }
      }

      let mut any_alive = false
      for enemy in enemies {
        if enemy.active {
          any_alive = true
        }
      }
      if !any_alive && spawn_left == 0 {
        for bullet in bullets {
          bullet.active = false
        }
        choosing = true
        gen_choices(choices)
        message = "Choose salvage before the next wave."
      }
      if hp <= 0.0F {
        over = true
        won = false
        message = "Your mech folded in the pit."
      }
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(11, 13, 18, 255))

    if title {
      @raylib.draw_rectangle_gradient_v(0, 0, screen_w, screen_h, @raylib.Color::new(28, 20, 18, 255), @raylib.Color::new(10, 10, 14, 255))
      @draw.draw_text("SCRAPYARD MECH PIT 2026", 204, 148, 58, @raylib.Color::new(246, 244, 238, 255))
      @draw.draw_text("Arena survival with salvage-built mech parts.", 330, 238, 30, @raylib.Color::new(255, 193, 116, 255))
      @draw.draw_text("WASD move  |  Mouse aim + fire  |  Space dash", 290, 398, 30, @raylib.Color::new(162, 218, 255, 255))
      @draw.draw_text("Between waves, choose one of three scrap upgrades.", 250, 440, 30, @raylib.Color::new(162, 218, 255, 255))
      @raylib.draw_rectangle(422, 618, 440, 82, @raylib.Color::new(98, 74, 42, 255))
      @draw.draw_text("PRESS ENTER TO DROP IN", 460, 646, 30, @raylib.Color::new(248, 245, 236, 255))
    } else {
      @raylib.draw_rectangle(arena_x, arena_y, arena_w, arena_h, @raylib.Color::new(26, 28, 34, 255))
      @raylib.draw_rectangle_lines(arena_x, arena_y, arena_w, arena_h, @raylib.Color::new(92, 86, 74, 255))
      for gx in 0..<10 {
        @raylib.draw_line(arena_x + gx * 92, arena_y, arena_x + gx * 92, arena_y + arena_h, @raylib.Color::new(32, 34, 40, 255))
      }
      for gy in 0..<8 {
        @raylib.draw_line(arena_x, arena_y + gy * 82, arena_x + arena_w, arena_y + gy * 82, @raylib.Color::new(32, 34, 40, 255))
      }

      for scrap in scraps {
        if !scrap.active {
          continue
        }
        @raylib.draw_circle(scrap.x.to_int(), scrap.y.to_int(), 6.0F, @raylib.Color::new(255, 202, 104, 255))
      }

      for bullet in bullets {
        if !bullet.active {
          continue
        }
        let col = if bullet.friendly { @raylib.Color::new(134, 222, 255, 255) } else { @raylib.Color::new(255, 126, 108, 255) }
        @raylib.draw_circle(bullet.x.to_int(), bullet.y.to_int(), bullet.r, col)
      }

      for enemy in enemies {
        if !enemy.active {
          continue
        }
        @raylib.draw_circle(enemy.x.to_int(), enemy.y.to_int(), if enemy.kind == 2 { 18.0F } else { 14.0F }, enemy_color(enemy.kind))
        @raylib.draw_circle_lines(enemy.x.to_int(), enemy.y.to_int(), if enemy.kind == 2 { 20.0F } else { 16.0F }, @raylib.Color::new(18, 18, 22, 255))
      }

      let mech_col = if dash_flash > 0.0F { @raylib.Color::new(255, 238, 176, 255) } else { @raylib.Color::new(134, 170, 255, 255) }
      @raylib.draw_circle(px.to_int(), py.to_int(), if chassis == 1 { 18.0F } else if chassis == 2 { 13.0F } else { 15.0F }, mech_col)
      @raylib.draw_line(px.to_int(), py.to_int(), mouse.x.to_int(), mouse.y.to_int(), @raylib.Color::new(160, 210, 255, 90))

      @raylib.draw_rectangle(1035, 90, 210, 660, @raylib.Color::new(18, 18, 24, 255))
      @draw.draw_text("Wave \{wave}/6", 1058, 114, 34, @raylib.Color::new(242, 246, 248, 255))
      @draw.draw_text("HP", 1058, 162, 24, @raylib.Color::new(214, 222, 230, 255))
      @raylib.draw_rectangle(1058, 194, 160, 12, @raylib.Color::new(36, 42, 48, 255))
      @raylib.draw_rectangle(1058, 194, (160.0F * clampf(hp, 0.0F, max_hp(chassis, plating)) / max_hp(chassis, plating)).to_int(), 12, @raylib.Color::new(236, 106, 106, 255))
      @draw.draw_text("Scrap \{scrap_bank}", 1058, 236, 26, @raylib.Color::new(255, 206, 118, 255))
      @draw.draw_text(weapon_name(weapon), 1058, 294, 22, @raylib.Color::new(134, 192, 255, 255))
      @draw.draw_text(chassis_name(chassis), 1058, 326, 22, @raylib.Color::new(138, 232, 182, 255))
      @draw.draw_text(booster_name(booster), 1058, 358, 22, @raylib.Color::new(255, 206, 118, 255))
      @draw.draw_text("Plating \{plating}", 1058, 408, 20, @raylib.Color::new(230, 148, 255, 255))
      @draw.draw_text("Overclock \{overclock}", 1058, 434, 20, @raylib.Color::new(230, 148, 255, 255))
      @draw.draw_text(message, 1058, 488, 22, @raylib.Color::new(228, 234, 240, 255))
      @draw.draw_text("LMB fire", 1058, 666, 20, @raylib.Color::new(166, 218, 255, 255))
      @draw.draw_text("WASD move", 1058, 692, 20, @raylib.Color::new(166, 218, 255, 255))
      @draw.draw_text("Space dash", 1058, 718, 20, @raylib.Color::new(166, 218, 255, 255))

      if choosing {
        @raylib.draw_rectangle(0, 0, screen_w, screen_h, @raylib.fade(@raylib.black, 0.64F))
        @draw.draw_text("SALVAGE PICK", 468, 92, 56, @raylib.Color::new(247, 243, 236, 255))
        for i in 0..<3 {
          let y = 180 + i * 180
          @raylib.draw_rectangle(1045, y, 200, 150, choice_color(choices[i]))
          @raylib.draw_rectangle_lines(1045, y, 200, 150, @raylib.Color::new(16, 18, 22, 255))
          @draw.draw_text("\{i + 1}", 1060, y + 14, 28, @raylib.Color::new(20, 20, 24, 255))
          @draw.draw_text(choice_name(choices[i]), 1062, y + 48, 20, @raylib.Color::new(16, 20, 24, 255))
          @draw.draw_text(choice_desc(choices[i]), 1062, y + 82, 18, @raylib.Color::new(20, 24, 28, 255))
        }
      }

      if over {
        @raylib.draw_rectangle(0, 0, screen_w, screen_h, @raylib.fade(@raylib.black, 0.62F))
        @draw.draw_text(if won { "PIT CLEARED" } else { "MECH DOWN" }, 420, 250, 68, if won { @raylib.Color::new(146, 242, 188, 255) } else { @raylib.Color::new(255, 122, 122, 255) })
        @draw.draw_text(message, 360, 340, 34, @raylib.Color::new(242, 246, 248, 255))
        @draw.draw_text("Press R to rebuild", 468, 430, 32, @raylib.Color::new(255, 206, 118, 255))
      }
    }

    @fps.draw()
    @raylib.end_drawing()
  }

  @draw.cleanup()
  @raylib.close_window()
}
