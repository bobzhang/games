///|
/// Compute sine of a Float value (wraps @math.sin which takes Double).
fn sinf(v : Float) -> Float {
  Float::from_double(@math.sin(v.to_double()))
}
