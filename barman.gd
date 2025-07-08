extends CharacterBody3D

@export var dialogs : Array[String]
@export var dialoguebox : DialogueBox
@export var is_finish : bool
@export var cur_dialogue : int

signal cam_out
signal cam_in


func _ready() -> void:
	dialoguebox.visible = false
	cur_dialogue = -1
	is_finish = false

func interact():
	#dialoguebox.text_box.text = 
	if (cur_dialogue == -1):
		emit_signal("cam_in")
		dialoguebox.visible = true
	cur_dialogue+=1
	if (cur_dialogue >= dialogs.size()):
		stop_interact()
		cur_dialogue = -1
		is_finish = true
	else:
		dialoguebox.text = dialogs[cur_dialogue]

func stop_interact():
	is_finish = true
	emit_signal("cam_out")
	dialoguebox.visible = false

func _physics_process(_delta: float) -> void:
	pass
