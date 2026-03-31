///|
pub fn check_targets(game : @types.Game) -> Bool {
  for i in 0..<game.targets.length() {
    let target = game.targets[i]
    if target.tree_index < 0 || target.tree_index >= game.trees.length() {
      return false
    }
    if game.trees[target.tree_index].height < target.required_height {
      return false
    }
  }
  true
}

///|
pub fn target_met(game : @types.Game, target_index : Int) -> Bool {
  if target_index < 0 || target_index >= game.targets.length() {
    return false
  }
  let target = game.targets[target_index]
  if target.tree_index < 0 || target.tree_index >= game.trees.length() {
    return false
  }
  game.trees[target.tree_index].height >= target.required_height
}

///|
pub fn calculate_stars(game : @types.Game) -> Int {
  if !check_targets(game) {
    return 0
  }
  // 1 star: all targets met
  let mut stars = 1
  // 2 stars: within par prunes
  if game.prunes_used <= game.par_prunes {
    stars = 2
  }
  // 3 stars: par prunes AND par turns
  if game.prunes_used <= game.par_prunes && game.turn <= game.par_turns {
    stars = 3
  }
  stars
}

///|
pub fn check_win_or_lose(game : @types.Game) -> Unit {
  if check_targets(game) {
    game.play_state = Won
  } else if game.turn >= game.turn_limit {
    game.play_state = Lost
  }
}
