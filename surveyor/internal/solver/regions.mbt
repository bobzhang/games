///|
pub fn has_fence_between(
  fences : Array[@types.FenceEdge],
  x1 : Int,
  y1 : Int,
  x2 : Int,
  y2 : Int,
) -> Bool {
  // Moving right: vertical fence at (y1, x2, Vertical)
  if x2 == x1 + 1 && y2 == y1 {
    return @types.has_fence(fences, @types.make_fence(y1, x2, Vertical))
  }
  // Moving left: vertical fence at (y1, x1, Vertical)
  if x2 == x1 - 1 && y2 == y1 {
    return @types.has_fence(fences, @types.make_fence(y1, x1, Vertical))
  }
  // Moving down: horizontal fence at (y2, x1, Horizontal)
  if y2 == y1 + 1 && x2 == x1 {
    return @types.has_fence(fences, @types.make_fence(y2, x1, Horizontal))
  }
  // Moving up: horizontal fence at (y1, x1, Horizontal)
  if y2 == y1 - 1 && x2 == x1 {
    return @types.has_fence(fences, @types.make_fence(y1, x1, Horizontal))
  }
  true // different cells not adjacent => treat as blocked
}

///|
pub fn flood_fill_regions(
  grid : @types.Grid,
  fences : Array[@types.FenceEdge],
) -> Array[@types.Region] {
  let w = grid.width
  let h = grid.height
  let total = w * h
  let visited : Array[Bool] = Array::new(capacity=total)
  for _i in 0..<total {
    visited.push(false)
  }
  let regions : Array[@types.Region] = []
  for y in 0..<h {
    for x in 0..<w {
      if !visited[y * w + x] {
        // BFS from this cell
        let tiles : Array[@types.Vec2i] = []
        let queue : Array[@types.Vec2i] = [@types.vec2i(x, y)]
        visited[y * w + x] = true
        while queue.length() > 0 {
          let cur = queue[0]
          // Remove first element by shifting
          for k in 1..<queue.length() {
            queue[k - 1] = queue[k]
          }
          let _ = queue.pop()
          tiles.push(cur)
          // Check 4 neighbors
          let dirs : Array[@types.Vec2i] = [
            @types.vec2i(1, 0),
            @types.vec2i(-1, 0),
            @types.vec2i(0, 1),
            @types.vec2i(0, -1),
          ]
          for d in 0..<dirs.length() {
            let nx = cur.x + dirs[d].x
            let ny = cur.y + dirs[d].y
            if nx >= 0 && nx < w && ny >= 0 && ny < h && !visited[ny * w + nx] {
              if !has_fence_between(fences, cur.x, cur.y, nx, ny) {
                visited[ny * w + nx] = true
                queue.push(@types.vec2i(nx, ny))
              }
            }
          }
        }
        // Build region info
        let houses : Array[@types.House] = []
        let mut has_road = false
        for i in 0..<tiles.length() {
          let t = tiles[i]
          match @types.grid_get(grid, t.x, t.y) {
            House(cid) => houses.push(@types.make_house(t.x, t.y, cid, 0))
            Road => has_road = true
            _ => ()
          }
        }
        regions.push({ tiles, houses, has_road, area: tiles.length(), })
      }
    }
  }
  regions
}

///|
pub fn find_region_for_tile(
  regions : Array[@types.Region],
  x : Int,
  y : Int,
) -> Int {
  for i in 0..<regions.length() {
    let r = regions[i]
    for j in 0..<r.tiles.length() {
      if r.tiles[j].x == x && r.tiles[j].y == y {
        return i
      }
    }
  }
  -1
}
