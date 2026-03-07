///|
/// Returns the index of the minimum element under `less`, or `-1` when the array is empty.
pub fn[T] min_index_by(items : Array[T], less : (T, T) -> Bool) -> Int {
  guard items is [first, .. rest] else { return -1 }
  for i, item in rest; best = 0, best_item = first {
    if less(item, best_item) {
      continue i + 1, item
    }
  } nobreak {
    best
  }
}

///|
/// Returns the index of the maximum element under `greater`, or `-1` when the array is empty.
pub fn[T] max_index_by(items : Array[T], greater : (T, T) -> Bool) -> Int {
  guard items is [first, .. rest] else { return -1 }
  for i, item in rest; best = 0, best_item = first {
    if greater(item, best_item) {
      continue i + 1, item
    }
  } nobreak {
    best
  }
}

///|
/// Returns the index of the first element satisfying `pred`, or `-1` when no element matches.
pub fn[T] first_index_by(items : Array[T], pred : (T) -> Bool) -> Int {
  for i, item in items {
    if pred(item) {
      return i
    }
  }
  -1
}
