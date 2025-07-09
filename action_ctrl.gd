extends Node3D

@export var actions : Array[Dictionary]
@export var action_index : int = 0
@export var pnj : Node3D
@export var speed : float
@export var wait_cnt : float
@export var is_waiting : bool
@export var NavAg: NavigationAgent3D
@export var targer_marker : Marker3D

var moving := false

func _ready() -> void:
	pnj.anim_finished.connect(_current_anim_is_finish)
	if actions.size() != 0:
		_interpret_action(actions[action_index])

func _interpret_action(action : Dictionary):
	if not action:
		print("aucune action")
		return

	print("Action reçue :", action)

	if action["type"] == "anim":
		print("→ Animation :", action["target"])
		pnj.anim.play(action["target"])
	elif action["type"] == "wait":
		wait_cnt = float(action["target"])
		is_waiting = true
		if (action.has("anim")):
			pnj.anim.play(action["anim"])
		else:
			pnj.anim.play("test/idle")
	elif action["type"] == "to_time":
		wait_cnt = float(action["target"]) - AutoRun.moment
		is_waiting = true
		if (action.has("anim")):
			pnj.anim.play(action["anim"])
		else:
			pnj.anim.play("test/idle")
	elif action["type"] == "move":
		print("→ Déplacement vers :", action["target"])
		var target_node = get_node_in_group_by_name("gaffeur", action["target"])
		if target_node:
			targer_marker = target_node
			NavAg.target_position = target_node.global_position
			if (action.has("anim")):
				pnj.anim.play(action["anim"])
			else:
				pnj.anim.play("walk")
			moving = true
		else:
			print("Cible introuvable")
			_next_action()

func get_node_in_group_by_name(group_name: String, node_name: String) -> Node:
	for node in get_tree().get_nodes_in_group(group_name):
		if node.name == node_name:
			return node
	return null

func _current_anim_is_finish(name: String):
	if (moving):
		return
	if (actions.size() <= action_index):
		return
	var act = actions[action_index]
	if act["type"] == "anim" and act["target"] == name:
		print("→ Animation terminée :", name)
		_next_action()
	else:
		print("→ Autre animation terminée :", name)

func _next_action():
	action_index += 1
	if action_index < actions.size():
		_interpret_action(actions[action_index])
	else:
		print("Toutes les actions ont été traitées.")

func _process(delta: float) -> void:
	if is_waiting:
		wait_cnt -= delta
		if (wait_cnt <= 0):
			wait_cnt = 0
			is_waiting = false
			_next_action()
	if moving:
		if NavAg.is_navigation_finished():
			moving = false
			pnj.anim.play("bar_waiting")
			get_parent().global_position = targer_marker.global_position
			get_parent().global_rotation = targer_marker.global_rotation
			_next_action()
		else:
			var next_pos = NavAg.get_next_path_position()
			var dir = (next_pos - global_position).normalized()
			# Déplacement simple (adapté à ton setup)
			get_parent().global_position += dir * speed * delta
			get_parent().look_at(next_pos, Vector3.UP)
