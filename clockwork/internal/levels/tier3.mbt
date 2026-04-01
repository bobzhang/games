///|
pub fn make_level_15() -> @types.LevelDef {
  let def = @types.new_level_def()
  def.id = 14
  def.name = "Grand Clock"
  def.tier = Clockwork
  def.description = "Build a full clock mechanism with four bells."
  def.par_components = 6
  let drive = @types.new_fixed_component(Gear(Large), 0, 3)
  drive.rotation_speed = 1.0
  def.fixed_components.push(drive)
  let bell1 = @types.new_bell(3, 1, 4)
  def.fixed_components.push(bell1)
  let bell2 = @types.new_bell(6, 1, 8)
  def.fixed_components.push(bell2)
  let bell3 = @types.new_bell(6, 5, 12)
  def.fixed_components.push(bell3)
  let bell4 = @types.new_bell(3, 5, 16)
  def.fixed_components.push(bell4)
  def.bell_targets = [4, 8, 12, 16]
  @types.palette_add(def.palette, Gear(Medium), 3)
  @types.palette_add(def.palette, Gear(Small), 3)
  @types.palette_add(def.palette, Cam, 3)
  @types.palette_add(def.palette, Escapement, 1)
  @types.palette_add(def.palette, Spring, 1)
  def
}

///|
pub fn make_level_16() -> @types.LevelDef {
  let def = @types.new_level_def()
  def.id = 15
  def.name = "Counter Spin"
  def.tier = Clockwork
  def.description = "Gears must spin in opposite directions."
  def.par_components = 5
  let drive1 = @types.new_fixed_component(Gear(Medium), 0, 2)
  drive1.rotation_speed = 1.0
  def.fixed_components.push(drive1)
  let drive2 = @types.new_fixed_component(Gear(Medium), 7, 5)
  drive2.rotation_speed = 1.0
  def.fixed_components.push(drive2)
  let bell1 = @types.new_bell(3, 3, 5)
  def.fixed_components.push(bell1)
  let bell2 = @types.new_bell(4, 5, 9)
  def.fixed_components.push(bell2)
  let bell3 = @types.new_bell(6, 2, 7)
  def.fixed_components.push(bell3)
  def.bell_targets = [5, 7, 9]
  @types.palette_add(def.palette, Gear(Medium), 3)
  @types.palette_add(def.palette, Gear(Small), 2)
  @types.palette_add(def.palette, Cam, 2)
  @types.palette_add(def.palette, Escapement, 1)
  def
}

///|
pub fn make_level_17() -> @types.LevelDef {
  let def = @types.new_level_def()
  def.id = 16
  def.name = "Spring Chain"
  def.tier = Clockwork
  def.description = "Springs provide delayed power bursts."
  def.par_components = 6
  let drive = @types.new_fixed_component(Gear(Medium), 0, 3)
  drive.rotation_speed = 1.0
  def.fixed_components.push(drive)
  let bell1 = @types.new_bell(4, 1, 5)
  def.fixed_components.push(bell1)
  let bell2 = @types.new_bell(6, 3, 10)
  def.fixed_components.push(bell2)
  let bell3 = @types.new_bell(4, 6, 15)
  def.fixed_components.push(bell3)
  def.bell_targets = [5, 10, 15]
  @types.palette_add(def.palette, Gear(Medium), 2)
  @types.palette_add(def.palette, Gear(Small), 2)
  @types.palette_add(def.palette, Spring, 2)
  @types.palette_add(def.palette, Cam, 2)
  @types.palette_add(def.palette, Escapement, 1)
  def
}

///|
pub fn make_level_18() -> @types.LevelDef {
  let def = @types.new_level_def()
  def.id = 17
  def.name = "Pendulum"
  def.tier = Clockwork
  def.description = "Multiple escapements create complex rhythms."
  def.par_components = 7
  let drive = @types.new_fixed_component(Gear(Large), 3, 0)
  drive.rotation_speed = 1.0
  def.fixed_components.push(drive)
  let bell1 = @types.new_bell(1, 3, 6)
  def.fixed_components.push(bell1)
  let bell2 = @types.new_bell(5, 3, 9)
  def.fixed_components.push(bell2)
  let bell3 = @types.new_bell(1, 6, 12)
  def.fixed_components.push(bell3)
  let bell4 = @types.new_bell(5, 6, 15)
  def.fixed_components.push(bell4)
  def.bell_targets = [6, 9, 12, 15]
  @types.palette_add(def.palette, Gear(Medium), 3)
  @types.palette_add(def.palette, Gear(Small), 2)
  @types.palette_add(def.palette, Gear(Large), 1)
  @types.palette_add(def.palette, Escapement, 2)
  @types.palette_add(def.palette, Cam, 3)
  def
}

///|
pub fn make_level_19() -> @types.LevelDef {
  let def = @types.new_level_def()
  def.id = 18
  def.name = "Cathedral"
  def.tier = Clockwork
  def.description = "Five bells must chime in sequence."
  def.par_components = 8
  let drive = @types.new_fixed_component(Gear(Large), 3, 0)
  drive.rotation_speed = 1.0
  def.fixed_components.push(drive)
  let bell1 = @types.new_bell(0, 2, 4)
  def.fixed_components.push(bell1)
  let bell2 = @types.new_bell(6, 2, 7)
  def.fixed_components.push(bell2)
  let bell3 = @types.new_bell(0, 5, 10)
  def.fixed_components.push(bell3)
  let bell4 = @types.new_bell(6, 5, 13)
  def.fixed_components.push(bell4)
  let bell5 = @types.new_bell(3, 7, 16)
  def.fixed_components.push(bell5)
  def.bell_targets = [4, 7, 10, 13, 16]
  @types.palette_add(def.palette, Gear(Medium), 4)
  @types.palette_add(def.palette, Gear(Small), 3)
  @types.palette_add(def.palette, Gear(Large), 2)
  @types.palette_add(def.palette, Cam, 3)
  @types.palette_add(def.palette, Escapement, 2)
  @types.palette_add(def.palette, Spring, 1)
  def
}

///|
pub fn make_level_20() -> @types.LevelDef {
  let def = @types.new_level_def()
  def.id = 19
  def.name = "Masterwork"
  def.tier = Clockwork
  def.description = "The ultimate clockwork challenge."
  def.par_components = 9
  let drive1 = @types.new_fixed_component(Gear(Large), 0, 0)
  drive1.rotation_speed = 1.0
  def.fixed_components.push(drive1)
  let drive2 = @types.new_fixed_component(Gear(Small), 7, 7)
  drive2.rotation_speed = 2.0
  def.fixed_components.push(drive2)
  let bell1 = @types.new_bell(3, 1, 5)
  def.fixed_components.push(bell1)
  let bell2 = @types.new_bell(6, 2, 8)
  def.fixed_components.push(bell2)
  let bell3 = @types.new_bell(1, 4, 11)
  def.fixed_components.push(bell3)
  let bell4 = @types.new_bell(5, 5, 14)
  def.fixed_components.push(bell4)
  let bell5 = @types.new_bell(2, 7, 17)
  def.fixed_components.push(bell5)
  let bell6 = @types.new_bell(6, 7, 20)
  def.fixed_components.push(bell6)
  def.bell_targets = [5, 8, 11, 14, 17, 20]
  @types.palette_add(def.palette, Gear(Medium), 4)
  @types.palette_add(def.palette, Gear(Small), 4)
  @types.palette_add(def.palette, Gear(Large), 2)
  @types.palette_add(def.palette, Cam, 3)
  @types.palette_add(def.palette, Escapement, 2)
  @types.palette_add(def.palette, Spring, 2)
  def
}
