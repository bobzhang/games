///|
/// Returns the index of the minimum element under `less`, or `-1` when the array view is empty.
pub fn[T] min_index_by(items : ArrayView[T], less : (T, T) -> Bool) -> Int {
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
/// Returns the index of the maximum element under `greater`, or `-1` when the array view is empty.
pub fn[T] max_index_by(items : ArrayView[T], greater : (T, T) -> Bool) -> Int {
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
pub fn[T] first_index_by(items : ArrayView[T], pred : (T) -> Bool) -> Int {
  for i, item in items {
    if pred(item) {
      return i
    }
  }
  -1
}

///|
/// Returns the index of the first element satisfying the index-aware predicate `pred`, or `-1` when no element matches.
pub fn[T] first_indexi_by(items : ArrayView[T], pred : (Int, T) -> Bool) -> Int {
  for i, item in items {
    if pred(i, item) {
      return i
    }
  }
  -1
}

///|
/// Returns whether any element satisfies `pred`.
pub fn[T] any_by(items : ArrayView[T], pred : (T) -> Bool) -> Bool {
  first_index_by(items, pred) >= 0
}

///|
/// Returns the number of elements satisfying `pred`.
pub fn[T] count_by(items : ArrayView[T], pred : (T) -> Bool) -> Int {
  for item in items; count = 0 {
    if pred(item) {
      continue count + 1
    }
  } nobreak {
    count
  }
}
