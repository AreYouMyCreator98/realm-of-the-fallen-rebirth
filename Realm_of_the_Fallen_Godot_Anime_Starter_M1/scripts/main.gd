extends Node3D
## Realm of the Fallen: The Awakening.
## Godot 4.7 + Vulkan Mobile; all lighting and world assets are local.

const World = preload("res://scripts/world.gd")
const Hero = preload("res://scripts/hero.gd")
const Camera = preload("res://scripts/camera_rig.gd")
const HUD = preload("res://scripts/hud.gd")

var hero # Runtime hero.gd
var camera_rig # Runtime camera_rig.gd
var hud # Runtime hud.gd
var _gate_message_sent := false

func _ready() -> void:
	_setup_input()
	World.populate(self)
	hero = Hero.new()
	hero.position = Vector3(0.0, 0.20, 13.3)
	add_child(hero)
	camera_rig = Camera.new()
	camera_rig.target = hero
	add_child(camera_rig)
	hud = HUD.new()
	hud.player = hero
	add_child(hud)
	hud.toast("THE AWAKENING  ·  Follow the moonlit path")

func _process(delta: float) -> void:
	World.tick(delta)
	if is_instance_valid(hero) and is_instance_valid(camera_rig):
		hero.camera_yaw = camera_rig.yaw
		if hero.position.z < -23.0 and not _gate_message_sent:
			_gate_message_sent = true
			hud.toast("THE SEALED GATE  ·  Chapter one awaits...")
		if hero.position.z > -20.0:
			_gate_message_sent = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		hero.strike()
	elif event.is_action_pressed("dodge"):
		hero.dodge()
	elif event.is_action_pressed("guard"):
		hero.set_guard(true)
	elif event.is_action_released("guard"):
		hero.set_guard(false)

func _setup_input() -> void:
	_bind("move_left", KEY_A)
	_bind("move_right", KEY_D)
	_bind("move_forward", KEY_W)
	_bind("move_back", KEY_S)
	_bind("sprint", KEY_SHIFT)
	_bind("attack", KEY_J)
	_bind("dodge", KEY_SPACE)
	_bind("guard", KEY_K)

func _bind(action: String, key: Key) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	var ev := InputEventKey.new()
	ev.physical_keycode = key
	if not InputMap.action_has_event(action, ev):
		InputMap.action_add_event(action, ev)
