///|
fn fi(i : Int32) -> Float {
  Float::from_int(i)
}

///|
fn rect(x : Int32, y : Int32, w : Int32, h : Int32) -> @raylib.Rectangle {
  @raylib.Rectangle::new(fi(x), fi(y), fi(w), fi(h))
}

///|
fn vec2(x : Int32, y : Int32) -> @raylib.Vector2 {
  @raylib.Vector2::new(fi(x), fi(y))
}
