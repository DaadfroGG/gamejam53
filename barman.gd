extends CharacterBody3D

@export var dialogs : Array[String]
@export var dialoguebox : DialogueBox
@export var is_finish : bool
@export var cur_dialogue : int
@export var vocal:AudioStreamPlayer3D
@export var dialogues_2 : Array[dialogue_line]
#const BARMAN_1 = preload("res://musique/Barman_1.wav")

signal cam_out
signal cam_in


func _ready() -> void:
	dialoguebox.visible = false
	cur_dialogue = -1
	is_finish = false

func interact():
	#dialoguebox.text_box.text = 
	if (cur_dialogue == -1):
		#vocal.stream = BARMAN_1
		#vocal.play()
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
