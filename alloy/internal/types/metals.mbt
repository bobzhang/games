///|
/// Get the base properties of a metal.
pub fn metal_props(kind : MetalKind) -> MetalProps {
  match kind {
    Iron => { hardness: 80.0, flexibility: 20.0, conductivity: 30.0 }
    Copper => { hardness: 25.0, flexibility: 50.0, conductivity: 90.0 }
    Tin => { hardness: 15.0, flexibility: 85.0, conductivity: 40.0 }
    Gold => { hardness: 10.0, flexibility: 60.0, conductivity: 95.0 }
    Carbon => { hardness: 95.0, flexibility: 5.0, conductivity: 10.0 }
    Zinc => { hardness: 35.0, flexibility: 45.0, conductivity: 55.0 }
  }
}

///|
/// Get display name for a metal.
pub fn metal_name(kind : MetalKind) -> String {
  match kind {
    Iron => "Iron"
    Copper => "Copper"
    Tin => "Tin"
    Gold => "Gold"
    Carbon => "Carbon"
    Zinc => "Zinc"
  }
}

///|
/// Get display color for a metal.
pub fn metal_color(kind : MetalKind) -> @raylib.Color {
  match kind {
    Iron => color_iron
    Copper => color_copper
    Tin => color_tin
    Gold => color_gold
    Carbon => color_carbon
    Zinc => color_zinc
  }
}

///|
/// Get display name for a temperature setting.
pub fn temp_name(t : Temperature) -> String {
  match t {
    Low => "Low"
    Medium => "Medium"
    High => "High"
  }
}

///|
/// Get display color for a temperature setting.
pub fn temp_color(t : Temperature) -> @raylib.Color {
  match t {
    Low => color_temp_low
    Medium => color_temp_medium
    High => color_temp_high
  }
}

///|
/// Get description for temperature effect.
pub fn temp_description(t : Temperature) -> String {
  match t {
    Low => "Preserves properties as-is"
    Medium => "Standard blend averaging"
    High => "Amplifies hardness, reduces flexibility"
  }
}
