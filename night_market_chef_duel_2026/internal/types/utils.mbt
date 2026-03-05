///|
/// Convert an order slot index to its node y position.
pub fn order_node_y(slot : Int) -> Float {
  orders_y0 +
  Float::from_int(slot.clamp(min=0, max=max_orders - 1)) * orders_gap
}

///|
/// Return `(x, y)` position for a navigation node.
pub fn node_pos(node : NavNode) -> (Float, Float) {
  match node {
    OrderSlot(i) => (orders_x, order_node_y(i))
    PrepStation => (prep_x, prep_y)
    GrillStation => (grill_x, grill_y)
    WokStation => (wok_x, wok_y)
    PassStation => (pass_x, pass_y)
  }
}

///|
/// Human-readable label for a navigation node.
pub fn node_name(node : NavNode) -> String {
  match node {
    OrderSlot(i) => "Order #" + (i + 1).to_string()
    PrepStation => "Prep"
    GrillStation => "Grill"
    WokStation => "Wok"
    PassStation => "Serve Pass"
  }
}

///|
/// Return all navigation nodes for cursor traversal.
pub fn all_nav_nodes() -> Array[NavNode] {
  let nodes : Array[NavNode] = []
  for i in 0..<max_orders {
    nodes.push(OrderSlot(i))
  }
  nodes.push(PrepStation)
  nodes.push(GrillStation)
  nodes.push(WokStation)
  nodes.push(PassStation)
  nodes
}

///|
/// Human-readable dish name for UI text.
pub fn dish_name(dish : Dish) -> String {
  match dish {
    Skewers => "Skewers"
    Noodles => "Noodles"
    Squid => "Char Squid"
    FriedRice => "Fried Rice"
    DishNone => "None"
  }
}

///|
/// Cooking lane required for a given dish.
pub fn dish_lane(dish : Dish) -> Lane {
  match dish {
    Skewers | Squid => Grill
    Noodles | FriedRice | DishNone => Wok
  }
}

///|
/// Base score reward when a dish is served.
pub fn dish_base_reward(dish : Dish) -> Int {
  match dish {
    Skewers => 120
    Noodles => 140
    Squid => 170
    FriedRice => 160
    DishNone => 90
  }
}

///|
/// Prep progress required to finish prep phase.
pub fn dish_prep_need(dish : Dish) -> Float {
  match dish {
    Skewers => 3.2
    Noodles => 3.8
    Squid => 4.2
    FriedRice => 3.5
    DishNone => 3.0
  }
}

///|
/// Heat progress required to finish cook phase.
pub fn dish_cook_need(dish : Dish) -> Float {
  match dish {
    Skewers => 3.6
    Noodles => 3.2
    Squid => 4.0
    FriedRice => 3.7
    DishNone => 3.0
  }
}

///|
/// Clamp a float to the inclusive range `[lo, hi]`.
pub fn clampf(v : Float, lo : Float, hi : Float) -> Float {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
/// Return the larger of two float values.
pub fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
  }
}

///|
/// Uniform random float in `[lo, hi]`.
pub fn randf(lo : Float, hi : Float) -> Float {
  let r = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
/// Uniform random integer in `[lo, hi]`.
pub fn randi(lo : Int, hi : Int) -> Int {
  @raylib.get_random_value(lo, hi)
}
