extends ColorRect

@export var volume_slider : HSlider
@export var music_slider : HSlider
@export var voix_slider : HSlider
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func set_volume(volume :float):
	if (volume < 0):
		volume = 0
	if (volume > 100):
		volume = 100
	var vol = float(volume) / 100
	var v = lerpf(-40, 0, vol)
	# Récupère l'index du bus Master
	var master_bus = AudioServer.get_bus_index("Master")
	# Définit son volume en décibels (dB)
	AudioServer.set_bus_volume_db(master_bus, v)  # par exemple -6 dB


func set_music(volume :float):
	if (volume < 0):
		volume = 0
	if (volume > 100):
		volume = 100
	var vol = float(volume) / 100
	var v = lerpf(-40, 0, vol)
	# Récupère l'index du bus Master
	var master_bus = AudioServer.get_bus_index("musique")
	# Définit son volume en décibels (dB)
	AudioServer.set_bus_volume_db(master_bus, v)  # par exemple -6 dB


func set_speak(volume :float):
	if (volume < 0):
		volume = 0
	if (volume > 100):
		volume = 100
	var vol = float(volume) / 100
	var v = lerpf(-40, 0, vol)
	# Récupère l'index du bus Master
	var master_bus = AudioServer.get_bus_index("speak")
	# Définit son volume en décibels (dB)
	AudioServer.set_bus_volume_db(master_bus, v)  # par exemple -6 dB

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	set_volume(volume_slider.value)
	set_volume(music_slider.value)
	set_volume(voix_slider.value)
	pass


func _on_h_slider_changed() -> void:
	set_volume(volume_slider.value)
	set_volume(music_slider.value)
	set_volume(voix_slider.value)
	pass # Replace with function body.
