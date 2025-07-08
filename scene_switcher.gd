extends Node


@export var next_scene : String
@export var cnt : float
@export var limite : float
@export var finish : bool
@export var text : Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _next_scene():
	get_tree().change_scene_to_packed(load(next_scene))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	cnt += delta
	AutoRun.moment = cnt
	if (text):
		text.text = str(floor(AutoRun.moment))
	if (cnt >= limite and finish == false):
		print("fin")
		_next_scene()
		finish = true
	pass
