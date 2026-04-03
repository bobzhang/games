///|
pub fn validate_enclosure(
  grid : @types.Grid,
  enc : @types.Enclosure,
  all_enclosures : Array[@types.Enclosure],
) -> Array[String] {
  let messages : Array[String] = []
  match enc.species {
    None => return messages
    Some(sp) => {
      let needs = @types.species_needs(sp)
      let space = enc.cells.length()
      if space < needs.min_space {
        messages.push(
          "\{needs.name}: needs \{needs.min_space} space, has \{space}",
        )
      }
      let primary_count = count_terrain_in_enclosure(
        grid,
        enc,
        needs.terrain_primary,
      )
      if primary_count < needs.terrain_primary_count {
        let tname = @types.terrain_label(needs.terrain_primary)
        messages.push(
          "\{needs.name}: needs \{needs.terrain_primary_count} \{tname}, has \{primary_count}",
        )
      }
      match needs.terrain_secondary {
        Some(sec_terrain) =>
          if needs.terrain_secondary_count > 0 {
            let sec_count = count_terrain_in_enclosure(grid, enc, sec_terrain)
            if sec_count < needs.terrain_secondary_count {
              let tname = @types.terrain_label(sec_terrain)
              messages.push(
                "\{needs.name}: needs \{needs.terrain_secondary_count} \{tname}, has \{sec_count}",
              )
            }
          }
        None => ()
      }
      if needs.water_adjacent {
        let water_adj = count_water_adjacent(grid, enc)
        if water_adj < needs.water_adjacent_count {
          messages.push(
            "\{needs.name}: needs \{needs.water_adjacent_count} water-adjacent cells, has \{water_adj}",
          )
        }
      }
      if needs.fears_predators {
        let predator_too_close = check_predator_proximity(
          grid, enc, all_enclosures,
        )
        if predator_too_close {
          messages.push(
            "\{needs.name}: predator too close (need \{@types.predator_safe_distance} distance)",
          )
        }
      }
    }
  }
  messages
}

///|
fn check_predator_proximity(
  grid : @types.Grid,
  enc : @types.Enclosure,
  all_enclosures : Array[@types.Enclosure],
) -> Bool {
  ignore(grid)
  let safe_dist = @types.predator_safe_distance
  for other in all_enclosures {
    if other.id == enc.id {
      continue
    }
    match other.species {
      Some(sp) => {
        let needs = @types.species_needs(sp)
        if needs.is_predator {
          let dist = min_enclosure_distance(enc, other)
          if dist < safe_dist {
            return true
          }
        }
      }
      None => ()
    }
  }
  false
}

///|
fn min_enclosure_distance(a : @types.Enclosure, b : @types.Enclosure) -> Int {
  let mut min_dist = 999
  for ca in a.cells {
    for cb in b.cells {
      let dx = if ca.0 > cb.0 { ca.0 - cb.0 } else { cb.0 - ca.0 }
      let dy = if ca.1 > cb.1 { ca.1 - cb.1 } else { cb.1 - ca.1 }
      let dist = dx + dy
      if dist < min_dist {
        min_dist = dist
      }
    }
  }
  min_dist
}

///|
pub fn validate_level(
  grid : @types.Grid,
  level : @types.LevelDef,
  enclosures : Array[@types.Enclosure],
) -> @types.LevelResult {
  let result = @types.new_level_result()
  result.par_tiles = level.par_tiles
  result.tiles_used = count_tiles_used(grid) + count_fences_used(grid)
  let mut all_met = true
  let species_placed : Array[@types.Species] = []
  for enc in enclosures {
    match enc.species {
      Some(sp) => {
        species_placed.push(sp)
        let msgs = validate_enclosure(grid, enc, enclosures)
        if msgs.length() > 0 {
          all_met = false
          for m in msgs {
            result.messages.push(m)
          }
        }
      }
      None => ()
    }
  }
  for sp in level.species {
    if species_placed.contains(sp) == false {
      all_met = false
      let needs = @types.species_needs(sp)
      result.messages.push("\{needs.name}: not placed in any enclosure")
    }
  }
  let duplicate_check : Array[@types.Species] = []
  for sp in species_placed {
    if duplicate_check.contains(sp) {
      result.messages.push("Duplicate species in multiple enclosures")
    } else {
      duplicate_check.push(sp)
    }
  }
  result.all_needs_met = all_met
  if all_met {
    result.stars = One
    if result.tiles_used <= level.par_tiles {
      result.stars = Two
      let total_bonus = compute_bonus_space(grid, enclosures)
      if total_bonus >= level.bonus_space {
        result.stars = Three
        result.bonus_met = true
      }
    }
  }
  result
}

///|
fn compute_bonus_space(
  _grid : @types.Grid,
  enclosures : Array[@types.Enclosure],
) -> Int {
  let mut total = 0
  for enc in enclosures {
    match enc.species {
      Some(sp) => {
        let needs = @types.species_needs(sp)
        let extra = enc.cells.length() - needs.min_space
        if extra > 0 {
          total += extra
        }
      }
      None => ()
    }
  }
  total
}

///|
pub fn star_count(rating : @types.StarRating) -> Int {
  match rating {
    Zero => 0
    One => 1
    Two => 2
    Three => 3
  }
}
