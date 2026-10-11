extends CanvasLayer
## Premium mobile-native UI: no font, plugin, CDN or third-party dependency.
const Joystick = preload("res://scripts/joystick.gd")
const INK := Color(0.029, 0.051, 0.071, 0.76)
const GOLD := Color(0.79, 0.66, 0.43, 0.92)
const IVORY := Color(0.94, 0.93, 0.86)
const SOUL := Color(0.26, 0.86, 0.97)
const World = preload("res://scripts/world.gd")

var root_control: Control
var player # Runtime hero script; dynamic access to custom properties.
var stick: Control
var health_fill: ColorRect
var stamina_fill: ColorRect
var level_label: Label
var details_label: Label
var objective_label: Label
var quality_button: Button
var attack_button: Button
var guard_button: Button
var dodge_button: Button
var heal_button: Button
var tooltip: Label
var high_quality := true
var _layout_size := Vector2.ZERO
var _toast_timer := 0.0
var _elapsed := 0.0

func _ready() -> void:
	root_control = Control.new()
	root_control.name = "SafeAreaHUD"
	root_control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root_control)
	_construct()
	_layout()

func _card(parent: Control, name: String, rect: Rect2, edge: Color = GOLD) -> Panel:
	var p := Panel.new()
	p.name = name
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.position = rect.position
	p.size = rect.size
	var st := StyleBoxFlat.new()
	st.bg_color = INK
	st.border_color = edge
	st.set_border_width_all(1)
	st.set_corner_radius_all(15)
	st.shadow_color = Color(0.0, 0.0, 0.0, 0.26)
	st.shadow_size = 7
	p.add_theme_stylebox_override("panel", st)
	parent.add_child(p)
	return p

func _label(parent: Control, val: String, at: Vector2, sz: int, col: Color = IVORY) -> Label:
	var lab := Label.new()
	lab.text = val
	lab.position = at
	lab.add_theme_font_size_override("font_size", sz)
	lab.add_theme_color_override("font_color", col)
	lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(lab)
	return lab

func _button(name: String, txt: String, stroke: Color = GOLD) -> Button:
	var b := Button.new()
	b.name = name
	b.text = txt
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_size_override("font_size", 18)
	b.add_theme_color_override("font_color", IVORY)
	b.add_theme_color_override("font_hover_color", Color.WHITE)
	for mode in ["normal", "hover", "pressed", "disabled"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.035, 0.075, 0.096, 0.85) if mode != "pressed" else Color(0.12, 0.29, 0.31, 0.94)
		style.border_color = stroke if mode != "disabled" else Color(0.3, 0.35, 0.35)
		style.set_border_width_all(3 if mode == "pressed" else 2)
		style.set_corner_radius_all(66)
		style.shadow_color = Color(stroke.r, stroke.g, stroke.b, 0.25)
		style.shadow_size = 9 if mode == "normal" else 3
		b.add_theme_stylebox_override(mode, style)
	root_control.add_child(b)
	return b

func _bar(parent: Control, at: Vector2, color: Color) -> ColorRect:
	var track := ColorRect.new()
	track.color = Color(0.04, 0.06, 0.08, 0.86)
	track.position = at
	track.size = Vector2(248, 10)
	parent.add_child(track)
	var fill := ColorRect.new()
	fill.color = color
	fill.position = at + Vector2(2, 2)
	fill.size = Vector2(244, 6)
	parent.add_child(fill)
	return fill

func _construct() -> void:
	var status := _card(root_control, "WandererVitals", Rect2(0, 0, 347, 118))
	_label(status, "✧ THE WANDERER", Vector2(19, 9), 23)
	level_label = _label(status, "LV 01", Vector2(284, 15), 15, GOLD)
	_label(status, "LIFE", Vector2(19, 47), 11, Color(0.89, 0.67, 0.64))
	health_fill = _bar(status, Vector2(80, 48), Color(0.96, 0.41, 0.43))
	_label(status, "SOUL", Vector2(19, 75), 11, SOUL)
	stamina_fill = _bar(status, Vector2(80, 76), Color(0.29, 0.84, 0.75))
	details_label = _label(status, "HP 100 / 100    ST 100 / 100", Vector2(17, 97), 10, Color(0.68, 0.77, 0.78))
	var header := _card(root_control, "Compass", Rect2(0, 0, 385, 39), Color(0.44, 0.63, 0.67, 0.60))
	var mark := _label(header, "W       ◇        N  ◆         E", Vector2(54, 4), 18, GOLD)
	mark.custom_minimum_size.x = 310
	var quest := _card(root_control, "Quest", Rect2(0, 0, 428, 63))
	_label(quest, "✦  THE AWAKENING", Vector2(17, 6), 20, IVORY)
	objective_label = _label(quest, "Follow the moonlit road to the sealed gate.", Vector2(18, 34), 13, Color(0.65, 0.84, 0.88))
	var info := _card(root_control, "Weather", Rect2(0, 0, 273, 36), Color(0.48, 0.69, 0.75, 0.45))
	_label(info, "☾  DAY 01   ·   MOONLIT   ·   MIST", Vector2(13, 6), 12, GOLD)
	stick = Joystick.new()
	stick.name = "MobileAnalogJoystick"
	stick.size = Vector2(200, 200)
	root_control.add_child(stick)
	attack_button = _button("Attack", "⚔\nATTACK")
	attack_button.add_theme_font_size_override("font_size", 20)
	guard_button = _button("Guard", "◇\nGUARD", Color(0.57, 0.77, 0.90))
	dodge_button = _button("Dodge", "↯\nDODGE", SOUL)
	heal_button = _button("Heal", "+\nHEAL", Color(0.45, 0.88, 0.68))
	quality_button = _button("QualityToggle", "✧ HIGH", GOLD)
	quality_button.add_theme_font_size_override("font_size", 13)
	tooltip = _label(root_control, "", Vector2.ZERO, 16, Color(0.92, 0.94, 0.86))
	tooltip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tooltip.visible = false
	attack_button.pressed.connect(_on_attack)
	dodge_button.pressed.connect(_on_dodge)
	heal_button.pressed.connect(_on_heal)
	guard_button.button_down.connect(_guard_start)
	guard_button.button_up.connect(_guard_end)
	quality_button.pressed.connect(_toggle_quality)

