///|
test "total_stars_empty" {
  let stars : Array[@types.StarRating] = Array::make(20, None)
  inspect(@types.total_stars(stars), content="0")
}

///|
test "total_stars_mixed" {
  let stars : Array[@types.StarRating] = Array::make(20, None)
  stars[0] = Three
  stars[1] = Two
  stars[2] = One
  inspect(@types.total_stars(stars), content="6")
}

///|
test "levels_completed_none" {
  let stars : Array[@types.StarRating] = Array::make(20, None)
  inspect(@types.levels_completed(stars), content="0")
}

///|
test "levels_completed_some" {
  let stars : Array[@types.StarRating] = Array::make(20, None)
  stars[0] = One
  stars[5] = Two
  stars[10] = Three
  inspect(@types.levels_completed(stars), content="3")
}

///|
test "three_star_count" {
  let stars : Array[@types.StarRating] = Array::make(20, None)
  stars[0] = Three
  stars[1] = Three
  stars[2] = Two
  stars[3] = One
  inspect(@types.three_star_count(stars), content="2")
}

///|
test "progress_percent_zero" {
  let stars : Array[@types.StarRating] = Array::make(20, None)
  inspect(@types.progress_percent(stars), content="0")
}

///|
test "progress_percent_half" {
  let stars : Array[@types.StarRating] = Array::make(20, None)
  for i in 0..<10 {
    stars[i] = One
  }
  inspect(@types.progress_percent(stars), content="50")
}

///|
test "progress_percent_all" {
  let stars : Array[@types.StarRating] = Array::make(20, None)
  for i in 0..<20 {
    stars[i] = Three
  }
  inspect(@types.progress_percent(stars), content="100")
}
