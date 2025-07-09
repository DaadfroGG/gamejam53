extends Camera3D

@export var max_yaw_angle: float = 25.0
@export var max_pitch_angle: float = 20.0
@export var rotation_speed: float = 5.0
@export var hand_move_speed: float = 5.0  # Speed of hand position lerp

@export var t_normal: float = 0.6        # Normal lerp factor (farther)
@export var t_interact: float = 0.4      # Closer lerp factor when interacting

@export var color_normal: Color = Color(1,1,1)         # white or default
@export var color_selected: Color = Color(0.2,1,0.0)   # greenish when selected
@export var color_pressed: Color = Color(1.0, 0.6, 0.2)  # orange-ish for pressed

@onready var hand: MeshInstance3D = $"../hand"
@onready var forward: StaticBody3D = $"../Forward"
@onready var backwards: StaticBody3D = $"../Backwards"
var was_interact_pressed: bool = false

var center_rotation: Vector3
var current_rotation: Vector3

var current_button: StaticBody3D = null
var target_hand_pos: Vector3  # The target position hand will move toward

const SWITCH_THRESHOLD := 8.0

func _ready() -> void:
	center_rotation = rotation_degrees
	current_rotation = rotation_degrees
	
	current_button = forward
	_update_target_hand_position(t_normal)
	_update_button_colors()

	# Initialize hand position
	hand.global_transform.origin = target_hand_pos

func _process(delta: float) -> void:
	var input_dir: Vector2 = Controls.direction
	var interact_pressed = Controls.interact_pressed  # Replace with your interact input check

	# Camera rotation
	var target_yaw = center_rotation.y - input_dir.x * max_yaw_angle
	var target_pitch = center_rotation.x - input_dir.y * max_pitch_angle

	target_yaw = clamp(target_yaw, center_rotation.y - max_yaw_angle, center_rotation.y + max_yaw_angle)
	target_pitch = clamp(target_pitch, center_rotation.x - max_pitch_angle, center_rotation.x + max_pitch_angle)

	current_rotation.y = lerp(current_rotation.y, target_yaw, delta * rotation_speed)
	current_rotation.x = lerp(current_rotation.x, target_pitch, delta * rotation_speed)

	rotation_degrees.x = current_rotation.x
	rotation_degrees.y = current_rotation.y

	# Decide which button to show based on yaw relative to center
	var yaw_diff = current_rotation.y - center_rotation.y
	var previous_button = current_button

	if yaw_diff > SWITCH_THRESHOLD:
		current_button = forward
	elif yaw_diff < -SWITCH_THRESHOLD:
		current_button = backwards
	
	if previous_button != current_button or was_interact_pressed != interact_pressed:
		_update_button_colors(interact_pressed)

	was_interact_pressed = interact_pressed

	if interact_pressed:
		_update_target_hand_position(t_interact)
	else:
		_update_target_hand_position(t_normal)

	# Smoothly move hand toward target position
	hand.global_transform.origin = hand.global_transform.origin.lerp(target_hand_pos, delta * hand_move_speed)

func _update_target_hand_position(t: float) -> void:
	var button_pos = current_button.global_transform.origin
	var camera_pos = global_transform.origin
	target_hand_pos = button_pos.lerp(camera_pos, t) - Vector3(0,0.20,0)

func _update_button_colors(pressed: bool = false) -> void:
	_set_button_color(forward, color_normal)
	_set_button_color(backwards, color_normal)
	
	if pressed:
		_set_button_color(current_button, color_pressed)
	else:
		_set_button_color(current_button, color_selected)

func _set_button_color(button: StaticBody3D, color: Color) -> void:
	var mesh_instance: MeshInstance3D = button.get_node_or_null("MeshInstance3D")
	if mesh_instance:
		var material := mesh_instance.material_override
		if not material or not (material is StandardMaterial3D):
			# Duplicate from mesh surface material if no override or not StandardMaterial3D
			var base_material := mesh_instance.mesh.surface_get_material(0)
			if base_material and base_material is StandardMaterial3D:
				material = base_material.duplicate()
				material.resource_local_to_scene = true
				mesh_instance.material_override = material
			else:
				return  # Can't set color if no valid material

		# Now safely modify the override
		material.albedo_color = color
