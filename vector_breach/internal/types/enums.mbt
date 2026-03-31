///|
pub(all) enum Screen {
  Title
  MapSelect
  MechSelect
  Campaign
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

///|
pub(all) enum AugmentKind {
  ExtendedBarrel     // +1 range on ranged attacks
  HeavyFrame         // +2 max HP, -1 move range
  OverchargedPush    // push distance +1
  ShieldGenerator    // start each battle with 2 shield
  HeatSink           // +1 max heat capacity
  ChainLightning     // attacks chain to adjacent enemy for 1 damage
  VampireCore        // heal 1 HP on kill
  FortifiedGrid      // grid objectives take 1 less damage
  ReflexBoost        // first mech each turn gets +1 move range
  EmergencyRepair    // auto-heal 1 HP when below 25%
} derive(Eq, Show)

///|
pub(all) enum CampaignNodeKind {
  Mission(Int)       // mission def index
  Boss(Int)          // boss mission def index
  Rest               // heal opportunity
  Shop               // buy augments
} derive(Eq, Show)

///|
pub(all) enum RewardChoice {
  PickAugment(Int)   // index into offered augments
  RepairAll
  GainGridPower
} derive(Eq, Show)

///|
pub(all) enum AnimKind {
  AnimNone
  AnimMove
  AnimAttack
  AnimPush
  AnimDeath
  AnimIntentReveal
} derive(Eq, Show)
