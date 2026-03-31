///|
/// Clamps float value into inclusive range `[low, high]`.
pub fn clampf(v : Float, low : Float, high : Float) -> Float {
  if v < low {
    low
  } else if v > high {
    high
  } else {
    v
  }
}

///|
/// Linearly interpolates from `a` to `b` by factor `t`.
pub fn lerpf(a : Float, b : Float, t : Float) -> Float {
  a + (b - a) * t
}

///|
/// Integer interpolation helper based on float interpolation.
pub fn lerpi(a : Int, b : Int, t : Float) -> Int {
  (Float::from_int(a) + Float::from_int(b - a) * t).to_int()
}

// Smoothstep interpolation

// ========== Noise Functions ==========

// Hash function for noise generation

///|
fn hash_int(x_in : Int) -> Int {
  let mut x = x_in.reinterpret_as_uint()
  x = x ^ (x >> 16)
  x = x * 73244475U // 0x45d9f3b
  x = x ^ (x >> 16)
  x = x * 73244475U
  x = x ^ (x >> 16)
  let result = x.reinterpret_as_int()
  if result < 0 {
    -result
  } else {
    result
  }
}

// 2D hash combining two coordinates

///|
fn hash_2d(x : Int, z : Int) -> Int {
  hash_int(x * 374761393 + z * 668265263 + 1274126177)
}

// Simple noise function for terrain generation using sin/cos

// Value noise with smooth interpolation

///|
/// Bilinearly blended value noise sample for terrain generation.
pub fn value_noise_2d(x : Float, z : Float) -> Float {
  let ix = x.floor().to_int()
  let iz = z.floor().to_int()
  let fx = x - Float::from_int(ix)
  let fz = z - Float::from_int(iz)
  // Smoothstep interpolation factors
  let sx = fx * fx * (3.0 - 2.0 * fx)
  let sz = fz * fz * (3.0 - 2.0 * fz)
  // Hash corners to get pseudo-random values
  let v00 = Float::from_int(hash_2d(ix, iz) % 1000) / 1000.0
  let v10 = Float::from_int(hash_2d(ix + 1, iz) % 1000) / 1000.0
  let v01 = Float::from_int(hash_2d(ix, iz + 1) % 1000) / 1000.0
  let v11 = Float::from_int(hash_2d(ix + 1, iz + 1) % 1000) / 1000.0
  // Bilinear interpolation
  let top = lerpf(v00, v10, sx)
  let bottom = lerpf(v01, v11, sx)
  lerpf(top, bottom, sz) * 2.0 - 1.0
}

// Multi-octave noise for terrain

///|
/// Multi-octave fractal noise over value noise base.
pub fn fractal_noise_2d(x : Float, z : Float, octaves : Int) -> Float {
  let mut amplitude : Float = 1.0
  let mut frequency : Float = 1.0
  let mut value : Float = 0.0
  let mut max_val : Float = 0.0
  for i in 0..<octaves {
    value += value_noise_2d(x * frequency, z * frequency) * amplitude
    max_val += amplitude
    amplitude *= 0.5
    frequency *= 2.0
    ignore(i)
  }
  value / max_val
}

// 3D noise for cave generation

// Cave noise using 3D value noise approximation

///|
/// 3D cave-noise helper tuned for subterranean carving.
pub fn cave_noise_3d(x : Float, y : Float, z : Float) -> Float {
  let freq = cave_frequency
  let n1 = @math.sinf(x * freq + y * freq * 0.7) *
    @math.cosf(z * freq * 1.2 + y * freq * 0.5)
  let n2 = @math.sinf(x * freq * 1.5 + z * freq * 0.8 + 2.0) *
    @math.cosf(y * freq * 1.3 + 1.5)
  let n3 = @math.cosf(x * freq * 0.6 + y * freq * 1.1 + z * freq * 0.9 + 3.0) *
    0.5
  (n1 + n2 + n3) / 2.5
}

// Better noise combining multiple octaves

///|
/// Terrain height noise contribution at world `(wx, wz)`.
pub fn terrain_noise(wx : Float, wz : Float) -> Float {
  let freq = terrain_frequency
  let n1 = @math.sinf(wx * freq) * @math.cosf(wz * freq * 1.3) * 0.5
  let n2 = @math.sinf(wx * freq * 2.1 + 1.7) *
    @math.cosf(wz * freq * 1.9 + 0.8) *
    0.25
  let n3 = @math.sinf(wx * freq * 0.5 + 3.1) *
    @math.cosf(wz * freq * 0.7 + 2.3) *
    0.6
  let n4 = @math.cosf(wx * freq * 3.0 + wz * freq * 2.5) * 0.15
  n1 + n2 + n3 + n4
}

// Biome noise - determines which biome at a given position

// Temperature noise - for biome blending

///|
/// Temperature field noise used by biome selection.
pub fn temperature_noise(wx : Float, wz : Float) -> Float {
  let freq : Float = 0.005
  let n = @math.sinf(wx * freq + 10.0) * @math.cosf(wz * freq * 1.1 + 7.0)
  n * 0.5 + 0.5
}

// Moisture noise - for biome blending

///|
/// Moisture field noise used by biome selection.
pub fn moisture_noise(wx : Float, wz : Float) -> Float {
  let freq : Float = 0.006
  let n = @math.cosf(wx * freq + 3.0) * @math.sinf(wz * freq * 0.9 + 5.0)
  n * 0.5 + 0.5
}

// ========== Biome determination ==========

///|
/// Returns biome id for world coordinates `(wx, wz)`.
pub fn get_biome_at(wx : Int, wz : Int) -> Biome {
  let fx = Float::from_int(wx)
  let fz = Float::from_int(wz)
  let temp = temperature_noise(fx, fz)
  let moist = moisture_noise(fx, fz)
  if temp < 0.25 {
    Tundra
  } else if temp > 0.75 && moist < 0.3 {
    Desert
  } else if temp > 0.5 && moist > 0.6 {
    Swamp
  } else if moist > 0.5 {
    Forest
  } else if fractal_noise_2d(fx * 0.01, fz * 0.01, 2) > 0.3 {
    Mountains
  } else {
    Plains
  }
}

// Get terrain height considering biome

