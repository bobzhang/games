///|
pub fn new_command(kind : @types.CommandKind) -> @types.Command {
  { kind, }
}

///|
pub fn command_name(kind : @types.CommandKind) -> String {
  match kind {
    Move => "Move"
    TurnLeft => "TurnL"
    TurnRight => "TurnR"
    Jump => "Jump"
    Push => "Push"
    If(cond) => "If:" + @types.condition_name(cond)
    Loop(n) => "Loop:" + n.to_string()
  }
}

///|
pub fn command_short_name(kind : @types.CommandKind) -> String {
  match kind {
    Move => "MOV"
    TurnLeft => "TL"
    TurnRight => "TR"
    Jump => "JMP"
    Push => "PSH"
    If(_) => "IF"
    Loop(_) => "LOP"
  }
}

///|
pub fn command_color(kind : @types.CommandKind) -> @raylib.Color {
  match kind {
    Move => @types.color_cmd_move
    TurnLeft | TurnRight => @types.color_cmd_turn
    Jump => @types.color_cmd_jump
    Push => @types.color_cmd_push
    If(_) => @types.color_cmd_if
    Loop(_) => @types.color_cmd_loop
  }
}

///|
pub fn command_description(kind : @types.CommandKind) -> String {
  match kind {
    Move => "Move forward 1 tile"
    TurnLeft => "Rotate 90 degrees left"
    TurnRight => "Rotate 90 degrees right"
    Jump => "Leap over 1 tile"
    Push => "Push a block forward"
    If(PathAhead) => "If path ahead"
    If(WallAhead) => "If wall ahead"
    If(AtGoal) => "If at goal"
    If(OnColor(c)) => "If on " + @types.tile_color_name(c)
    Loop(n) => "Repeat next " + n.to_string() + "x"
  }
}

///|
pub fn is_control_flow(kind : @types.CommandKind) -> Bool {
  match kind {
    If(_) | Loop(_) => true
    _ => false
  }
}

///|
pub fn validate_program(program : @types.Program) -> Bool {
  program.commands.length() > 0 && program.commands.length() <= program.max_slots
}

///|
pub fn program_add(
  program : @types.Program,
  kind : @types.CommandKind
) -> Bool {
  if program.commands.length() < program.max_slots {
    program.commands.push(new_command(kind))
    true
  } else {
    false
  }
}

///|
pub fn program_insert(
  program : @types.Program,
  index : Int,
  kind : @types.CommandKind
) -> Bool {
  if program.commands.length() < program.max_slots && index >= 0 && index <=
    program.commands.length() {
    program.commands.insert(index, new_command(kind))
    true
  } else {
    false
  }
}

///|
pub fn program_remove(program : @types.Program, index : Int) -> Bool {
  if index >= 0 && index < program.commands.length() {
    program.commands.remove(index) |> ignore
    true
  } else {
    false
  }
}

///|
pub fn program_clear(program : @types.Program) -> Unit {
  program.commands = []
}

///|
pub fn program_move_up(program : @types.Program, index : Int) -> Bool {
  if index > 0 && index < program.commands.length() {
    let temp = program.commands[index]
    program.commands[index] = program.commands[index - 1]
    program.commands[index - 1] = temp
    true
  } else {
    false
  }
}

///|
pub fn program_move_down(program : @types.Program, index : Int) -> Bool {
  if index >= 0 && index < program.commands.length() - 1 {
    let temp = program.commands[index]
    program.commands[index] = program.commands[index + 1]
    program.commands[index + 1] = temp
    true
  } else {
    false
  }
}

///|
pub fn all_conditions() -> Array[@types.Condition] {
  [PathAhead, WallAhead, AtGoal, OnColor(Red), OnColor(Blue), OnColor(Green)]
}

///|
pub fn basic_commands() -> Array[@types.CommandKind] {
  [Move, TurnLeft, TurnRight]
}

///|
pub fn leap_commands() -> Array[@types.CommandKind] {
  [Move, TurnLeft, TurnRight, Jump]
}

///|
pub fn logic_commands() -> Array[@types.CommandKind] {
  [
    Move, TurnLeft, TurnRight, Jump, If(PathAhead), If(WallAhead), If(AtGoal),
    If(OnColor(Red)),
  ]
}

///|
pub fn mastery_commands() -> Array[@types.CommandKind] {
  [
    Move, TurnLeft, TurnRight, Jump, Push, If(PathAhead), If(WallAhead), Loop(2),
    Loop(3),
  ]
}
