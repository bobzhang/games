///|
const MapSize : Int = 10

///|
fn float_array_to_fixed(arr : @raylib.FloatArray) -> FixedArray[Float] {
  let len = arr.length()
  let result : FixedArray[Float] = FixedArray::make(len, (0.0 : Float))
  for i in 0..<len {
    result[i] = arr[i]
  }
  result
}

///|
fn ushort_array_to_fixed(arr : @raylib.UShortArray) -> FixedArray[UInt16] {
  let len = arr.length()
  let result = FixedArray::make(len, (0 : UInt16))
  for i in 0..<len {
    result[i] = arr[i].to_uint16()
  }
  result
}

///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.set_config_flags(@raylib.FlagMsaa4xHint)
  @raylib.init_window(
    screen_width, screen_height, "raylib [shaders] example - lightmap",
  )

  // Define the camera to look into our 3d world
  let mut camera = @raylib.Camera3D::new(
    @raylib.Vector3::new(4.0, 6.0, 8.0),
    @raylib.Vector3::new(0.0, 0.0, 0.0),
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    45.0,
    @raylib.CameraPerspective,
  )

  // GenMeshPlane doesn't generate texcoords2, so we generate the plane first,
  // extract its data, then recreate the mesh with texcoords2 included.
  let plane = @raylib.gen_mesh_plane(
    Float::from_int(MapSize),
    Float::from_int(MapSize),
    1,
    1,
  )
  let plane_vertices = float_array_to_fixed(plane.vertices().unwrap())
  let plane_texcoords = float_array_to_fixed(plane.texcoords().unwrap())
  let plane_normals = float_array_to_fixed(plane.normals().unwrap())
  let plane_indices = ushort_array_to_fixed(plane.indices().unwrap())
  @raylib.unload_mesh(plane)

  // texcoords2: 4 vertices * 2 components = 8 floats
  let texcoords2 : FixedArray[Float] = [
    0.0, 0.0, // vertex 0
     1.0, 0.0, // vertex 1
     0.0, 1.0, // vertex 2
     1.0, 1.0,
  ] // vertex 3

  let mesh = @raylib.Mesh::new(
    plane_vertices,
    texcoords=plane_texcoords,
    texcoords2~,
    normals=plane_normals,
    indices=plane_indices,
  )

  // Load lightmap shader
  let shader = @raylib.load_shader(
    "resources/shaders/glsl330/lightmap.vs", "resources/shaders/glsl330/lightmap.fs",
  )

  let texture = @raylib.load_texture("resources/cubicmap_atlas.png")
  let light = @raylib.load_texture("resources/spark_flame.png")

  @raylib.gen_texture_mipmaps(texture)
  @raylib.set_texture_filter(texture, @raylib.TextureFilterTrilinear)

  let lightmap = @raylib.RenderTexture::load(MapSize, MapSize)

  @raylib.set_render_texture_filter(lightmap, @raylib.TextureFilterTrilinear)

  let material = @raylib.Material::default()
  @raylib.set_material_shader(material, shader)
  @raylib.set_material_texture(material, @raylib.MaterialMapAlbedo, texture)
  // Set lightmap texture on METALNESS map slot (used as texture1 in shader)
  let lightmap_tex = @raylib.get_render_texture_texture(lightmap)
  @raylib.set_material_texture(
    material,
    @raylib.MaterialMapMetalness,
    lightmap_tex,
  )

  // Drawing to lightmap
  @raylib.begin_texture_mode(lightmap)
  @raylib.clear_background(@raylib.black)

  let light_w = Float::from_int(@raylib.get_texture_width(light))
  let light_h = Float::from_int(@raylib.get_texture_height(light))

  @raylib.begin_blend_mode(@raylib.BlendAdditive)
  @raylib.draw_texture_pro(
    light,
    @raylib.Rectangle::new(0.0, 0.0, light_w, light_h),
    @raylib.Rectangle::new(0.0, 0.0, 20.0, 20.0),
    @raylib.Vector2::new(10.0, 10.0),
    0.0,
    @raylib.red,
  )
  @raylib.draw_texture_pro(
    light,
    @raylib.Rectangle::new(0.0, 0.0, light_w, light_h),
    @raylib.Rectangle::new(8.0, 4.0, 20.0, 20.0),
    @raylib.Vector2::new(10.0, 10.0),
    0.0,
    @raylib.blue,
  )
  @raylib.draw_texture_pro(
    light,
    @raylib.Rectangle::new(0.0, 0.0, light_w, light_h),
    @raylib.Rectangle::new(8.0, 8.0, 10.0, 10.0),
    @raylib.Vector2::new(5.0, 5.0),
    0.0,
    @raylib.green,
  )
  @raylib.begin_blend_mode(@raylib.BlendAlpha)
  @raylib.end_texture_mode()

  @raylib.set_target_fps(60)
  @draw.init_font()

  // Main game loop
  while !@raylib.window_should_close() {
    // Update
    camera = @raylib.update_camera(camera, @raylib.CameraOrbital)

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    @raylib.begin_mode_3d(camera)
    @raylib.draw_mesh(mesh, material, @raylib.Matrix::identity())
    @raylib.end_mode_3d()

    @raylib.draw_fps(10, 10)

    let render_w = @raylib.get_render_width()
    let map_size_f = Float::from_int(MapSize)

    @raylib.draw_render_texture_pro(
      lightmap,
      @raylib.Rectangle::new(0.0, 0.0, -map_size_f, -map_size_f),
      @raylib.Rectangle::new(
        Float::from_int(render_w - MapSize * 8 - 10),
        10.0,
        Float::from_int(MapSize * 8),
        Float::from_int(MapSize * 8),
      ),
      @raylib.Vector2::new(0.0, 0.0),
      0.0,
      @raylib.white,
    )

    @draw.draw_text(
      "lightmap",
      render_w - 66,
      16 + MapSize * 8,
      10,
      @raylib.gray,
    )
    @draw.draw_text(
      "10x10 pixels",
      render_w - 76,
      30 + MapSize * 8,
      10,
      @raylib.gray,
    )

    @fps.draw()
    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_mesh(mesh)
  @raylib.unload_shader(shader)
  @raylib.unload_texture(texture)
  @raylib.unload_texture(light)
  @draw.cleanup()
  @raylib.close_window()
}
