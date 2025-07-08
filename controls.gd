extends Node
#move_up      → W / Up arrow
#move_down    → S / Down arrow
#move_left    → A / Left arrow
#move_right   → D / Right arrow
#interact     → E / Enter / Tap

@onready var direction := Vector2.ZERO
@onready var interact_pressed := false

# For on-screen joystick support
var joystick_vector := Vector2.ZERO
var is_touch_enabled := true
var is_held := false

func _process(_delta: float) -> void:
	_update_direction()

func _update_direction() -> void:
	var input_dir := Vector2.ZERO

	if !is_touch_enabled:
		input_dir.y -= Input.get_action_strength("up")
		input_dir.y += Input.get_action_strength("down")
		input_dir.x -= Input.get_action_strength("left")
		input_dir.x += Input.get_action_strength("right")

		is_held = input_dir.length_squared() > 0.0  # any key pressed
	else:
		input_dir = joystick_vector
		is_held = joystick_vector.length_squared() > 0.0  # joystick is dragged

	direction = input_dir  # Optional: normalize if needed
