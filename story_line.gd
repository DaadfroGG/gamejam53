extends Node3D

@export var story_actions : Array[Action]

var already_triggered : Array[Action] = []

func _process(delta: float) -> void:
	var current_moment = AutoRun.moment

	for action in story_actions:
		if action.moment <= current_moment and action not in already_triggered:
			print("Action déclenchée :", action.qui, action.type, action.target)
			print("je vais cherchez " + action.qui)
			var char = AutoRun.get_node_in_group_by_name("pnj", action.qui)
			if (char):
				print("j'ai trouvé "+action.qui)
				if (action.type == "move"):
					print("je dit a " + action.qui + " d'allez " + action.target)
					char.go_to(action.target)
			already_triggered.append(action)
			
