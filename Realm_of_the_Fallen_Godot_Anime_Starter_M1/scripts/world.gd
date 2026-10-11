extends RefCounted
## Procedural art direction: Fallen Radiance.
## No network assets and no plugins. One moon shadow caster, pooled foliage and stone.

const GROUND_TEXTURE = preload("res://assets/textures/ground.png")
const STONE_TEXTURE = preload("res://assets/textures/stone.png")
const BARK_TEXTURE = preload("res://assets/textures/bark.png")
const AURA_TEXTURE = preload("res://assets/textures/aura.png")
const CONTACT_SHADOW = preload("res://assets/textures/contact_shadow.png")

static var _root: Node3D
static var _rng := RandomNumberGenerator.new()
static var _mat: Dictionary = {}
static var _flames: Array[Node3D] = []
static var _orbitals: Array[Node3D] = []
static var _time := 0.0
static var _shadow_tf: Array = []
static var moon: DirectionalLight3D
static var environment: Environment

static func populate(parent: Node3D) -> void:
	_root = Node3D.new()
	_root.name = "ForgottenGraveyard"
	parent.add_child(_root)
	_rng.seed = 22071011
	_mat.clear()
	_flames.clear()
	_orbitals.clear()
	_shadow_tf.clear()
	_time = 0.0
	_materials()
	_lighting()
	_ground()
	_cobbled_road()
	_forest()
	_graveyard()
	_ruins()
	_gateway()
	_motifs()

static func tick(delta: float) -> void:
	_time += delta
	for i in range(_flames.size()):
		var f: Node3D = _flames[i]
		if is_instance_valid(f):
			f.scale.y = 0.88 + 0.13 * sin(_time * 3.9 + float(i) * 2.17)
	for i in range(_orbitals.size()):
		var obj: Node3D = _orbitals[i]
		if is_instance_valid(obj):
			obj.rotation.y += delta * (0.45 if i % 2 == 0 else -0.3)
			obj.position.y += sin(_time * 1.5 + i) * delta * 0.018

static func _materials() -> void:
	_mat["ground"] = _standard(Color(0.49, 0.59, 0.62), 1.0, 0.0, GROUND_TEXTURE, 7.0)
	_mat["stone"] = _standard(Color(0.76, 0.82, 0.92), 0.95, 0.0, STONE_TEXTURE, 1.0)
	_mat["stone_dark"] = _standard(Color(0.31, 0.40, 0.51), 0.94, 0.0, STONE_TEXTURE, 1.0)
	_mat["stone_pale"] = _standard(Color(0.96, 0.97, 1.0), 0.91, 0.0, STONE_TEXTURE, 1.0)
	_mat["bark"] = _standard(Color(0.55, 0.53, 0.65), 1.0, 0.0, BARK_TEXTURE, 2.0)
	_mat["leaf"] = _standard(Color(0.23, 0.41, 0.46), 0.99)
	_mat["leaf_alt"] = _standard(Color(0.34, 0.47, 0.54), 0.99)
	_mat["grass"] = _standard(Color(0.45, 0.70, 0.68), 0.95)
	_mat["iron"] = _standard(Color(0.12, 0.19, 0.24), 0.38, 0.56)
	_mat["gold"] = _standard(Color(0.85, 0.68, 0.41), 0.35, 0.68)
	_mat["rune"] = _standard(Color(0.09, 0.83, 0.98), 0.35, 0.0)
	_mat["rune"].emission_enabled = true
	_mat["rune"].emission = Color(0.12, 0.77, 1.0)
	_mat["rune"].emission_energy_multiplier = 4.1
	_mat["ember"] = _standard(Color(1.0, 0.60, 0.23), 0.65)
	_mat["ember"].emission_enabled = true
	_mat["ember"].emission = Color(1.0, 0.42, 0.14)
	_mat["ember"].emission_energy_multiplier = 3.7
	_mat["shadow_plant"] = _standard(Color(0.23, 0.39, 0.37), 0.97)

