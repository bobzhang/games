///|
pub(all) enum Screen {
  Title
  MapSelect
  MechSelect
  Battle
  EnemyTurn
  Reward
  GameOver
  Victory
} derive(Eq, Show)

///|
pub(all) enum Command {
  Move(Int, Int)
  Attack(Int, Int, Int)
  Overclock(Int)
  Wait
  Push(Int, Int, Int)
} derive(Show)

///|
pub(all) enum Effect {
  Damage(Int)
  Push(Int, Int)
  Pull(Int, Int)
  Shield(Int)
  Heal(Int)
  Stun
  Spawn(Int, Int, Int)
  DestroyTile(Int, Int)
  ApplyHazard(Int, Int, Int)
} derive(Show)

///|
pub(all) enum Intent {
  March(Int, Int)
  FireLine(Int, Int, Int)
  Leap(Int, Int)
  AreaBlast(Int, Int, Int)
  Summon(Int, Int, Int)
  Charge(Int, Int)
  MinePlace(Int, Int)
} derive(Show)

///|
pub(all) enum Objective {
  DefendGrid(Int)
  Survive(Int)
  Assassinate(Int)
  CapturePoints(Int)
  Escort(Int, Int)
} derive(Eq, Show)

///|
pub(all) enum TileKind {
  Floor
  Wall
  Chasm
  Water
  Lava
  Ice
  ControlPoint
  SpawnPoint
} derive(Eq, Show)

///|
pub(all) enum UnitTeam {
  Player
  Enemy
} derive(Eq, Show)

///|
pub(all) enum MechClass {
  Vanguard
  Striker
  Sentinel
} derive(Eq, Show)

///|
pub(all) enum EnemyType {
  Rammer
  Artillery
  BeamTurret
  Leaper
  MineLayer
  ShieldDrone
  Splitter
  Boss
} derive(Eq, Show)

///|
pub(all) enum HazardKind {
  None
  Fire
  Acid
  Mine
  Smoke
} derive(Eq, Show)

///|
pub(all) enum Direction {
  North
  South
  East
  West
} derive(Eq, Show)

///|
pub(all) enum EffectKind {
  DamagePreview
  PushPreview
  PullPreview
  MovePreview
  HazardPreview
  KillPreview
  CollisionPreview
} derive(Eq, Show)
