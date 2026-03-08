///|
fn make_rooms() -> Array[Room] {
  Array::makei(cols * rows, fn(_i) {
    {
      label: "",
      contam: 0.0F,
      oxygen: 100.0F,
      crew: 100.0F,
      source: 0.0F,
      purge_t: 0.0F,
      boost_t: 0.0F,
    }
  })
}

///|
fn make_hdoors() -> Array[Bool] {
  Array::make((cols - 1) * rows, true)
}

///|
fn make_vdoors() -> Array[Bool] {
  Array::make(cols * (rows - 1), true)
}

///|
test "sector 1 setup seeds sources and timer" {
  let rooms = make_rooms()
  let hdoors = make_hdoors()
  let vdoors = make_vdoors()
  let timer = reset_sector(1, rooms, hdoors, vdoors)

  assert_eq(timer.to_int(), 70)
  assert_eq(rooms[room_idx(3, 0)].source.to_int(), 7)
  assert_eq(rooms[room_idx(2, 1)].source.to_int(), 4)
  assert_false(vdoors[vdoor_idx(1, 0)])
}

///|
test "restore_crew reapplies prior casualties after sector reset" {
  let rooms = make_rooms()
  let hdoors = make_hdoors()
  let vdoors = make_vdoors()
  ignore(reset_sector(2, rooms, hdoors, vdoors))

  let carry = Array::makei(rooms.length(), fn(i) { Float::from_int(60 + i) })
  restore_crew(rooms, carry)

  assert_eq(rooms[0].crew.to_int(), 60)
  assert_eq(rooms[rooms.length() - 1].crew.to_int(), 60 + rooms.length() - 1)
}

///|
test "open horizontal door spreads contamination" {
  let rooms = make_rooms()
  let hdoors = make_hdoors()
  let vdoors = make_vdoors()

  rooms[room_idx(0, 0)].contam = 80.0F
  rooms[room_idx(1, 0)].contam = 0.0F
  rooms[room_idx(0, 0)].oxygen = 40.0F
  rooms[room_idx(1, 0)].oxygen = 100.0F

  let left_before = rooms[room_idx(0, 0)].contam
  let right_before = rooms[room_idx(1, 0)].contam
  ignore(update_systems(rooms, hdoors, vdoors, 1.0F, 1, 100.0F, 100.0F))

  assert_true(rooms[room_idx(0, 0)].contam < left_before)
  assert_true(rooms[room_idx(1, 0)].contam > right_before)
}
