///|
pub(all) struct EnemyStats {
  hp : Int
  speed : Float
  damage : Int
  attack_range : Float
  attack_cooldown : Float
  radius : Float
  sight_range : Float
  reward_gold : Int
}

///|
pub fn get_enemy_stats(
  kind : @types.EnemyKind,
  floor_num : Int
) -> EnemyStats {
  let floor_bonus = (floor_num - 1) * 2
  match kind {
    Slime =>
      {
        hp: 20 + floor_bonus * 2,
        speed: 100.0,
        damage: 8 + floor_bonus,
        attack_range: 30.0,
        attack_cooldown: 1.0,
        radius: 16.0,
        sight_range: 250.0,
        reward_gold: 5,
      }
    SlimeSmall =>
      {
        hp: 8 + floor_bonus,
        speed: 130.0,
        damage: 4 + floor_bonus / 2,
        attack_range: 20.0,
        attack_cooldown: 0.8,
        radius: 10.0,
        sight_range: 200.0,
        reward_gold: 2,
      }
    Skeleton =>
      {
        hp: 30 + floor_bonus * 3,
        speed: 120.0,
        damage: 12 + floor_bonus,
        attack_range: 40.0,
        attack_cooldown: 1.2,
        radius: 14.0,
        sight_range: 300.0,
        reward_gold: 8,
      }
    Archer =>
      {
        hp: 18 + floor_bonus * 2,
        speed: 90.0,
        damage: 10 + floor_bonus,
        attack_range: 280.0,
        attack_cooldown: 1.8,
        radius: 12.0,
        sight_range: 350.0,
        reward_gold: 10,
      }
    Bat =>
      {
        hp: 12 + floor_bonus,
        speed: 200.0,
        damage: 6 + floor_bonus,
        attack_range: 25.0,
        attack_cooldown: 0.6,
        radius: 10.0,
        sight_range: 400.0,
        reward_gold: 4,
      }
    Spider =>
      {
        hp: 25 + floor_bonus * 2,
        speed: 80.0,
        damage: 10 + floor_bonus,
        attack_range: 200.0,
        attack_cooldown: 2.0,
        radius: 16.0,
        sight_range: 200.0,
        reward_gold: 8,
      }
    Golem =>
      {
        hp: 80 + floor_bonus * 5,
        speed: 50.0,
        damage: 25 + floor_bonus * 2,
        attack_range: 60.0,
        attack_cooldown: 2.5,
        radius: 24.0,
        sight_range: 250.0,
        reward_gold: 20,
      }
  }
}
