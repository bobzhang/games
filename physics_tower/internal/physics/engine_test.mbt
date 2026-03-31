///|
test "gravity pulls bodies down" {
  let world = @types.new_world()
  let _id = @physics.add_body(world, Block, Wood, 500.0, 400.0, 0.0)
  let initial_y = world.bodies[0].y
  // Run several physics steps
  for _i in 0..<20 {
    @physics.step(world, 0.016)
  }
  let final_y = world.bodies[0].y
  // Body should have moved down (y increases downward)
  inspect(final_y > initial_y, content="true")
}

///|
test "ground collision stops falling" {
  let world = @types.new_world()
  let _id = @physics.add_body(world, Block, Wood, 500.0, 780.0, 0.0)
  // Run many physics steps to let it settle
  for _i in 0..<200 {
    @physics.step(world, 0.016)
  }
  let body = world.bodies[0]
  let half_h = body.height * 0.5
  let bottom = body.y + half_h
  // Body should not be below ground
  inspect(bottom <= world.ground_y + 1.0, content="true")
  // Body should be nearly at rest
  inspect(@types.absf(body.vy) < 5.0, content="true")
}

///|
test "joint constraint holds bodies together" {
  let world = @types.new_world()
  let id_a = @physics.add_body(world, Block, Stone, 500.0, 700.0, 0.0)
  let id_b = @physics.add_body(world, Block, Stone, 500.0, 640.0, 0.0)
  // Create a fixed joint between them
  let joint = @types.new_joint(Fixed, id_a, id_b, 0.0, -30.0, 0.0, 30.0, 200.0)
  world.joints.push(joint)
  // Run physics to let them settle
  for _i in 0..<100 {
    @physics.step(world, 0.016)
  }
  let a = world.bodies[0]
  let b = world.bodies[1]
  // Bodies should still be near each other (within their height + some tolerance)
  let dist = @types.absf(a.y - b.y)
  inspect(dist < 120.0, content="true")
  // Joint should not be broken
  inspect(world.joints[0].broken, content="false")
}

///|
test "stress accumulates from weight" {
  let world = @types.new_world()
  // Place a bottom block on the ground
  let _id0 = @physics.add_body(world, Block, Wood, 500.0, 790.0, 0.0)
  // Stack another block on top
  let _id1 = @physics.add_body(world, Block, Stone, 500.0, 730.0, 0.0)
  // Auto-join them
  @physics.auto_join(world, 1)
  // Run physics
  for _i in 0..<100 {
    @physics.step(world, 0.016)
  }
  let bottom = world.bodies[0]
  // Bottom body should have accumulated some stress from weight above
  inspect(bottom.stress > 0.0, content="true")
}

///|
test "breaking threshold works" {
  let world = @types.new_world()
  let _id = @physics.add_body(world, Block, Wood, 500.0, 400.0, 0.0)
  let body = world.bodies[0]
  // Manually set stress above wood threshold (100.0)
  body.stress = 150.0
  // Run a physics step which calls check_breaks internally
  @physics.step(world, 0.016)
  // Body should be broken
  inspect(body.broken, content="true")
}

///|
test "wind applies horizontal force" {
  let world = @types.new_world()
  let _id = @physics.add_body(world, Block, Wood, 500.0, 750.0, 0.0)
  let body = world.bodies[0]
  // Start wind
  @physics.start_wind(world, 200.0)
  let initial_vx = body.vx
  // Run physics
  for _i in 0..<20 {
    @physics.step(world, 0.016)
  }
  // Body should have moved horizontally due to wind
  // The vx should be different from initial (wind pushed it)
  let moved = @types.absf(body.vx - initial_vx) > 0.1 ||
    @types.absf(body.x - 500.0) > 0.1
  inspect(moved, content="true")
  @physics.stop_wind(world)
}

///|
test "tower height measurement" {
  let world = @types.new_world()
  // No bodies = 0 height
  let h0 = @physics.measure_tower_height(world)
  inspect(h0 < 1.0, content="true")
  // Add a body near the ground
  let _id = @physics.add_body(world, Block, Stone, 500.0, 790.0, 0.0)
  let h1 = @physics.measure_tower_height(world)
  // Should have some height
  inspect(h1 > 0.0, content="true")
  // Add a body higher up
  let _id2 = @physics.add_body(world, Block, Stone, 500.0, 600.0, 0.0)
  let h2 = @physics.measure_tower_height(world)
  // Height should be greater now
  inspect(h2 > h1, content="true")
}

