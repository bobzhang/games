///|
pub fn find_hint(
  tablet : @types.Tablet,
  current : @types.Mapping,
) -> @types.Symbol? {
  // Find an unmapped symbol that appears in the inscription
  // Prioritize symbols that appear most frequently
  let inscription = tablet.inscription
  let needed = @types.get_inscription_symbols_unique(inscription)
  // Count frequency of each unmapped symbol
  let mut best_sym : @types.Symbol? = None
  let mut best_freq = 0
  for i in 0..<needed.length() {
    let sym = needed[i]
    let si = @types.symbol_index(sym)
    // Skip already correctly mapped or given symbols
    if current.values[si] >= 0 {
      continue
    }
    if @types.is_given_symbol(tablet, sym) {
      continue
    }
    // Count occurrences
    let mut freq = 0
    for j in 0..<inscription.symbols.length() {
      match inscription.symbols[j].symbol {
        Some(s) => if s == sym { freq += 1 }
        None => ()
      }
    }
    if freq > best_freq {
      best_freq = freq
      best_sym = Some(sym)
    }
  }
  best_sym
}

///|
pub fn get_hint_letter(tablet : @types.Tablet, sym : @types.Symbol) -> Int {
  @types.mapping_get(tablet.solution_mapping, sym)
}