///|
/// Returns biome-specific terrain height at `(wx, wz)` for known biome id.
pub fn get_biome_terrain_height(wx : Int, wz : Int, biome : Biome) -> Int {
  let fx = Float::from_int(wx)
  let fz = Float::from_int(wz)
  let n = terrain_noise(fx, fz)
  let mut height_base : Float = Float::from_int(base_height)
  let mut amplitude : Float = terrain_amplitude
  match biome {
    Plains => {
      height_base = Float::from_int(base_height) + 2.0
      amplitude = 6.0
    }
    Forest => {
      height_base = Float::from_int(base_height) + 3.0
      amplitude = 10.0
    }
    Desert => {
      height_base = Float::from_int(base_height) - 1.0
      amplitude = 5.0
    }
    Mountains => {
      height_base = Float::from_int(base_height) + 10.0
      amplitude = 22.0
    }
    Tundra => {
      height_base = Float::from_int(base_height) + 1.0
      amplitude = 8.0
    }
    Swamp => {
      height_base = Float::from_int(base_height) - 2.0
      amplitude = 3.0
    }
  }
  let h = height_base + n * amplitude
  h.to_int().clamp(min=1, max=chunk_y - 10)
}

// ========== Terrain generation ==========

// Get height at a world position

// Determine if a tree should be placed at world position

///|
/// Returns whether a tree should spawn at `(wx, wz)` for a biome.
pub fn should_place_tree(wx : Int, wz : Int, biome : Biome) -> Bool {
  let fx = Float::from_int(wx)
  let fz = Float::from_int(wz)
  let v = @math.sinf(fx * 0.73 + 5.1) * @math.cosf(fz * 0.91 + 3.7)
  let v2 = @math.sinf(fx * 1.37 + fz * 0.53) * 0.5
  let combined = (v + v2) * 0.5
  let threshold : Float = match biome {
    Forest => 0.35
    Plains => 0.7
    Swamp => 0.5
    Tundra => 0.8
    _ => 999.0
  }
  combined > threshold
}

// Check if this spot should have a cave opening

///|
/// Returns whether `(wx, wy, wz)` should be carved as cave space.
pub fn is_cave(wx : Int, wy : Int, wz : Int) -> Bool {
  if wy < cave_min_height || wy > cave_max_height {
    return false
  }
  let fx = Float::from_int(wx)
  let fy = Float::from_int(wy)
  let fz = Float::from_int(wz)
  let n = cave_noise_3d(fx, fy, fz)
  let threshold = cave_threshold
  n.abs() > threshold
}

// Check if should generate ore at this position

///|
/// Returns whether ore block `ore` should spawn at `(wx, wy, wz)`.
pub fn should_place_ore(
  wx : Int,
  wy : Int,
  wz : Int,
  ore_type : Int,
  rng : Int,
) -> Bool {
  let fx = Float::from_int(wx)
  let fy = Float::from_int(wy)
  let fz = Float::from_int(wz)
  let hash = hash_int(wx * 7919 + wy * 104729 + wz * 15485863 + rng)
  let r = Float::from_int(hash % 10000) / 10000.0
  if ore_type == block_ore_iron {
    if wy < ore_iron_min_y || wy > ore_iron_max_y {
      return false
    }
    let ore_n = @math.sinf(fx * 0.3 + fy * 0.2 + fz * 0.25) * 0.5 + 0.5
    r < ore_iron_chance && ore_n > 0.6
  } else if ore_type == block_ore_gold {
    if wy < ore_gold_min_y || wy > ore_gold_max_y {
      return false
    }
    let ore_n = @math.cosf(fx * 0.25 + fy * 0.3 + fz * 0.2) * 0.5 + 0.5
    r < ore_gold_chance && ore_n > 0.65
  } else if ore_type == block_ore_diamond {
    if wy < ore_diamond_min_y || wy > ore_diamond_max_y {
      return false
    }
    let ore_n = @math.sinf(fx * 0.35 + fy * 0.15 + fz * 0.3 + 1.0) * 0.5 + 0.5
    r < ore_diamond_chance && ore_n > 0.7
  } else {
    false
  }
}

// Generate terrain for a single chunk

///|
/// Generates base terrain, caves, ores, and vegetation for a chunk.
pub fn generate_chunk_terrain(chunk : Chunk, game : Game) -> Unit {
  let base_wx = chunk.cx * chunk_x
  let base_wz = chunk.cz * chunk_z
  // Determine biome for chunk center
  let center_wx = base_wx + chunk_x / 2
  let center_wz = base_wz + chunk_z / 2
  let biome = get_biome_at(center_wx, center_wz)
  chunk.biome = biome

  for lz in 0..<chunk_z {
    for lx in 0..<chunk_x {
      let wx = base_wx + lx
      let wz = base_wz + lz
      let local_biome = get_biome_at(wx, wz)
      let height = get_biome_terrain_height(wx, wz, local_biome)
      // Fill blocks from bottom to height
      for y in 0..<chunk_y {
        if y == 0 {
          chunk.set_block(lx, y, lz, block_bedrock)
        } else if y < height - 4 {
          // Check for caves
          if is_cave(wx, y, wz) {
            chunk.set_block(lx, y, lz, block_air)
            // Check for ores
          } else if should_place_ore(
              wx,
              y,
              wz,
              block_ore_diamond,
              game.rng_state,
            ) {
            chunk.set_block(lx, y, lz, block_ore_diamond)
          } else if should_place_ore(
              wx,
              y,
              wz,
              block_ore_gold,
              game.rng_state + 1,
            ) {
            chunk.set_block(lx, y, lz, block_ore_gold)
          } else if should_place_ore(
              wx,
              y,
              wz,
              block_ore_iron,
              game.rng_state + 2,
            ) {
            chunk.set_block(lx, y, lz, block_ore_iron)
          } else {
            chunk.set_block(lx, y, lz, block_stone)
          }
        } else if y < height - 1 {
          // Sub-surface layer depends on biome
          if local_biome == Desert {
            chunk.set_block(lx, y, lz, block_sand)
          } else if local_biome == Tundra {
            chunk.set_block(lx, y, lz, block_gravel)
          } else {
            chunk.set_block(lx, y, lz, block_dirt)
          }
        } else if y == height - 1 {
          // Surface block varies by biome
          if local_biome == Desert {
            chunk.set_block(lx, y, lz, block_sand)
          } else if local_biome == Tundra {
            chunk.set_block(lx, y, lz, block_snow)
          } else if local_biome == Swamp {
            if height < base_height {
              chunk.set_block(lx, y, lz, block_clay)
            } else {
              chunk.set_block(lx, y, lz, block_grass)
            }
          } else if height < base_height - 2 {
            chunk.set_block(lx, y, lz, block_sand)
          } else if local_biome == Mountains && height > base_height + 18 {
            chunk.set_block(lx, y, lz, block_snow)
          } else {
            chunk.set_block(lx, y, lz, block_grass)
          }
        } else if y < base_height - 4 && y >= height {
          // Water fills low areas
          chunk.set_block(lx, y, lz, block_water)
        } else {
          chunk.set_block(lx, y, lz, block_air)
        }
      }
    }
  }

  // Place trees (second pass so we can check surface)
  for lz in 2..<(chunk_z - 2) {
    for lx in 2..<(chunk_x - 2) {
      let wx = base_wx + lx
      let wz = base_wz + lz
      let local_biome = get_biome_at(wx, wz)
      let height = get_biome_terrain_height(wx, wz, local_biome)
      let surface_block = chunk.get_block(lx, height - 1, lz)

      // Trees on grass
      if height >= base_height - 1 && should_place_tree(wx, wz, local_biome) {
        if surface_block == block_grass || surface_block == block_snow {
          // Place trunk (variable height)
          let trunk_height : Int = match local_biome {
            Forest => 5
            Tundra => 3
            _ => 4
          }
          for ty in 0..<trunk_height {
            chunk.set_block(lx, height + ty, lz, block_wood)
          }
          // Place leaves (sphere-ish)
          let leaf_base = height + trunk_height - 1
          for ly in 0..<3 {
            let radius = if ly == 2 { 1 } else { 2 }
            let neg_r = -radius
            for dz in neg_r..<=radius {
              for dx in neg_r..<=radius {
                let dist = Float::from_int(dx).abs() + Float::from_int(dz).abs()
                if dist.to_int() <= radius + 1 {
                  let tx = lx + dx
                  let tz = lz + dz
                  let ty = leaf_base + ly
                  if tx >= 0 &&
                    tx < chunk_x &&
                    tz >= 0 &&
                    tz < chunk_z &&
                    ty < chunk_y {
                    if chunk.get_block(tx, ty, tz) == block_air {
                      chunk.set_block(tx, ty, tz, block_leaves)
                    }
                  }
                }
              }
            }
          }
        }
      }

      // Cactus in desert
      if local_biome == Desert && surface_block == block_sand {
        let cactus_check = @math.sinf(Float::from_int(wx) * 1.3 + 2.5) *
          @math.cosf(Float::from_int(wz) * 0.9 + 1.7)
        if cactus_check > 0.75 {
          // Place a cactus (2-3 blocks tall)
          let cactus_h = if cactus_check > 0.85 { 3 } else { 2 }
          for cy in 0..<cactus_h {
            if height + cy < chunk_y {
              chunk.set_block(lx, height + cy, lz, block_cactus)
            }
          }
        }
      }

      // Flowers and tall grass in plains/forest
      if (local_biome == Plains || local_biome == Forest) &&
        surface_block == block_grass {
        let flower_check = @math.sinf(Float::from_int(wx) * 2.1 + 3.3) *
          @math.cosf(Float::from_int(wz) * 1.7 + 4.1)
        if flower_check > 0.7 && height < chunk_y {
          if flower_check > 0.85 {
            chunk.set_block(lx, height, lz, block_flower_red)
          } else if flower_check > 0.77 {
            chunk.set_block(lx, height, lz, block_flower_yellow)
          } else {
            chunk.set_block(lx, height, lz, block_tall_grass)
          }
        }
      }
    }
  }

  // ========== Structure placement (after terrain and vegetation) ==========
  generate_structures_in_chunk(chunk, game)
}

