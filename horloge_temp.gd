extends Node3D

@export var cnt:float 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cnt =0
	AutoRun.moment = cnt
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	cnt += delta
	AutoRun.moment = cnt
	pass
