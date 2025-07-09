extends Node3D

enum cam_pos {base, barman, other}
@export var cam : Camera3D
@export var cnt : float
@export var cadre : cam_pos

@export var curve_fov : Curve
@export var curve_pos : Curve
@export var curve_rot : Curve

@export var duree: float

@export var cam_base : Marker3D
@export var cam_bar : Marker3D


var beg_pos : Vector3
var beg_rot : Vector3
var beg_fov : float

var end_pos : Vector3
var end_rot : Vector3
var end_fov : float



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	go_bar()
	pass # Replace with function body.


func go_base():
	cnt = 0
	cadre = cam_pos.base
	beg_setup()
	get_marker(cadre)

func go_bar():
	cnt = 0
	cadre = cam_pos.barman
	beg_setup()
	get_marker(cadre)

func go_to(marker : Marker3D):
	cnt = 0
	cadre = cam_pos.other
	beg_setup()
	end_pos = marker.global_position
	end_rot = marker.global_rotation
	end_fov = marker.fov
		
func get_marker(curr_cam : cam_pos):
	if (curr_cam == cam_pos.base):
		end_pos = cam_base.global_position
		end_rot = cam_base.global_rotation
		end_fov = cam_base.fov
	
	if (curr_cam == cam_pos.barman):
		end_pos = cam_bar.global_position
		end_rot = cam_bar.global_rotation
		end_fov = cam_bar.fov
	pass
func beg_setup():
	beg_pos = cam.global_position
	beg_rot = cam.global_rotation
	beg_fov = cam.fov
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (cnt <= duree):
		cam.global_position = lerp(beg_pos, end_pos, curve_pos.sample(cnt / duree))
		cam.global_rotation = lerp(beg_rot, end_rot, curve_rot.sample(cnt / duree))
		cam.fov = clamp(lerp(beg_fov, end_fov, curve_fov.sample(cnt / duree)), 1.0, 179.0)

		cnt += delta
	
	
	pass
