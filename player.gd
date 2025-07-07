extends CharacterBody3D

@onready var hitbox: Area3D = $HitBox

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const HITBOX_OFFSET_DISTANCE = 1.3
var last_input_dir := Vector2.ZERO
var current_interact: Node3D = null

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	if input_dir.length() > 0:
		last_input_dir = input_dir.normalized()
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	#if Input.is_action_pressed("run"):
		#print("run")
		#velocity.x = direction.x * SPEED*3
		#velocity.z = direction.z * SPEED*3
	# Offset hitbox in last input direction
	#var current_y := 1
	var offset_direction = (transform.basis * Vector3(last_input_dir.x, 0, last_input_dir.y)).normalized()
	hitbox.transform.origin = Vector3(
		offset_direction.x,
		0,
		offset_direction.z
	) * HITBOX_OFFSET_DISTANCE

	move_and_slide()

func _on_hit_box_body_entered(body: Node3D) -> void:
	if current_interact == null:
		print("Body detected:", body)
		current_interact = body
	pass # Replace with function body.


func _on_hit_box_body_exited(body: Node3D) -> void:
	if body == current_interact:
		print("Body Out:", body)
		current_interact = null
	pass # Replace with function body.