///|
/// Places POI structures (ruined camps, watchtowers, abandoned mines, shrines,
/// ore pockets) within a chunk based on deterministic hashing of chunk coords.
fn generate_structures_in_chunk(chunk : Chunk, game : Game) -> Unit {
  let base_wx = chunk.cx * chunk_x
  let base_wz = chunk.cz * chunk_z
  let seed = game.world_seed
  // Use deterministic hash from chunk coords + seed for structure placement
  let chunk_hash = hash_int(chunk.cx * 49157 + chunk.cz * 98317 + seed)
  let structure_roll = chunk_hash % 1000

  // Ruined camp: ~3-5 per world (roughly 1 in 15 chunks)
  if structure_roll < 65 {
    let cx_local = (chunk_hash / 7) % (chunk_x - 6) + 3
    let cz_local = (chunk_hash / 13) % (chunk_z - 6) + 3
    let wx = base_wx + cx_local
    let wz = base_wz + cz_local
    let local_biome = get_biome_at(wx, wz)
    let height = get_biome_terrain_height(wx, wz, local_biome)
    if height >= base_height - 2 && height < chunk_y - 5 {
      place_ruined_camp(chunk, cx_local, cz_local, height)
    }
  }

  // Watchtower: ~1-2 per world (roughly 1 in 35 chunks)
  let tower_roll = hash_int(chunk.cx * 73721 + chunk.cz * 33391 + seed + 1) % 1000
  if tower_roll < 30 {
    let tx = (tower_roll / 3) % (chunk_x - 4) + 2
    let tz = (tower_roll / 5) % (chunk_z - 4) + 2
    let wx = base_wx + tx
    let wz = base_wz + tz
    let local_biome = get_biome_at(wx, wz)
    let height = get_biome_terrain_height(wx, wz, local_biome)
    if height >= base_height && height < chunk_y - 15 {
      place_watchtower(chunk, tx, tz, height)
    }
  }

  // Abandoned mine entrance: ~1-2 per world (roughly 1 in 40 chunks)
  let mine_roll = hash_int(chunk.cx * 12289 + chunk.cz * 24593 + seed + 2) % 1000
  if mine_roll < 25 {
    let mx = (mine_roll / 3) % (chunk_x - 6) + 3
    let mz = (mine_roll / 7) % (chunk_z - 6) + 3
    let wx = base_wx + mx
    let wz = base_wz + mz
    let local_biome = get_biome_at(wx, wz)
    let height = get_biome_terrain_height(wx, wz, local_biome)
    if height >= base_height && height < chunk_y - 10 &&
      (local_biome == Mountains || local_biome == Plains || local_biome == Forest) {
      place_abandoned_mine(chunk, mx, mz, height)
    }
  }

  // Shrine: ~1 per world (roughly 1 in 60 chunks)
  let shrine_roll = hash_int(
    chunk.cx * 6151 + chunk.cz * 12343 + seed + 3,
  ) % 1000
  if shrine_roll < 16 {
    let sx = (shrine_roll / 3) % (chunk_x - 8) + 4
    let sz = (shrine_roll / 5) % (chunk_z - 8) + 4
    let wx = base_wx + sx
    let wz = base_wz + sz
    let local_biome = get_biome_at(wx, wz)
    let height = get_biome_terrain_height(wx, wz, local_biome)
    if height >= base_height - 1 && height < chunk_y - 5 {
      place_shrine(chunk, sx, sz, height)
    }
  }

  // Ore pocket: ~3-5 per world (roughly 1 in 13 chunks)
  let ore_roll = hash_int(chunk.cx * 3079 + chunk.cz * 7919 + seed + 4) % 1000
  if ore_roll < 75 {
    let ox = (ore_roll / 3) % (chunk_x - 4) + 2
    let oz = (ore_roll / 7) % (chunk_z - 4) + 2
    // Place deep underground between y=5 and y=25
    let oy = 5 + (ore_roll / 11) % 20
    place_ore_pocket(chunk, ox, oy, oz, ore_roll)
  }
}

