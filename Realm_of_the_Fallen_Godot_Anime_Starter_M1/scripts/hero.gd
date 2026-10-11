extends CharacterBody3D
## Milestone-one playable procedural anime-fantasy avatar.
## Swap the "Visual" node for a rigged GLB later; controls/camera stay unchanged.

var health := 100.0
var stamina := 100.0
var analog := Vector2.ZERO
var camera_yaw := 0.0
var is_blocking := false
var attack_timer := 0.0
var dodge_timer := 0.0
var dodge_cooldown := 0.0
var move_speed := 4.5
var _run_clock := 0.0
var _dash_vector := Vector3.FORWARD
var _visual: Node3D
var _left_leg: Node3D
var _right_leg: Node3D
var _left_arm: Node3D
var _right_arm: Node3D
var _cape_nodes: Array[Node3D] = []
var _slash: Node3D
var _sword: Node3D
var _edge_material: StandardMaterial3D
const TOON_SHADER = preload("res://shaders/anime_toon.gdshader")

func _ready() -> void:
	name = "TheWanderer_Player"
	collision_layer = 2
	collision_mask = 1
	var collider := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.height = 1.9
	capsule.radius = 0.34
	collider.shape = capsule
	collider.position.y = 0.95
	add_child(collider)
	_build_visuals()

func _physics_process(delta: float) -> void:
	var keyboard := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var axes := analog if analog.length_squared() > 0.01 else keyboard
	var fw := Vector3(-sin(camera_yaw), 0, -cos(camera_yaw))
	var rt := Vector3(cos(camera_yaw), 0, -sin(camera_yaw))
	var direction := (rt * axes.x - fw * axes.y).limit_length(1.0)
	var running := (axes.length() > 0.82 or Input.is_action_pressed("sprint")) and stamina > 1.0 and not is_blocking
	if running:
		stamina = maxf(0.0, stamina - 14.0 * delta)
	else:
		stamina = minf(100.0, stamina + 18.0 * delta)
	var actual_speed := (7.0 if running else move_speed) * (0.38 if is_blocking else 1.0)
	if dodge_timer > 0.0:
		dodge_timer -= delta
		direction = _dash_vector
		actual_speed = 12.0
	else:
		var desired_yaw := atan2(-direction.x, -direction.z) if direction.length_squared() > 0.001 else _visual.rotation.y
		_visual.rotation.y = lerp_angle(_visual.rotation.y, desired_yaw, minf(1.0, delta * 13.0))
	var target_v := direction * actual_speed
	velocity.x = move_toward(velocity.x, target_v.x, delta * (35.0 if direction.length_squared() > 0.01 else 24.0))
	velocity.z = move_toward(velocity.z, target_v.z, delta * (35.0 if direction.length_squared() > 0.01 else 24.0))
	velocity.y = -0.5 if is_on_floor() else velocity.y - 22.0 * delta
	move_and_slide()
	position.x = clampf(position.x, -17.8, 17.8)
	position.z = clampf(position.z, -33.0, 21.0)
	dodge_cooldown = maxf(0, dodge_cooldown - delta)
	attack_timer = maxf(0, attack_timer - delta)
	_update_animation(delta, direction.length())

func strike() -> void:
	if attack_timer > 0 or dodge_timer > 0:
		return
	attack_timer = 0.46
	_slash.visible = true

func dodge() -> void:
	if stamina < 25.0 or dodge_cooldown > 0:
		return
	stamina -= 25.0
	dodge_cooldown = 0.85
	dodge_timer = 0.21
	var fw := Vector3(-sin(camera_yaw), 0, -cos(camera_yaw))
	var rt := Vector3(cos(camera_yaw), 0, -sin(camera_yaw))
	_dash_vector = (rt * analog.x - fw * analog.y).normalized() if analog.length_squared() > 0.1 else -_visual.global_transform.basis.z
	_dash_vector.y = 0
	_dash_vector = _dash_vector.normalized()

func set_guard(held: bool) -> void:
	is_blocking = held

func drink_potion() -> bool:
	if health >= 100.0:
		return false
	health = minf(100.0, health + 45.0)
	return true

