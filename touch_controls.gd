extends Control

@onready var joystick_base := $JoystickBase
@onready var joystick_handle := $JoystickHandle
var dead_zone_radius := 2000.0  # pixels; tweak as needed
@export var default_alpha : float = 0.5  # Default alpha when joystick is shown
@export var base_texture_scale: float = 0.15  # percent of screen width
@export var handle_size_multiplier: float = 3.0  # multiplier of base size
@export var radius_multiplier: float = 0.5	  # Radius as a fraction of base size


var radius := 70.0
var start_pos := Vector2.ZERO
var target_handle_pos := Vector2.ZERO

var is_dragged := false

var tap_detected := false
var touch_start_pos := Vector2.ZERO
var max_tap_distance := 20  # max movement allowed to count as a tap
var tap_start_time := 0.0
var max_tap_duration := 0.15  # seconds, max time for a tap

var tap_flash_duration := 0.2  # seconds the tap color stays visible
var tap_flash_timer := 0.0
var is_flashing_tap := false

var fade_delay := 0.5  # seconds before fading starts
var fade_duration := 0.2  # seconds to fully fade out

var fade_timer := 0.0
var fading_out := false

var original_start_pos := Vector2.ZERO  # store initial joystick base pos
func set_joystick_alpha(alpha: float) -> void:
	var color = Color(1, 1, 1, alpha)
	joystick_base.modulate = color
	joystick_handle.modulate = color
func set_joystick_color(color: Color) -> void:
	joystick_base.modulate = color
	joystick_handle.modulate = color

func _ready() -> void:
	set_joystick_color(Color(1, 1, 1, 0.0))  # white but fully transparent

	Controls.is_touch_enabled = true
	
	var base_size = get_viewport_rect().size.x * base_texture_scale
	joystick_base.size = Vector2(base_size, base_size)
	joystick_handle.size = joystick_base.size * handle_size_multiplier
	radius = base_size * radius_multiplier

	joystick_base.set_stretch_mode(TextureRect.STRETCH_SCALE)
	joystick_handle.set_stretch_mode(TextureRect.STRETCH_SCALE)

	await get_tree().process_frame

	original_start_pos = joystick_base.position + joystick_base.size * 0.5
	start_pos = original_start_pos
	target_handle_pos = start_pos - joystick_handle.size * 0.5
	joystick_handle.position = target_handle_pos


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var pos = get_local_mouse_position()
		if event.pressed:
			tap_detected = true
			touch_start_pos = pos
			tap_start_time = Time.get_ticks_msec() / 1000.0
			is_dragged = false  # Reset drag state

			set_joystick_alpha(default_alpha)
			fading_out = false  # cancel any ongoing fade

			start_pos = pos
			joystick_base.position = start_pos - joystick_base.size * 0.5
			target_handle_pos = start_pos - joystick_handle.size * 0.5
			joystick_handle.position = target_handle_pos
			Controls.joystick_vector = Vector2.ZERO

		else:
			var tap_duration = (Time.get_ticks_msec() / 1000.0) - tap_start_time
			if tap_detected and pos.distance_to(touch_start_pos) <= max_tap_distance and tap_duration <= max_tap_duration:
				Controls.interact_pressed = true

				# Change to gray color temporarily
				set_joystick_color(Color(0.6, 0.6, 1, default_alpha))  # gray with full alpha
				is_flashing_tap = true
				tap_flash_timer = tap_flash_duration

			tap_detected = false
			Controls.joystick_vector = Vector2.ZERO
			target_handle_pos = start_pos - joystick_handle.size * 0.5

			# Start fade-out countdown
			fade_timer = fade_delay
			fading_out = true

	elif event is InputEventScreenDrag:
		is_dragged = true  # Dragging started

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

	if is_flashing_tap:
		tap_flash_timer -= _delta
		if tap_flash_timer <= 0.0:
			is_flashing_tap = false
			Controls.interact_pressed = false
			var current_alpha = joystick_base.modulate.a
			set_joystick_color(Color(1, 1, 1, current_alpha))  # restore white with same alpha
	if fading_out:
		if fade_timer > 0.0:
			fade_timer -= _delta
		else:
			var current_alpha = joystick_base.modulate.a
			var new_alpha = lerp(current_alpha, 0.0, _delta / fade_duration)
			set_joystick_color(Color(1, 1, 1, new_alpha))  # fade white to transparent

			if new_alpha <= 0.01:
				set_joystick_color(Color(1, 1, 1, 0.0))
				fading_out = false
