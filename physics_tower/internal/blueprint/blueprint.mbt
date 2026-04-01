///|
/// Returns the total cost of a blueprint in inventory pieces.
pub fn blueprint_cost(bp : @types.Blueprint, game : @types.Game) -> Int {
  ignore(game)
  bp.cost
}

///|
/// Checks if the player has enough inventory to place a blueprint.
pub fn can_afford_blueprint(bp : @types.Blueprint, game : @types.Game) -> Bool {
  // Count required pieces by kind+material
  let needs : Array[((@types.PieceKind, @types.Material), Int)] = Array::new(
    capacity=bp.pieces.length(),
  )
  for p in bp.pieces {
    let (kind, mat, _, _, _) = p
    let mut found = false
    for i in 0..<needs.length() {
      let ((k, m), c) = needs[i]
      if k == kind && m == mat {
        needs[i] = ((k, m), c + 1)
        found = true
        break
      }
    }
    if !found {
      needs.push(((kind, mat), 1))
    }
  }
  // Check inventory has enough of each
  for need in needs {
    let ((nk, nm), nc) = need
    let mut have = 0
    for inv_item in game.inventory {
      let (ik, im, ic) = inv_item
      if ik == nk && im == nm {
        have = have + ic
      }
    }
    if have < nc {
      return false
    }
  }
  true
}

///|
/// Places a blueprint at the given world position.
/// Returns the number of bodies placed, or 0 on failure.
pub fn place_blueprint(
  bp : @types.Blueprint,
  game : @types.Game,
  cx : Float,
  cy : Float,
) -> Int {
  if !can_afford_blueprint(bp, game) {
    return 0
  }
  let mut placed = 0
  let ids : Array[Int] = Array::new(capacity=bp.pieces.length())
  for p in bp.pieces {
    let (kind, mat, ox, oy, angle) = p
    let wx = cx + ox
    let wy = cy + oy
    // Clamp to build area
    let clamped_x = @types.clampf(
      wx,
      @types.build_area_left + 40.0,
      @types.build_area_right - 40.0,
    )
    let clamped_y = @types.clampf(
      wy,
      @types.build_area_top,
      @types.ground_y - 10.0,
    )
    let id = @physics.add_body(
      game.world,
      kind,
      mat,
      clamped_x,
      clamped_y,
      angle,
    )
    ids.push(id)
    // Deduct from inventory
    deduct_inventory(game, kind, mat)
    placed = placed + 1
  }
  // Auto-join all placed bodies to each other and to existing structure
  for id in ids {
    @physics.auto_join(game.world, id)
  }
  // Settle briefly
  for _i in 0..<10 {
    @physics.step(game.world, 0.016)
  }
  placed
}

///|
/// Deducts one piece of (kind, material) from inventory.
fn deduct_inventory(
  game : @types.Game,
  kind : @types.PieceKind,
  mat : @types.Material,
) -> Unit {
  for i in 0..<game.inventory.length() {
    let (ik, im, ic) = game.inventory[i]
    if ik == kind && im == mat && ic > 0 {
      game.inventory[i] = (ik, im, ic - 1)
      return
    }
  }
}

///|
/// Saves the current tower as a custom blueprint.
/// Records positions relative to centroid of all active bodies.
pub fn save_custom_blueprint(
  game : @types.Game,
  name : String,
) -> @types.Blueprint? {
  let world = game.world
  if world.bodies.length() == 0 {
    return None
  }
  // Compute centroid of active bodies
  let mut sum_x : Float = 0.0
  let mut sum_y : Float = 0.0
  let mut count = 0
  for body in world.bodies {
    if body.active && !body.broken {
      sum_x = sum_x + body.x
      sum_y = sum_y + body.y
      count = count + 1
    }
  }
  if count == 0 {
    return None
  }
  let cx = sum_x / Float::from_int(count)
  let cy = sum_y / Float::from_int(count)
  let pieces : Array[(@types.PieceKind, @types.Material, Float, Float, Float)] = Array::new(
    capacity=count,
  )
  for body in world.bodies {
    if body.active && !body.broken {
      pieces.push(
        (body.kind, body.material, body.x - cx, body.y - cy, body.angle),
      )
    }
  }
  let idx = game.custom_blueprints.length()
  let bp : @types.Blueprint = { kind: Custom(idx), name, pieces, cost: count }
  game.custom_blueprints.push(bp)
  Some(bp)
}

