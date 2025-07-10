extends Node3D

@export var node_action : Node3D
@export var scenario : Event_scenario
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	node_action.actions_scenario = scenario
	node_action.start_action()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
