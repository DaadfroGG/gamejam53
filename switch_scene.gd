extends ColorRect


@export var target_scene: String   # Choisissez la scène dans l’inspecteur

func change_to_target_scene() -> void:
	if target_scene:
		get_tree().change_scene_to_packed(load(target_scene))
	else:
		push_warning("Aucune scène n’est assignée à 'target_scene' !")


func _on_gui_input(_event: InputEvent) -> void:
	change_to_target_scene()
	pass # Replace with function body.