func _process(delta: float) -> void:
	if get_viewport().get_visible_rect().size != _layout_size:
		_layout()
	_elapsed += delta
	if is_instance_valid(player):
		player.analog = stick.value
		health_fill.size.x = lerpf(health_fill.size.x, 244.0 * player.health / 100.0, minf(1.0, delta * 8))
		stamina_fill.size.x = lerpf(stamina_fill.size.x, 244.0 * player.stamina / 100.0, minf(1.0, delta * 8))
		details_label.text = "HP %03d / 100    ST %03d / 100" % [ceili(player.health), ceili(player.stamina)]
		dodge_button.modulate = Color.WHITE if player.dodge_cooldown <= 0 else Color(0.60, 0.68, 0.73, 0.65)
	_toast_timer = maxf(0.0, _toast_timer - delta)
	tooltip.visible = _toast_timer > 0.0

func _layout() -> void:
	if root_control == null:
		return
	var bounds := get_viewport().get_visible_rect().size
	_layout_size = bounds
	var k := clampf(bounds.x / 720.0, 0.48, 1.1)
	var h := bounds.y
	var w := bounds.x
	var status := root_control.get_node("WandererVitals") as Control
	status.scale = Vector2.ONE * k
	status.position = Vector2(20 * k, 21 * k)
	var compass := root_control.get_node("Compass") as Control
	compass.scale = Vector2.ONE * k
	compass.position = Vector2(w * 0.5 - 192.5 * k, 144 * k)
	var quest := root_control.get_node("Quest") as Control
	quest.scale = Vector2.ONE * k
	quest.position = Vector2(w * 0.5 - 214 * k, 195 * k)
	var weather := root_control.get_node("Weather") as Control
	weather.scale = Vector2.ONE * k
	weather.position = Vector2(w * 0.5 - 136.5 * k, 270 * k)
	quality_button.position = Vector2(w - 135 * k, 24 * k)
	quality_button.size = Vector2(116, 44) * k
	quality_button.add_theme_font_size_override("font_size", maxi(10, int(13 * k)))
	stick.position = Vector2(24 * k, h - 252 * k)
	stick.scale = Vector2.ONE * k
	attack_button.position = Vector2(w - 164 * k, h - 179 * k)
	attack_button.size = Vector2(132, 132) * k
	guard_button.position = Vector2(w - 276 * k, h - 257 * k)
	guard_button.size = Vector2(94, 94) * k
	dodge_button.position = Vector2(w - 281 * k, h - 129 * k)
	dodge_button.size = Vector2(93, 93) * k
	heal_button.position = Vector2(w - 163 * k, h - 325 * k)
	heal_button.size = Vector2(92, 92) * k
	tooltip.position = Vector2(w * 0.5 - 270 * k, h * 0.68)
	tooltip.size = Vector2(540 * k, 45 * k)
	tooltip.add_theme_font_size_override("font_size", int(17 * k))

func toast(message: String) -> void:
	tooltip.text = message
	_toast_timer = 2.8
	tooltip.visible = true

func _on_attack() -> void:
	if is_instance_valid(player):
		player.strike()

func _on_dodge() -> void:
	if is_instance_valid(player):
		player.dodge()

func _on_heal() -> void:
	if is_instance_valid(player) and player.drink_potion():
		toast("Aether restored.")
	else:
		toast("Health is full. Potions come later.")

func _guard_start() -> void:
	if is_instance_valid(player):
		player.set_guard(true)

func _guard_end() -> void:
	if is_instance_valid(player):
		player.set_guard(false)

func _toggle_quality() -> void:
	high_quality = not high_quality
	quality_button.text = "✧ HIGH" if high_quality else "✧ ECO"
	get_viewport().scaling_3d_scale = 1.0 if high_quality else 0.77
	World.set_quality(high_quality)
	toast("Graphics: " + ("High lighting + shadows" if high_quality else "Eco — shadows off"))
