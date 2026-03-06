///|
/// High-level lifecycle states for a school run.
pub(all) enum GameState {
  Title
  Playing
  Paused
  GameOver
} derive(Eq)

///|
/// Student profile with skill, fatigue, and current room.
pub(all) struct Student {
  name : String
  mut skill : Float
  mut fatigue : Float
  mut room : Room

  fn new(name : String, skill : Float) -> Student
}

///|
/// Per-frame input actions consumed by game logic.
pub(all) struct Input {
  mut move_x : Int
  mut move_y : Int
  mut confirm_pressed : Bool
  mut cancel_pressed : Bool
  mut burst_pressed : Bool
  mut pause_pressed : Bool
  mut restart_pressed : Bool
  mut start_pressed : Bool

  fn new() -> Input
}

///|
/// Full mutable state for school management gameplay.
pub(all) struct Game {
  input : Input
  students : Array[Student]
  mut state : GameState
  mut week : Int
  mut funds : Float
  mut reputation : Float
  mut week_duration : Float
  mut week_time_left : Float
  mut cursor_row : Int
  mut cursor_col : Int
  mut speed_burst_t : Float
  mut speed_burst_cd : Float
  mut incident_timer : Float
  mut incident_count_week : Int
  mut total_incidents : Int
  mut incident_flash_t : Float
  mut message : String
  mut message_t : Float
  mut scene_t : Float
  mut week_banner_t : Float
  mut weeks_survived : Int
  mut best_week : Int
  mut defeat_reason : String

  fn new() -> Game
}

///|
/// Return the display name for a roster slot index.
pub fn student_name(slot : Int) -> String {
  if slot == 0 {
    "Aiko"
  } else if slot == 1 {
    "Bo"
  } else if slot == 2 {
    "Chun"
  } else if slot == 3 {
    "Daichi"
  } else if slot == 4 {
    "Eri"
  } else {
    "Feng"
  }
}

///|
/// Return starting skill for a roster slot index.
pub fn starting_skill(slot : Int) -> Float {
  if slot == 0 {
    34.0
  } else if slot == 1 {
    41.0
  } else if slot == 2 {
    46.0
  } else if slot == 3 {
    52.0
  } else if slot == 4 {
    39.0
  } else {
    48.0
  }
}

///|
/// Create a student starting in rest with low fatigue.
#deprecated
pub fn Student::new(name : String, skill : Float) -> Student {
  { name, skill, fatigue: 12.0, room: Rest }
}

///|
/// Build a zeroed input snapshot with no pressed actions.
#deprecated
pub fn Input::new() -> Input {
  {
    move_x: 0,
    move_y: 0,
    confirm_pressed: false,
    cancel_pressed: false,
    burst_pressed: false,
    pause_pressed: false,
    restart_pressed: false,
    start_pressed: false,
  }
}

///|
/// Create a new run initialized to title state and starter roster.
#deprecated
pub fn Game::new() -> Game {
  let roster : Array[Student] = []

  for i in 0..<student_count {
    roster.push(Student(student_name(i), starting_skill(i)))
  }

  {
    input: Input(),
    students: roster,
    state: Title,
    week: 1,
    funds: start_funds,
    reputation: start_reputation,
    week_duration: week_duration_for(1),
    week_time_left: week_duration_for(1),
    cursor_row: 0,
    cursor_col: Rest.to_int(),
    speed_burst_t: 0.0,
    speed_burst_cd: 0.0,
    incident_timer: 0.0,
    incident_count_week: 0,
    total_incidents: 0,
    incident_flash_t: 0.0,
    message: "",
    message_t: 0.0,
    scene_t: 0.0,
    week_banner_t: 0.0,
    weeks_survived: 0,
    best_week: 0,
    defeat_reason: "",
  }
}
