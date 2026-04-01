///|
pub fn total_stars(stars : Array[StarRating]) -> Int {
  let mut total = 0
  for star in stars {
    total += star_rating_value(star)
  }
  total
}

///|
pub fn levels_completed(stars : Array[StarRating]) -> Int {
  let mut count = 0
  for star in stars {
    if star_rating_value(star) > 0 {
      count += 1
    }
  }
  count
}

///|
pub fn three_star_count(stars : Array[StarRating]) -> Int {
  let mut count = 0
  for star in stars {
    if star is Three {
      count += 1
    }
  }
  count
}

///|
pub fn progress_percent(stars : Array[StarRating]) -> Int {
  let completed = levels_completed(stars)
  completed * 100 / total_levels
}
