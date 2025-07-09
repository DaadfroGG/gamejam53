extends Node3D

@export var anim: AnimationPlayer

signal anim_finished(name:String)

func _ready() -> void:
	anim.animation_finished.connect(_on_animation_finished)
	return
	anim.play("open_door")

func _on_animation_finished(name: String) -> void:
	print("je vient de jouer l'annimation : " + str(name))
	anim_finished.emit(name)
	return
	if name == "open_door":
		anim.play("bar_waiting_001")