///|
/// Places a ruined camp: small cleared area with campfire and 1-2 chests.
fn place_ruined_camp(chunk : Chunk, lx : Int, lz : Int, height : Int) -> Unit {
  // Clear area (3x3) and place floor
  let neg2 = -2
  for dz in neg2..<=2 {
    for dx in neg2..<=2 {
      let tx = lx + dx
      let tz = lz + dz
      if tx >= 0 && tx < chunk_x && tz >= 0 && tz < chunk_z {
        // Ground level
        chunk.set_block(tx, height - 1, tz, block_dirt)
        // Clear above
        for cy in height..<(height + 3) {
          if cy < chunk_y {
            chunk.set_block(tx, cy, tz, block_air)
          }
        }
      }
    }
  }
  // Place campfire in center
  if height < chunk_y {
    chunk.set_block(lx, height, lz, block_campfire)
  }
  // Place 1-2 chests nearby
  if lx + 1 < chunk_x && height < chunk_y {
    chunk.set_block(lx + 1, height, lz, block_chest)
  }
  if lz + 1 < chunk_z && height < chunk_y {
    chunk.set_block(lx, height, lz + 1, block_chest)
  }
  // Place some cobblestone seats
  if lx - 1 >= 0 && height < chunk_y {
    chunk.set_block(lx - 1, height, lz, block_cobblestone)
  }
  if lz - 1 >= 0 && height < chunk_y {
    chunk.set_block(lx, height, lz - 1, block_cobblestone)
  }
}

///|
/// Places a watchtower: tall stone/wood column with ladders and view platform.
fn place_watchtower(chunk : Chunk, lx : Int, lz : Int, height : Int) -> Unit {
  let tower_height = 10
  // Four corner pillars
  for dy in 0..<tower_height {
    let y = height + dy
    if y >= chunk_y {
      break
    }
    // Corner pillars (stone)
    if lx - 1 >= 0 && lz - 1 >= 0 {
      chunk.set_block(lx - 1, y, lz - 1, block_cobblestone)
    }
    if lx + 1 < chunk_x && lz - 1 >= 0 {
      chunk.set_block(lx + 1, y, lz - 1, block_cobblestone)
    }
    if lx - 1 >= 0 && lz + 1 < chunk_z {
      chunk.set_block(lx - 1, y, lz + 1, block_cobblestone)
    }
    if lx + 1 < chunk_x && lz + 1 < chunk_z {
      chunk.set_block(lx + 1, y, lz + 1, block_cobblestone)
    }
    // Ladder on center column
    chunk.set_block(lx, y, lz, block_ladder)
  }
  // View platform at top (3x3 planks)
  let top_y = height + tower_height
  if top_y < chunk_y {
    let neg1 = -1
    for dz in neg1..<=1 {
      for dx in neg1..<=1 {
        let tx = lx + dx
        let tz = lz + dz
        if tx >= 0 && tx < chunk_x && tz >= 0 && tz < chunk_z {
          chunk.set_block(tx, top_y, tz, block_planks)
        }
      }
    }
    // Railing (cobblestone edges)
    let neg1r = -1
    for d in neg1r..<=1 {
      if lx - 1 >= 0 && lz + d >= 0 && lz + d < chunk_z && top_y + 1 < chunk_y {
        chunk.set_block(lx - 1, top_y + 1, lz + d, block_cobblestone)
      }
      if lx + 1 < chunk_x && lz + d >= 0 && lz + d < chunk_z && top_y + 1 < chunk_y {
        chunk.set_block(lx + 1, top_y + 1, lz + d, block_cobblestone)
      }
      if lx + d >= 0 && lx + d < chunk_x && lz - 1 >= 0 && top_y + 1 < chunk_y {
        chunk.set_block(lx + d, top_y + 1, lz - 1, block_cobblestone)
      }
      if lx + d >= 0 && lx + d < chunk_x && lz + 1 < chunk_z && top_y + 1 < chunk_y {
        chunk.set_block(lx + d, top_y + 1, lz + 1, block_cobblestone)
      }
    }
    // Torch on top
    if top_y + 2 < chunk_y {
      chunk.set_block(lx, top_y + 1, lz, block_torch)
    }
  }
}

///|
/// Places an abandoned mine entrance: tunnel entrance with rails and exposed ore.
fn place_abandoned_mine(
  chunk : Chunk,
  lx : Int,
  lz : Int,
  height : Int,
) -> Unit {
  // Entrance: 3-wide, 3-tall opening going down into the ground
  let neg1 = -1
  for dx in neg1..<=1 {
    let tx = lx + dx
    if tx >= 0 && tx < chunk_x {
      // Clear entrance
      for dy in 0..<3 {
        let y = height + dy
        if y < chunk_y {
          chunk.set_block(tx, y, lz, block_air)
        }
      }
      // Support beams at entrance
      if dx == -1 || dx == 1 {
        chunk.set_block(tx, height, lz, block_wood)
        chunk.set_block(tx, height + 1, lz, block_wood)
        if height + 2 < chunk_y {
          chunk.set_block(tx, height + 2, lz, block_planks)
        }
      }
    }
  }
  // Tunnel going into the hillside (deeper z)
  for depth in 1..<=6 {
    let tz = lz + depth
    if tz >= chunk_z {
      break
    }
    for dx in neg1..<=1 {
      let tx = lx + dx
      if tx >= 0 && tx < chunk_x {
        for dy in 0..<3 {
          let y = height - depth + dy
          if y >= 1 && y < chunk_y {
            chunk.set_block(tx, y, tz, block_air)
          }
        }
      }
    }
    // Rails on floor
    let floor_y = height - depth
    if floor_y >= 1 && floor_y < chunk_y && lx >= 0 && lx < chunk_x && tz < chunk_z {
      chunk.set_block(lx, floor_y, tz, block_rail)
    }
    // Exposed ore in walls at deeper levels
    if depth >= 3 {
      let ore_y = height - depth + 1
      if ore_y >= 1 && ore_y < chunk_y {
        if lx - 1 >= 0 {
          chunk.set_block(lx - 1, ore_y, tz, block_ore_iron)
        }
        if depth >= 5 && lx + 1 < chunk_x {
          chunk.set_block(lx + 1, ore_y, tz, block_ore_gold)
        }
      }
    }
    // Torch every 3 blocks
    if depth % 3 == 0 {
      let torch_y = height - depth + 2
      if torch_y >= 1 && torch_y < chunk_y && lx + 1 < chunk_x {
        chunk.set_block(lx + 1, torch_y, tz, block_torch)
      }
    }
  }
}

