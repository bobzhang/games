///|
/// Compute weighted-average blend of ingredients in the crucible,
/// then apply temperature modifiers.
pub fn blend(
  ingredients : Array[@types.Ingredient],
  temperature : @types.Temperature,
) -> @types.BlendResult {
  if ingredients.is_empty() {
    return { hardness: 0.0, flexibility: 0.0, conductivity: 0.0, }
  }
  let mut total_h : Float = 0.0
  let mut total_f : Float = 0.0
  let mut total_c : Float = 0.0
  let mut total_weight : Float = 0.0
  for i in 0..<ingredients.length() {
    let ing = ingredients[i]
    let props = @types.metal_props(ing.metal)
    let w = Float::from_int(ing.amount)
    total_h += props.hardness * w
    total_f += props.flexibility * w
    total_c += props.conductivity * w
    total_weight += w
  }
  // Weighted average
  let avg_h = total_h / total_weight
  let avg_f = total_f / total_weight
  let avg_c = total_c / total_weight
  // Apply temperature modifiers
  let result = apply_temperature(avg_h, avg_f, avg_c, temperature)
  result
}

///|
/// Temperature modifiers:
/// - Low: properties preserved (slight reduction of 5% toward 50)
/// - Medium: standard blend (no modification)
/// - High: hardness amplified +15%, flexibility reduced -15%
fn apply_temperature(
  h : Float,
  f : Float,
  c : Float,
  temp : @types.Temperature,
) -> @types.BlendResult {
  match temp {
    Low => {
      // Slight damping toward center (preserves properties)
      let damp : Float = 0.95
      let center : Float = 50.0
      let hh = center + (h - center) * damp
      let ff = center + (f - center) * damp
      let cc = center + (c - center) * damp
      {
        hardness: @types.clampf(hh, 0.0, 100.0),
        flexibility: @types.clampf(ff, 0.0, 100.0),
        conductivity: @types.clampf(cc, 0.0, 100.0),
      }
    }
    Medium =>
      {
        hardness: @types.clampf(h, 0.0, 100.0),
        flexibility: @types.clampf(f, 0.0, 100.0),
        conductivity: @types.clampf(c, 0.0, 100.0),
      }
    High => {
      // Amplify hardness, reduce flexibility
      let boost : Float = 1.15
      let reduce : Float = 0.85
      {
        hardness: @types.clampf(h * boost, 0.0, 100.0),
        flexibility: @types.clampf(f * reduce, 0.0, 100.0),
        conductivity: @types.clampf(c, 0.0, 100.0),
      }
    }
  }
}

///|
/// Check if a blend result meets the target alloy requirements.
pub fn check_target(
  result : @types.BlendResult,
  target : @types.TargetAlloy,
) -> Bool {
  in_range(result.hardness, target.hardness) &&
  in_range(result.flexibility, target.flexibility) &&
  in_range(result.conductivity, target.conductivity)
}

///|
/// Check if a value is within a property range.
pub fn in_range(value : Float, range : @types.PropertyRange) -> Bool {
  value >= range.min && value <= range.max
}

///|
/// Compute distance from blend result to center of target ranges.
/// Lower is better. Used for 3-star scoring.
pub fn distance_to_center(
  result : @types.BlendResult,
  target : @types.TargetAlloy,
) -> Float {
  let hc = (target.hardness.min + target.hardness.max) / 2.0
  let fc = (target.flexibility.min + target.flexibility.max) / 2.0
  let cc = (target.conductivity.min + target.conductivity.max) / 2.0
  let dh = result.hardness - hc
  let df = result.flexibility - fc
  let dc = result.conductivity - cc
  let sum = dh * dh + df * df + dc * dc
  Float::from_double(sum.to_double().sqrt())
}

///|
/// Calculate star rating based on blend quality.
/// 1 star: all properties in range
/// 2 star: at or below par ingredients
/// 3 star: par ingredients AND close to target center
pub fn calculate_stars(
  result : @types.BlendResult,
  target : @types.TargetAlloy,
  ingredients_used : Int,
  par_ingredients : Int,
) -> @types.StarRating {
  if !check_target(result, target) {
    return Zero
  }
  let at_par = ingredients_used <= par_ingredients
  if at_par {
    // Check closeness to center for 3 stars
    let dist = distance_to_center(result, target)
    let threshold : Float = 12.0
    if dist < threshold {
      Three
    } else {
      Two
    }
  } else {
    One
  }
}
