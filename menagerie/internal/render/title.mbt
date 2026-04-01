///|
fn draw_title(game : @types.Game) -> Unit {
  ignore(game)
  let sw = @types.screen_width
  // Title text
  let title = "MENAGERIE"
  let tw = @draw.measure_text(title, 64)
  @draw.draw_text(title, (sw - tw) / 2, 180, 64, @types.color_title)
  // Subtitle
  let sub = "Zoo Habitat Design Puzzle"
  let sub_w = @draw.measure_text(sub, 24)
  @draw.draw_text(sub, (sw - sub_w) / 2, 260, 24, @types.color_hud_text)
  // Prompt
  let prompt = "Press SPACE or ENTER to start"
  let pw = @draw.measure_text(prompt, 20)
  @draw.draw_text(prompt, (sw - pw) / 2, 440, 20, @types.color_warning)
  // Instructions
  let inst1 = "Design habitats for zoo animals"
  let i1w = @draw.measure_text(inst1, 18)
  @draw.draw_text(inst1, (sw - i1w) / 2, 520, 18, @types.color_hud_text)
  let inst2 = "Each species has unique terrain and space needs"
  let i2w = @draw.measure_text(inst2, 18)
  @draw.draw_text(inst2, (sw - i2w) / 2, 548, 18, @types.color_hud_text)
}