///|
/// Places a shrine: stone circle with rare loot in center.
fn place_shrine(chunk : Chunk, lx : Int, lz : Int, height : Int) -> Unit {
  // Stone ring (radius 3)
  let radius = 3
  let neg_r = -radius
  for dz in neg_r..<=radius {
    for dx in neg_r..<=radius {
      let dist = Float::from_int(dx * dx + dz * dz).sqrt()
      let tx = lx + dx
      let tz = lz + dz
      if tx >= 0 && tx < chunk_x && tz >= 0 && tz < chunk_z {
        // Ring of shrine stones
        if dist >= 2.5 && dist <= 3.5 {
          if height < chunk_y {
            chunk.set_block(tx, height, tz, block_shrine_stone)
          }
          // Pillars at cardinal points
          if (dx == 0 && (dz == radius || dz == -radius)) ||
            (dz == 0 && (dx == radius || dx == -radius)) {
            if height + 1 < chunk_y {
              chunk.set_block(tx, height + 1, tz, block_shrine_stone)
            }
            if height + 2 < chunk_y {
              chunk.set_block(tx, height + 2, tz, block_torch)
            }
          }
        }
        // Clear interior
        if dist < 2.5 {
          for cy in height..<(height + 3) {
            if cy < chunk_y {
              chunk.set_block(tx, cy, tz, block_air)
            }
          }
        }
      }
    }
  }
  // Loot chest in center
  if height < chunk_y {
    chunk.set_block(lx, height, lz, block_chest)
  }
}

///|
/// Places a concentrated ore pocket underground.
fn place_ore_pocket(
  chunk : Chunk,
  lx : Int,
  ly : Int,
  lz : Int,
  roll : Int,
) -> Unit {
  // Determine ore type based on depth and roll
  let ore_type = if ly < 12 {
    if roll % 3 == 0 {
      block_ore_diamond
    } else {
      block_ore_gold
    }
  } else if ly < 20 {
    if roll % 2 == 0 {
      block_ore_gold
    } else {
      block_ore_iron
    }
  } else {
    block_ore_iron
  }
  // Place cluster of 4-8 ore blocks
  let count = 4 + roll % 5
  let neg1 = -1
  let mut placed = 0
  for dy in neg1..<=1 {
    for dz in neg1..<=1 {
      for dx in neg1..<=1 {
        if placed >= count {
          break
        }
        let tx = lx + dx
        let ty = ly + dy
        let tz = lz + dz
        if tx >= 0 &&
          tx < chunk_x &&
          ty >= 1 &&
          ty < chunk_y &&
          tz >= 0 &&
          tz < chunk_z {
          let existing = chunk.get_block(tx, ty, tz)
          if existing == block_stone {
            chunk.set_block(tx, ty, tz, ore_type)
            placed += 1
          }
        }
      }
    }
  }
}

// ========== World access helpers ==========

// Get chunk from world

// Get block at world coordinates

///|
/// Reads world block id at absolute coordinates, returning air out of bounds.
pub fn get_world_block(game : Game, wx : Int, wy : Int, wz : Int) -> Int {
  if wy < 0 || wy >= chunk_y {
    return block_air
  }
  let cx = if wx >= 0 { wx / chunk_x } else { (wx - chunk_x + 1) / chunk_x }
  let cz = if wz >= 0 { wz / chunk_z } else { (wz - chunk_z + 1) / chunk_z }
  if cx < 0 || cx >= world_chunks_x || cz < 0 || cz >= world_chunks_z {
    return block_air
  }
  let lx = wx - cx * chunk_x
  let lz = wz - cz * chunk_z
  game.chunks[cz * world_chunks_x + cx].get_block(lx, wy, lz)
}

// Set block at world coordinates

///|
/// Writes world block id at absolute coordinates if in bounds.
pub fn set_world_block(
  game : Game,
  wx : Int,
  wy : Int,
  wz : Int,
  block : Int,
) -> Unit {
  if wy < 0 || wy >= chunk_y {
    return
  }
  let cx = if wx >= 0 { wx / chunk_x } else { (wx - chunk_x + 1) / chunk_x }
  let cz = if wz >= 0 { wz / chunk_z } else { (wz - chunk_z + 1) / chunk_z }
  if cx < 0 || cx >= world_chunks_x || cz < 0 || cz >= world_chunks_z {
    return
  }
  let lx = wx - cx * chunk_x
  let lz = wz - cz * chunk_z
  let chunk = game.chunks[cz * world_chunks_x + cx]
  chunk.set_block(lx, wy, lz, block)
}

// Check if a block is solid (not air, not water, not flowers/grass)

///|
/// Returns whether a block id is considered collision-solid.
pub fn is_solid(block : Int) -> Bool {
  block != block_air &&
  block != block_water &&
  block != block_flower_red &&
  block != block_flower_yellow &&
  block != block_tall_grass &&
  block != block_ladder &&
  block != block_rail
}

// Check if a block is transparent (used for face culling)

///|
/// Returns whether a block id should be rendered as transparent/translucent.
pub fn is_transparent(block : Int) -> Bool {
  block == block_air ||
  block == block_water ||
  block == block_glass ||
  block == block_leaves ||
  block == block_flower_red ||
  block == block_flower_yellow ||
  block == block_tall_grass ||
  block == block_torch ||
  block == block_ladder ||
  block == block_rail ||
  block == block_campfire
}

// Check if a block is a decoration (flower, grass, torch)

///|
/// Returns whether a block id is decorative foliage/prop content.
pub fn is_decoration(block : Int) -> Bool {
  block == block_flower_red ||
  block == block_flower_yellow ||
  block == block_tall_grass ||
  block == block_torch ||
  block == block_ladder ||
  block == block_rail ||
  block == block_campfire
}

// Check if a block is affected by gravity

///|
/// Returns whether a block id is affected by gravity physics.
pub fn is_gravity_block(block : Int) -> Bool {
  block == block_sand || block == block_gravel
}

// Block name for UI display

