///|
pub(all) struct BiomeTheme {
  wall_color : @raylib.Color
  floor_color : @raylib.Color
  floor_alt_color : @raylib.Color
  accent_color : @raylib.Color
  name : String
}

///|
/// Return the biome theme for a given floor number.
pub fn get_biome(floor_num : Int) -> BiomeTheme {
  if floor_num <= 5 {
    // Stone Crypt  --  dark purple-gray tones
    {
      wall_color: @raylib.Color::new(55, 50, 62, 255),
      floor_color: @raylib.Color::new(38, 35, 45, 255),
      floor_alt_color: @raylib.Color::new(42, 38, 48, 255),
      accent_color: @raylib.Color::new(80, 70, 90, 255),
      name: "Stone Crypt",
    }
  } else if floor_num <= 10 {
    // Fungal Caverns  --  damp greens
    {
      wall_color: @raylib.Color::new(30, 55, 40, 255),
      floor_color: @raylib.Color::new(25, 42, 35, 255),
      floor_alt_color: @raylib.Color::new(28, 46, 38, 255),
      accent_color: @raylib.Color::new(60, 120, 80, 255),
      name: "Fungal Caverns",
    }
  } else if floor_num <= 15 {
    // Molten Depths  --  warm reds and oranges
    {
      wall_color: @raylib.Color::new(65, 30, 20, 255),
      floor_color: @raylib.Color::new(45, 22, 18, 255),
      floor_alt_color: @raylib.Color::new(50, 25, 20, 255),
      accent_color: @raylib.Color::new(180, 80, 30, 255),
      name: "Molten Depths",
    }
  } else {
    // Abyssal Void  --  deep blues and blacks
    {
      wall_color: @raylib.Color::new(20, 25, 55, 255),
      floor_color: @raylib.Color::new(15, 18, 40, 255),
      floor_alt_color: @raylib.Color::new(18, 22, 45, 255),
      accent_color: @raylib.Color::new(60, 80, 180, 255),
      name: "Abyssal Void",
    }
  }
}
