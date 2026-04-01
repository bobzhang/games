///|
fn fi(i : Int) -> Float {
  Float::from_int(i)
}

///|
fn rect(x : Int, y : Int, w : Int, h : Int) -> @raylib.Rectangle {
  @raylib.Rectangle::new(fi(x), fi(y), fi(w), fi(h))
}

///|
fn vec2(x : Int, y : Int) -> @raylib.Vector2 {
  @raylib.Vector2::new(fi(x), fi(y))
}
