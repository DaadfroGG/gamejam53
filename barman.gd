extends CharacterBody3D

@export var dialoguebox : DialogueBox
signal cam_out
signal cam_in
func _ready() -> void:
	dialoguebox.visible = false

func interact():
	dialoguebox.text_box.text = "Je suis le barman du Tigre Mongo. Le bar ferme à 18h."
	emit_signal("cam_in")
	dialoguebox.visible = true

func stop_interact():
	emit_signal("cam_out")
	dialoguebox.visible = false

func _physics_process(_delta: float) -> void:
	pass