static func _standard(c: Color, rough: float, metal: float = 0.0, tex: Texture2D = null, tiles: float = 1.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = rough
	m.metallic = metal
	if tex != null:
		m.albedo_texture = tex
		m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
		m.uv1_scale = Vector3(tiles, tiles, 1.0)
	return m

static func _lighting() -> void:
	environment = Environment.new()
	environment.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sky_paint := ProceduralSkyMaterial.new()
	sky_paint.sky_top_color = Color(0.028, 0.043, 0.11)
	sky_paint.sky_horizon_color = Color(0.17, 0.25, 0.37)
	sky_paint.ground_bottom_color = Color(0.055, 0.075, 0.12)
	sky_paint.ground_horizon_color = Color(0.15, 0.22, 0.28)
	sky_paint.sun_angle_max = 12.0
	sky.sky_material = sky_paint
	environment.sky = sky
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	environment.ambient_light_energy = 0.57
	environment.reflected_light_source = Environment.REFLECTION_SOURCE_BG
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.fog_enabled = true
	environment.fog_light_color = Color(0.15, 0.25, 0.35)
	environment.fog_density = 0.014
	environment.fog_sky_affect = 0.45
	environment.glow_enabled = true
	environment.glow_intensity = 0.54
	environment.glow_strength = 0.88
	environment.glow_bloom = 0.08
	environment.adjustment_enabled = true
	environment.adjustment_contrast = 1.08
	environment.adjustment_saturation = 1.15
	var world_env := WorldEnvironment.new()
	world_env.name = "Atmosphere_Fog_Bloom_Tonemap"
	world_env.environment = environment
	_root.add_child(world_env)
	moon = DirectionalLight3D.new()
	moon.name = "Moonlight_ShadowCaster"
	moon.light_color = Color(0.61, 0.73, 1.0)
	moon.light_energy = 1.22
	moon.rotation_degrees = Vector3(-48.0, -34.0, 0.0)
	moon.shadow_enabled = true
	moon.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS
	moon.directional_shadow_max_distance = 58.0
	moon.shadow_blur = 1.6
	_root.add_child(moon)
	var cold_rim := DirectionalLight3D.new()
	cold_rim.name = "Weak_Fill_NoShadows"
	cold_rim.light_color = Color(0.18, 0.73, 0.78)
	cold_rim.light_energy = 0.27
	cold_rim.rotation_degrees = Vector3(-24.0, 125.0, 0.0)
	_root.add_child(cold_rim)

static func _mesh(mesh: Mesh, mat: Material, pos: Vector3, parent: Node3D = null) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.mesh = mesh
	node.material_override = mat
	node.position = pos
	(parent if parent != null else _root).add_child(node)
	return node

static func _box(pos: Vector3, size: Vector3, mat: Material, yaw: float = 0.0, parent: Node3D = null) -> MeshInstance3D:
	var m := BoxMesh.new()
	m.size = size
	var obj := _mesh(m, mat, pos, parent)
	obj.rotation.y = yaw
	return obj

static func _cyl(pos: Vector3, radius: float, height: float, mat: Material, tops: float = -1.0, parent: Node3D = null, sides: int = 8) -> MeshInstance3D:
	var m := CylinderMesh.new()
	m.bottom_radius = radius
	m.top_radius = (tops if tops >= 0.0 else radius)
	m.height = height
	m.radial_segments = sides
	m.rings = 1
	return _mesh(m, mat, pos, parent)

static func _orb(pos: Vector3, scale_size: Vector3, mat: Material, parent: Node3D = null) -> MeshInstance3D:
	var s := SphereMesh.new()
	s.radial_segments = 8
	s.rings = 4
	var node := _mesh(s, mat, pos, parent)
	node.scale = scale_size
	return node

static func _pyramid(pos: Vector3, radius: float, h: float, mat: Material, parent: Node3D = null) -> MeshInstance3D:
	return _cyl(pos, radius, h, mat, 0.0, parent, 5)

static func _mm(mesh: Mesh, material: Material, transforms: Array, colors: Array, name: String) -> void:
	if transforms.is_empty():
		return
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true
	mm.mesh = mesh
	mm.instance_count = transforms.size()
	for i in range(transforms.size()):
		mm.set_instance_transform(i, transforms[i])
		mm.set_instance_color(i, colors[i])
	var actor := MultiMeshInstance3D.new()
	actor.name = name
	actor.multimesh = mm
	actor.material_override = material
	_root.add_child(actor)

static func _ground() -> void:
	var land := PlaneMesh.new()
	land.size = Vector2(110, 110)
	land.subdivide_width = 4
	land.subdivide_depth = 4
	var terrain := _mesh(land, _mat["ground"], Vector3.ZERO)
	terrain.name = "PaintedMoonlitGround"
	terrain.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var floor_body := StaticBody3D.new()
	floor_body.name = "GroundCollision"
	_root.add_child(floor_body)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(100, 0.5, 100)
	shape.shape = box
	shape.position.y = -0.26
	floor_body.add_child(shape)
	# Dark cliff silhouettes disguise the plane border and suggest a much larger world.
	for i in range(60):
		var angle := TAU * float(i) / 60.0
		var rad := _rng.randf_range(31.0, 50.0)
		var height := _rng.randf_range(2.0, 9.0)
		var loc := Vector3(cos(angle) * rad, height * 0.28 - 0.7, sin(angle) * rad)
		_orb(loc, Vector3(_rng.randf_range(3.5, 8.0), height, _rng.randf_range(3.5, 7.5)), _mat["stone_dark"])

static func _cobbled_road() -> void:
	var mesh := BoxMesh.new()
	mesh.size = Vector3.ONE
	var stone_mat := _standard(Color(0.77, 0.8, 0.91), 0.96, 0.0, STONE_TEXTURE)
	stone_mat.vertex_color_use_as_albedo = true
	var tf: Array = []
	var colors: Array = []
	for row in range(93):
		var z := 19.5 - float(row) * 0.52
		for col in range(3):
			if _rng.randf() < 0.065:
				continue
			var bend := 0.45 * sin(z * 0.25)
			var x := bend + (float(col) - 1.0) * 0.91 + _rng.randf_range(-0.12, 0.12)
			var width := _rng.randf_range(0.63, 0.96)
			var height := _rng.randf_range(0.09, 0.17)
			var basis := Basis(Vector3.UP, _rng.randf_range(-0.12, 0.12)).scaled(Vector3(width, height, _rng.randf_range(0.38, 0.51)))
			tf.append(Transform3D(basis, Vector3(x, height * 0.46, z)))
			var tint := _rng.randf_range(0.69, 1.0)
			colors.append(Color(tint * 0.94, tint * 0.96, tint, 1.0))
	_mm(mesh, stone_mat, tf, colors, "InstancedAncientPaving")
	# Gold trim rune stepping stones draw the eye toward the far gate.
	for z in [12.0, 2.0, -9.0, -22.0]:
		_box(Vector3(0.45 * sin(z * 0.25), 0.12, z), Vector3(0.7, 0.025, 0.11), _mat["gold"])

static func _forest() -> void:
	var trunk := CylinderMesh.new()
	trunk.bottom_radius = 0.8
	trunk.top_radius = 0.34
	trunk.height = 1.0
	trunk.radial_segments = 7
	var leaves := SphereMesh.new()
	leaves.radial_segments = 7
	leaves.rings = 4
	var bark_mat := _standard(Color(0.44, 0.47, 0.54), 1.0, 0.0, BARK_TEXTURE, 1.8)
	bark_mat.vertex_color_use_as_albedo = true
	var canopy_mat := _standard(Color(0.30, 0.54, 0.54), 0.94)
	canopy_mat.vertex_color_use_as_albedo = true
	var ttf: Array = []
	var tcl: Array = []
	var ctf: Array = []
	var ccl: Array = []
	for i in range(98):
		var angle := _rng.randf_range(0, TAU)
		var distance := _rng.randf_range(19.0, 58.0)
		var x := cos(angle) * distance
		var z := sin(angle) * distance
		if absf(x) < 12.0 and z > -36 and z < 22:
			continue
		var h := _rng.randf_range(5.5, 12.0)
		var lean := _rng.randf_range(-0.14, 0.14)
		var b := Basis(Vector3(lean, 1, 0).normalized(), _rng.randf_range(-0.2, 0.2)).scaled(Vector3(0.70 * h / 8, h, 0.70 * h / 8))
		ttf.append(Transform3D(b, Vector3(x, h / 2, z)))
		if distance < 39.0:
			_shadow_tf.append(Transform3D(Basis().scaled(Vector3(2.2, 1.0, 1.8)), Vector3(x, 0.012, z)))
		tcl.append(Color(_rng.randf_range(0.74, 0.93), 1.0, 1.0, 1))
		for j in range(3):
			var spread := 2.5 - float(j) * 0.40
			var b2 := Basis(Vector3.UP, _rng.randf_range(-PI, PI)).scaled(Vector3(spread * h / 8, 1.9 * h / 8, spread * h / 8))
			ctf.append(Transform3D(b2, Vector3(x + _rng.randf_range(-0.2, 0.2), h * (0.62 + j * 0.16), z)))
			ccl.append(Color(_rng.randf_range(0.66, 0.94), _rng.randf_range(0.72, 0.99), _rng.randf_range(0.92, 1.0), 1.0))
	_mm(trunk, bark_mat, ttf, tcl, "InstancedForestTrunks")
	_mm(leaves, canopy_mat, ctf, ccl, "InstancedPainterlyCanopies")
	var rock := SphereMesh.new()
	rock.radial_segments = 6
	rock.rings = 3
	var rock_tf: Array = []
	var rock_col: Array = []
	for j in range(160):
		var x := _rng.randf_range(-34, 34)
		var z := _rng.randf_range(-41, 30)
		if absf(x) < 3.2 and z > -30 and z < 20:
			continue
		var s := _rng.randf_range(0.22, 1.25)
		rock_tf.append(Transform3D(Basis(Vector3.UP, _rng.randf_range(0, TAU)).scaled(Vector3(s * 1.3, s * 0.6, s)), Vector3(x, s * 0.16, z)))
		rock_col.append(Color(_rng.randf_range(0.67, 0.98), _rng.randf_range(0.76, 0.97), 1.0, 1.0))
	var stone_m := _standard(Color(0.58, 0.69, 0.82), 0.97, 0.0, STONE_TEXTURE)
	stone_m.vertex_color_use_as_albedo = true
	_mm(rock, stone_m, rock_tf, rock_col, "InstancedPebblesAndBoulders")
	# Three-dimensional blades. MultiMesh avoids hundreds of draw calls.
	var grass_mesh := _grass_mesh()
	var gmat := _standard(Color(0.33, 0.56, 0.56), 1.0)
	gmat.cull_mode = BaseMaterial3D.CULL_DISABLED
	gmat.vertex_color_use_as_albedo = true
	var gtf: Array = []
	var gcl: Array = []
	for j in range(1250):
		var x := _rng.randf_range(-29, 29)
		var z := _rng.randf_range(-38, 29)
		if absf(x - 0.45 * sin(z * 0.25)) < 2.1 and z > -29 and z < 20:
			continue
		var sz := _rng.randf_range(0.25, 0.95)
		gtf.append(Transform3D(Basis(Vector3.UP, _rng.randf_range(0, TAU)).scaled(Vector3(sz, sz, sz)), Vector3(x, 0.04, z)))
		gcl.append(Color(_rng.randf_range(0.7, 1.0), _rng.randf_range(0.75, 1.0), _rng.randf_range(0.73, 1.0), 1.0))
	_mm(grass_mesh, gmat, gtf, gcl, "1250_InstancedMoonGrassTufts")

static func _grass_mesh() -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for rot in [0.0, PI / 2.0]:
		var b := Basis(Vector3.UP, rot)
		var pts := [b * Vector3(-0.21, 0, 0), b * Vector3(0.21, 0, 0), b * Vector3(0, 0.73, 0)]
		for p in pts:
			st.set_normal(Vector3.UP)
			st.add_vertex(p)
	st.generate_normals()
	return st.commit()

static func _graveyard() -> void:
	for i in range(35):
		var z := _rng.randf_range(-23.0, 18.0)
		var side := (-1.0 if i % 2 == 0 else 1.0)
		var x := side * _rng.randf_range(4.0, 14.0)
		var h := _rng.randf_range(0.75, 1.6)
		var stone: Material = _mat["stone_pale"] if i % 5 == 0 else _mat["stone"]
		var grave := Node3D.new()
		grave.position = Vector3(x, 0, z)
		grave.rotation.y = _rng.randf_range(-0.4, 0.4)
		grave.rotation.z = _rng.randf_range(-0.09, 0.09)
		_root.add_child(grave)
		_shadow_tf.append(Transform3D(Basis().scaled(Vector3(2.0, 1.0, 1.3)), Vector3(x, 0.018, z)))
		_box(Vector3(0, 0.12, 0), Vector3(1.3, 0.24, 0.75), _mat["stone_dark"], 0.0, grave)
		_box(Vector3(0, 0.28 + h * 0.42, -0.06), Vector3(_rng.randf_range(0.65, 0.93), h, 0.23), stone, 0.0, grave)
		if i % 4 == 0:
			_box(Vector3(0, h + 0.35, -0.05), Vector3(0.32, 0.65, 0.24), stone, 0.0, grave)
			_box(Vector3(0, h + 0.49, -0.05), Vector3(0.80, 0.21, 0.24), stone, 0.0, grave)
		else:
			_box(Vector3(0, h * 0.62, -0.2), Vector3(0.08, 0.4, 0.028), _mat["stone_dark"], 0.0, grave)
			_box(Vector3(0, h * 0.64, -0.22), Vector3(0.3, 0.055, 0.028), _mat["stone_dark"], 0.0, grave)
		if i % 7 == 0:
			_cyan_torch(Vector3(x + 1.0, 0, z - 0.5), false)
	# Central awakening sarcophagus and stylized engraved stone.
	_box(Vector3(-1.2, 0.48, 15.3), Vector3(3.0, 0.95, 1.6), _mat["stone_dark"], 0.14)
	_box(Vector3(-1.2, 1.04, 15.3), Vector3(3.15, 0.17, 1.72), _mat["stone_pale"], 0.14)
	for i in range(5):
		_box(Vector3(-2.35 + i * 0.57, 1.14, 15.3), Vector3(0.07, 0.04, 0.64), _mat["gold"], 0.14)
	# Distinctive monuments lead the player's eye down the path.
	for x,z in [[-9,-4], [9,-13], [-12,-18], [13,9]]:
		_cyl(Vector3(x, 0.22, z), 1.55, 0.44, _mat["stone_dark"])
		_cyl(Vector3(x, 1.15, z), 0.65, 1.9, _mat["stone"])
		_box(Vector3(x, 2.21, z), Vector3(1.6, 0.19, 1.2), _mat["stone_pale"])
		_pyramid(Vector3(x, 2.85, z), 0.62, 1.15, _mat["stone_dark"])

static func _ruins() -> void:
	# Ancient broken colonnades and pillars at the edge of the processional road.
	for side in [-1, 1]:
		for k in range(6):
			var x := float(side) * 9.3
			var z := 9.0 - float(k) * 6.0
			var ht := _rng.randf_range(2.5, 5.6)
			_box(Vector3(x, 0.3, z), Vector3(2.1, 0.6, 2.0), _mat["stone_dark"])
			_cyl(Vector3(x, ht / 2 + 0.45, z), 0.48, ht, _mat["stone"])
			_box(Vector3(x, ht + 0.52, z), Vector3(1.42, 0.26, 1.34), _mat["stone_pale"])
			if k % 2 == 1:
				_cyan_torch(Vector3(x - 1.1 * side, 0, z), false)
	# Fallen arch pieces and a giant ruined angel-wing motif in the distance.
	for n in range(3):
		_box(Vector3(-14.0 + n * 1.8, 0.25, -27), Vector3(1.4, 0.5, 2.8), _mat["stone"], float(n) * 0.12)
	_box(Vector3(-13.4, 4.0, -30), Vector3(1.8, 8.0, 2.6), _mat["stone_dark"])
	_box(Vector3(-15.4, 5.4, -30), Vector3(3.5, 0.58, 2.6), _mat["stone_pale"], 0.18)
	_cyan_torch(Vector3(-11.0, 0, -28), true)

static func _gateway() -> void:
	# Hero landmark: stacked stone gate, cyan magic seal and animated rings.
	for side in [-1.0, 1.0]:
		var x := float(side) * 3.85
		_box(Vector3(x, 0.5, -28.3), Vector3(2.25, 1.0, 2.3), _mat["stone_dark"])
		_box(Vector3(x, 3.6, -28.3), Vector3(1.75, 5.9, 1.85), _mat["stone_pale"])
		_box(Vector3(x, 7.0, -28.3), Vector3(2.36, 0.65, 2.25), _mat["stone_dark"])
		_pyramid(Vector3(x, 8.75, -28.3), 1.1, 2.9, _mat["stone_dark"])
		_cyan_torch(Vector3(x, 7.7, -27.7), true)
	_box(Vector3(0, 7.8, -28.3), Vector3(9.0, 1.3, 2.2), _mat["stone_dark"])
	_box(Vector3(0, 8.68, -28.3), Vector3(9.7, 0.42, 2.45), _mat["stone_pale"])
	_box(Vector3(0, 9.56, -28.3), Vector3(3.2, 1.5, 1.8), _mat["stone_dark"])
	_pyramid(Vector3(0, 11.0, -28.3), 1.65, 1.7, _mat["stone_pale"])
	var portal := Node3D.new()
	portal.name = "AnimatedSealedGate"
	portal.position = Vector3(0, 4.1, -28.0)
	_root.add_child(portal)
	for radius in [1.7, 2.1]:
		var torus := TorusMesh.new()
		torus.inner_radius = radius - 0.03
		torus.outer_radius = radius + 0.03
		torus.rings = 64
		torus.ring_segments = 6
		var ring := _mesh(torus, _mat["rune"], Vector3.ZERO, portal)
		ring.rotation.x = PI / 2.0
	for i in range(8):
		var ang := TAU * float(i) / 8.0
		var a := Vector3(cos(ang) * 2.1, sin(ang) * 2.1, 0.0)
		var shard := _pyramid(a, 0.13, 0.46, _mat["rune"], portal)
		shard.rotation.z = ang
	_orbitals.append(portal)
	_orb(Vector3(0, 4.0, -28.0), Vector3(0.36, 0.66, 0.36), _mat["rune"])
	_cyan_torch(Vector3(0, 1.0, -27.8), true)

static func _motifs() -> void:
	_contact_shadows()
	# Deliberately small count of distinct lanterns: glow is from emissive geometry,
	# only a few warm fill lights; no shadow-casting point lights on mobile.
	for loc in [Vector3(-3.1, 0, 12), Vector3(3.1, 0, 12), Vector3(-3.2, 0, 1), Vector3(3.2, 0, -11)]:
		_cyan_torch(loc, false)
	# Glowing airborne flecks, placed spatially instead of a heavy particle simulation.
	var orbmesh := SphereMesh.new()
	orbmesh.radial_segments = 6
	orbmesh.rings = 3
	var tf: Array = []
	var col: Array = []
	for k in range(180):
		var x := _rng.randf_range(-17, 17)
		var z := _rng.randf_range(-31, 23)
		var y := _rng.randf_range(0.4, 4.0)
		var s := _rng.randf_range(0.016, 0.052)
		tf.append(Transform3D(Basis().scaled(Vector3.ONE * s), Vector3(x, y, z)))
		col.append(Color(0.68, 0.94, 1, 1))
	var bits := _standard(Color(0.34, 0.97, 1.0), 0.9)
	bits.vertex_color_use_as_albedo = true
	bits.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	bits.emission_enabled = true
	bits.emission = Color(0.17, 0.8, 1.0)
	bits.emission_energy_multiplier = 2.1
	_mm(orbmesh, bits, tf, col, "180_InsectLights")

static func _contact_shadows() -> void:
	# Mobile rendering has no SSAO. Shadow discs fake grounded ambient occlusion
	# at a single draw call for all the gravestones and nearby trees.
	var mesh := PlaneMesh.new()
	mesh.size = Vector2.ONE
	var m := StandardMaterial3D.new()
	m.albedo_texture = CONTACT_SHADOW
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	m.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_DISABLED
	var colors: Array = []
	for i in range(_shadow_tf.size()):
		colors.append(Color(1.0, 1.0, 1.0, 0.85))
	_mm(mesh, m, _shadow_tf, colors, "InstancedGroundContactShadows")

static func _cyan_torch(at: Vector3, intense: bool) -> void:
	var anchor := Node3D.new()
	anchor.position = at
	_root.add_child(anchor)
	_cyl(Vector3(0, 0.72, 0), 0.18, 1.4, _mat["stone_dark"], -1.0, anchor)
	_cyl(Vector3(0, 1.49, 0), 0.36, 0.14, _mat["gold"], -1.0, anchor)
	var flame := Node3D.new()
	anchor.add_child(flame)
	flame.position = Vector3(0, 1.9, 0)
	_pyramid(Vector3.ZERO, (0.34 if intense else 0.23), (1.08 if intense else 0.65), _mat["rune"], flame)
	_flames.append(flame)
	var glow := Sprite3D.new()
	glow.texture = AURA_TEXTURE
	glow.pixel_size = (0.022 if intense else 0.014)
	glow.position = flame.position
	glow.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	glow.no_depth_test = false
	glow.shaded = false
	anchor.add_child(glow)
	if intense or _rng.randf() > 0.74:
		var light := OmniLight3D.new()
		light.position = Vector3(0, 2.0, 0)
		light.light_color = Color(0.08, 0.75, 1.0)
		light.light_energy = 0.8 if intense else 0.44
		light.omni_range = 5.5 if intense else 3.1
		light.shadow_enabled = false
		anchor.add_child(light)

static func set_quality(high: bool) -> void:
	if is_instance_valid(moon):
		moon.shadow_enabled = high
	if environment != null:
		environment.glow_enabled = high
