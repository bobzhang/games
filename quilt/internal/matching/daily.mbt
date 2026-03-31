///|
pub fn date_hash(year : Int, month : Int, day : Int) -> Int {
  let mut h = year * 10000 + month * 100 + day
  h = h * 1103515245 + 12345
  let v = h / 65536
  if v < 0 {
    -v
  } else {
    v
  }
}

///|
pub fn generate_daily_board(seed : Int) -> (@types.Board, Array[@types.Patch]) {
  @types.seed_rng(seed)
  let size = 4
  let board = @types.new_board(size)
  let patterns = @types.all_patterns()
  let pat_count = patterns.length()
  // Generate a solved board first
  let solved : Array[@types.Patch] = []
  for row in 0..<size {
    for col in 0..<size {
      // For each cell, choose edges that match neighbors
      let n : @types.EdgePattern = if row > 0 {
        solved[(row - 1) * size + col].edges[2]
      } else {
        patterns[@types.rng_int(pat_count)]
      }
      let w : @types.EdgePattern = if col > 0 {
        solved[row * size + (col - 1)].edges[1]
      } else {
        patterns[@types.rng_int(pat_count)]
      }
      let e = patterns[@types.rng_int(pat_count)]
      let s = patterns[@types.rng_int(pat_count)]
      solved.push(@types.new_patch(n, e, s, w))
    }
  }
  // Shuffle into tray with random rotations
  let tray : Array[@types.Patch] = []
  let indices : Array[Int] = []
  let total = size * size
  for i in 0..<total {
    indices.push(i)
  }
  // Fisher-Yates shuffle
  for i = indices.length() - 1; i > 0; i = i - 1 {
    let j = @types.rng_int(i + 1)
    let tmp = indices[i]
    indices[i] = indices[j]
    indices[j] = tmp
  }
  for i in 0..<indices.length() {
    let mut pa = solved[indices[i]]
    let rots = @types.rng_int(4)
    for _r in 0..<rots {
      pa = @types.rotate_patch(pa)
    }
    tray.push(pa)
  }
  (board, tray)
}
