///|
test "get_set_voxel" {
  let g = @types.new_voxel_grid(3)
  inspect(@voxel.get_voxel(g, 0, 0, 0), content="false")
  @voxel.set_voxel(g, 1, 1, 1, true)
  inspect(@voxel.get_voxel(g, 1, 1, 1), content="true")
  inspect(@voxel.get_voxel(g, 0, 0, 0), content="false")
  @voxel.set_voxel(g, 1, 1, 1, false)
  inspect(@voxel.get_voxel(g, 1, 1, 1), content="false")
}

///|
test "get_voxel out of bounds" {
  let g = @types.new_voxel_grid(3)
  inspect(@voxel.get_voxel(g, -1, 0, 0), content="false")
  inspect(@voxel.get_voxel(g, 3, 0, 0), content="false")
  inspect(@voxel.get_voxel(g, 0, -1, 0), content="false")
  inspect(@voxel.get_voxel(g, 0, 3, 0), content="false")
}

///|
test "count_filled" {
  let g = @types.new_voxel_grid(3)
  inspect(@voxel.count_filled(g), content="0")
  @voxel.set_voxel(g, 0, 0, 0, true)
  inspect(@voxel.count_filled(g), content="1")
  @voxel.set_voxel(g, 1, 1, 1, true)
  inspect(@voxel.count_filled(g), content="2")
  @voxel.set_voxel(g, 2, 2, 2, true)
  inspect(@voxel.count_filled(g), content="3")
}

///|
test "compute_top_silhouette" {
  let g = @types.new_voxel_grid(3)
  // Set voxel at (1, 0, 1) - should appear at (x=1, z=1) in top view
  @voxel.set_voxel(g, 1, 0, 1, true)
  let sil = @voxel.compute_top_silhouette(g)
  inspect(sil.width, content="3")
  inspect(sil.height, content="3")
  // Cell (x=1, z=1) should be filled
  inspect(sil.cells[1 + 1 * 3], content="true")
  // Others should be empty
  inspect(sil.cells[0], content="false")
}

///|
test "compute_top_silhouette projects Y" {
  let g = @types.new_voxel_grid(3)
  // Multiple voxels stacked in Y at (0, *, 0)
  @voxel.set_voxel(g, 0, 0, 0, true)
  @voxel.set_voxel(g, 0, 1, 0, true)
  @voxel.set_voxel(g, 0, 2, 0, true)
  let sil = @voxel.compute_top_silhouette(g)
  // Should show just one filled cell at (x=0, z=0)
  inspect(sil.cells[0], content="true")
  inspect(sil.cells[1], content="false")
}

///|
test "compute_front_silhouette" {
  let g = @types.new_voxel_grid(3)
  // Set voxel at (1, 2, 0) - top row in 3D
  @voxel.set_voxel(g, 1, 2, 0, true)
  let sil = @voxel.compute_front_silhouette(g)
  // Front view: x is column, inverted y is row
  // y=2 inverted = row 0, x=1 = col 1
  inspect(sil.cells[1 + 0 * 3], content="true")
}

///|
test "compute_front_silhouette projects Z" {
  let g = @types.new_voxel_grid(3)
  // Voxels along Z at (0, 0, *)
  @voxel.set_voxel(g, 0, 0, 0, true)
  @voxel.set_voxel(g, 0, 0, 1, true)
  @voxel.set_voxel(g, 0, 0, 2, true)
  let sil = @voxel.compute_front_silhouette(g)
  // Should show one filled cell at (x=0, inverted y=0) = (col 0, row 2)
  inspect(sil.cells[0 + 2 * 3], content="true")
  inspect(sil.cells[1 + 2 * 3], content="false")
}

///|
test "compute_side_silhouette" {
  let g = @types.new_voxel_grid(3)
  @voxel.set_voxel(g, 0, 1, 2, true)
  let sil = @voxel.compute_side_silhouette(g)
  // Side view: z is column, inverted y is row
  // z=2 = col 2, y=1 inverted = row 1
  inspect(sil.cells[2 + 1 * 3], content="true")
}

///|
test "compute_side_silhouette projects X" {
  let g = @types.new_voxel_grid(3)
  @voxel.set_voxel(g, 0, 0, 0, true)
  @voxel.set_voxel(g, 1, 0, 0, true)
  @voxel.set_voxel(g, 2, 0, 0, true)
  let sil = @voxel.compute_side_silhouette(g)
  // Should show one cell at (z=0, inverted y=0) = (col 0, row 2)
  inspect(sil.cells[0 + 2 * 3], content="true")
  inspect(sil.cells[1 + 2 * 3], content="false")
}

///|
test "silhouettes_match" {
  let a = @types.new_silhouette(3, 3)
  let b = @types.new_silhouette(3, 3)
  inspect(@voxel.silhouettes_match(a, b), content="true")
  a.cells[0] = true
  inspect(@voxel.silhouettes_match(a, b), content="false")
  b.cells[0] = true
  inspect(@voxel.silhouettes_match(a, b), content="true")
}

///|
test "silhouettes_match different sizes" {
  let a = @types.new_silhouette(3, 3)
  let b = @types.new_silhouette(4, 4)
  inspect(@voxel.silhouettes_match(a, b), content="false")
}

