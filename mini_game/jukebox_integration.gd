extends Node3D

@export var is_in_game : bool
@export var is_in_pos : bool
@export var camera_3d: Camera3D
@onready var icon_can_play: Control = $IconCanPlay
@onready var icon_pos: Marker3D = $IconPos
@onready var player_place: Marker3D = $PlayerPlace
@export var old_cam : Camera3D
@onready var touch_controls: Control = $TouchControls
@onready var button: Button = $Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera_3d.current = false
	pass # Replace with function body.

func interact():
	old_cam = get_viewport().get_camera_3d()
	AutoRun.player.can_control = false
	old_cam.current = false
	camera_3d.current = true
	is_in_game = true
	AutoRun.player.global_position = player_place.global_position
	
	pass
	
func out_game():
	is_in_game = true
	camera_3d.current = false
	old_cam.current = true
	AutoRun.player.can_control = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	camera_3d.visible = is_in_game
	button.visible = is_in_game
	touch_controls.visible = is_in_game
	if (AutoRun.player.current_interact):
		is_in_pos = AutoRun.player.current_interact.get_parent_node_3d() == self
		if (is_in_pos and not is_in_game):
			icon_can_play.visible = true
			var cam = get_viewport().get_camera_3d()
			
			icon_can_play.position = cam.unproject_position(icon_pos.global_position)
		else:
			icon_can_play.visible = false
	
	pass
