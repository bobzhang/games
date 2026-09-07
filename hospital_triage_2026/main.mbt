///|
/// Screen width in pixels.
let sw : Int = 1120

///|
/// Screen height in pixels.
let sh : Int = 740

///|
/// Number of hospital ward columns displayed on screen.
let ward_count : Int = 4

///|
/// Returns the horizontal centre pixel coordinate for the given ward index.
fn ward_x(ward : Int) -> Float {
  170.0 + Float::from_int(ward) * 240.0
}

///|
/// Generated hospital backdrop texture.
let tex_hospital_background : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated ward bay texture.
let tex_ward_bay : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated nurse sprite texture.
let tex_nurse : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated mild patient sprite texture.
let tex_patient_mild : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated medium patient sprite texture.
let tex_patient_medium : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated critical patient sprite texture.
let tex_patient_critical : Ref[@raylib.Texture?] = { val: None, }

///|
/// Generated treatment station texture.
let tex_treatment_station : Ref[@raylib.Texture?] = { val: None, }

///|
/// A hospital patient with liveness flag, assigned ward, screen position, severity level (0=mild/1=medium/2=critical), and elapsed wait time.
struct Patient {
  mut alive : Bool
  mut ward : Int
  mut x : Float
  mut y : Float
  mut severity : Int // 0 mild, 1 medium, 2 critical
  mut wait : Float
}

///|
/// Loads one generated Hospital Triage texture.
fn load_art_texture(file_name : String) -> @raylib.Texture {
  let texture = @raylib.load_texture(
    "hospital_triage_2026/resources/\{file_name}",
  )
  @raylib.set_texture_filter(texture, @raylib.TextureFilterBilinear)
  texture
}

///|
/// Loads generated Hospital Triage render assets.
fn load_assets() -> Unit {
  tex_hospital_background.val = Some(
    load_art_texture("hospital_background.png"),
  )
  tex_ward_bay.val = Some(load_art_texture("ward_bay.png"))
  tex_nurse.val = Some(load_art_texture("nurse_sprite.png"))
  tex_patient_mild.val = Some(load_art_texture("patient_mild.png"))
  tex_patient_medium.val = Some(load_art_texture("patient_medium.png"))
  tex_patient_critical.val = Some(load_art_texture("patient_critical.png"))
  tex_treatment_station.val = Some(load_art_texture("treatment_station.png"))
}

///|
/// Unloads generated Hospital Triage render assets.
fn unload_assets() -> Unit {
  fn unload(texture_ref : Ref[@raylib.Texture?]) -> Unit {
    match texture_ref.val {
      Some(texture) => {
        @raylib.unload_texture(texture)
        texture_ref.val = None
      }
      None => ()
    }
  }

  unload(tex_hospital_background)
  unload(tex_ward_bay)
  unload(tex_nurse)
  unload(tex_patient_mild)
  unload(tex_patient_medium)
  unload(tex_patient_critical)
  unload(tex_treatment_station)
}

///|
/// Draws a texture cover-cropped into a destination rectangle.
fn draw_texture_cover(
  texture : @raylib.Texture,
  x : Float,
  y : Float,
  w : Float,
  h : Float,
  tint : @raylib.Color,
) -> Unit {
  let source_w : Float = Float::from_int(texture.width())
  let source_h : Float = Float::from_int(texture.height())
  let source_ratio : Float = source_w / source_h
  let dest_ratio : Float = w / h

  let mut src_x : Float = 0.0
  let mut src_y : Float = 0.0
  let mut src_w : Float = source_w
  let mut src_h : Float = source_h

  if source_ratio > dest_ratio {
    src_w = source_h * dest_ratio
    src_x = (source_w - src_w) * 0.5
  } else if source_ratio < dest_ratio {
    src_h = source_w / dest_ratio
    src_y = (source_h - src_h) * 0.5
  }

  @raylib.draw_texture_pro(
    texture,
    @raylib.Rectangle::new(src_x, src_y, src_w, src_h),
    @raylib.Rectangle::new(x, y, w, h),
    @raylib.Vector2::new(0.0, 0.0),
    0.0,
    tint,
  )
}

