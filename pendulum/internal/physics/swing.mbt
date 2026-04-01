///|
pub fn tick_swing(
  weight : @types.Weight,
  rope : @types.Rope,
  arc : Array[@types.ArcPoint],
  pegs : Array[@types.Vec2i],
  walls : Array[@types.Vec2i],
  goal : @types.Vec2i,
  collectibles : Array[@types.Vec2i],
  collected : Array[Bool],
) -> Unit {
  match weight.state {
    Swinging => tick_swinging(weight, rope, arc, pegs, collectibles, collected)
    Launched => tick_launched(weight, walls, goal, collectibles, collected)
    Stopped | AtGoal => ()
  }
}

///|
fn tick_swinging(
  weight : @types.Weight,
  rope : @types.Rope,
  arc : Array[@types.ArcPoint],
  pegs : Array[@types.Vec2i],
  collectibles : Array[@types.Vec2i],
  collected : Array[Bool],
) -> Unit {
  if arc.length() == 0 {
    weight.state = Stopped
    return
  }
  let bottom = find_bottom_index(arc)
  let (left_limit, right_limit) = compute_swing_extent(arc, bottom)
  // Advance along arc
  match weight.swing_dir {
    Right => {
      weight.arc_index = weight.arc_index + 1
      if weight.arc_index >= right_limit {
        weight.arc_index = right_limit
        weight.swing_dir = Left
      }
    }
    Left => {
      weight.arc_index = weight.arc_index - 1
      if weight.arc_index <= left_limit {
        weight.arc_index = left_limit
        weight.swing_dir = Right
      }
    }
  }
  // Clamp
  if weight.arc_index < 0 {
    weight.arc_index = 0
  }
  if weight.arc_index >= arc.length() {
    weight.arc_index = arc.length() - 1
  }
  // Update position
  let pt = arc[weight.arc_index]
  weight.pos = @types.vec2i(pt.gx, pt.gy)
  // Check for peg wrapping
  let wrap = check_peg_wrap(rope.anchor, weight.pos, pegs, rope.wrapped_pegs)
  match wrap {
    Some(peg) => {
      rope.wrapped_pegs.push(peg)
      rope.anchor = peg
      let new_len = compute_new_rope_length(peg, weight.pos)
      rope.length = new_len
    }
    None => ()
  }
  // Check collectible pickup
  check_collectibles(weight.pos, collectibles, collected)
}

///|
fn tick_launched(
  weight : @types.Weight,
  walls : Array[@types.Vec2i],
  goal : @types.Vec2i,
  collectibles : Array[@types.Vec2i],
  collected : Array[Bool],
) -> Unit {
  // Move along launch velocity
  let new_x = weight.launch_pos.x + weight.launch_vel.x
  let new_y = weight.launch_pos.y + weight.launch_vel.y
  let new_gx = @types.roundf(new_x)
  let new_gy = @types.roundf(new_y)
  // Check bounds
  if new_gx < 0 ||
    new_gx >= @types.grid_cols ||
    new_gy < 0 ||
    new_gy >= @types.grid_rows {
    weight.state = Stopped
    return
  }
  // Check wall collision
  for i = 0; i < walls.length(); i = i + 1 {
    if walls[i].x == new_gx && walls[i].y == new_gy {
      weight.state = Stopped
      return
    }
  }
  // Update position
  weight.launch_pos.x = new_x
  weight.launch_pos.y = new_y
  weight.pos = @types.vec2i(new_gx, new_gy)
  // Check goal
  if new_gx == goal.x && new_gy == goal.y {
    weight.state = AtGoal
    return
  }
  // Check collectibles
  check_collectibles(weight.pos, collectibles, collected)
}

///|
fn check_collectibles(
  pos : @types.Vec2i,
  collectibles : Array[@types.Vec2i],
  collected : Array[Bool],
) -> Unit {
  for i = 0; i < collectibles.length(); i = i + 1 {
    if i < collected.length() && !collected[i] {
      if collectibles[i].x == pos.x && collectibles[i].y == pos.y {
        collected[i] = true
      }
    }
  }
}

///|
pub fn cut_rope(
  weight : @types.Weight,
  rope : @types.Rope,
  arc : Array[@types.ArcPoint],
) -> Unit {
  if weight.state != Swinging {
    return
  }
  // Compute launch velocity from current position and swing direction
  let vel = @types.compute_launch_velocity(
    rope.anchor,
    weight.pos,
    weight.swing_dir,
  )
  weight.launch_vel = vel
  weight.launch_pos = @types.vec2f(
    Float::from_int(weight.pos.x),
    Float::from_int(weight.pos.y),
  )
  weight.state = Launched
  ignore(arc)
}

///|
pub fn check_goal_on_swing(weight : @types.Weight, goal : @types.Vec2i) -> Unit {
  if weight.state == Swinging {
    if weight.pos.x == goal.x && weight.pos.y == goal.y {
      weight.state = AtGoal
    }
  }
}

///|
pub fn compute_stars(
  ticks : Int,
  par : Int,
  collectibles_total : Int,
  collectibles_got : Int,
) -> Int {
  let mut stars = 1 // reached goal
  if ticks <= par {
    stars = 2
  }
  if ticks <= par && collectibles_got >= collectibles_total {
    stars = 3
  }
  stars
}
