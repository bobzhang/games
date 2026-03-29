///|
pub fn push_event(game : @types.Game, event : @types.GameEvent) -> Unit {
  game.events.push(event)
}

///|
pub fn clear_events(game : @types.Game) -> Unit {
  game.events.clear()
}
