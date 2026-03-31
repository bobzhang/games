///|
pub fn init_editor(
  editor : @types.EditorState,
  available : Array[@types.CommandKind]
) -> Unit {
  editor.cursor = 0
  editor.palette_cursor = 0
  editor.palette_open = false
  editor.palette_commands = available
  editor.loop_count = 2
  editor.condition_index = 0
}

///|
pub fn cursor_up(editor : @types.EditorState, program : @types.Program) -> Unit {
  if editor.palette_open {
    if editor.palette_cursor > 0 {
      editor.palette_cursor -= 1
    }
  } else if editor.cursor > 0 {
    editor.cursor -= 1
  }
  let _ = program
}

///|
pub fn cursor_down(
  editor : @types.EditorState,
  program : @types.Program
) -> Unit {
  if editor.palette_open {
    if editor.palette_cursor < editor.palette_commands.length() - 1 {
      editor.palette_cursor += 1
    }
  } else {
    let max = @types.mini(program.commands.length(), program.max_slots - 1)
    if editor.cursor < max {
      editor.cursor += 1
    }
  }
}

///|
pub fn toggle_palette(editor : @types.EditorState) -> Unit {
  editor.palette_open = !editor.palette_open
  if editor.palette_open {
    editor.palette_cursor = 0
  }
}

///|
pub fn close_palette(editor : @types.EditorState) -> Unit {
  editor.palette_open = false
}

///|
pub fn select_from_palette(
  editor : @types.EditorState,
  program : @types.Program
) -> Bool {
  if !editor.palette_open {
    return false
  }
  if editor.palette_cursor >= 0 &&
    editor.palette_cursor < editor.palette_commands.length() {
    let kind = editor.palette_commands[editor.palette_cursor]
    let success = @commands.program_insert(program, editor.cursor, kind)
    if success {
      editor.palette_open = false
      if editor.cursor < program.commands.length() - 1 {
        editor.cursor += 1
      }
    }
    return success
  }
  false
}

///|
pub fn delete_at_cursor(
  editor : @types.EditorState,
  program : @types.Program
) -> Bool {
  if program.commands.length() == 0 {
    return false
  }
  let success = @commands.program_remove(program, editor.cursor)
  if success && editor.cursor >= program.commands.length() && editor.cursor > 0 {
    editor.cursor -= 1
  }
  success
}

///|
pub fn move_cmd_up(
  editor : @types.EditorState,
  program : @types.Program
) -> Bool {
  if @commands.program_move_up(program, editor.cursor) {
    editor.cursor -= 1
    return true
  }
  false
}

///|
pub fn move_cmd_down(
  editor : @types.EditorState,
  program : @types.Program
) -> Bool {
  if @commands.program_move_down(program, editor.cursor) {
    editor.cursor += 1
    return true
  }
  false
}

///|
pub fn clear_program(
  editor : @types.EditorState,
  program : @types.Program
) -> Unit {
  @commands.program_clear(program)
  editor.cursor = 0
}

///|
pub fn add_command_by_index(
  editor : @types.EditorState,
  program : @types.Program,
  index : Int
) -> Bool {
  if index >= 0 && index < editor.palette_commands.length() {
    let kind = editor.palette_commands[index]
    let success = @commands.program_insert(program, editor.cursor, kind)
    if success && editor.cursor < program.commands.length() - 1 {
      editor.cursor += 1
    }
    return success
  }
  false
}

///|
pub fn clamp_cursor(
  editor : @types.EditorState,
  program : @types.Program
) -> Unit {
  if editor.cursor < 0 {
    editor.cursor = 0
  }
  if editor.cursor >= program.commands.length() {
    editor.cursor = @types.maxi(0, program.commands.length() - 1)
  }
}

///|
pub fn get_current_command(
  editor : @types.EditorState,
  program : @types.Program
) -> @types.CommandKind? {
  if editor.cursor >= 0 && editor.cursor < program.commands.length() {
    Some(program.commands[editor.cursor].kind)
  } else {
    None
  }
}
