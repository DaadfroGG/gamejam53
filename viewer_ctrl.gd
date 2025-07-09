extends Node3D

@export var mesh_instance_3d: Node3D
@export var speed_rot : float = 45
@export var origin_pos : Marker3D
@export var cnt : float
@export var view_point : Marker3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func interact():
	pass

func out_game():
	mesh_instance_3d.global_position = origin_pos.global_position
	mesh_instance_3d.global_rotation = origin_pos.global_rotation
	pass
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (get_parent_node_3d().is_in_game):
		if (cnt < 1):
			mesh_instance_3d.global_position = lerp(origin_pos.global_position, view_point.global_position, cnt)
			mesh_instance_3d.global_rotation = lerp(origin_pos.global_rotation, view_point.global_rotation, cnt)
		else:
			mesh_instance_3d.global_rotation = view_point.global_rotation
			
		
		var vec = Controls.joystick_vector
		mesh_instance_3d.rotate_y(vec.x * delta * speed_rot)
		mesh_instance_3d.rotate_x(vec.y * delta * speed_rot)
	else:
		mesh_instance_3d.global_position = origin_pos.global_position
		mesh_instance_3d.global_rotation = origin_pos.global_rotation
	pass
