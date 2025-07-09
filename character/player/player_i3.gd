extends CharacterBody3D
class_name Player

@onready var hitbox: Area3D = $HitBox
@onready var anim := $all/AnimationPlayer

@export var tactil_ctrl: bool  # Optional; not needed anymore unless you use it elsewhere
@export var is_moving: bool = false
@export var can_control: bool = true

@export var input_dir: Vector2  # ✅ Add this line if not already defined

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const HITBOX_OFFSET_DISTANCE = 1.3

var last_input_dir := Vector2.ZERO
var current_interact: Node3D = null
var in_dialogue: bool = false

func _ready() -> void:
	AutoRun.player = self
func _process(delta: float) -> void:
	if (not can_control):
		return
	if (velocity.length() > 0.1):
		is_moving = true
		anim.play("walk")
	else:
		anim.play("idle")
		
	is_moving = velocity.length() > 0.1
	

func _physics_process(delta: float) -> void:
	if (not can_control):
		return
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	var cam = get_viewport().get_camera_3d()

	# Get movement direction from Controls
	var input_dir := Controls.direction

	# Save last direction if any input
	if input_dir.length() > 0:
		last_input_dir = input_dir

	# Interaction (single tap or key)
	if Controls.interact_pressed and current_interact != null:
		Controls.interact_pressed = false
		var body_name = current_interact.name
		print("NAME: ", body_name)

		match body_name:
			"Barman":
				print("You are talking to the Barman.")
				current_interact.interact()
				in_dialogue = not current_interact.is_finish
			"Jukebox":
				print("You are interacting with the Jukebox.")
				current_interact.interact()
			"ObjectViewer":
				print("vous regarder un object.")
				current_interact.interact()
			"ArrowGame":
				print("vous avez intéragie avec le jeu de flechette.")
				current_interact.interact()
			_:
				print("Unknown interactable: ", body_name)

	# Only move if not in dialogue
	if not in_dialogue:
		var cam_basis = cam.global_transform.basis

		var forward = -cam_basis.z
		forward.y = 0
		forward = -forward.normalized()

		var right = cam_basis.x
		right.y = 0
		right = right.normalized()

		var direction = (right * input_dir.x + forward * input_dir.y).normalized()
		
		# Si on a une direction valide, on tourne le personnage dans ce sens
		if direction != Vector3.ZERO:
			look_at(global_transform.origin + direction, Vector3.UP)
			rotate_y(deg_to_rad(90))  # Ajuste selon ton modèle

		if direction != Vector3.ZERO:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)

		# Move hitbox in last direction
		var offset_direction = (right * last_input_dir.x + forward * last_input_dir.y).normalized()
		hitbox.transform.origin = offset_direction * HITBOX_OFFSET_DISTANCE

		move_and_slide()


func _on_hit_box_body_entered(body: Node3D) -> void:
	print(body)
	if current_interact == null:
		print("Body detected:", body)
		current_interact = body


func _on_hit_box_body_exited(body: Node3D) -> void:
	if body == current_interact:
		print("Body Out:", body)
		current_interact = null
