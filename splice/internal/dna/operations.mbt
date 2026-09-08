///|
pub fn cut(seq : Array[@types.Base], pos : Int) -> Array[@types.Base] {
  if pos < 0 || pos >= seq.length() {
    return @types.copy_sequence(seq)
  }
  let result : Array[@types.Base] = Array::new(capacity=seq.length() - 1)
  for i in 0..<seq.length() {
    if i != pos {
      result.push(seq[i])
    }
  }
  result
}

///|
pub fn insert(
  seq : Array[@types.Base],
  pos : Int,
  base : @types.Base,
) -> Array[@types.Base] {
  let p = if pos < 0 {
    0
  } else if pos > seq.length() {
    seq.length()
  } else {
    pos
  }
  let result : Array[@types.Base] = Array::new(capacity=seq.length() + 1)
  for i in 0..<p {
    result.push(seq[i])
  }
  result.push(base)
  for i in p..<seq.length() {
    result.push(seq[i])
  }
  result
}

///|
pub fn duplicate(
  seq : Array[@types.Base],
  start : Int,
  end : Int,
) -> Array[@types.Base] {
  let s = if start < 0 { 0 } else { start }
  let e = if end > seq.length() { seq.length() } else { end }
  if s >= e {
    return @types.copy_sequence(seq)
  }
  let result : Array[@types.Base] = Array::new(capacity=seq.length() + e - s)
  for i in 0..<e {
    result.push(seq[i])
  }
  // Insert duplicate
  for i in s..<e {
    result.push(seq[i])
  }
  for i in e..<seq.length() {
    result.push(seq[i])
  }
  result
}

///|
pub fn invert(
  seq : Array[@types.Base],
  start : Int,
  end : Int,
) -> Array[@types.Base] {
  let s = if start < 0 { 0 } else { start }
  let e = if end > seq.length() { seq.length() } else { end }
  if s >= e {
    return @types.copy_sequence(seq)
  }
  let result : Array[@types.Base] = Array::new(capacity=seq.length())
  for i in 0..<s {
    result.push(seq[i])
  }
  // Reversed range
  let mut i = e - 1
  while i >= s {
    result.push(seq[i])
    i -= 1
  }
  for i in e..<seq.length() {
    result.push(seq[i])
  }
  result
}

///|
pub fn delete(
  seq : Array[@types.Base],
  start : Int,
  end : Int,
) -> Array[@types.Base] {
  let s = if start < 0 { 0 } else { start }
  let e = if end > seq.length() { seq.length() } else { end }
  if s >= e {
    return @types.copy_sequence(seq)
  }
  let result : Array[@types.Base] = Array::new(capacity=seq.length() - (e - s))
  for i in 0..<s {
    result.push(seq[i])
  }
  for i in e..<seq.length() {
    result.push(seq[i])
  }
  result
}

///|
pub fn get_removed(
  seq : Array[@types.Base],
  start : Int,
  end : Int,
) -> Array[@types.Base] {
  let s = if start < 0 { 0 } else { start }
  let e = if end > seq.length() { seq.length() } else { end }
  let result : Array[@types.Base] = []
  for i in s..<e {
    result.push(seq[i])
  }
  result
}
