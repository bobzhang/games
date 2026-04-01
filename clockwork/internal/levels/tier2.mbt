///|
pub fn make_level_8() -> @types.LevelDef {
  let def = @types.new_level_def()
  def.id = 7
  def.name = "Push Bell"
  def.tier = Timing
  def.description = "Use a cam to push the bell at the right moment."
  def.par_components = 2
  let drive = @types.new_fixed_component(Gear(Medium), 1, 3)
  drive.rotation_speed = 1.0
  def.fixed_components.push(drive)
  let bell = @types.new_bell(4, 3, 6)
  def.fixed_components.push(bell)
  def.bell_targets = [6]
  @types.palette_add(def.palette, Gear(Medium), 1)
  @types.palette_add(def.palette, Cam, 1)
  def
}

///|
pub fn make_level_9() -> @types.LevelDef {
  let def = @types.new_level_def()
  def.id = 8
  def.name = "Tick Tock"
  def.tier = Timing
  def.description = "The escapement regulates timing. Use it wisely."
  def.par_components = 3
  let drive = @types.new_fixed_component(Gear(Small), 0, 3)
  drive.rotation_speed = 2.0
  def.fixed_components.push(drive)
  let bell = @types.new_bell(5, 3, 10)
  def.fixed_components.push(bell)
  def.bell_targets = [10]
  @types.palette_add(def.palette, Gear(Medium), 1)
  @types.palette_add(def.palette, Escapement, 1)
  @types.palette_add(def.palette, Cam, 1)
  def
}

///|
pub fn make_level_10() -> @types.LevelDef {
  let def = @types.new_level_def()
  def.id = 9
  def.name = "Double Push"
  def.tier = Timing
  def.description = "Two cams, two bells, precise timing."
  def.par_components = 4
  let drive = @types.new_fixed_component(Gear(Medium), 3, 0)
  drive.rotation_speed = 1.0
  def.fixed_components.push(drive)
  let bell1 = @types.new_bell(1, 3, 5)
  def.fixed_components.push(bell1)
  let bell2 = @types.new_bell(5, 3, 8)
  def.fixed_components.push(bell2)
  def.bell_targets = [5, 8]
  @types.palette_add(def.palette, Gear(Medium), 2)
  @types.palette_add(def.palette, Cam, 2)
  @types.palette_add(def.palette, Gear(Small), 1)
  def
}

///|
pub fn make_level_11() -> @types.LevelDef {
  let def = @types.new_level_def()
  def.id = 10
  def.name = "Spring Loaded"
  def.tier = Timing
  def.description = "Wind the spring, then release for a burst."
  def.par_components = 3
  let drive = @types.new_fixed_component(Gear(Medium), 1, 2)
  drive.rotation_speed = 1.0
  def.fixed_components.push(drive)
  let bell = @types.new_bell(5, 4, 7)
  def.fixed_components.push(bell)
  def.bell_targets = [7]
  @types.palette_add(def.palette, Gear(Small), 1)
  @types.palette_add(def.palette, Spring, 1)
  @types.palette_add(def.palette, Cam, 1)
  def
}

///|
pub fn make_level_12() -> @types.LevelDef {
  let def = @types.new_level_def()
  def.id = 11
  def.name = "Regulated"
  def.tier = Timing
  def.description = "Escapement plus cam for precise bell timing."
  def.par_components = 4
  let drive = @types.new_fixed_component(Gear(Small), 0, 2)
  drive.rotation_speed = 2.0
  def.fixed_components.push(drive)
  let bell1 = @types.new_bell(4, 2, 6)
  def.fixed_components.push(bell1)
  let bell2 = @types.new_bell(6, 4, 12)
  def.fixed_components.push(bell2)
  def.bell_targets = [6, 12]
  @types.palette_add(def.palette, Gear(Medium), 2)
  @types.palette_add(def.palette, Escapement, 1)
  @types.palette_add(def.palette, Cam, 2)
  def
}

///|
pub fn make_level_13() -> @types.LevelDef {
  let def = @types.new_level_def()
  def.id = 12
  def.name = "Cascade"
  def.tier = Timing
  def.description = "Chain multiple timing elements."
  def.par_components = 5
  let drive = @types.new_fixed_component(Gear(Large), 0, 0)
  drive.rotation_speed = 0.5
  def.fixed_components.push(drive)
  let bell1 = @types.new_bell(3, 3, 6)
  def.fixed_components.push(bell1)
  let bell2 = @types.new_bell(6, 6, 10)
  def.fixed_components.push(bell2)
  def.bell_targets = [6, 10]
  @types.palette_add(def.palette, Gear(Small), 2)
  @types.palette_add(def.palette, Gear(Medium), 2)
  @types.palette_add(def.palette, Cam, 2)
  @types.palette_add(def.palette, Escapement, 1)
  def
}

///|
pub fn make_level_14() -> @types.LevelDef {
  let def = @types.new_level_def()
  def.id = 13
  def.name = "Syncopation"
  def.tier = Timing
  def.description = "Ring three bells at different beats."
  def.par_components = 5
  let drive = @types.new_fixed_component(Gear(Medium), 3, 0)
  drive.rotation_speed = 1.0
  def.fixed_components.push(drive)
  let bell1 = @types.new_bell(1, 3, 4)
  def.fixed_components.push(bell1)
  let bell2 = @types.new_bell(3, 5, 7)
  def.fixed_components.push(bell2)
  let bell3 = @types.new_bell(6, 3, 10)
  def.fixed_components.push(bell3)
  def.bell_targets = [4, 7, 10]
  @types.palette_add(def.palette, Gear(Medium), 2)
  @types.palette_add(def.palette, Gear(Small), 2)
  @types.palette_add(def.palette, Cam, 2)
  @types.palette_add(def.palette, Escapement, 1)
  def
}
