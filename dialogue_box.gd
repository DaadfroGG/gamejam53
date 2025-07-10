extends Control
class_name DialogueBox

# ──────────────────────────────
#  ▌Export / paramètres publics
# ──────────────────────────────
@export var text              : String
@export var response          : Array[dialogue_line]
@export var list_choix        : VBoxContainer      # Conteneur qui reçoit les boutons
@export var current_select    : int     = 0        # Index de la ligne actuellement surlignée
@export var waiting_rep       : bool    = false    # Vrai si l'on attend la réponse du joueur

@export var move_threshold    : float   = 0.5      # Intensité mini Y du joystick pour déclencher ↑/↓
@export var move_cooldown     : float   = 0.18     # Délai entre deux déplacements successifs (s)

# ──────────────────────────────
#  ▌Variables internes
# ──────────────────────────────
var _move_timer     : float   = 0.0                # Compte à rebours pour l'anti-rebond
var _style_normal   := StyleBoxFlat.new()
var _style_selected := StyleBoxFlat.new()

@onready var _text_box : RichTextLabel = $ColorRect/ColorRect2/RichTextLabel

# ──────────────────────────────
#  ▌Signals
# ──────────────────────────────
signal response_user(index: int, branch: Array[dialogue_line])

# ──────────────────────────────
#  ▌Initialisation
# ──────────────────────────────
func _ready() -> void:
	# Couleurs de fond simples : gris foncé / gris clair
	_style_normal.bg_color   = Color(0.20, 0.20, 0.20)
	_style_selected.bg_color = Color(0.40, 0.40, 0.40)

	set_process_unhandled_input(true)          # Conserve la navigation clavier/manette
	set_process(true)                          # Autorise _process() pour le joystick

# ──────────────────────────────
#  ▌Outils internes
# ──────────────────────────────
func _clear_choice_buttons() -> void:
	# Supprime tous les boutons actuellement listés dans list_choix
	for child in list_choix.get_children():
		child.queue_free()

# ──────────────────────────────
#  ▌Création des boutons de choix
# ──────────────────────────────
func _create_choice_buttons() -> void:
	# Nettoyage préalable
	_clear_choice_buttons()

	# Instanciation
	for i in response.size():
		var line : dialogue_line = response[i]
		if line == null:
			push_warning("Le dialogue_line à l’index %d est null !" % i)
			continue

		var btn := Button.new()
		btn.text = line.text
		btn.add_theme_stylebox_override("normal", _style_normal)
		btn.connect("button_down", Callable(self, "_on_choice_pressed").bind(i))
		list_choix.add_child(btn)

	# Première ligne sélectionnée
	current_select = 0
	_update_selection()

# ──────────────────────────────
#  ▌Mise à jour de la surbrillance
# ──────────────────────────────
func _update_selection() -> void:
	var buttons := list_choix.get_children()

	for i in buttons.size():
		var btn := buttons[i] as Button
		if i == current_select:
			btn.add_theme_stylebox_override("normal", _style_selected)
			btn.grab_focus()
		else:
			btn.add_theme_stylebox_override("normal", _style_normal)

# ──────────────────────────────
#  ▌Réaction à un clic / validation
# ──────────────────────────────
func _on_choice_pressed(index: int) -> void:
	AutoRun.player.list_actions.append(response[index].actions_trigger)
	var branch := response[index].response
	emit_signal("response_user", index, branch)

func confirm_selection() -> void:
	
	_on_choice_pressed(current_select)

# ──────────────────────────────
#  ▌Chargement d’une nouvelle ligne
# ──────────────────────────────
func update_dial(dial: dialogue_line) -> void:
	text       = dial.text
	response   = dial.response
	_text_box.text = text

	waiting_rep = (response.size() > 0)
	if waiting_rep:
		_create_choice_buttons()
	else:
		# Aucune réponse possible : on vide la liste pour ne pas afficher les anciens choix
		_clear_choice_buttons()

# ──────────────────────────────
#  ▌Navigation via clavier / manette
# ──────────────────────────────
func _unhandled_input(event: InputEvent) -> void:
	if not waiting_rep:
		return

	if event.is_action_pressed("ui_down"):
		current_select = clamp(current_select + 1, 0, response.size() - 1)
		_update_selection()
	elif event.is_action_pressed("ui_up"):
		current_select = clamp(current_select - 1, 0, response.size() - 1)
		_update_selection()
	elif event.is_action_pressed("ui_accept"):
		confirm_selection()

# ──────────────────────────────
#  ▌Navigation via joystick virtuel
# ──────────────────────────────
func _process(delta: float) -> void:
	if not waiting_rep:
		return

	# ── Gestion du délai anti-rebond
	_move_timer = max(_move_timer - delta, 0.0)

	# ── Lecture du joystick virtualisé
	var joy_vec : Vector2 = Controls.joystick_vector
	var joy_y   : float   = joy_vec.y

	if _move_timer == 0.0:
		if joy_y >  move_threshold:                 # Descendre
			current_select = clamp(current_select + 1, 0, response.size() - 1)
			_update_selection()
			_move_timer = move_cooldown
		elif joy_y < -move_threshold:               # Monter
			current_select = clamp(current_select - 1, 0, response.size() - 1)
			_update_selection()
			_move_timer = move_cooldown

	# ── Validation par « tap »
	if Controls.interact_pressed:
		Controls.interact_pressed = false          # Consomme l’événement
		confirm_selection()
