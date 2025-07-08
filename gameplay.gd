extends Camera3D

@export var max_yaw_angle: float = 25.0
@export var max_pitch_angle: float = 20.0
@export var rotation_speed: float = 5.0
@export var projectile_speed: float = 10.0

var was_held := false
@onready var target: StaticBody3D = $"../StaticBody3D"
@onready var target_collision: CollisionShape3D = $"../StaticBody3D/CollisionShape3D"
@onready var ray_cast_3d: RayCast3D = $RayCast3D
@export var fov_normal: float = 70.0
@export var fov_zoomed: float = 50.0
@export var fov_anim_speed: float = 5.0
@onready var score_text: RichTextLabel = $"../RichTextLabel"
var total_score: float = 0.0
const PARTICLE = preload("res://particle.tscn")
const TRAIL_PARTICLE = preload("res://trail.tscn")
var center_rotation: Vector3
var current_rotation: Vector3

var projectiles := []

func _ready() -> void:
	center_rotation = rotation_degrees
	current_rotation = rotation_degrees
	fov = fov_normal

func _process(delta: float) -> void:
	var input_dir: Vector2 = Controls.direction
	var is_held := Controls.is_held

	if is_held and not was_held:
		print("Started holding input")

	if not is_held and was_held:
		print("Released input")
		_spawn_projectile()

	_update_projectiles(delta)

	was_held = is_held

	var target_yaw = center_rotation.y - input_dir.x * max_yaw_angle
	var target_pitch = center_rotation.x - input_dir.y * max_pitch_angle

	target_yaw = clamp(target_yaw, center_rotation.y - max_yaw_angle, center_rotation.y + max_yaw_angle)
	target_pitch = clamp(target_pitch, center_rotation.x - max_pitch_angle, center_rotation.x + max_pitch_angle)

	current_rotation.y = lerp(current_rotation.y, target_yaw, delta * rotation_speed)
	current_rotation.x = lerp(current_rotation.x, target_pitch, delta * rotation_speed)

	rotation_degrees.x = current_rotation.x
	rotation_degrees.y = current_rotation.y

	ray_cast_3d.target_position = -transform.basis.z * 1000.0
	ray_cast_3d.force_raycast_update()
	if ray_cast_3d.is_colliding():
		#print("ohyeaaah")
		var collision_point: Vector3 = ray_cast_3d.get_collision_point()
		var collision_center: Vector3 = target_collision.global_transform.origin

		var distance_to_center: float = collision_point.distance_to(collision_center)

		var cylinder_shape = target_collision.shape as CylinderShape3D
		var radius = cylinder_shape.radius if cylinder_shape else 1.0

		var normalized_distance = distance_to_center / radius
	if is_held:
		fov = lerp(fov, fov_zoomed, delta * fov_anim_speed)
	else:
		fov = lerp(fov, fov_normal, delta * fov_anim_speed)
func _spawn_projectile() -> void:
	# Reset if max darts reached ...
	if projectiles.size() >= 3:
		for p in projectiles:
			if is_instance_valid(p["node"]):
				p["node"].queue_free()
		projectiles.clear()
		total_score = 0.0
		score_text.bbcode_text = "[center][b]Score: 0[/b][/center]"
		print("Max darts reached — resetting all darts and score")

	var target_pos: Vector3

	if ray_cast_3d.is_colliding():
		target_pos = ray_cast_3d.get_collision_point()
	else:
		target_pos = global_transform.origin + (-global_transform.basis.z.normalized() * 100)

	var proj = MeshInstance3D.new()
	get_tree().current_scene.add_child(proj)
	proj.mesh = SphereMesh.new()
	proj.scale = Vector3(0.05, 0.05, 0.1)
	var forward = -global_transform.basis.z.normalized()
	proj.global_transform.origin = global_transform.origin + forward * 1.0
	proj.visible = true

	var trail = TRAIL_PARTICLE.instantiate()
	proj.add_child(trail)
	trail.position = Vector3.ZERO
	trail.emitting = true

	projectiles.append({
		"node": proj,
		"target_pos": target_pos,
		"moving": true
	})

func _update_projectiles(delta: float) -> void:
	total_score = 0.0

	var collision_center = target_collision.global_transform.origin

	for i in range(projectiles.size() - 1, -1, -1):
		var p = projectiles[i]
		var proj = p["node"]
		var target_pos = p["target_pos"]
		var current_pos = proj.global_transform.origin

		if p["moving"]:
			var direction = (target_pos - current_pos).normalized()
			var distance_left = current_pos.distance_to(target_pos)
			var step = projectile_speed * delta
			
			var next_pos = current_pos + direction * step
			
			var space_state = get_world_3d().direct_space_state
			
			var query = PhysicsRayQueryParameters3D.new()
			query.from = current_pos
			query.to = next_pos
			query.exclude = [proj]
			query.collision_mask = target.collision_layer
			
			var result = space_state.intersect_ray(query)

			if result and result.collider == target:
				proj.global_transform.origin = result.position
				p["moving"] = false
				print("Projectile hit target!")

				# Stop trail emission on all particle children
				for child in proj.get_children():
					if child.has_method("set_emitting"):
						child.emitting = false
						print("Stopped trail emission on hit")

				# Spawn impact particles
				var particles_instance = PARTICLE.instantiate()
				get_tree().current_scene.add_child(particles_instance)
				particles_instance.global_transform.origin = result.position
				particles_instance.emitting = true

				particles_instance.one_shot = true
				particles_instance.finished.connect(particles_instance.queue_free)

			elif step >= distance_left:
				proj.global_transform.origin = target_pos
				p["moving"] = false
				print("Projectile reached target")

				# Stop trail emission on all particle children
				for child in proj.get_children():
					if child.has_method("set_emitting"):
						child.emitting = false
						print("Stopped trail emission on reach")

			else:
				proj.global_transform.origin = next_pos

		
		var dist_to_center = proj.global_transform.origin.distance_to(collision_center)
		var cylinder_shape = target_collision.shape as CylinderShape3D
		var radius = cylinder_shape.radius if cylinder_shape else 1.0
		var normalized_distance = clamp(dist_to_center / radius, 0, 1)
		var score = 1.0 - normalized_distance
		
		total_score += score

	var display_score = int(round(total_score * 100))
	score_text.bbcode_text = "[center][b]Score: %d[/b][/center]" % display_score
