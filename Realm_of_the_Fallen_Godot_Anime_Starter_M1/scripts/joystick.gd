extends Control
## Multi-touch analog joystick. Other fingers remain free for actions or camera orbit.

var value: Vector2 = Vector2.ZERO
var touch_index: int = -1
var using_mouse: bool = false
const RADIUS := 81.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and touch_index == -1:
			touch_index = event.index
			_update_value(event.position)
			accept_event()
		elif not event.pressed and event.index == touch_index:
			touch_index = -1
			value = Vector2.ZERO
			queue_redraw()
			accept_event()
	elif event is InputEventScreenDrag and event.index == touch_index:
		_update_value(event.position)
		accept_event()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		using_mouse = event.pressed
		if using_mouse:
			_update_value(event.position)
		else:
			value = Vector2.ZERO
			queue_redraw()
		accept_event()
	elif event is InputEventMouseMotion and using_mouse:
		_update_value(event.position)
		accept_event()

func _update_value(local_pos: Vector2) -> void:
	var center := size * 0.5
	value = ((local_pos - center) / RADIUS).limit_length(1.0)
	queue_redraw()

func _draw() -> void:
	var c := size * 0.5
	draw_circle(c, 91.0, Color(0.025, 0.060, 0.082, 0.27))
	draw_arc(c, 88.0, 0.0, TAU, 80, Color(0.79, 0.68, 0.46, 0.48), 2.0, true)
	draw_arc(c, 65.0, 0.0, TAU, 72, Color(0.36, 0.82, 0.86, 0.15), 1.0, true)
	for i in range(4):
		var a := float(i) * PI / 2.0
		var p := c + Vector2(cos(a), sin(a)) * 87.0
		draw_colored_polygon(PackedVector2Array([p + Vector2(0, -5), p + Vector2(4, 0), p + Vector2(0, 5), p + Vector2(-4, 0)]), Color(0.86, 0.71, 0.42, 0.62))
	var knob := c + value * RADIUS
	draw_circle(knob, 33.0, Color(0.01, 0.075, 0.093, 0.76))
	draw_arc(knob, 32.0, 0.0, TAU, 60, Color(0.36, 0.91, 0.94, 0.85), 3.0, true)
	draw_circle(knob, 24.0, Color(0.14, 0.21, 0.24, 0.58))