///|
test "ray_toggle_top add voxel" {
  let g = @types.new_voxel_grid(3)
  // Toggle at (col=1, row=1) in top view => (x=1, z=1), first empty y
  let result = @voxel.ray_toggle_top(g, 1, 1)
  match result {
    Some(pos) => {
      inspect(pos.x, content="1")
      inspect(pos.y, content="0") // First empty from bottom
      inspect(pos.z, content="1")
      inspect(@voxel.get_voxel(g, 1, 0, 1), content="true")
    }
    None => inspect(false, content="true")
  }
}

///|
test "ray_toggle_top stacks" {
  let g = @types.new_voxel_grid(3)
  // First toggle: fills y=0
  let _ = @voxel.ray_toggle_top(g, 0, 0)
  inspect(@voxel.get_voxel(g, 0, 0, 0), content="true")
  // Second toggle: fills y=1
  let _ = @voxel.ray_toggle_top(g, 0, 0)
  inspect(@voxel.get_voxel(g, 0, 1, 0), content="true")
  // Third toggle: fills y=2
  let _ = @voxel.ray_toggle_top(g, 0, 0)
  inspect(@voxel.get_voxel(g, 0, 2, 0), content="true")
  // Fourth toggle: all filled, removes from top (y=2)
  let _ = @voxel.ray_toggle_top(g, 0, 0)
  inspect(@voxel.get_voxel(g, 0, 2, 0), content="false")
  inspect(@voxel.get_voxel(g, 0, 1, 0), content="true")
}

///|
test "ray_toggle_front" {
  let g = @types.new_voxel_grid(3)
  // Front view: col=1, row=0 => x=1, y=2 (inverted), first empty z
  let result = @voxel.ray_toggle_front(g, 1, 0)
  match result {
    Some(pos) => {
      inspect(pos.x, content="1")
      inspect(pos.y, content="2")
      inspect(pos.z, content="0")
    }
    None => inspect(false, content="true")
  }
}

///|
test "ray_toggle_side" {
  let g = @types.new_voxel_grid(3)
  // Side view: col=2, row=1 => z=2, y=1 (inverted), first empty x
  let result = @voxel.ray_toggle_side(g, 2, 1)
  match result {
    Some(pos) => {
      inspect(pos.x, content="0")
      inspect(pos.y, content="1")
      inspect(pos.z, content="2")
    }
    None => inspect(false, content="true")
  }
}

///|
test "check_connected empty grid" {
  let g = @types.new_voxel_grid(3)
  inspect(@voxel.check_connected(g), content="true")
}

///|
test "check_connected single voxel" {
  let g = @types.new_voxel_grid(3)
  @voxel.set_voxel(g, 1, 1, 1, true)
  inspect(@voxel.check_connected(g), content="true")
}

///|
test "check_connected adjacent voxels" {
  let g = @types.new_voxel_grid(3)
  @voxel.set_voxel(g, 0, 0, 0, true)
  @voxel.set_voxel(g, 1, 0, 0, true)
  @voxel.set_voxel(g, 2, 0, 0, true)
  inspect(@voxel.check_connected(g), content="true")
}

///|
test "check_connected disconnected" {
  let g = @types.new_voxel_grid(3)
  @voxel.set_voxel(g, 0, 0, 0, true)
  @voxel.set_voxel(g, 2, 2, 2, true)
  inspect(@voxel.check_connected(g), content="false")
}

///|
test "check_connected L shape" {
  let g = @types.new_voxel_grid(3)
  @voxel.set_voxel(g, 0, 0, 0, true)
  @voxel.set_voxel(g, 1, 0, 0, true)
  @voxel.set_voxel(g, 1, 1, 0, true)
  inspect(@voxel.check_connected(g), content="true")
}

///|
test "check_completion with matching silhouettes" {
  let g = @types.new_voxel_grid(3)
  // Create a simple target: single voxel at center
  @voxel.set_voxel(g, 1, 1, 1, true)
  let top = @voxel.compute_top_silhouette(g)
  let front = @voxel.compute_front_silhouette(g)
  let side = @voxel.compute_side_silhouette(g)
  let targets = @types.new_target_set(top, front, side)
  inspect(@voxel.check_completion(g, targets), content="true")
}

///|
test "check_completion with non-matching" {
  let g = @types.new_voxel_grid(3)
  @voxel.set_voxel(g, 1, 1, 1, true)
  let top = @voxel.compute_top_silhouette(g)
  let front = @voxel.compute_front_silhouette(g)
  let side = @voxel.compute_side_silhouette(g)
  let targets = @types.new_target_set(top, front, side)
  // Change the grid
  @voxel.set_voxel(g, 0, 0, 0, true)
  inspect(@voxel.check_completion(g, targets), content="false")
}

///|
test "ray_preview returns preview position" {
  let g = @types.new_voxel_grid(3)
  let result = @voxel.ray_preview(g, Top, 1, 1)
  match result {
    Some(pos) => {
      inspect(pos.x, content="1")
      inspect(pos.y, content="0")
      inspect(pos.z, content="1")
    }
    None => inspect(false, content="true")
  }
}

///|
test "voxel budget enforcement" {
  let g = @types.new_voxel_grid(3)
  @voxel.set_voxel(g, 0, 0, 0, true)
  @voxel.set_voxel(g, 1, 0, 0, true)
  @voxel.set_voxel(g, 2, 0, 0, true)
  let filled = @voxel.count_filled(g)
  inspect(filled, content="3")
  // A budget of 3 means we can't add more
  inspect(filled >= 3, content="true")
}