///|
/// Returns display name for a block id.
pub fn block_name(kind : Int) -> String {
  if kind == block_air {
    "Air"
  } else if kind == block_dirt {
    "Dirt"
  } else if kind == block_grass {
    "Grass"
  } else if kind == block_stone {
    "Stone"
  } else if kind == block_wood {
    "Wood"
  } else if kind == block_leaves {
    "Leaves"
  } else if kind == block_water {
    "Water"
  } else if kind == block_sand {
    "Sand"
  } else if kind == block_glass {
    "Glass"
  } else if kind == block_brick {
    "Brick"
  } else if kind == block_ore_iron {
    "Iron Ore"
  } else if kind == block_ore_gold {
    "Gold Ore"
  } else if kind == block_ore_diamond {
    "Diamond Ore"
  } else if kind == block_snow {
    "Snow"
  } else if kind == block_gravel {
    "Gravel"
  } else if kind == block_planks {
    "Planks"
  } else if kind == block_cobblestone {
    "Cobblestone"
  } else if kind == block_torch {
    "Torch"
  } else if kind == block_bedrock {
    "Bedrock"
  } else if kind == block_flower_red {
    "Red Flower"
  } else if kind == block_flower_yellow {
    "Yellow Flower"
  } else if kind == block_tall_grass {
    "Tall Grass"
  } else if kind == block_cactus {
    "Cactus"
  } else if kind == block_clay {
    "Clay"
  } else if kind == item_stick {
    "Stick"
  } else if kind == item_workbench {
    "Workbench"
  } else if kind == item_furnace {
    "Furnace"
  } else if kind == item_iron_ingot {
    "Iron Ingot"
  } else if kind == item_coal {
    "Coal"
  } else if kind == block_chest {
    "Chest"
  } else if kind == block_ladder {
    "Ladder"
  } else if kind == block_rail {
    "Rail"
  } else if kind == block_campfire {
    "Campfire"
  } else if kind == block_shrine_stone {
    "Shrine Stone"
  } else if kind == item_rotten_flesh {
    "Rotten Flesh"
  } else if kind == item_bone {
    "Bone"
  } else if kind == item_string {
    "String"
  } else if kind == item_arrow {
    "Arrow"
  } else if kind == item_raw_meat {
    "Raw Meat"
  } else if kind == item_cooked_meat {
    "Cooked Meat"
  } else {
    "Unknown"
  }
}

// Get tool name

///|
/// Returns display name for a tool id.
pub fn tool_name(kind : Int) -> String {
  if kind == tool_hand {
    "Hand"
  } else if kind == tool_wooden_pickaxe {
    "Wood Pick"
  } else if kind == tool_stone_pickaxe {
    "Stone Pick"
  } else if kind == tool_iron_pickaxe {
    "Iron Pick"
  } else if kind == tool_wooden_axe {
    "Wood Axe"
  } else if kind == tool_stone_axe {
    "Stone Axe"
  } else if kind == tool_iron_axe {
    "Iron Axe"
  } else if kind == tool_wooden_shovel {
    "Wood Shovel"
  } else if kind == tool_stone_shovel {
    "Stone Shovel"
  } else if kind == tool_iron_shovel {
    "Iron Shovel"
  } else if kind == tool_wooden_sword {
    "Wood Sword"
  } else if kind == tool_stone_sword {
    "Stone Sword"
  } else if kind == tool_iron_sword {
    "Iron Sword"
  } else {
    "Unknown"
  }
}

// Get entity type name

///|
/// Returns display name for an entity/mob id.
pub fn entity_name(kind : Int) -> String {
  if kind == entity_pig {
    "Pig"
  } else if kind == entity_cow {
    "Cow"
  } else if kind == entity_chicken {
    "Chicken"
  } else if kind == entity_zombie {
    "Zombie"
  } else if kind == entity_skeleton {
    "Skeleton"
  } else if kind == entity_spider {
    "Spider"
  } else {
    "Unknown"
  }
}

// Get biome name

///|
/// Returns display name for a biome id.
pub fn biome_name(kind : Biome) -> String {
  match kind {
    Plains => "Plains"
    Forest => "Forest"
    Desert => "Desert"
    Mountains => "Mountains"
    Tundra => "Tundra"
    Swamp => "Swamp"
  }
}

///|
/// Returns whether an item id represents a tool.
pub fn is_tool_item(id : Int) -> Bool {
  id == tool_wooden_pickaxe ||
  id == tool_stone_pickaxe ||
  id == tool_iron_pickaxe ||
  id == tool_wooden_axe ||
  id == tool_stone_axe ||
  id == tool_iron_axe ||
  id == tool_wooden_shovel ||
  id == tool_stone_shovel ||
  id == tool_iron_shovel ||
  id == tool_wooden_sword ||
  id == tool_stone_sword ||
  id == tool_iron_sword
}

///|
/// Returns the total count of an item across all inventory slots.
pub fn Inventory::count_item(self : Inventory, item_id : Int) -> Int {
  let mut total = 0
  for i in 0..<inventory_slots {
    if self.slots[i].item_id == item_id && self.slots[i].count > 0 {
      total += self.slots[i].count
    }
  }
  total
}

///|
/// Removes up to `count` items from inventory, deducting across multiple slots.
/// Returns the number actually removed.
pub fn Inventory::remove_item(
  self : Inventory,
  item_id : Int,
  count : Int,
) -> Int {
  let mut remaining = count
  for i in 0..<inventory_slots {
    if remaining <= 0 {
      break
    }
    if self.slots[i].item_id == item_id && self.slots[i].count > 0 {
      let take = if self.slots[i].count < remaining {
        self.slots[i].count
      } else {
        remaining
      }
      self.slots[i].count -= take
      remaining -= take
      if self.slots[i].count <= 0 {
        self.slots[i].item_id = 0
        self.slots[i].count = 0
      }
    }
  }
  count - remaining
}

///|
/// Returns true if the inventory has room for the given item and count.
pub fn Inventory::has_space_for(
  self : Inventory,
  item_id : Int,
  count : Int,
) -> Bool {
  let mut remaining = count
  // Check existing stacks
  for i in 0..<inventory_slots {
    if remaining <= 0 {
      return true
    }
    if self.slots[i].item_id == item_id &&
      self.slots[i].count > 0 &&
      self.slots[i].count < stack_max {
      let can_add = stack_max - self.slots[i].count
      remaining -= can_add
    }
  }
  if remaining <= 0 {
    return true
  }
  // Check empty slots
  for i in 0..<inventory_slots {
    if remaining <= 0 {
      return true
    }
    if self.slots[i].count <= 0 {
      remaining -= stack_max
    }
  }
  remaining <= 0
}

// Get mining time for a block with a given tool

///|
/// Returns mining duration (seconds) for block/tool pair.
pub fn get_mining_time(block : Int, tool : Int) -> Float {
  let base : Float = if block == block_dirt ||
    block == block_sand ||
    block == block_clay {
    mine_speed_dirt
  } else if block == block_grass || block == block_gravel {
    mine_speed_grass
  } else if block == block_stone || block == block_cobblestone {
    mine_speed_stone
  } else if block == block_wood || block == block_planks {
    mine_speed_wood
  } else if block == block_leaves {
    mine_speed_leaves
  } else if block == block_glass {
    mine_speed_glass
  } else if block == block_brick {
    mine_speed_brick
  } else if block == block_ore_iron ||
    block == block_ore_gold ||
    block == block_ore_diamond {
    mine_speed_ore
  } else if block == block_bedrock {
    mine_speed_bedrock
  } else if block == block_snow {
    mine_speed_dirt
  } else {
    1.0
  }
  // Tool multipliers
  let mult : Float = if tool == tool_hand {
    1.0
  } else if tool == tool_wooden_pickaxe ||
    tool == tool_wooden_axe ||
    tool == tool_wooden_shovel {
    0.6
  } else if tool == tool_stone_pickaxe ||
    tool == tool_stone_axe ||
    tool == tool_stone_shovel {
    0.4
  } else if tool == tool_iron_pickaxe ||
    tool == tool_iron_axe ||
    tool == tool_iron_shovel {
    0.25
  } else {
    1.0
  }
  base * mult
}