func _update_animation(delta: float, travel: float) -> void:
	_run_clock += delta * (11.0 if travel > 0.8 else 6.2) * travel
	var stride := sin(_run_clock) * minf(travel, 1.0)
	_left_leg.rotation.x = stride * 0.44
	_right_leg.rotation.x = -stride * 0.44
	_left_arm.rotation.x = -stride * 0.2
	_right_arm.rotation.x = stride * 0.2
	_visual.position.y = sin(_run_clock * 2.0) * 0.035 * travel + sin(float(Time.get_ticks_msec()) * 0.0013) * 0.015
	for i in range(_cape_nodes.size()):
		var tail: Node3D = _cape_nodes[i]
		tail.rotation.x = 0.12 + 0.065 * sin(_run_clock * 0.62 + i * 1.3) + 0.20 * travel
		tail.rotation.z = 0.032 * sin(_run_clock * 0.75 + i * 1.8)
	if attack_timer > 0:
		var progress := 1.0 - attack_timer / 0.46
		_right_arm.rotation.x = -0.9 + sin(progress * PI) * -0.9
		_right_arm.rotation.z = sin(progress * PI * 2.0) * 0.42
		_slash.visible = progress > 0.18 and progress < 0.87
		_slash.rotation.z = -0.7 + progress * 2.4
		_slash.scale = Vector3.ONE * (0.80 + progress * 0.5)
	else:
		_slash.visible = false
	if dodge_timer > 0:
		_visual.rotation.x = -0.32
	else:
		_visual.rotation.x = lerpf(_visual.rotation.x, (-0.14 if is_blocking else 0.0), minf(1.0, delta * 12.0))

func _material(col: Color, metal: float = 0.0, rough: float = 0.56) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = col
	m.metallic = metal
	m.roughness = rough
	return m

func _toon(col: Color, rim: float = 0.28) -> ShaderMaterial:
	var m := ShaderMaterial.new()
	m.shader = TOON_SHADER
	m.set_shader_parameter("base_color", col)
	m.set_shader_parameter("rim_strength", rim)
	return m

func _part(parent: Node3D, mesh: Mesh, mat: Material, pos: Vector3, scale3: Vector3 = Vector3.ONE) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.mesh = mesh
	node.material_override = mat
	node.position = pos
	node.scale = scale3
	parent.add_child(node)
	return node

func _box(parent: Node3D, pos: Vector3, dims: Vector3, mat: Material) -> MeshInstance3D:
	var m := BoxMesh.new()
	m.size = dims
	return _part(parent, m, mat, pos)

func _sphere(parent: Node3D, pos: Vector3, size3: Vector3, mat: Material) -> MeshInstance3D:
	var s := SphereMesh.new()
	s.radial_segments = 12
	s.rings = 7
	return _part(parent, s, mat, pos, size3)

