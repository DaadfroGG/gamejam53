extends ColorRect

@export var game_scene: PackedScene   # Choisissez la scène dans l’inspecteur
@export var param_scene: PackedScene   # Choisissez la scène dans l’inspecteur
@export var credit_scene: PackedScene   # Choisissez la scène dans l’inspecteur
@export var logs_scene: PackedScene   # Choisissez la scène dans l’inspecteur

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



func go_play() -> void:
	if game_scene:
		get_tree().change_scene_to_packed(game_scene)
	else:
		push_warning("Aucune scène n’est assignée à 'target_scene' !")

func go_param() -> void:
	if game_scene:
		get_tree().change_scene_to_packed(game_scene)
	else:
		push_warning("Aucune scène n’est assignée à 'target_scene' !")

func go_credit() -> void:
	if game_scene:
		get_tree().change_scene_to_packed(game_scene)
	else:
		push_warning("Aucune scène n’est assignée à 'target_scene' !")
		
func go_logs() -> void:
	if game_scene:
		get_tree().change_scene_to_packed(game_scene)
	else:
		push_warning("Aucune scène n’est assignée à 'target_scene' !")


func quit_game() -> void:
	# Ferme le jeu sur toutes les plateformes (Android retourne simplement au launcher).
	get_tree().quit()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
