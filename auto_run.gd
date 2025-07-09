extends Node

var moment : float
var player : Node3D
var back_btn : ColorRect
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
func get_node_in_group_by_name(group_name: String, node_name: String) -> Node:
	for node in get_tree().get_nodes_in_group(group_name):
		if node.name == node_name:
			return node
	return null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
