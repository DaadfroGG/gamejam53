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

func choix():
	print("l'user a pris une desicion")
	pass
	
	
func _ready() -> void:
	dialoguebox.visible = false
	cur_dialogue = -1
	is_finish = false
	dialoguebox.connect("response_user", Callable(self, "_on_response_selected"))

func _on_response_selected(index: int, dialogues_branch: Array[dialogue_line]) -> void:
	
	if cur_dialogue < 0 or cur_dialogue >= dialogues_2.size():
		push_error("Dialogue hors limite lors du choix.")
		return
	
	var selected_response : dialogue_line = dialogues_2[cur_dialogue].response[index]
	if selected_response == null:
		push_error("Réponse sélectionnée est nulle.")
		return
	else:
		dialogues_2 = selected_response.response
		cur_dialogue = -1
	
	# Ajoute la réponse sélectionnée dans la suite du dialogue
	#dialogues_2.insert(cur_dialogue + 1, selected_response)
	interact()

func interact():
	print("interact")
	if (cur_dialogue == -1):
		emit_signal("cam_in")
		dialoguebox.visible = true
		print("start_conv")
	

	# Si on attend une réponse utilisateur, ne rien faire
	if (cur_dialogue != -1 and dialoguebox.waiting_rep):
			print("chois de l'user")
			dialoguebox.confirm_selection()
			cur_dialogue = -1

	cur_dialogue += 1
	
	
	if (cur_dialogue >= dialogues_2.size()):
		emit_signal("cam_out")
		dialoguebox.visible = false
		AutoRun.player.can_control = true
		AutoRun.player.in_dialogue = false
		is_finish = true
		print("end_conv")
		return
	# Attention à ne pas dépasser les limites
	if (cur_dialogue > dialogues_2.size()):
		if (dialogues_2[cur_dialogue].response.size() == 0):
			print("stop dial")
			stop_interact()
			cur_dialogue = -1
			is_finish = true
		else:
			print("reponse du joueur")
			dialoguebox.choix()
	else:
		
		
		
		print("pas fini")
		print("pas de choix possible")
		var current_line := dialogues_2[cur_dialogue]
		dialoguebox.update_dial(current_line)
		vocal.stream = current_line.audio
		vocal.play()
	print("fin de la step d'interact")
	print("============================")
	print("============================")
	print("============================")
			


func stop_interact():
	is_finish = true
	emit_signal("cam_out")
	dialoguebox.visible = false

func _physics_process(_delta: float) -> void:
	pass
