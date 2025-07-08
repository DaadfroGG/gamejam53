extends Node3D

@export var nav_ag : NavigationAgent3D
@export var is_moving : bool = false
@export var default_walk : String
@export var speed : float = 5.0
@onready var anim: AnimationPlayer = $char/AnimationPlayer
func go_to(gaffeur : String):
	print("le metteur en scene me dit d'aller à " + gaffeur)
	var target = AutoRun.get_node_in_group_by_name("gaffeur", gaffeur)
	if target:
		print("j'ai trouvé le gaffeur " + gaffeur)
		print("je cible cette destination")
		nav_ag.target_position = target.global_position
		is_moving = true
		print(anim)
		anim.play(default_walk)
		anim.get_animation(default_walk).loop = true
		anim.speed_scale = 2

func _process(delta: float) -> void:
	if is_moving:
		if nav_ag.is_navigation_finished():
			print("Je suis arrivé à destination.")
			is_moving = false
			return

		var next_path_position = nav_ag.get_next_path_position()
		var direction = (next_path_position - global_position).normalized()

		# Tourner le personnage vers le prochain point
		look_at(next_path_position, Vector3.UP)

		# Déplacement
		global_position += direction * speed * delta
