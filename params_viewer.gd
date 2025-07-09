extends Control

@export var menu_control : Control
@export var menu_jouability : Control
@export var menu_audio : Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func off_display():
	menu_control.visible = false
	menu_jouability.visible = false
	menu_audio.visible = false
	
	pass
func on_display():
	menu_control.visible = true
	menu_jouability.visible = true
	menu_audio.visible = true
	pass

func _on_tab_bar_tab_clicked(tab: int) -> void:
	print(tab)
	if (tab == 0):
		menu_control.visible = true
		menu_jouability.visible = false
		menu_audio.visible = false
	
	if (tab == 1):
		menu_control.visible = false
		menu_jouability.visible = true
		menu_audio.visible = false
	
	if (tab == 2):
		menu_control.visible = false
		menu_jouability.visible = false
		menu_audio.visible = true
	pass # Replace with function body.
