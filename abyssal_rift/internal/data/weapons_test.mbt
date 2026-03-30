///|
test "sword stats" {
  let stats = @data.get_weapon_stats(Sword)
  inspect(
    stats.name,
    content=(
      #|Sword
    ),
  )
  inspect(
    stats.base_damage,
    content=(
      #|18
    ),
  )
  inspect(
    stats.combo_count,
    content=(
      #|3
    ),
  )
  inspect(
    stats.is_ranged,
    content=(
      #|false
    ),
  )
}

///|
test "daggers stats" {
  let stats = @data.get_weapon_stats(Daggers)
  inspect(
    stats.name,
    content=(
      #|Daggers
    ),
  )
  inspect(
    stats.base_damage,
    content=(
      #|7
    ),
  )
  inspect(
    stats.attack_speed,
    content=(
      #|0.14000000059604645
    ),
  )
  inspect(
    stats.crit_bonus,
    content=(
      #|0.20000000298023224
    ),
  )
}

///|
test "bow stats" {
  let stats = @data.get_weapon_stats(Bow)
  inspect(
    stats.name,
    content=(
      #|Bow
    ),
  )
  inspect(
    stats.is_ranged,
    content=(
      #|true
    ),
  )
  inspect(
    stats.projectile_speed,
    content=(
      #|650
    ),
  )
}

///|
test "staff stats" {
  let stats = @data.get_weapon_stats(Staff)
  inspect(
    stats.name,
    content=(
      #|Staff
    ),
  )
  inspect(
    stats.is_ranged,
    content=(
      #|true
    ),
  )
  inspect(
    stats.projectile_speed,
    content=(
      #|280
    ),
  )
}

///|
test "all weapons have distinct base damage" {
  let s = @data.get_weapon_stats(Sword)
  let d = @data.get_weapon_stats(Daggers)
  let b = @data.get_weapon_stats(Bow)
  let st = @data.get_weapon_stats(Staff)
  inspect(
    s.base_damage != d.base_damage,
    content=(
      #|true
    ),
  )
  inspect(
    b.base_damage != st.base_damage,
    content=(
      #|true
    ),
  )
}

///|
test "ranged weapons have projectile speed" {
  let b = @data.get_weapon_stats(Bow)
  let st = @data.get_weapon_stats(Staff)
  inspect(
    b.is_ranged && b.projectile_speed > 0.0,
    content=(
      #|true
    ),
  )
  inspect(
    st.is_ranged && st.projectile_speed > 0.0,
    content=(
      #|true
    ),
  )
}

///|
test "melee weapons have no projectile speed" {
  let s = @data.get_weapon_stats(Sword)
  let d = @data.get_weapon_stats(Daggers)
  inspect(
    s.projectile_speed,
    content=(
      #|0
    ),
  )
  inspect(
    d.projectile_speed,
    content=(
      #|0
    ),
  )
}

///|
test "windup time varies by weapon" {
  inspect(
    @data.get_windup_time(Sword, 0),
    content=(
      #|0.07999999821186066
    ),
  )
  inspect(
    @data.get_windup_time(Sword, 2),
    content=(
      #|0.11999999731779099
    ),
  )
  inspect(
    @data.get_windup_time(Daggers, 0),
    content=(
      #|0.03999999910593033
    ),
  )
  inspect(
    @data.get_windup_time(Bow, 0),
    content=(
      #|0.30000001192092896
    ),
  )
}

///|
test "active time per weapon" {
  inspect(
    @data.get_active_time(Sword),
    content=(
      #|0.10000000149011612
    ),
  )
  inspect(
    @data.get_active_time(Daggers),
    content=(
      #|0.05999999865889549
    ),
  )
  inspect(
    @data.get_active_time(Bow),
    content=(
      #|0.05000000074505806
    ),
  )
  inspect(
    @data.get_active_time(Staff),
    content=(
      #|0.07999999821186066
    ),
  )
}

///|
test "recovery time per weapon" {
  inspect(
    @data.get_recovery_time(Sword, 0),
    content=(
      #|0.15000000596046448
    ),
  )
  inspect(
    @data.get_recovery_time(Sword, 2),
    content=(
      #|0.25
    ),
  )
  inspect(
    @data.get_recovery_time(Daggers, 0),
    content=(
      #|0.07999999821186066
    ),
  )
  inspect(
    @data.get_recovery_time(Staff, 0),
    content=(
      #|0.30000001192092896
    ),
  )
}
