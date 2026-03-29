///|
pub(all) enum GameState {
  Title
  Playing
  Paused
  GameOver
  Victory
  MetaScreen
} derive(Eq)

///|
pub(all) enum MetaUpgrade {
  StartingHpUp
  StartingShieldUp
  StartingGold
  WeaponMastery
  DashMastery
  PotionEfficiency
} derive(Eq, Show)

///|
pub(all) enum RoomState {
  Idle
  Sealed
  Cleared
} derive(Eq)

///|
pub(all) enum WeaponKind {
  Sword
  Daggers
  Bow
  Staff
} derive(Eq, Show)

///|
pub(all) enum EnemyKind {
  Slime
  SlimeSmall
  Skeleton
  Archer
  Bat
  Spider
  Golem
  BroodMother
  LichKing
} derive(Eq, Show)

///|
pub(all) enum ItemKind {
  HealthPotion
  WeaponPickup(WeaponKind)
  Gold(Int)
  PassiveItem(PassiveKind)
} derive(Show)

///|
pub(all) enum PassiveKind {
  MaxHpUp
  DamageUp
  SpeedUp
  CritUp
  DashCooldownDown
  DefenseUp
  AttackSpeedUp
  PickupRange
  LifeSteal
  Thorns
  Berserker
  GlassCannon
  Vampiric
  ChainLightning
} derive(Eq, Show)

///|
pub(all) enum RoomKind {
  Start
  Combat
  Treasure
  Boss
  Corridor
  Shrine
  EliteVault
  Challenge
} derive(Eq, Show)

///|
pub(all) enum EncounterType {
  Standard
  Swarm
  SniperNest
  BossRush
  SurvivalWave
  PoisonNest
  Ambush
} derive(Eq, Show)

///|
pub fn encounter_name(encounter : EncounterType) -> String {
  match encounter {
    Standard => "COMBAT!"
    Swarm => "SWARM!"
    SniperNest => "SNIPER NEST!"
    BossRush => "ELITE RUSH!"
    SurvivalWave => "SURVIVAL WAVE!"
    PoisonNest => "POISON NEST!"
    Ambush => "AMBUSH!"
  }
}

///|
pub(all) enum ShrineKind {
  BloodAltar
  HealingSpring
  GambleShrine
  CursedChest
  ReforgeAnvil
} derive(Eq, Show)

///|
pub(all) enum Direction {
  Up
  Down
  Left
  Right
} derive(Eq, Show)

///|
pub(all) enum GameEvent {
  Hit(Float, Float, Int, Bool)
  Kill(EnemyKind, Float, Float)
  PlayerDamaged(Int, Float, Float)
  Pickup(ItemKind, Float, Float)
  RoomCleared
  BossPhaseChange(Int)
  DashUsed(Float, Float, Float, Float)
  WeaponSwing(Float, Float, Float)
  SynergyUnlocked(String)
} derive(Show)

///|
pub(all) enum AttackState {
  Idle
  Windup(Float)
  Active(Float)
  Recovery(Float)
} derive(Eq)

///|
pub(all) enum EnemyState {
  Idle
  Patrol
  Chase
  Attack(Float)
  Hurt(Float)
  Dead(Float)
} derive(Eq)

///|
pub(all) enum StatusEffect {
  Slow(Float)
  Poison(Float)
  Shield(Float)
  Haste(Float)
} derive(Show)

///|
pub(all) enum EliteAffix {
  None
  Fast
  Armored
  Splitting
  Vampiric
  Explosive
} derive(Eq, Show)
