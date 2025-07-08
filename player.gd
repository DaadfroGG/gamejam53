extends CharacterBody3D
class_name Player

@onready var hitbox: Area3D = $HitBox

@export var tactil_ctrl: bool  # Optional; not needed anymore unless you use it elsewhere


@export var input_dir: Vector2  # ✅ Add this line if not already defined

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const HITBOX_OFFSET_DISTANCE = 1.3

var last_input_dir := Vector2.ZERO
var current_interact: Node3D = null
var in_dialogue: bool = false

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Get movement direction from Controls
	var input_dir := Controls.direction

	# Save last direction if any input
	if input_dir.length() > 0:
		last_input_dir = input_dir

	# Interaction (single tap or key)
	if Controls.interact_pressed and current_interact != null:
		var body_name = current_interact.name
		print("NAME: ", body_name)

		match body_name:
			"Barman":
				print("You are talking to the Barman.")
				current_interact.interact()
				in_dialogue = not current_interact.is_finish  # ← update dialogue state *after* interact
			"Jukebox":
				print("You are interacting with the Jukebox.")
			_:
				print("Unknown interactable: ", body_name)

	# Only move if not in dialogue
	if not in_dialogue:
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y))
		if direction != Vector3.ZERO:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)

		# Move hitbox in last direction
		var offset_direction = (transform.basis * Vector3(last_input_dir.x, 0, last_input_dir.y))
		hitbox.transform.origin = offset_direction * HITBOX_OFFSET_DISTANCE

		move_and_slide()


func _on_hit_box_body_entered(body: Node3D) -> void:
	if current_interact == null:
		print("Body detected:", body)
		current_interact = body


func _on_hit_box_body_exited(body: Node3D) -> void:
	if body == current_interact:
		print("Body Out:", body)
		current_interact = null
