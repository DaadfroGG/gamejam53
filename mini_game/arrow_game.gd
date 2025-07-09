extends Node3D


@export var player_in_zone:bool
@export var is_in_game:bool
@onready var camera_3d: Camera3D = $Camera3D
@onready var ray_cast_3d: RayCast3D = $Camera3D/RayCast3D
@onready var rich_text_label: Label = $RichTextLabel
@onready var can_play_icon : Control = $IconCanPlay
@onready var icon_pos : Marker3D = $IconPos
@onready var player_place : Marker3D = $PlayerPlace


@export var old_cam : Camera3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	camera_3d.visible = is_in_game
	ray_cast_3d.visible = is_in_game
	ray_cast_3d.visible = is_in_game
	
	if (not is_in_game and AutoRun.player.current_interact and AutoRun.player.current_interact.get_parent_node_3d() == self):
		can_play_icon.visible = true
		var cam = get_viewport().get_camera_3d()
		can_play_icon.position = cam.unproject_position(icon_pos.global_position)
		
	else:
		can_play_icon.visible = false
	pass
	
func out_game():
	is_in_game = false
	AutoRun.player.can_control = true
	old_cam.current = true
	camera_3d.current = false
	old_cam.visible = true

func interact():
	print("=======================")
	print("=======Fleshette=======")
	print("=======================")
	old_cam = get_viewport().get_camera_3d()
	old_cam.visible = false
	old_cam.current = false
	camera_3d.reset_state()
	camera_3d.current = true
	AutoRun.player.can_control = false
	AutoRun.player.global_position = player_place.global_position
	is_in_game = true


func _on_area_3d_body_entered(body: Node3D) -> void:
	if (body.name == "Player"):
		player_in_zone = true
		
	pass # Replace with function body.


func _on_area_3d_body_exited(body: Node3D) -> void:
	if (body.name == "Player"):
		player_in_zone = false
	pass # Replace with function body.
