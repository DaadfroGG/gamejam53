extends Control

# Public: resulting direction, X = horizontal, Z = vertical (Y kept for 3‑D compatibility)
@export var dir_analogue: Vector3 = Vector3.ZERO
@export var tmp : CharacterBody3D 
# Maximum distance (in pixels) the stick can travel before being clamped
@export var max_distance := 120.0

# Private state
var _touch_id: int = -1           # Id of the finger that owns this joystick, -1 when free
var _start_pos: Vector2 = Vector2.ZERO  # Position where the touch started

func _ready() -> void:
	# We want to receive the raw touch events
	set_process_input(true)

func _input(event: InputEvent) -> void:
	# --- A finger touches the screen ---
	if event is InputEventScreenTouch:
		var st := event as InputEventScreenTouch
		if st.pressed:
			# Grab the first free finger
			if _touch_id == -1:
				_touch_id = st.index
				_start_pos = st.position
				dir_analogue = Vector3.ZERO
		else:
			# Finger released → reset everything
			if st.index == _touch_id:
				_touch_id = -1
				dir_analogue = Vector3.ZERO

	# --- Finger is moving while pressed ---
	elif event is InputEventScreenDrag and event.index == _touch_id:
		var drag := event as InputEventScreenDrag
		var delta: Vector2 = drag.position - _start_pos

		# Clamp to the desired max radius
		if delta.length() > max_distance:
			delta = delta.normalized() * max_distance

		# Convert 2‑D delta → 3‑D direction (XZ plane)
		var dir2d := delta / max_distance  # Now in the range [‑1,1]
		dir_analogue = Vector3(dir2d.x, 0.0, dir2d.y)

		# Optional: tell other UI elements we handled this touch
		get_viewport().set_input_as_handled()

func _process(_delta: float) -> void:
	# Debug: draw the base circle + stick in the editor/game. Remove if you have your own graphics.
	if Engine.is_editor_hint():
		queue_redraw()
	tmp.input_dir = Vector2(dir_analogue.x, dir_analogue.z)
	

func _draw() -> void:
	if _touch_id != -1:
		# Draw base circle
		draw_circle(_start_pos, max_distance, Color(0.3,0.3,0.3,0.2))
		# Draw stick position
		var stick_pos := _start_pos + Vector2(dir_analogue.x, dir_analogue.z) * max_distance
		draw_circle(stick_pos, 20, Color(0.8,0.8,0.8,0.9))
