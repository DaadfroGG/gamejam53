extends Control

@export var pnj : Node
@export var player : Node
@export var is_active : bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (not is_active):
		self.visible = false
	else:
		self.visible = player.current_interact == pnj
	pass


func _on_barman_cam_in() -> void:
	is_active = false
	pass # Replace with function body.


func _on_barman_cam_out() -> void:
	is_active = true
	pass # Replace with function body.
