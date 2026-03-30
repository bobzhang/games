///|
test "skeleton stats at floor 1" {
  let stats = @data.get_enemy_stats(Skeleton, 1)
  inspect(
    stats.hp,
    content=(
      #|30
    ),
  )
  inspect(
    stats.speed,
    content=(
      #|120
    ),
  )
  inspect(
    stats.damage,
    content=(
      #|12
    ),
  )
  inspect(
    stats.reward_gold,
    content=(
      #|8
    ),
  )
}

///|
test "enemy stats scale with floor" {
  let floor1 = @data.get_enemy_stats(Skeleton, 1)
  let floor5 = @data.get_enemy_stats(Skeleton, 5)
  let floor10 = @data.get_enemy_stats(Skeleton, 10)
  inspect(
    floor1.hp < floor5.hp && floor5.hp < floor10.hp,
    content=(
      #|true
    ),
  )
}

///|
test "slime stats scale with floor" {
  let floor1 = @data.get_enemy_stats(Slime, 1)
  let floor5 = @data.get_enemy_stats(Slime, 5)
  inspect(
    floor1.hp,
    content=(
      #|20
    ),
  )
  inspect(
    floor5.hp,
    content=(
      #|36
    ),
  )
  inspect(
    floor1.damage < floor5.damage,
    content=(
      #|true
    ),
  )
}

///|
test "golem is tankier than slime" {
  let golem = @data.get_enemy_stats(Golem, 1)
  let slime = @data.get_enemy_stats(Slime, 1)
  inspect(
    golem.hp > slime.hp,
    content=(
      #|true
    ),
  )
  inspect(
    golem.speed < slime.speed,
    content=(
      #|true
    ),
  )
}

///|
test "boss BroodMother has high HP" {
  let boss = @data.get_enemy_stats(BroodMother, 5)
  inspect(
    boss.hp >= 500,
    content=(
      #|true
    ),
  )
  inspect(
    boss.hp,
    content=(
      #|580
    ),
  )
  inspect(
    boss.reward_gold,
    content=(
      #|100
    ),
  )
}

///|
test "boss LichKing stats" {
  let lich = @data.get_enemy_stats(LichKing, 1)
  inspect(
    lich.hp,
    content=(
      #|800
    ),
  )
  inspect(
    lich.reward_gold,
    content=(
      #|200
    ),
  )
  inspect(
    lich.attack_range,
    content=(
      #|300
    ),
  )
}

///|
test "bat is fastest enemy" {
  let bat = @data.get_enemy_stats(Bat, 1)
  let skeleton = @data.get_enemy_stats(Skeleton, 1)
  let golem = @data.get_enemy_stats(Golem, 1)
  inspect(
    bat.speed > skeleton.speed,
    content=(
      #|true
    ),
  )
  inspect(
    bat.speed > golem.speed,
    content=(
      #|true
    ),
  )
}

///|
test "archer has long attack range" {
  let archer = @data.get_enemy_stats(Archer, 1)
  let skeleton = @data.get_enemy_stats(Skeleton, 1)
  inspect(
    archer.attack_range > skeleton.attack_range,
    content=(
      #|true
    ),
  )
  inspect(
    archer.attack_range,
    content=(
      #|280
    ),
  )
}

///|
test "floor scaling formula" {
  // At floor 1, floor_bonus = 0; at floor 3, floor_bonus = 4
  let f1 = @data.get_enemy_stats(Skeleton, 1)
  let f3 = @data.get_enemy_stats(Skeleton, 3)
  inspect(
    f1.hp,
    content=(
      #|30
    ),
  )
  inspect(
    f3.hp,
    content=(
      #|42
    ),
  )
  inspect(
    f3.hp - f1.hp,
    content=(
      #|12
    ),
  )
}
