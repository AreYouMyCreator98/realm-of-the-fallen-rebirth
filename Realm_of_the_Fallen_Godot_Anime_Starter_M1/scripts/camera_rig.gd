extends Node3D
## Third-person camera with shoulder composition and smooth drag orbit.
var target: Node3D
var yaw := 0.0
var pitch := 0.26
var distance := 5.3
var camera: Camera3D
var _mouse_orbit := false
var _touch_orbit := -1

func _ready() -> void:
	camera = Camera3D.new()
	camera.name = "CinematicThirdPersonCamera"
	camera.current = true
	camera.fov = 54.0
	camera.near = 0.08
	camera.far = 110.0
	add_child(camera)
	camera.position = Vector3(0, 3.8, 6)
	camera.look_at(Vector3(0, 1.5, 0))

func _process(delta: float) -> void:
	if not is_instance_valid(target):
		return
	var focus := target.global_position + Vector3(0, 1.48, 0)
	var orbit := Vector3(sin(yaw) * distance * cos(pitch), distance * sin(pitch) + 0.64, cos(yaw) * distance * cos(pitch))
	var destination := focus + orbit
	# Lerp, rather than a hard snap, gives a premium soft-chase camera.
	camera.global_position = camera.global_position.lerp(destination, 1.0 - exp(-9.0 * delta))
	camera.look_at(focus, Vector3.UP)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and event.position.x > get_viewport().get_visible_rect().size.x * 0.38 and _touch_orbit == -1:
			_touch_orbit = event.index
		elif not event.pressed and event.index == _touch_orbit:
			_touch_orbit = -1
	elif event is InputEventScreenDrag and event.index == _touch_orbit:
		_orbit(event.relative)
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			_mouse_orbit = event.pressed
		if event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			distance = clampf(distance - 0.35, 3.4, 7.1)
		if event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			distance = clampf(distance + 0.35, 3.4, 7.1)
	elif event is InputEventMouseMotion and _mouse_orbit:
		_orbit(event.relative)

func _orbit(delta_pos: Vector2) -> void:
	yaw -= delta_pos.x * 0.007
	pitch = clampf(pitch - delta_pos.y * 0.004, -0.10, 0.74)