///|
/// Draws a texture centered on a destination point.
fn draw_texture_centered(
  texture : @raylib.Texture,
  cx : Float,
  cy : Float,
  w : Float,
  h : Float,
  rotation : Float,
  tint : @raylib.Color,
) -> Unit {
  @raylib.draw_texture_pro(
    texture,
    @raylib.Rectangle::new(
      0.0,
      0.0,
      Float::from_int(texture.width()),
      Float::from_int(texture.height()),
    ),
    @raylib.Rectangle::new(cx, cy, w, h),
    @raylib.Vector2::new(w * 0.5, h * 0.5),
    rotation,
    tint,
  )
}

///|
/// Draws a generated texture scaled to fit a centered box.
fn draw_texture_fit(
  texture : @raylib.Texture,
  cx : Float,
  cy : Float,
  max_w : Float,
  max_h : Float,
  rotation : Float,
  tint : @raylib.Color,
) -> Unit {
  let source_w : Float = Float::from_int(texture.width())
  let source_h : Float = Float::from_int(texture.height())
  let source_ratio : Float = source_w / source_h
  let box_ratio : Float = max_w / max_h
  let mut w : Float = max_w
  let mut h : Float = max_h
  if source_ratio > box_ratio {
    h = max_w / source_ratio
  } else {
    w = max_h * source_ratio
  }
  draw_texture_centered(texture, cx, cy, w, h, rotation, tint)
}

///|
/// Draws the generated hospital backdrop.
fn draw_hospital_background() -> Bool {
  match tex_hospital_background.val {
    Some(texture) => {
      draw_texture_cover(
        texture,
        0.0,
        0.0,
        Float::from_int(sw),
        Float::from_int(sh),
        @raylib.white,
      )
      @raylib.draw_rectangle(
        0,
        0,
        sw,
        sh,
        @raylib.Color::new(230, 240, 248, 62),
      )
      true
    }
    None => false
  }
}

///|
/// Draws a generated ward bay lane.
fn draw_ward_bay_art(x : Float) -> Bool {
  match tex_ward_bay.val {
    Some(texture) => {
      draw_texture_cover(
        texture,
        x - 75.0,
        160.0,
        150.0,
        520.0,
        @raylib.Color::new(250, 252, 255, 246),
      )
      @raylib.draw_rectangle(
        (x - 75.0).to_int(),
        160,
        150,
        520,
        @raylib.Color::new(240, 248, 255, 36),
      )
      true
    }
    None => false
  }
}

///|
/// Returns the generated patient texture for the severity.
fn patient_texture(sev : Int) -> @raylib.Texture? {
  if sev == 0 {
    tex_patient_mild.val
  } else if sev == 1 {
    tex_patient_medium.val
  } else {
    tex_patient_critical.val
  }
}

///|
/// Draws generated patient art for a live queue token.
fn draw_patient_art(patient : Patient) -> Bool {
  match patient_texture(patient.severity) {
    Some(texture) => {
      @raylib.draw_circle(
        patient.x.to_int(),
        (patient.y + 13.0).to_int(),
        18.0,
        @raylib.fade(severity_color(patient.severity), 0.24),
      )
      draw_texture_fit(
        texture,
        patient.x,
        patient.y,
        if patient.severity == 2 {
          50.0
        } else {
          42.0
        },
        if patient.severity == 2 {
          62.0
        } else {
          54.0
        },
        0.0,
        @raylib.white,
      )
      true
    }
    None => false
  }
}