func _cone(parent: Node3D, pos: Vector3, dims: Vector3, mat: Material, angle: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var c := CylinderMesh.new()
	c.top_radius = 0.0
	c.bottom_radius = 0.5
	c.height = 1.0
	c.radial_segments = 5
	var obj := _part(parent, c, mat, pos, dims)
	obj.rotation = angle
	return obj

func _build_visuals() -> void:
	_visual = Node3D.new()
	_visual.name = "Visual_ReplaceableWithRiggedGLB"
	add_child(_visual)
	var cloth := _toon(Color(0.055, 0.078, 0.14))
	var cloth_2 := _toon(Color(0.12, 0.15, 0.23))
	var silver := _material(Color(0.49, 0.59, 0.75), 0.68, 0.28)
	var silver_hi := _material(Color(0.82, 0.89, 1.0), 0.73, 0.22)
	var gold := _material(Color(0.79, 0.58, 0.35), 0.72, 0.26)
	var skin := _material(Color(0.95, 0.75, 0.70), 0.0, 0.8)
	var hair := _toon(Color(0.69, 0.74, 0.91), 0.46)
	var hair_hi := _toon(Color(0.90, 0.91, 1.0), 0.35)
	var eye := _material(Color(0.09, 0.80, 1.0), 0.0, 0.33)
	var leather := _material(Color(0.12, 0.09, 0.13), 0.0, 0.77)
	_edge_material = _material(Color(0.14, 0.84, 1.0), 0.27, 0.14)
	_edge_material.emission_enabled = true
	_edge_material.emission = Color(0.11, 0.71, 0.98)
	_edge_material.emission_energy_multiplier = 3.9
	# Anime proportions: longer boots, compact torso, narrow waist and detailed collar.
	_sphere(_visual, Vector3(0, 1.33, 0), Vector3(0.37, 0.49, 0.21), cloth)
	_box(_visual, Vector3(0, 1.42, -0.19), Vector3(0.50, 0.54, 0.07), silver)
	_box(_visual, Vector3(0, 1.22, -0.235), Vector3(0.21, 0.15, 0.09), gold)
	_box(_visual, Vector3(0, 1.00, 0), Vector3(0.67, 0.18, 0.37), leather)
	for s in [-1.0, 1.0]:
		_box(_visual, Vector3(s * 0.28, 0.98, -0.20), Vector3(0.12, 0.20, 0.07), silver_hi)
		_box(_visual, Vector3(s * 0.25, 1.46, -0.23), Vector3(0.11, 0.39, 0.06), gold)
	# Layered high collar.
	_box(_visual, Vector3(0, 1.81, 0.03), Vector3(0.42, 0.35, 0.35), cloth_2)
	_box(_visual, Vector3(0, 1.91, -0.16), Vector3(0.37, 0.05, 0.04), gold)
	# Anime head, eye whites, azure irises, dark brows and many sculpted hair clumps.
	_sphere(_visual, Vector3(0, 2.10, 0), Vector3(0.225, 0.29, 0.21), skin)
	for s in [-1.0, 1.0]:
		_sphere(_visual, Vector3(s * 0.099, 2.13, -0.186), Vector3(0.074, 0.037, 0.025), _material(Color(0.91, 0.97, 1.0)))
		_sphere(_visual, Vector3(s * 0.096, 2.13, -0.206), Vector3(0.023, 0.032, 0.011), eye)
		_box(_visual, Vector3(s * 0.096, 2.19, -0.195), Vector3(0.13, 0.021, 0.016), cloth)
		_sphere(_visual, Vector3(s * 0.218, 2.06, 0), Vector3(0.045, 0.075, 0.04), skin)
	_box(_visual, Vector3(0, 2.0, -0.216), Vector3(0.09, 0.017, 0.013), cloth_2)
	_sphere(_visual, Vector3(0, 2.34, 0.018), Vector3(0.255, 0.14, 0.26), hair)
	var rng := RandomNumberGenerator.new()
	rng.seed = 90531
	for i in range(20):
		var a := float(i) * TAU / 20.0
		var r := rng.randf_range(0.12, 0.22)
		var length := rng.randf_range(0.19, 0.42)
		var lock := _cone(_visual, Vector3(sin(a) * r, 2.37 + rng.randf_range(-0.03, 0.08), cos(a) * r), Vector3(0.17, length, 0.19), hair if i % 3 else hair_hi, Vector3(rng.randf_range(-0.40, 0.45), a, rng.randf_range(-0.55, 0.55)))
		lock.rotation.z += sin(a) * 0.30
	for j in range(4):
		_cone(_visual, Vector3(-0.18 + j * 0.11, 2.29, -0.19), Vector3(0.14, 0.25, 0.15), hair_hi if j % 2 == 0 else hair, Vector3(-0.55, 0, -0.36))
	# Segmented arms, overbuilt layered pauldrons and glove plates.
	for side in [-1.0, 1.0]:
		var arm := Node3D.new()
		arm.position = Vector3(side * 0.36, 1.66, 0)
		_visual.add_child(arm)
		if side < 0:
			_left_arm = arm
		else:
			_right_arm = arm
		_sphere(arm, Vector3(side * 0.10, -0.10, 0), Vector3(0.23, 0.21, 0.24), silver)
		for k in range(3):
			var plate := _box(arm, Vector3(side * (0.12 + k * 0.06), 0.03 - k * 0.08, 0.02), Vector3(0.29, 0.12, 0.39), silver_hi if k == 0 else silver)
			plate.rotation.z = side * 0.19
		_box(arm, Vector3(side * 0.12, -0.31, 0), Vector3(0.17, 0.44, 0.19), cloth_2)
		_box(arm, Vector3(side * 0.13, -0.58, -0.02), Vector3(0.20, 0.29, 0.22), silver)
		_box(arm, Vector3(side * 0.13, -0.74, -0.01), Vector3(0.18, 0.14, 0.20), leather)
	# Legs pivot around the hips for a real walking silhouette.
	for side in [-1.0, 1.0]:
		var leg := Node3D.new()
		leg.position = Vector3(side * 0.19, 0.92, 0)
		_visual.add_child(leg)
		if side < 0:
			_left_leg = leg
		else:
			_right_leg = leg
		_box(leg, Vector3(0, -0.19, 0), Vector3(0.25, 0.48, 0.31), cloth_2)
		_box(leg, Vector3(0, -0.47, -0.055), Vector3(0.28, 0.42, 0.29), silver)
		_box(leg, Vector3(0, -0.70, -0.07), Vector3(0.29, 0.25, 0.33), silver_hi)
		_box(leg, Vector3(0, -0.81, -0.19), Vector3(0.34, 0.19, 0.49), leather)
		_box(leg, Vector3(0, -0.85, -0.39), Vector3(0.35, 0.045, 0.20), silver)
	# Lightweight overlapping coat panels, each bone-free joint moves independently.
	for i in range(5):
		var tail := Node3D.new()
		tail.position = Vector3((float(i) - 2.0) * 0.15, 1.18, 0.19)
		_visual.add_child(tail)
		_cape_nodes.append(tail)
		var panel := _box(tail, Vector3(0, -0.43, 0.19), Vector3(0.22, 0.97 + absf(2-i) * 0.1, 0.037), cloth if i % 2 else cloth_2)
		panel.rotation.z = (i - 2) * 0.09
		_box(tail, Vector3(0, -0.89, 0.25), Vector3(0.14, 0.03, 0.03), gold)
	# Sword rests on the back until actual hand-rig animation is added.
	_sword = Node3D.new()
	_sword.name = "Soulforged_Blade_Placeholder"
	_sword.position = Vector3(0.28, 1.43, 0.25)
	_sword.rotation = Vector3(0.18, 0.1, -0.43)
	_visual.add_child(_sword)
	_box(_sword, Vector3(0, 0.12, 0), Vector3(0.095, 0.85, 0.10), leather)
	_box(_sword, Vector3(0, -0.36, 0), Vector3(0.53, 0.08, 0.14), silver_hi)
	_box(_sword, Vector3(0, -0.90, 0), Vector3(0.15, 1.05, 0.045), _edge_material)
	_cone(_sword, Vector3(0, -1.50, 0), Vector3(0.17, 0.26, 0.07), _edge_material, Vector3(PI, 0, 0))
	# Arc mesh previews a fantasy strike; damage/enemies come in next milestone.
	_slash = Node3D.new()
	_slash.name = "SoulArc_AttackPreview"
	_slash.position = Vector3(0.0, 1.25, -0.8)
	_visual.add_child(_slash)
	var slash_mesh := _make_slash_mesh()
	var vfx := _material(Color(0.27, 0.93, 1.0, 0.65), 0.0, 0.12)
	vfx.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	vfx.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	vfx.cull_mode = BaseMaterial3D.CULL_DISABLED
	vfx.emission_enabled = true
	vfx.emission = Color(0.2, 0.86, 1.0)
	vfx.emission_energy_multiplier = 3.0
	_part(_slash, slash_mesh, vfx, Vector3.ZERO)
	_slash.visible = false

func _make_slash_mesh() -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(28):
		var a := -1.7 + float(i) / 28.0 * 3.4
		var b := -1.7 + float(i + 1) / 28.0 * 3.4
		var inner := 1.13
		var outer := 1.38
		var p0 := Vector3(cos(a) * inner, sin(a) * inner, 0)
		var p1 := Vector3(cos(a) * outer, sin(a) * outer, 0)
		var p2 := Vector3(cos(b) * inner, sin(b) * inner, 0)
		var p3 := Vector3(cos(b) * outer, sin(b) * outer, 0)
		for p in [p0, p1, p2, p1, p3, p2]:
			surface.add_vertex(p)
	return surface.commit()
