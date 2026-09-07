///|
pub fn parse_grid(
  lines : Array[String],
) -> (
  Array[Array[@types.TileKind]],
  @types.Vec2i,
  @types.Vec2i,
  Array[@types.Vec2i],
) {
  let grid : Array[Array[@types.TileKind]] = []
  let mut start : @types.Vec2i = { x: 0, y: 0, }
  let mut exit : @types.Vec2i = { x: 0, y: 0, }
  let gems : Array[@types.Vec2i] = []
  for y in 0..<@types.grid_height {
    let row : Array[@types.TileKind] = []
    let line = if y < lines.length() { lines[y] } else { "############" }
    for x in 0..<@types.grid_width {
      let ch = if x < line.length() { line[x] } else { '#' }
      match ch {
        '#' => row.push(Wall)
        '.' => row.push(Floor)
        'X' => {
          row.push(Exit)
          exit = { x, y, }
        }
        '@' => {
          row.push(Floor)
          start = { x, y, }
        }
        'P' => row.push(Pit)
        'I' => row.push(Ice)
        'A' => row.push(Anchor)
        'G' => {
          row.push(Floor)
          gems.push({ x, y, })
        }
        '0' => row.push(Switch(0))
        '1' => row.push(Switch(1))
        '2' => row.push(Switch(2))
        '3' => row.push(Switch(3))
        'a' => row.push(Door(0))
        'b' => row.push(Door(1))
        'c' => row.push(Door(2))
        'd' => row.push(Door(3))
        _ => row.push(Floor)
      }
    }
    grid.push(row)
  }
  (grid, start, exit, gems)
}

///|
pub fn make_level(
  world : Int,
  index : Int,
  floor_lines : Array[String],
  ceiling_lines : Array[String],
  switch_links : Array[@types.SwitchLink],
  goal : @types.GoalKind,
  par_moves : Int,
) -> @types.Level {
  let (floor_tiles, floor_start, floor_exit, floor_gems) = parse_grid(
    floor_lines,
  )
  let (ceiling_tiles, ceiling_start, ceiling_exit, ceiling_gems) = parse_grid(
    ceiling_lines,
  )
  {
    world,
    index,
    floor_tiles,
    ceiling_tiles,
    switch_links,
    floor_start,
    ceiling_start,
    floor_exit,
    ceiling_exit,
    goal,
    par_moves,
    gems: floor_gems,
    ceiling_gems,
  }
}
