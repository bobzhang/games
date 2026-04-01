///|
pub fn new_region(damages : Array[DamageKind]) -> Region {
  let state : RegionState = if damages.length() == 0 { Pristine } else { Damaged }
  { state, damage_types: damages, treatments_applied: [], fragile: false, stain_permanent: false }
}

///|
pub fn new_artwork(w : Int, h : Int, regions : Array[Region]) -> Artwork {
  { width: w, height: h, regions }
}

///|
pub fn new_budget(clean : Int, fill : Int, retouch : Int, seal : Int) -> ToolBudget {
  { clean, fill, retouch, seal }
}

///|
pub fn clone_budget(b : ToolBudget) -> ToolBudget {
  { clean: b.clean, fill: b.fill, retouch: b.retouch, seal: b.seal }
}

///|
pub fn new_level(
  tier : Tier,
  name : String,
  regions : Array[Region],
  budget : ToolBudget,
  par_tools : Int
) -> Level {
  let art = new_artwork(grid_cols, grid_rows, regions)
  { tier, name, artwork: art, budget, par_tools }
}

///|
pub fn new_score() -> LevelScore {
  { stars: 0, restored_count: 0, worsened_count: 0, sealed_count: 0, total_tools_used: 0 }
}

///|
pub fn tool_color(kind : ToolKind) -> @raylib.Color {
  match kind {
    Clean => color_tool_clean
    Fill => color_tool_fill
    Retouch => color_tool_retouch
    Seal => color_tool_seal
  }
}

///|
pub fn tool_name(kind : ToolKind) -> String {
  match kind {
    Clean => "Clean"
    Fill => "Fill"
    Retouch => "Retouch"
    Seal => "Seal"
  }
}

///|
pub fn damage_name(kind : DamageKind) -> String {
  match kind {
    Crack => "Crack"
    Stain => "Stain"
    Fade => "Fade"
    Flake => "Flake"
  }
}

///|
pub fn damage_color(kind : DamageKind) -> @raylib.Color {
  match kind {
    Crack => color_crack
    Stain => color_stain
    Fade => color_fade
    Flake => color_flake
  }
}

///|
pub fn state_name(s : RegionState) -> String {
  match s {
    Pristine => "Pristine"
    Damaged => "Damaged"
    Treated => "Treated"
    Restored => "Restored"
    Worsened => "Worsened"
    Sealed => "Sealed"
  }
}

///|
pub fn state_color(s : RegionState) -> @raylib.Color {
  match s {
    Pristine => color_pristine
    Damaged => color_canvas
    Treated => color_treated
    Restored => color_restored
    Worsened => color_worsened
    Sealed => color_sealed
  }
}

///|
pub fn get_budget_for_tool(budget : ToolBudget, tool : ToolKind) -> Int {
  match tool {
    Clean => budget.clean
    Fill => budget.fill
    Retouch => budget.retouch
    Seal => budget.seal
  }
}

///|
pub fn use_budget(budget : ToolBudget, tool : ToolKind) -> Unit {
  match tool {
    Clean => budget.clean = budget.clean - 1
    Fill => budget.fill = budget.fill - 1
    Retouch => budget.retouch = budget.retouch - 1
    Seal => budget.seal = budget.seal - 1
  }
}

///|
pub fn restore_budget(budget : ToolBudget, tool : ToolKind) -> Unit {
  match tool {
    Clean => budget.clean = budget.clean + 1
    Fill => budget.fill = budget.fill + 1
    Retouch => budget.retouch = budget.retouch + 1
    Seal => budget.seal = budget.seal + 1
  }
}

///|
pub fn tier_name(t : Tier) -> String {
  match t {
    Sketches => "Sketches"
    Paintings => "Paintings"
    Masterworks => "Masterworks"
  }
}

///|
pub fn tier_index(t : Tier) -> Int {
  match t {
    Sketches => 0
    Paintings => 1
    Masterworks => 2
  }
}

///|
pub fn tier_from_index(i : Int) -> Tier {
  if i == 0 {
    Sketches
  } else if i == 1 {
    Paintings
  } else {
    Masterworks
  }
}

///|
pub fn tier_level_range(t : Tier) -> (Int, Int) {
  match t {
    Sketches => (0, 7)
    Paintings => (7, 14)
    Masterworks => (14, 20)
  }
}

///|
pub fn clone_region(r : Region) -> Region {
  let dmg : Array[DamageKind] = []
  for i in 0..<r.damage_types.length() {
    dmg.push(r.damage_types[i])
  }
  let treats : Array[ToolKind] = []
  for i in 0..<r.treatments_applied.length() {
    treats.push(r.treatments_applied[i])
  }
  {
    state: r.state,
    damage_types: dmg,
    treatments_applied: treats,
    fragile: r.fragile,
    stain_permanent: r.stain_permanent,
  }
}

///|
pub fn new_game() -> Game {
  let scores : Array[Int] = []
  for _i in 0..<20 {
    scores.push(0)
  }
  {
    screen: Title,
    selected_tier: Sketches,
    selected_level: 0,
    current_level: None,
    current_budget: None,
    selected_tool: Clean,
    play_state: Selecting,
    anim_timer: 0.0,
    anim_region: -1,
    hover_region: -1,
    score: None,
    level_scores: scores,
    undo_stack: [],
    total_tools_used: 0,
    message: "",
    message_timer: 0.0,
    frame_count: 0,
    title_anim_timer: 0.0,
  }
}

///|
pub fn region_has_damage(r : Region, kind : DamageKind) -> Bool {
  for i in 0..<r.damage_types.length() {
    if r.damage_types[i] == kind {
      return true
    }
  }
  false
}

///|
pub fn region_has_treatment(r : Region, kind : ToolKind) -> Bool {
  for i in 0..<r.treatments_applied.length() {
    if r.treatments_applied[i] == kind {
      return true
    }
  }
  false
}

///|
pub fn sinf(a : Float) -> Float {
  Float::from_double(@math.sin(a.to_double()))
}

///|
pub fn cosf(a : Float) -> Float {
  Float::from_double(@math.cos(a.to_double()))
}

///|
pub fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
  } else {
    v
  }
}

///|
pub fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
  }
}

///|
pub fn minf(a : Float, b : Float) -> Float {
  if a < b {
    a
  } else {
    b
  }
}

///|
pub fn mini(a : Int, b : Int) -> Int {
  if a < b {
    a
  } else {
    b
  }
}

///|
pub fn maxi(a : Int, b : Int) -> Int {
  if a > b {
    a
  } else {
    b
  }
}