///|
/// Draws generated nurse art at the current ward station.
fn draw_nurse_art(x : Float, y : Int) -> Bool {
  match tex_nurse.val {
    Some(texture) => {
      @raylib.draw_circle(
        x.to_int(),
        y + 19,
        24.0,
        @raylib.Color::new(36, 84, 140, 52),
      )
      draw_texture_fit(
        texture,
        x,
        Float::from_int(y - 9),
        50.0,
        72.0,
        0.0,
        @raylib.white,
      )
      true
    }
    None => false
  }
}

///|
/// Draws generated treatment station art in the side treatment area.
fn draw_treatment_station_art() -> Bool {
  match tex_treatment_station.val {
    Some(texture) => {
      draw_texture_fit(
        texture,
        Float::from_int(sw - 165),
        258.0,
        220.0,
        112.0,
        0.0,
        @raylib.white,
      )
      true
    }
    None => false
  }
}

///|
/// Marks every patient slot as inactive, effectively clearing the ward.
fn reset_patients(ps : Array[Patient]) -> Unit {
  for ps_elem in ps {
    ps_elem.alive = false
  }
}

///|
/// Finds the first inactive patient slot and spawns a new patient in a random ward with probability-weighted severity.
fn spawn_patient(ps : Array[Patient]) -> Unit {
  for ps_elem in ps {
    if !ps_elem.alive {
      let w = @raylib.get_random_value(0, ward_count - 1)
      let r = @raylib.get_random_value(0, 99)
      let sev = if r < 42 { 0 } else if r < 82 { 1 } else { 2 }
      ps_elem.alive = true
      ps_elem.ward = w
      ps_elem.x = ward_x(w)
      ps_elem.y = 150.0
      ps_elem.severity = sev
      ps_elem.wait = 0.0
      break
    }
  }
}

///|
/// Returns the treatment duration in seconds for the given severity (2.2s mild, 3.4s medium, 4.8s critical).
fn treat_time(sev : Int) -> Float {
  if sev == 0 {
    2.2
  } else if sev == 1 {
    3.4
  } else {
    4.8
  }
}

///|
/// Returns the score awarded for successfully treating a patient of the given severity (28/48/92).
fn treat_score(sev : Int) -> Int {
  if sev == 0 {
    28
  } else if sev == 1 {
    48
  } else {
    92
  }
}

///|
/// Maps a severity index to its display colour (lime=mild, orange=medium, red=critical).
fn severity_color(sev : Int) -> @raylib.Color {
  if sev == 0 {
    @raylib.lime
  } else if sev == 1 {
    @raylib.orange
  } else {
    @raylib.red
  }
}

///|
/// Maps a severity index to a short label string ("MILD"/"MED"/"CRIT").
fn severity_name(sev : Int) -> String {
  if sev == 0 {
    "MILD"
  } else if sev == 1 {
    "MED"
  } else {
    "CRIT"
  }
}