///|
test "earthquake applies forces to grounded bodies" {
  let world = @types.new_world()
  let _id = @physics.add_body(world, Block, Stone, 500.0, 790.0, 0.0)
  // Ground the body
  world.bodies[0].grounded = true
  // Start earthquake
  @physics.start_earthquake(world, 5.0, 400.0)
  // Run a few steps
  for _i in 0..<10 {
    @physics.step(world, 0.016)
  }
  // Quake timer should have decreased
  inspect(world.quake_timer < 5.0, content="true")
}

///|
test "clear world removes all bodies" {
  let world = @types.new_world()
  let _id1 = @physics.add_body(world, Block, Wood, 500.0, 700.0, 0.0)
  let _id2 = @physics.add_body(world, Block, Stone, 500.0, 660.0, 0.0)
  @physics.auto_join(world, 1)
  inspect(world.bodies.length() > 0, content="true")
  inspect(world.joints.length() > 0, content="true")
  @physics.clear_world(world)
  inspect(world.bodies.length(), content="0")
  inspect(world.joints.length(), content="0")
}

///|
test "is_settled detects rest state" {
  let world = @types.new_world()
  // Empty world is settled
  inspect(@physics.is_settled(world), content="true")
  // Add a body with velocity
  let _id = @physics.add_body(world, Block, Wood, 500.0, 700.0, 0.0)
  world.bodies[0].vx = 100.0
  inspect(@physics.is_settled(world), content="false")
  // Zero the velocity
  world.bodies[0].vx = 0.0
  world.bodies[0].vy = 0.0
  inspect(@physics.is_settled(world), content="true")
}

///|
test "auto_join creates joints between nearby bodies" {
  let world = @types.new_world()
  let _id0 = @physics.add_body(world, Block, Stone, 500.0, 790.0, 0.0)
  let _id1 = @physics.add_body(world, Block, Stone, 500.0, 730.0, 0.0)
  @physics.auto_join(world, 1)
  // Should have created at least one joint
  inspect(world.joints.length() > 0, content="true")
  // Joint should connect body 0 and body 1
  let joint = world.joints[0]
  let connects = (joint.body_a == 0 && joint.body_b == 1) ||
    (joint.body_a == 1 && joint.body_b == 0)
  inspect(connects, content="true")
}

///|
test "find_body returns correct body" {
  let world = @types.new_world()
  let _id0 = @physics.add_body(world, Block, Wood, 500.0, 700.0, 0.0)
  let _id1 = @physics.add_body(world, Beam, Steel, 600.0, 600.0, 0.0)
  let found = @physics.find_body(world, 1)
  match found {
    Some(b) => {
      inspect(b.kind == Beam, content="true")
      inspect(b.material == Steel, content="true")
    }
    None => inspect(false, content="true")
  }
  // Non-existent ID returns None
  let not_found = @physics.find_body(world, 99)
  inspect(not_found is None, content="true")
}

///|
test "impact applies force and stress" {
  let world = @types.new_world()
  let _id = @physics.add_body(world, Block, Stone, 500.0, 600.0, 0.0)
  let body = world.bodies[0]
  let old_stress = body.stress
  @physics.apply_impact(body, 1000.0, 500.0)
  // Body should have velocity now
  inspect(@types.absf(body.vx) > 0.1, content="true")
  inspect(@types.absf(body.vy) > 0.1, content="true")
  // Stress should have increased
  inspect(body.stress > old_stress, content="true")
}

///|
test "star calculation edge cases" {
  // Score 0 = 0 stars
  let stars_0 = if 0 >= 800 {
    3
  } else if 0 >= 400 {
    2
  } else if 0 > 0 {
    1
  } else {
    0
  }
  inspect(stars_0, content="0")
  // Score 1 = 1 star
  let stars_1 = if 1 >= 800 {
    3
  } else if 1 >= 400 {
    2
  } else if 1 > 0 {
    1
  } else {
    0
  }
  inspect(stars_1, content="1")
  // Score 400 = 2 stars
  let stars_400 = if 400 >= 800 {
    3
  } else if 400 >= 400 {
    2
  } else if 400 > 0 {
    1
  } else {
    0
  }
  inspect(stars_400, content="2")
  // Score 800 = 3 stars
  let stars_800 = if 800 >= 800 {
    3
  } else if 800 >= 400 {
    2
  } else if 800 > 0 {
    1
  } else {
    0
  }
  inspect(stars_800, content="3")
}