///|
/// Returns the tool tier: 0=hand, 1=wood, 2=stone, 3=iron.
pub fn get_tool_tier(tool : Int) -> Int {
  if tool == tool_wooden_pickaxe ||
    tool == tool_wooden_axe ||
    tool == tool_wooden_shovel ||
    tool == tool_wooden_sword {
    1
  } else if tool == tool_stone_pickaxe ||
    tool == tool_stone_axe ||
    tool == tool_stone_shovel ||
    tool == tool_stone_sword {
    2
  } else if tool == tool_iron_pickaxe ||
    tool == tool_iron_axe ||
    tool == tool_iron_shovel ||
    tool == tool_iron_sword {
    3
  } else {
    0
  }
}

///|
/// Returns the minimum pickaxe tier needed to mine a block.
/// 0 = hand, 1 = wood pick, 2 = stone pick, 3 = iron pick.
/// Returns -1 if not an ore/hard block needing a pickaxe.
pub fn required_pick_tier(block : Int) -> Int {
  if block == block_stone || block == block_cobblestone {
    1
  } else if block == block_ore_iron {
    2
  } else if block == block_ore_gold || block == block_ore_diamond {
    3
  } else {
    0
  }
}

///|
/// Returns whether a tool can mine a specific block at all.
/// Wrong pickaxe tier for ore means the block won't drop.
pub fn can_mine_block(tool : Int, block : Int) -> Bool {
  let required = required_pick_tier(block)
  if required <= 0 {
    return true
  }
  // Need a pickaxe for stone/ore blocks
  let is_pick = tool == tool_wooden_pickaxe ||
    tool == tool_stone_pickaxe ||
    tool == tool_iron_pickaxe
  if !is_pick {
    return false
  }
  get_tool_tier(tool) >= required
}

///|
/// Returns mining speed multiplier based on tool vs block match.
/// Wrong tool = 4x slower. Correct tool class = bonus speed.
pub fn mining_speed_multiplier(tool : Int, block : Int) -> Float {
  let is_pick = tool == tool_wooden_pickaxe ||
    tool == tool_stone_pickaxe ||
    tool == tool_iron_pickaxe
  let is_axe_t = tool == tool_wooden_axe ||
    tool == tool_stone_axe ||
    tool == tool_iron_axe
  let is_shovel_t = tool == tool_wooden_shovel ||
    tool == tool_stone_shovel ||
    tool == tool_iron_shovel
  // Determine best tool class for block
  let block_wants_pick = block == block_stone ||
    block == block_cobblestone ||
    block == block_ore_iron ||
    block == block_ore_gold ||
    block == block_ore_diamond ||
    block == block_brick
  let block_wants_axe = block == block_wood || block == block_planks
  let block_wants_shovel = block == block_dirt ||
    block == block_grass ||
    block == block_sand ||
    block == block_gravel ||
    block == block_clay ||
    block == block_snow
  if tool == tool_hand {
    return 1.0
  }
  // Matching tool class bonus
  if block_wants_pick && is_pick {
    return 1.0
  }
  if block_wants_axe && is_axe_t {
    return 1.0
  }
  if block_wants_shovel && is_shovel_t {
    return 1.0
  }
  // Wrong tool for this block = penalty
  if block_wants_pick && !is_pick {
    return 4.0
  }
  if block_wants_axe && !is_axe_t {
    return 2.0
  }
  if block_wants_shovel && !is_shovel_t {
    return 2.0
  }
  1.0
}

///|
/// Returns whether the player is near a placed workbench block.
pub fn is_near_workbench(game : Game) -> Bool {
  let px = game.player.x.to_int()
  let py = game.player.y.to_int()
  let pz = game.player.z.to_int()
  let range = station_proximity.to_int()
  let neg_r = -range
  for dy in neg_r..<=range {
    for dz in neg_r..<=range {
      for dx in neg_r..<=range {
        let b = get_world_block(game, px + dx, py + dy, pz + dz)
        if b == item_workbench {
          return true
        }
      }
    }
  }
  false
}

///|
/// Returns whether the player is near a placed furnace block.
pub fn is_near_furnace(game : Game) -> Bool {
  let px = game.player.x.to_int()
  let py = game.player.y.to_int()
  let pz = game.player.z.to_int()
  let range = station_proximity.to_int()
  let neg_r = -range
  for dy in neg_r..<=range {
    for dz in neg_r..<=range {
      for dx in neg_r..<=range {
        let b = get_world_block(game, px + dx, py + dy, pz + dz)
        if b == item_furnace {
          return true
        }
      }
    }
  }
  false
}

///|
/// Returns whether a block is placeable (includes workbench, furnace, chest).
pub fn is_placeable_item(id : Int) -> Bool {
  id == item_workbench || id == item_furnace
}

// Get drop from breaking a block

///|
/// Returns dropped item id when a block is mined.
pub fn get_block_drop(block : Int) -> Int {
  if block == block_stone {
    block_cobblestone
  } else if block == block_grass {
    block_dirt
  } else if block == block_leaves {
    block_air
  } else if block == block_bedrock {
    block_air
  } else if block == block_tall_grass ||
    block == block_flower_red ||
    block == block_flower_yellow {
    block_air
  } else if block == block_campfire {
    item_coal
  } else if block == block_shrine_stone {
    block_stone
  } else if block == block_rail ||
    block == block_ladder {
    block_air
  } else {
    block
  }
}

// Check if entity is hostile

///|
/// Returns whether an entity kind is hostile toward player.
pub fn is_hostile(kind : Int) -> Bool {
  kind == entity_zombie || kind == entity_skeleton || kind == entity_spider
}

// Get max health for entity type

///|
/// Returns max health value for a given entity kind.
pub fn get_entity_max_health(kind : Int) -> Int {
  if kind == entity_pig {
    pig_health
  } else if kind == entity_cow {
    cow_health
  } else if kind == entity_chicken {
    chicken_health
  } else if kind == entity_zombie {
    zombie_health
  } else if kind == entity_skeleton {
    skeleton_health
  } else if kind == entity_spider {
    spider_health
  } else {
    10
  }
}

// RNG