///|
/// Loads custom blueprints into the available blueprints list.
pub fn load_custom_blueprints(game : @types.Game) -> Unit {
  // Merge default + custom into the blueprints array
  let defaults = @types.default_blueprints()
  game.blueprints.clear()
  for bp in defaults {
    game.blueprints.push(bp)
  }
  for bp in game.custom_blueprints {
    game.blueprints.push(bp)
  }
}

///|
/// Returns all available blueprints including custom ones.
pub fn get_all_blueprints(game : @types.Game) -> Array[@types.Blueprint] {
  let result : Array[@types.Blueprint] = Array::new(
    capacity=game.blueprints.length() + game.custom_blueprints.length(),
  )
  for bp in game.blueprints {
    result.push(bp)
  }
  result
}

///|
/// Returns the display name for a blueprint kind.
pub fn blueprint_kind_name(kind : @types.BlueprintKind) -> String {
  match kind {
    Column => "Column"
    ArchWay => "Archway"
    Truss => "Truss"
    Foundation => "Foundation"
    Custom(_) => "Custom"
  }
}

///|
/// Computes the bounding box of a blueprint for ghost preview.
pub fn blueprint_bounds(bp : @types.Blueprint) -> (Float, Float, Float, Float) {
  let mut min_x : Float = 99999.0
  let mut min_y : Float = 99999.0
  let mut max_x : Float = -99999.0
  let mut max_y : Float = -99999.0
  for p in bp.pieces {
    let (kind, _, ox, oy, _) = p
    let (w, h) = @types.piece_dimensions(kind)
    let hw = w * 0.5
    let hh = h * 0.5
    if ox - hw < min_x {
      min_x = ox - hw
    }
    if oy - hh < min_y {
      min_y = oy - hh
    }
    if ox + hw > max_x {
      max_x = ox + hw
    }
    if oy + hh > max_y {
      max_y = oy + hh
    }
  }
  (min_x, min_y, max_x, max_y)
}

///|
/// Validates a blueprint: ensures all pieces are within reasonable offsets.
pub fn validate_blueprint(bp : @types.Blueprint) -> Bool {
  if bp.pieces.length() == 0 {
    return false
  }
  for p in bp.pieces {
    let (_, _, ox, oy, _) = p
    if @types.absf(ox) > 500.0 || @types.absf(oy) > 500.0 {
      return false
    }
  }
  true
}

///|
/// Creates a column blueprint with the specified material and block count.
pub fn make_column(mat : @types.Material, count : Int) -> @types.Blueprint {
  let pieces : Array[(@types.PieceKind, @types.Material, Float, Float, Float)] = Array::new(
    capacity=count,
  )
  for i in 0..<count {
    let oy = Float::from_int(i) * -@types.block_h
    pieces.push((Block, mat, 0.0, oy, 0.0))
  }
  { kind: Column, name: "Column x" + count.to_string(), pieces, cost: count }
}

///|
/// Creates a truss blueprint with the specified material.
pub fn make_truss(mat : @types.Material) -> @types.Blueprint {
  let pieces : Array[(@types.PieceKind, @types.Material, Float, Float, Float)] = [
    (Block, mat, -40.0, 0.0, 0.0),
    (Block, mat, 40.0, 0.0, 0.0),
    (Triangle, mat, 0.0, -55.0, 0.0),
    (Beam, mat, 0.0, -90.0, 0.0),
  ]
  { kind: Truss, name: "Truss", pieces, cost: 4 }
}

///|
/// Creates a foundation blueprint with the specified material.
pub fn make_foundation(mat : @types.Material) -> @types.Blueprint {
  let pieces : Array[(@types.PieceKind, @types.Material, Float, Float, Float)] = [
    (Beam, mat, -60.0, 0.0, 0.0),
    (Beam, mat, 60.0, 0.0, 0.0),
    (Block, mat, 0.0, 0.0, 0.0),
  ]
  { kind: Foundation, name: "Foundation", pieces, cost: 3 }
}

///|
/// Creates an archway blueprint with column and beam materials.
pub fn make_archway(
  col_mat : @types.Material,
  beam_mat : @types.Material,
) -> @types.Blueprint {
  let pieces : Array[(@types.PieceKind, @types.Material, Float, Float, Float)] = [
    (Block, col_mat, -70.0, 0.0, 0.0),
    (Block, col_mat, -70.0, -60.0, 0.0),
    (Block, col_mat, 70.0, 0.0, 0.0),
    (Block, col_mat, 70.0, -60.0, 0.0),
    (Beam, beam_mat, 0.0, -100.0, 0.0),
  ]
  { kind: ArchWay, name: "Archway", pieces, cost: 5 }
}
