///|
/// Creates a new challenge state for the given mode.
pub fn start_challenge(mode : @types.ChallengeMode) -> @types.ChallengeState {
  @types.new_challenge_state(mode)
}

///|
/// Updates the challenge state. Returns true if the challenge just ended.
pub fn update_challenge(
  cs : @types.ChallengeState,
  world : @types.World,
  dt : Float,
) -> Bool {
  if cs.completed {
    return false
  }
  match cs.mode {
    TimeAttack => update_time_attack(cs, world, dt)
    BudgetMode => update_budget_mode(cs, world, dt)
    Survival => update_survival(cs, world, dt)
    Precision => update_precision(cs, world, dt)
  }
}

///|
/// Time Attack: build as tall as possible in 60 seconds.
fn update_time_attack(
  cs : @types.ChallengeState,
  world : @types.World,
  dt : Float,
) -> Bool {
  cs.time_left = cs.time_left - dt
  if cs.time_left <= 0.0 {
    cs.time_left = 0.0
    cs.completed = true
    // Score is based on tower height
    let height = @physics.measure_tower_height(world)
    cs.challenge_score = (height * 2.0 + 0.5).to_int()
    return true
  }
  false
}

///|
/// Budget Mode: reach target height with minimum pieces.
fn update_budget_mode(
  cs : @types.ChallengeState,
  world : @types.World,
  dt : Float,
) -> Bool {
  ignore(dt)
  let height = @physics.measure_tower_height(world)
  if height >= cs.target_height {
    cs.completed = true
    // Score: fewer pieces used = higher score
    let pieces_saved = cs.budget_limit - cs.budget_used
    cs.challenge_score = 500 + pieces_saved * 100
    return true
  }
  if cs.budget_used >= cs.budget_limit {
    // Out of budget, run physics to see if it holds
    cs.time_left = cs.time_left - dt
    if cs.time_left <= 0.0 {
      cs.completed = true
      if height >= cs.target_height {
        let pieces_saved = cs.budget_limit - cs.budget_used
        cs.challenge_score = 500 + pieces_saved * 100
      } else {
        cs.challenge_score = (height / cs.target_height * 300.0 + 0.5).to_int()
      }
      return true
    }
  }
  false
}

///|
/// Survival: tower must withstand 5 rounds of increasing hazards.
fn update_survival(
  cs : @types.ChallengeState,
  world : @types.World,
  dt : Float,
) -> Bool {
  if cs.hazard_round >= @types.survival_rounds {
    cs.completed = true
    cs.rounds_survived = @types.survival_rounds
    cs.challenge_score = cs.rounds_survived * 200
    return true
  }
  cs.hazard_timer = cs.hazard_timer + dt
  let round_duration : Float = 8.0
  if cs.hazard_timer >= round_duration {
    cs.hazard_timer = 0.0
    cs.hazard_round = cs.hazard_round + 1
    // Apply hazard for this round
    let intensity = Float::from_int(cs.hazard_round)
    apply_survival_hazard(world, cs.hazard_round, intensity)
    cs.rounds_survived = cs.hazard_round
  }
  // Check if tower is destroyed (no active bodies)
  let active = @physics.count_active_bodies(world)
  let broken = @physics.count_broken_bodies(world)
  if active == 0 && broken > 0 {
    cs.completed = true
    cs.challenge_score = cs.rounds_survived * 200
    return true
  }
  false
}

///|
/// Precision: build to exact height within tolerance.
fn update_precision(
  cs : @types.ChallengeState,
  world : @types.World,
  dt : Float,
) -> Bool {
  cs.time_left = cs.time_left - dt
  let height = @physics.measure_tower_height(world)
  let diff = @types.absf(height - cs.target_height)
  if diff <= @types.precision_tolerance && @physics.is_settled(world) {
    cs.completed = true
    // Perfect precision = high score
    let precision_bonus = ((@types.precision_tolerance - diff) * 1000.0 + 0.5).to_int()
    cs.challenge_score = 1000 + precision_bonus
    return true
  }
  if cs.time_left <= 0.0 {
    cs.time_left = 0.0
    cs.completed = true
    // Score based on how close
    if diff < 10.0 {
      cs.challenge_score = ((10.0F - diff) * 50.0F + 0.5F).to_int()
    } else {
      cs.challenge_score = 0
    }
    return true
  }
  false
}

///|
/// Applies a hazard for the survival round.
fn apply_survival_hazard(
  world : @types.World,
  round : Int,
  intensity : Float,
) -> Unit {
  // Rounds alternate between wind, earthquake, and impact with increasing intensity
  let hazard_type = round % 3
  match hazard_type {
    0 => {
      let dir : Float = if round % 2 == 0 { 1.0 } else { -1.0 }
      @physics.start_wind(world, @types.wind_test_force * intensity * 0.6 * dir)
    }
    1 =>
      @physics.start_earthquake(
        world,
        @types.quake_test_duration * 0.8,
        @types.quake_test_intensity * intensity * 0.5,
      )
    _ => @physics.fire_impact(world, @types.impact_force * intensity * 0.4)
  }
}

///|
/// Returns the challenge mode name.
pub fn challenge_mode_name(mode : @types.ChallengeMode) -> String {
  match mode {
    TimeAttack => "Time Attack"
    BudgetMode => "Budget Mode"
    Survival => "Survival"
    Precision => "Precision"
  }
}

///|
/// Returns the challenge mode description.
pub fn challenge_mode_description(mode : @types.ChallengeMode) -> String {
  match mode {
    TimeAttack => "Build as tall as possible in 60 seconds"
    BudgetMode => "Reach 300px height with 8 or fewer pieces"
    Survival => "Withstand 5 rounds of increasing hazards"
    Precision => "Build to exactly 400px height (+/-1px)"
  }
}

///|
/// Returns all available challenge modes.
pub fn get_challenge_modes() -> Array[@types.ChallengeMode] {
  [TimeAttack, BudgetMode, Survival, Precision]
}

///|
/// Returns the score rating (1-3 stars) for a challenge result.
pub fn challenge_stars(cs : @types.ChallengeState) -> Int {
  if cs.challenge_score >= 800 {
    3
  } else if cs.challenge_score >= 400 {
    2
  } else if cs.challenge_score > 0 {
    1
  } else {
    0
  }
}

///|
/// Returns the HUD status text for the current challenge state.
pub fn challenge_status_text(cs : @types.ChallengeState) -> String {
  match cs.mode {
    TimeAttack => {
      let secs = (cs.time_left + 0.5).to_int()
      "Time: " + secs.to_string() + "s"
    }
    BudgetMode =>
      "Pieces: " +
      cs.budget_used.to_string() +
      "/" +
      cs.budget_limit.to_string()
    Survival =>
      "Round: " +
      (cs.hazard_round + 1).to_string() +
      "/" +
      @types.survival_rounds.to_string()
    Precision => {
      let secs = (cs.time_left + 0.5).to_int()
      "Time: " + secs.to_string() + "s  Target: 400px"
    }
  }
}

///|
/// Gets the inventory for challenge modes (generous supply).
pub fn challenge_inventory() -> Array[(@types.PieceKind, @types.Material, Int)] {
  [
    (Block, Wood, 30),
    (Block, Stone, 20),
    (Beam, Wood, 20),
    (Beam, Steel, 15),
    (Triangle, Wood, 15),
    (Arch, Stone, 10),
    (Cable, Steel, 10),
  ]
}
