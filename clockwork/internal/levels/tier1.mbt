///|
pub fn make_level_1() -> @types.LevelDef {
  let def = @types.new_level_def()
  def.id = 0
  def.name = "First Chime"
  def.tier = Ticks
  def.description = "Place a gear to connect the drive to the bell."
  def.par_components = 1
  // Fixed drive gear at (1,3)
  let drive = @types.new_fixed_component(Gear(Medium), 1, 3)
  drive.rotation_speed = 1.0
  def.fixed_components.push(drive)
  // Bell at (3,3)
  let bell = @types.new_bell(3, 3, 5)
  def.fixed_components.push(bell)
  def.bell_targets = [5]
  // Palette: 1 medium gear
  @types.palette_add(def.palette, Gear(Medium), 1)
  def
}

///|
pub fn make_level_2() -> @types.LevelDef {
  let def = @types.new_level_def()
  def.id = 1
  def.name = "Two Tone"
  def.tier = Ticks
  def.description = "Connect two bells with a gear train."
  def.par_components = 2
  let drive = @types.new_fixed_component(Gear(Large), 0, 3)
  drive.rotation_speed = 1.0
  def.fixed_components.push(drive)
  let bell1 = @types.new_bell(3, 3, 4)
  def.fixed_components.push(bell1)
  let bell2 = @types.new_bell(5, 3, 8)
  def.fixed_components.push(bell2)
  def.bell_targets = [4, 8]
  @types.palette_add(def.palette, Gear(Medium), 2)
  @types.palette_add(def.palette, Gear(Small), 1)
  def
}

///|
pub fn make_level_3() -> @types.LevelDef {
  let def = @types.new_level_def()
  def.id = 2
  def.name = "Speed Up"
  def.tier = Ticks
  def.description = "Use small gears for faster rotation."
  def.par_components = 2
  let drive = @types.new_fixed_component(Gear(Large), 1, 4)
  drive.rotation_speed = 0.5
  def.fixed_components.push(drive)
  let bell = @types.new_bell(4, 4, 3)
  def.fixed_components.push(bell)
  def.bell_targets = [3]
  @types.palette_add(def.palette, Gear(Small), 2)
  @types.palette_add(def.palette, Gear(Medium), 1)
  def
}

///|
pub fn make_level_4() -> @types.LevelDef {
  let def = @types.new_level_def()
  def.id = 3
  def.name = "Slow Down"
  def.tier = Ticks
  def.description = "Large gears reduce speed. Time the bell precisely."
  def.par_components = 2
  let drive = @types.new_fixed_component(Gear(Small), 1, 3)
  drive.rotation_speed = 2.0
  def.fixed_components.push(drive)
  let bell = @types.new_bell(5, 3, 12)
  def.fixed_components.push(bell)
  def.bell_targets = [12]
  @types.palette_add(def.palette, Gear(Large), 2)
  @types.palette_add(def.palette, Gear(Medium), 1)
  def
}

///|
pub fn make_level_5() -> @types.LevelDef {
  let def = @types.new_level_def()
  def.id = 4
  def.name = "Fork"
  def.tier = Ticks
  def.description = "Branch the gear train to reach two bells."
  def.par_components = 3
  let drive = @types.new_fixed_component(Gear(Medium), 3, 1)
  drive.rotation_speed = 1.0
  def.fixed_components.push(drive)
  let bell1 = @types.new_bell(1, 3, 5)
  def.fixed_components.push(bell1)
  let bell2 = @types.new_bell(5, 3, 5)
  def.fixed_components.push(bell2)
  def.bell_targets = [5, 5]
  @types.palette_add(def.palette, Gear(Medium), 3)
  @types.palette_add(def.palette, Gear(Small), 1)
  def
}

///|
pub fn make_level_6() -> @types.LevelDef {
  let def = @types.new_level_def()
  def.id = 5
  def.name = "Zigzag"
  def.tier = Ticks
  def.description = "Route gears around obstacles."
  def.par_components = 4
  let drive = @types.new_fixed_component(Gear(Medium), 0, 0)
  drive.rotation_speed = 1.0
  def.fixed_components.push(drive)
  let bell = @types.new_bell(4, 4, 8)
  def.fixed_components.push(bell)
  // Obstacles (fixed non-driving gears that block paths)
  let block1 = @types.new_fixed_component(Gear(Large), 1, 1)
  block1.rotation_speed = 0.0
  def.fixed_components.push(block1)
  def.bell_targets = [8]
  @types.palette_add(def.palette, Gear(Medium), 3)
  @types.palette_add(def.palette, Gear(Small), 2)
  def
}

///|
pub fn make_level_7() -> @types.LevelDef {
  let def = @types.new_level_def()
  def.id = 6
  def.name = "Three Bells"
  def.tier = Ticks
  def.description = "Ring all three bells in order."
  def.par_components = 4
  let drive = @types.new_fixed_component(Gear(Medium), 0, 3)
  drive.rotation_speed = 1.0
  def.fixed_components.push(drive)
  let bell1 = @types.new_bell(3, 1, 4)
  def.fixed_components.push(bell1)
  let bell2 = @types.new_bell(5, 3, 6)
  def.fixed_components.push(bell2)
  let bell3 = @types.new_bell(3, 5, 8)
  def.fixed_components.push(bell3)
  def.bell_targets = [4, 6, 8]
  @types.palette_add(def.palette, Gear(Medium), 3)
  @types.palette_add(def.palette, Gear(Small), 2)
  @types.palette_add(def.palette, Gear(Large), 1)
  def
}
