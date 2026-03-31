///|
/// Compute a ghost preview: grow the tree 1-2 turns ahead to show the player
/// what will happen without pruning.
pub fn compute_preview(
  g : @types.TreeGrid,
  species : @types.Species,
  turns : Int
) -> @types.TreeGrid {
  let mut current = @types.clone_grid(g)
  for _i in 0..<turns {
    current = grow_one_turn(current, species)
  }
  current
}

///|
/// Compute a single turn preview
pub fn preview_one_turn(
  g : @types.TreeGrid,
  species : @types.Species
) -> @types.TreeGrid {
  compute_preview(g, species, 1)
}

///|
/// Compute a two turn preview
pub fn preview_two_turns(
  g : @types.TreeGrid,
  species : @types.Species
) -> @types.TreeGrid {
  compute_preview(g, species, 2)
}
