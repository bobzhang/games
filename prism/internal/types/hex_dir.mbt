///|
pub fn hex_dir_opposite(d : HexDir) -> HexDir {
  match d {
    E => W
    NE => SW
    NW => SE
    W => E
    SW => NE
    SE => NW
  }
}

///|
/// Rotate 60 degrees clockwise.
pub fn hex_dir_cw(d : HexDir) -> HexDir {
  match d {
    E => SE
    SE => SW
    SW => W
    W => NW
    NW => NE
    NE => E
  }
}

///|
/// Rotate 60 degrees counter-clockwise.
pub fn hex_dir_ccw(d : HexDir) -> HexDir {
  match d {
    E => NE
    NE => NW
    NW => W
    W => SW
    SW => SE
    SE => E
  }
}

///|
/// Axial coordinate deltas for flat-top hex neighbors.
/// E=(+1,0), NE=(+1,-1), NW=(0,-1), W=(-1,0), SW=(-1,+1), SE=(0,+1).
pub fn hex_dir_dq(d : HexDir) -> Int {
  match d {
    E => 1
    NE => 1
    NW => 0
    W => -1
    SW => -1
    SE => 0
  }
}

///|
pub fn hex_dir_dr(d : HexDir) -> Int {
  match d {
    E => 0
    NE => -1
    NW => -1
    W => 0
    SW => 1
    SE => 1
  }
}

///|
pub fn hex_dir_name(d : HexDir) -> String {
  match d {
    E => "E"
    NE => "NE"
    NW => "NW"
    W => "W"
    SW => "SW"
    SE => "SE"
  }
}

///|
pub fn hex_dir_index(d : HexDir) -> Int {
  match d {
    E => 0
    NE => 1
    NW => 2
    W => 3
    SW => 4
    SE => 5
  }
}

///|
pub fn index_to_hex_dir(i : Int) -> HexDir {
  match i % 6 {
    0 => E
    1 => NE
    2 => NW
    3 => W
    4 => SW
    _ => SE
  }
}

///|
/// Mirror reflection: incoming beam is reflected across the mirror axis.
/// Mirror facing direction defines its normal. The reflection sends
/// the beam back as if bouncing off the perpendicular axis.
pub fn mirror_reflect_hex(incoming : HexDir, facing : HexDir) -> HexDir {
  // The mirror normal is `facing`. A beam hitting from direction `incoming`
  // (which means it travels in direction `incoming`) reflects.
  // In hex, the reflection across axis `facing` can be computed by:
  // reflected = facing rotated by -(incoming - facing) = 2*facing - incoming
  let fi = hex_dir_index(facing)
  let ii = hex_dir_index(incoming)
  let reflected = ((2 * fi - ii) % 6 + 6) % 6
  index_to_hex_dir(reflected)
}

///|
/// Crystal refraction: deflect beam 60 degrees left or right.
pub fn crystal_refract(incoming : HexDir, face : CrystalFace) -> HexDir {
  match face {
    Left60 => hex_dir_ccw(incoming)
    Right60 => hex_dir_cw(incoming)
  }
}

///|
/// All six hex directions in order.
pub fn all_hex_dirs() -> Array[HexDir] {
  [E, NE, NW, W, SW, SE]
}
