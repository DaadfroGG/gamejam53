extends Control

@onready var joystick_base := $JoystickBase
@onready var joystick_handle := $JoystickHandle
var dead_zone_radius := 2000.0  # pixels; tweak as needed

var radius := 100.0
var start_pos := Vector2.ZERO
var target_handle_pos := Vector2.ZERO


var tap_detected := false
var touch_start_pos := Vector2.ZERO
var max_tap_distance := 20  # max movement allowed to count as a tap
var tap_start_time := 0.0
var max_tap_duration := 0.25  # seconds, max time for a tap

var original_start_pos := Vector2.ZERO  # store initial joystick base pos

func _ready() -> void:
	Controls.is_touch_enabled = true
	
	var base_size = get_viewport_rect().size.x * 0.15
	joystick_base.size = Vector2(base_size, base_size)
	joystick_handle.size = joystick_base.size * 2
	
	joystick_base.set_stretch_mode(TextureRect.STRETCH_SCALE)
	joystick_handle.set_stretch_mode(TextureRect.STRETCH_SCALE)

	await get_tree().process_frame

	original_start_pos = joystick_base.position + joystick_base.size * 0.5
	start_pos = original_start_pos
	target_handle_pos = start_pos - joystick_handle.size * 0.5
	joystick_handle.position = target_handle_pos


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var pos = get_local_mouse_position()

		if event.pressed:
			tap_detected = true
			touch_start_pos = pos
			tap_start_time = Time.get_ticks_msec() / 1000.0  # current time in seconds
			
			# Move joystick base under finger as before
			start_pos = pos
			joystick_base.position = start_pos - joystick_base.size * 0.5
			target_handle_pos = start_pos - joystick_handle.size * 0.5
			joystick_handle.position = target_handle_pos
			Controls.joystick_vector = Vector2.ZERO

		else:
			# On release, check if it was a tap with time limit
			var tap_duration = (Time.get_ticks_msec() / 1000.0) - tap_start_time
			if tap_detected and pos.distance_to(touch_start_pos) <= max_tap_distance and tap_duration <= max_tap_duration:
				Controls.interact_pressed = true
				print("Joystick tap detected! interact_pressed set to true. Duration: ", tap_duration)
			tap_detected = false

			# Leave joystick base where it was; reset vector and optionally center handle
			Controls.joystick_vector = Vector2.ZERO
			target_handle_pos = start_pos - joystick_handle.size * 0.5

	elif event is InputEventScreenDrag:
		var pos = get_local_mouse_position()
		# If drag moves too far, cancel tap detection
		if tap_detected and pos.distance_to(touch_start_pos) > max_tap_distance:
			tap_detected = false

		var delta = pos - start_pos
		var dist = delta.length()

		if dist > dead_zone_radius:
			Controls.joystick_vector = Vector2.ZERO
			target_handle_pos = start_pos - joystick_handle.size * 0.5
		else:
			var clamped = delta.normalized() * min(dist, radius)
			var vec = clamped / radius
			Controls.joystick_vector = vec.limit_length(1.0)
			target_handle_pos = start_pos + clamped - joystick_handle.size * 0.5


var lerp_speed := 0.999  # Close to 1.0 = almost instant snap; lower = slower
func _process(_delta: float) -> void:
	joystick_handle.position = joystick_handle.position.lerp(
		target_handle_pos,
		1.0 - pow(1.0 - lerp_speed, _delta)
	)
