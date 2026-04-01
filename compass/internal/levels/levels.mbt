///|
pub fn get_level(index : Int) -> @types.LevelData {
  match index {
    0 => level_1()
    1 => level_2()
    2 => level_3()
    3 => level_4()
    4 => level_5()
    5 => level_6()
    6 => level_7()
    7 => level_8()
    8 => level_9()
    9 => level_10()
    10 => level_11()
    11 => level_12()
    12 => level_13()
    13 => level_14()
    14 => level_15()
    15 => level_16()
    16 => level_17()
    17 => level_18()
    18 => level_19()
    19 => level_20()
    _ => level_1()
  }
}

///|
pub fn init_level(index : Int) -> @types.LevelState {
  let data = get_level(index)
  let revealed : Array[Array[Bool]] = []
  for _y in 0..<@types.grid_rows {
    revealed.push(Array::make(@types.grid_cols, false))
  }
  // Reveal 3x3 area around start
  reveal_area(revealed, data.start.x, data.start.y)
  let ship = @types.new_ship(data.start)
  let bearing = @types.compute_bearing(data.start, data.lighthouse)
  ship.heading = bearing
  {
    data,
    revealed,
    ship,
    phase: Playing,
    message: "Navigate to the lighthouse!",
    message_timer: 3.0,
    compass_beep: false,
    near_land_dir: North,
  }
}

///|
pub fn reveal_area(revealed : Array[Array[Bool]], cx : Int, cy : Int) -> Unit {
  let r = @types.reveal_radius
  for dy in -r..=r {
    for dx in -r..=r {
      let nx = cx + dx
      let ny = cy + dy
      if @types.in_bounds(nx, ny) {
        revealed[ny][nx] = true
      }
    }
  }
}

///|
pub fn tier_name(tier : Int) -> String {
  match tier {
    1 => "Calm Seas"
    2 => "Rough Waters"
    3 => "Treacherous Depths"
    _ => "Unknown"
  }
}