///|
/// Initialises the Raylib window, pre-allocates the patient array, runs the triage game loop, and closes the window on exit.
fn main {
  @raylib.init_window(sw, sh, "Hospital Triage 2026")
  defer @raylib.close_window()
  defer @draw.cleanup()
  @raylib.set_target_fps(60)
  @draw.init_font()
  load_assets()
  defer unload_assets()

  let patients : Array[Patient] = Array::makei(140, fn(_i) {
    { alive: false, ward: 0, x: 0.0, y: 0.0, severity: 0, wait: 0.0, }
  })

  let mut nurse_ward = 1
  let mut nx : Float = ward_x(nurse_ward)

  let mut treating = false
  let mut tr_sev = 0
  let mut tr_time_left : Float = 0.0

  let mut spawn_tick : Float = 0.0
  let mut timer : Float = 150.0
  let mut lives = 5
  let mut score = 0
  let mut treated = 0
  let mut failed = 0

  let mut over = false
  let mut msg = "A/D move wards, Space admit first patient in ward"

  while !@raylib.window_should_close() {
    let frame_dt = @raylib.get_frame_time()
    let dt = if frame_dt > 0.05F { 0.05F } else { frame_dt }

    if @raylib.is_key_pressed(@raylib.KeyR) {
      reset_patients(patients)
      nurse_ward = 1
      nx = ward_x(nurse_ward)
      treating = false
      tr_sev = 0
      tr_time_left = 0.0
      spawn_tick = 0.0
      timer = 150.0
      lives = 5
      score = 0
      treated = 0
      failed = 0
      over = false
      msg = "Shift restarted."
    }

    if !over {
      timer = timer - dt
      if timer <= 0.0 {
        timer = 0.0
        over = true
        msg = "Shift complete."
      }

      if @raylib.is_key_pressed(@raylib.KeyA) ||
        @raylib.is_key_pressed(@raylib.KeyLeft) {
        if nurse_ward > 0 {
          nurse_ward = nurse_ward - 1
        }
      }
      if @raylib.is_key_pressed(@raylib.KeyD) ||
        @raylib.is_key_pressed(@raylib.KeyRight) {
        if nurse_ward < ward_count - 1 {
          nurse_ward = nurse_ward + 1
        }
      }
      nx = ward_x(nurse_ward)

      spawn_tick = spawn_tick + dt
      if spawn_tick >= 0.48 {
        spawn_tick = spawn_tick - 0.48
        spawn_patient(patients)
      }

      if treating {
        tr_time_left = tr_time_left - dt
        if tr_time_left <= 0.0 {
          treating = false
          treated = treated + 1
          let gain = treat_score(tr_sev)
          score = score + gain
          timer = timer + 2.6
          if timer > 170.0 {
            timer = 170.0
          }
          msg = "Patient stabilized +\{gain}."
        }
      }

      for patient in patients {
        if !patient.alive {
          continue
        }

        let spd : Float = if patient.severity == 2 {
          (55.0 : Float)
        } else if patient.severity == 1 {
          (42.0 : Float)
        } else {
          (32.0 : Float)
        }
        patient.y = patient.y + spd * dt
        patient.wait = patient.wait + dt

        let panic_time : Float = if patient.severity == 2 {
          (7.0 : Float)
        } else if patient.severity == 1 {
          (10.0 : Float)
        } else {
          (13.0 : Float)
        }
        if patient.wait > panic_time {
          patient.alive = false
          failed = failed + 1
          let life_loss = if patient.severity == 2 { 2 } else { 1 }
          let score_loss = if patient.severity == 2 { 36 } else { 20 }
          lives = lives - life_loss
          score = score - score_loss
          msg = "Patient condition worsened untreated."
          continue
        }

        if patient.y > Float::from_int(sh - 100) {
          patient.alive = false
          failed = failed + 1
          lives = lives - 1
          score = score - 14
          msg = "Patient left without treatment."
        }
      }

      if !treating &&
        (
          @raylib.is_key_pressed(@raylib.KeySpace) ||
          @raylib.is_key_pressed(@raylib.KeyEnter)
        ) {
        let pick = for
          i in 0..<patients.length()
          pick = -1, best_y = 1_000_000.0F {
          if patients[i].alive && patients[i].ward == nurse_ward {
            if patients[i].y < best_y {
              continue i, patients[i].y
            }
          }
        } nobreak {
          pick
        }
        if pick >= 0 {
          tr_sev = patients[pick].severity
          tr_time_left = treat_time(tr_sev)
          treating = true
          patients[pick].alive = false
          msg = "Patient admitted to treatment bed."
        }
      }

      if lives <= 0 {
        lives = 0
        over = true
        msg = "Hospital overwhelmed."
      }
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(230, 236, 242, 255))

    if !draw_hospital_background() {
      @raylib.draw_rectangle(
        0,
        0,
        sw,
        130,
        @raylib.Color::new(188, 214, 236, 255),
      )
      @raylib.draw_rectangle(
        0,
        130,
        sw,
        sh - 130,
        @raylib.Color::new(248, 248, 248, 255),
      )
    }

    for w in 0..<ward_count {
      let x = ward_x(w)
      if !draw_ward_bay_art(x) {
        @raylib.draw_rectangle(
          (x - 75.0).to_int(),
          160,
          150,
          520,
          @raylib.Color::new(240, 244, 248, 255),
        )
      }
      @raylib.draw_rectangle_lines(
        (x - 75.0).to_int(),
        160,
        150,
        520,
        @raylib.Color::new(180, 190, 205, 255),
      )
      @draw.draw_text(
        "WARD \{w + 1}",
        (x - 56.0).to_int(),
        168,
        24,
        @raylib.darkblue,
      )
    }

    for patient in patients {
      if patient.alive {
        if !draw_patient_art(patient) {
          let c = severity_color(patient.severity)
          @raylib.draw_circle(patient.x.to_int(), patient.y.to_int(), 15.0, c)
        }
        @draw.draw_text(
          severity_name(patient.severity),
          (patient.x - 26.0).to_int(),
          (patient.y - 30.0).to_int(),
          16,
          @raylib.black,
        )
      }
    }

    // Nurse and treatment bed
    if !draw_nurse_art(nx, sh - 82) {
      @raylib.draw_circle(nx.to_int(), sh - 82, 16.0, @raylib.blue)
      @raylib.draw_rectangle(
        (nx - 26.0).to_int(),
        sh - 64,
        52,
        10,
        @raylib.darkblue,
      )
    }

    @raylib.draw_rectangle(
      sw - 290,
      180,
      250,
      150,
      @raylib.Color::new(214, 228, 242, 255),
    )
    ignore(draw_treatment_station_art())
    @draw.draw_text("TREATMENT", sw - 262, 194, 28, @raylib.darkblue)
    if treating {
      @draw.draw_text(
        "Patient: \{severity_name(tr_sev)}",
        sw - 270,
        236,
        24,
        severity_color(tr_sev),
      )
      @draw.draw_text(
        "ETA \{tr_time_left.to_int()}s",
        sw - 270,
        270,
        24,
        @raylib.black,
      )
    } else {
      @draw.draw_text("Bed Available", sw - 260, 250, 26, @raylib.lime)
    }

    @raylib.draw_rectangle(
      18,
      16,
      640,
      108,
      @raylib.Color::new(21, 39, 58, 220),
    )
    @draw.draw_text("HOSPITAL TRIAGE 2026", 28, 22, 36, @raylib.skyblue)
    @draw.draw_text(
      "Score \{score}  Treated \{treated}  Failed \{failed}  Lives \{lives}",
      28,
      66,
      28,
      @raylib.raywhite,
    )

    let t = timer.to_int()
    @draw.draw_text(
      "Time \{t}s",
      710,
      28,
      36,
      if t < 20 {
        @raylib.red
      } else {
        @raylib.orange
      },
    )

    @draw.draw_text(
      "Critical patients expire faster and cost more lives.", 20, 654, 24, @raylib.darkgray,
    )
    @raylib.draw_rectangle(
      20,
      688,
      sw - 40,
      30,
      @raylib.Color::new(28, 42, 58, 220),
    )
    @draw.draw_text(msg, 28, 693, 20, @raylib.raywhite)

    if over {
      @raylib.draw_rectangle(
        300,
        250,
        520,
        180,
        @raylib.fade(@raylib.black, 0.82),
      )
      @draw.draw_text(
        if lives > 0 {
          "SHIFT COMPLETE"
        } else {
          "SHIFT FAILED"
        },
        390,
        312,
        50,
        if lives > 0 {
          @raylib.lime
        } else {
          @raylib.red
        },
      )
      @draw.draw_text("Press R to restart", 430, 370, 34, @raylib.white)
    }

    @fps.draw()
    @raylib.end_drawing()
  }
}
