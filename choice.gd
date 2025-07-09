class_name Choice extends ColorRect

@export var text : String = "Back"
@onready var button: TouchScreenButton = $Button

@onready var rich_text_label: RichTextLabel = $ColorRect2/RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AutoRun.back_btn = self
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rich_text_label.text = text
	pass

func _on_button_pressed() -> void:
	call_out_game_on_children(get_tree().root)

func call_out_game_on_children(node: Node) -> void:
	if node.has_method("out_game"):
		node.out_game()
	for child in node.get_children():
		if child is Node:
			call_out_game_on_children(child)