///|
/// Advances game RNG and returns next pseudo-random integer.
pub fn rand_next(game : Game) -> Int {
  let mut x = game.rng_state
  x = x ^ (x << 13)
  x = x ^ (x >> 17)
  x = x ^ (x << 5)
  if x < 0 {
    x = -x
  }
  game.rng_state = x
  x
}

// Random float 0..1

///|
/// Returns random float in `[0, 1)`.
pub fn rand_float(game : Game) -> Float {
  let r = rand_next(game)
  Float::from_int(r % 10000) / 10000.0
}

// Random int in range [low, high)

// Show temporary message

///|
/// Shows a temporary gameplay message on HUD.
pub fn show_message(game : Game, text : String, duration : Float) -> Unit {
  game.message_text = text
  game.message_timer = duration
}

// Check if a face of a block is visible (neighbor is transparent)

///|
/// Returns whether face adjacent to block at `(wx, wy, wz)` should be visible.
pub fn is_face_visible(game : Game, wx : Int, wy : Int, wz : Int) -> Bool {
  let block = get_world_block(game, wx, wy, wz)
  is_transparent(block)
}

// Spawn a particle

///|
/// Spawns one particle with explicit position, velocity, color, lifetime, and size.
pub fn spawn_particle(
  game : Game,
  px : Float,
  py : Float,
  pz : Float,
  pvx : Float,
  pvy : Float,
  pvz : Float,
  r : Int,
  g : Int,
  b : Int,
  size : Float,
  lifetime : Float,
) -> Unit {
  for i in 0..<particle_max {
    if !game.particles[i].active {
      let p = game.particles[i]
      p.active = true
      p.x = px
      p.y = py
      p.z = pz
      p.vx = pvx
      p.vy = pvy
      p.vz = pvz
      p.color_r = r
      p.color_g = g
      p.color_b = b
      p.size = size
      p.lifetime = lifetime
      p.max_lifetime = lifetime
      return
    }
  }
}

// Spawn block break particles (color provided by caller)

///|
/// Spawns a burst of break particles centered on a broken block.
pub fn spawn_break_particles(
  game : Game,
  wx : Int,
  wy : Int,
  wz : Int,
  r : Int,
  g : Int,
  b : Int,
) -> Unit {
  let cx = Float::from_int(wx) + 0.5
  let cy = Float::from_int(wy) + 0.5
  let cz = Float::from_int(wz) + 0.5
  for i in 0..<8 {
    let angle = Float::from_int(i) * 0.785
    let speed : Float = 2.0 + Float::from_int(i % 3)
    let pvx = @math.cosf(angle) * speed
    let pvy : Float = 3.0 + Float::from_int(i % 2) * 2.0
    let pvz = @math.sinf(angle) * speed
    spawn_particle(game, cx, cy, cz, pvx, pvy, pvz, r, g, b, 0.12, 0.8)
  }
}

// Distance between two 3D points

///|
/// Computes 3D Euclidean distance.
pub fn distance3d(
  x1 : Float,
  y1 : Float,
  z1 : Float,
  x2 : Float,
  y2 : Float,
  z2 : Float,
) -> Float {
  let dx = x2 - x1
  let dy = y2 - y1
  let dz = z2 - z1
  (dx * dx + dy * dy + dz * dz).sqrt()
}

// Horizontal distance (xz plane)

///|
/// Computes horizontal (`x/z`) distance.
pub fn distance_xz(x1 : Float, z1 : Float, x2 : Float, z2 : Float) -> Float {
  @math.hypotf(x2 - x1, z2 - z1)
}

// Direction facing text

///|
/// Returns cardinal-facing label based on yaw angle.
pub fn facing_direction(yaw : Float) -> String {
  let normalized = (yaw + two_pi) % two_pi
  if normalized < 0.393 || normalized > 5.89 {
    "North"
  } else if normalized < 1.178 {
    "NE"
  } else if normalized < 1.963 {
    "East"
  } else if normalized < 2.749 {
    "SE"
  } else if normalized < 3.534 {
    "South"
  } else if normalized < 4.32 {
    "SW"
  } else if normalized < 5.105 {
    "West"
  } else {
    "NW"
  }
}

// ========== Tool durability helpers ==========

///|
/// Returns the maximum durability for a given tool id.
pub fn get_tool_max_durability(tool : Int) -> Int {
  if tool == tool_wooden_pickaxe ||
    tool == tool_wooden_axe ||
    tool == tool_wooden_shovel ||
    tool == tool_wooden_sword {
    durability_wood
  } else if tool == tool_stone_pickaxe ||
    tool == tool_stone_axe ||
    tool == tool_stone_shovel ||
    tool == tool_stone_sword {
    durability_stone
  } else if tool == tool_iron_pickaxe ||
    tool == tool_iron_axe ||
    tool == tool_iron_shovel ||
    tool == tool_iron_sword {
    durability_iron
  } else {
    0 // Hand has no durability
  }
}

// ========== Inventory full check ==========

///|
/// Returns true when every inventory slot is occupied with non-empty stacks.
pub fn Inventory::is_full(self : Inventory) -> Bool {
  for i in 0..<inventory_slots {
    if self.slots[i].count <= 0 {
      return false
    }
    if self.slots[i].count < stack_max {
      return false
    }
  }
  true
}

// ========== Damage number spawning ==========

///|
/// Spawns a floating damage number at the given world position.
pub fn spawn_damage_number(
  game : Game,
  x : Float,
  y : Float,
  z : Float,
  amount : Int,
  r : Int,
  g : Int,
  b : Int,
) -> Unit {
  for i in 0..<damage_number_max {
    if !game.damage_numbers[i].active {
      let dn = game.damage_numbers[i]
      dn.active = true
      dn.x = x
      dn.y = y
      dn.z = z
      dn.amount = amount
      dn.timer = 1.5
      dn.color_r = r
      dn.color_g = g
      dn.color_b = b
      return
    }
  }
}

// ========== Mining crack particles ==========

///|
/// Spawns a few small particles around the mined block as cracks progress.
pub fn spawn_mining_crack_particles(
  game : Game,
  wx : Int,
  wy : Int,
  wz : Int,
  r : Int,
  g : Int,
  b : Int,
) -> Unit {
  let cx = Float::from_int(wx) + 0.5
  let cy = Float::from_int(wy) + 0.5
  let cz = Float::from_int(wz) + 0.5
  for i in 0..<3 {
    let angle = Float::from_int(i) * 2.1 + rand_float(game) * 1.0
    let speed : Float = 1.0 + rand_float(game) * 1.5
    let pvx = @math.cosf(angle) * speed
    let pvy : Float = 1.5 + rand_float(game) * 1.5
    let pvz = @math.sinf(angle) * speed
    spawn_particle(game, cx, cy, cz, pvx, pvy, pvz, r, g, b, 0.06, 0.4)
  }
}
