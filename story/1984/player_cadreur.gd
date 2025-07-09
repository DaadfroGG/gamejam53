extends Node3D


@export var cam_ctrl : Node3D
@export var cam_entrer : Marker3D
@export var cam_bar : Marker3D
@export var cam_back : Marker3D
@export var cam_barback1 : Marker3D
@export var cam_barback2 : Marker3D
@export var cam_center : Marker3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_entrer_body_entered(body: Node3D) -> void:
	if (body.name == "Player"):
		print("je suis arrivé dans l'entré")
		cam_ctrl.go_to(cam_entrer)
	pass # Replace with function body.


func _on_area_3d_body_bar_cam_entered(body: Node3D) -> void:
	if (body.name == "Player"):
		print("je suis arrivé dans l'entré")
		cam_ctrl.go_to(cam_bar)
	pass # Replace with function body.


func _on_area_3d_body_back_cam_entered(body: Node3D) -> void:
	if (body.name == "Player"):
		print("je suis arrivé dans l'entré")
		cam_ctrl.go_to(cam_back)
	pass # Replace with function body.


func _on_area_3d_body_bar_back1_cam_entered(body: Node3D) -> void:
	if (body.name == "Player"):
		print("je suis arrivé dans l'entré")
		cam_ctrl.go_to(cam_barback1)
	pass # Replace with function body.

func _on_area_3d_body_bar_back2_cam_entered(body: Node3D) -> void:
	if (body.name == "Player"):
		print("je suis arrivé dans l'entré")
		cam_ctrl.go_to(cam_barback2)
	pass # Replace with function body.
	
func _on_area_3d_body_center_cam_entered(body: Node3D) -> void:
	if (body.name == "Player"):
		print("je suis arrivé dans l'entré")
		cam_ctrl.go_to(cam_center)
	pass # Replace with function body.
