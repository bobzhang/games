///|
/// Apply a tool to a region. Returns true if the tool was consumed (even if it worsened).
pub fn apply_tool(region : @types.Region, tool : @types.ToolKind) -> Bool {
  // Cannot apply to already restored, sealed, or pristine regions
  match region.state {
    Pristine | Restored | Sealed => return false
    _ => ()
  }
  // Track the treatment
  region.treatments_applied.push(tool)
  match tool {
    Clean => apply_clean(region)
    Fill => apply_fill(region)
    Retouch => apply_retouch(region)
    Seal => apply_seal(region)
  }
  true
}

///|
/// Clean: removes Stains. If used on Crack -> worsens to Flake!
fn apply_clean(region : @types.Region) -> Unit {
  let has_stain = @types.region_has_damage(region, Stain)
  let has_crack = @types.region_has_damage(region, Crack)
  let has_flake = @types.region_has_damage(region, Flake)
  let has_fade = @types.region_has_damage(region, Fade)
  // If stain is permanent, cleaning does nothing useful
  if region.stain_permanent {
    region.state = Worsened
    return
  }
  if has_stain {
    // Check if cracks are still unrepaired - clean on crack worsens!
    if has_crack && !@types.region_has_treatment(region, Fill) {
      // Crack becomes Flake - worsen!
      replace_damage(region, Crack, Flake)
      region.state = Worsened
      return
    }
    // Stain cleaned successfully
    remove_damage(region, Stain)
    // Check if all damage handled
    if is_all_damage_treated(region) {
      region.state = Treated
    } else {
      region.state = Treated
    }
    return
  }
  // No stain - if there's a crack, using clean worsens it to flake
  if has_crack {
    replace_damage(region, Crack, Flake)
    region.state = Worsened
    return
  }
  // Clean on flake or fade - no direct harm but not useful
  if has_flake || has_fade {
    // Doesn't help, doesn't worsen for these
    region.state = Treated
    return
  }
  // Already treated/no applicable damage
  region.state = Treated
}

///|
/// Fill: repairs Cracks and Flakes. If used on Stain -> sets stain permanently!
fn apply_fill(region : @types.Region) -> Unit {
  let has_crack = @types.region_has_damage(region, Crack)
  let has_flake = @types.region_has_damage(region, Flake)
  let has_stain = @types.region_has_damage(region, Stain)
  if has_crack || has_flake {
    // Fill successfully addresses cracks and flakes
    if has_crack {
      remove_damage(region, Crack)
    }
    if has_flake {
      remove_damage(region, Flake)
      // Flake needs retouch after fill
    }
    // If also has stain, that's ok - fill doesn't worsen if there's structural damage
    if is_all_damage_treated(region) {
      region.state = Treated
    } else {
      region.state = Treated
    }
    return
  }
  // Fill on stain with no structural damage -> sets stain permanently
  if has_stain {
    region.stain_permanent = true
    region.state = Worsened
    return
  }
  // Fill on fade - not harmful, not helpful
  region.state = Treated
}

///|
/// Retouch: restores Fade. If used on Flake -> cosmetic only (fragile).
fn apply_retouch(region : @types.Region) -> Unit {
  let has_fade = @types.region_has_damage(region, Fade)
  let has_flake = @types.region_has_damage(region, Flake)
  if has_fade {
    remove_damage(region, Fade)
    if is_all_damage_treated(region) {
      region.state = Treated
    } else {
      region.state = Treated
    }
    return
  }
  // Retouch on unrepaired flake - cosmetic only, looks fixed but fragile
  if has_flake {
    remove_damage(region, Flake)
    region.fragile = true
    region.state = Treated
    return
  }
  // For previously filled flake regions, retouch is the correct next step
  region.state = Treated
}

///|
/// Seal: locks in restoration. Must be last step.
/// If used on unrepaired damage -> seals in the damage!
fn apply_seal(region : @types.Region) -> Unit {
  // Check if all damage has been properly addressed
  if region.damage_types.length() > 0 {
    // Still has unrepaired damage - seals in the damage
    region.state = Sealed
    return
  }
  // Check for bad states
  if region.state == Worsened {
    region.state = Sealed
    return
  }
  // Fragile regions that were cosmetically retouched
  if region.fragile {
    region.state = Sealed
    return
  }
  // Permanent stain sealed in
  if region.stain_permanent {
    region.state = Sealed
    return
  }
  // All damage addressed and no issues -> properly restored!
  region.state = Restored
}

///|
fn remove_damage(region : @types.Region, kind : @types.DamageKind) -> Unit {
  let new_damages : Array[@types.DamageKind] = []
  let mut removed_one = false
  for i in 0..<region.damage_types.length() {
    if region.damage_types[i] == kind && !removed_one {
      removed_one = true
    } else {
      new_damages.push(region.damage_types[i])
    }
  }
  // Replace the array contents
  while region.damage_types.length() > 0 {
    let _ = region.damage_types.pop()
  }
  for i in 0..<new_damages.length() {
    region.damage_types.push(new_damages[i])
  }
}

///|
fn replace_damage(
  region : @types.Region,
  old_kind : @types.DamageKind,
  new_kind : @types.DamageKind,
) -> Unit {
  let mut replaced = false
  for i in 0..<region.damage_types.length() {
    if region.damage_types[i] == old_kind && !replaced {
      region.damage_types[i] = new_kind
      replaced = true
    }
  }
}

///|
fn is_all_damage_treated(region : @types.Region) -> Bool {
  region.damage_types.length() == 0
}
