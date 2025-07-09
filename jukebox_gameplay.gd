extends Camera3D

@export var max_yaw_angle: float = 25.0
@export var max_pitch_angle: float = 20.0
@export var rotation_speed: float = 5.0
@export var hand_move_speed: float = 5.0  # Speed of hand position lerp

@export var t_normal: float = 0.6        # Normal lerp factor (farther)
@export var t_interact: float = 0.4      # Closer lerp factor when interacting

@export var color_normal: Color = Color(1,1,1)         # white or default
@export var color_selected: Color = Color(0.2,1,0.0)   # greenish when selected
@export var color_pressed: Color = Color(1.0, 0.6, 0.2)  # orange-ish for pressed
@onready var change_track_sound: AudioStreamPlayer3D = $"../ChangeTrackSound"

@onready var hand: MeshInstance3D = $"../hand"
@onready var forward: StaticBody3D = $"../Forward"
@onready var backwards: StaticBody3D = $"../Backwards"
var was_interact_pressed: bool = false
@onready var music_player: AudioStreamPlayer3D = $SfxPlayer
var forward_original_pos: Vector3
var backwards_original_pos: Vector3
var forward_pressed_anim_time := 0.0
var backwards_pressed_anim_time := 0.0
var pressed_anim_duration := 0.3  # duration in seconds
var pressed_anim_distance := 0.1  # how far to move the button

var center_rotation: Vector3
var current_rotation: Vector3

var current_button: StaticBody3D = null
var target_hand_pos: Vector3  # The target position hand will move toward

const SWITCH_THRESHOLD := 8.0
var pending_track_index: int = -1

func _ready() -> void:
	center_rotation = rotation_degrees
	current_rotation = rotation_degrees
	
	current_button = forward
	_update_target_hand_position(t_normal)
	_update_button_colors()
	music_tracks = get_audio_files_from_folder("res://musique/")
	if music_tracks.size() > 0:
		play_music_track(0)

	forward_original_pos = forward.global_transform.origin
	backwards_original_pos = backwards.global_transform.origin
	# Initialize hand position
	hand.global_transform.origin = target_hand_pos

func change_track(direction: int) -> void:
	var new_index = current_track_index + direction
	if new_index < 0:
		new_index = music_tracks.size() - 1
	elif new_index >= music_tracks.size():
		new_index = 0

	pending_track_index = new_index
	music_player.stop()  # Stop current music immediately before playing the change track sound
	change_track_sound.play()




func play_music_track(index: int) -> void:
	if index >= 0 and index < music_tracks.size():
		current_track_index = index
		music_player.stream = music_tracks[index]
		print("Now playing:", music_tracks[index].resource_path)
		music_player.play()


func _on_sfx_player_finished() -> void:
	var next_index = (current_track_index + 1) % music_tracks.size()
	play_music_track(next_index)


var music_tracks: Array[AudioStream] = []
var current_track_index: int = 0

func get_audio_files_from_folder(folder_path: String) -> Array[AudioStream]:
	var streams: Array[AudioStream] = []
	var dir := DirAccess.open(folder_path)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.get_extension() in ["wav", "ogg", "mp3"]:
				var file_path = folder_path.path_join(file_name)
				var stream = load(file_path)
				if stream and stream is AudioStream:
					streams.append(stream)
			file_name = dir.get_next()
		dir.list_dir_end()
	
	return streams

func _process(delta: float) -> void:
	var input_dir: Vector2 = Controls.direction
	var interact_pressed = Controls.interact_pressed  # or use Input.is_action_pressed("interact")

	# Camera rotation
	var target_yaw = center_rotation.y - input_dir.x * max_yaw_angle
	var target_pitch = center_rotation.x - input_dir.y * max_pitch_angle

	target_yaw = clamp(target_yaw, center_rotation.y - max_yaw_angle, center_rotation.y + max_yaw_angle)
	target_pitch = clamp(target_pitch, center_rotation.x - max_pitch_angle, center_rotation.x + max_pitch_angle)

	current_rotation.y = lerp(current_rotation.y, target_yaw, delta * rotation_speed)
	current_rotation.x = lerp(current_rotation.x, target_pitch, delta * rotation_speed)

	rotation_degrees.x = current_rotation.x
	rotation_degrees.y = current_rotation.y
   # Decide which button to show based on yaw relative to center
	var yaw_diff = current_rotation.y - center_rotation.y
	var previous_button = current_button

	if yaw_diff > SWITCH_THRESHOLD:
		current_button = forward
	elif yaw_diff < -SWITCH_THRESHOLD:
		current_button = backwards

	if previous_button != current_button or was_interact_pressed != interact_pressed:
		_update_button_colors(interact_pressed)

	# Edge detection for interact press
	if interact_pressed and not was_interact_pressed:
		if current_button == forward:
			change_track(1)
			forward_pressed_anim_time = pressed_anim_duration  # start animating forward button
		elif current_button == backwards:
			change_track(-1)
			backwards_pressed_anim_time = pressed_anim_duration  # start animating backwards button


	if interact_pressed:
		_update_target_hand_position(t_interact)
	else:
		_update_target_hand_position(t_normal)

	hand.global_transform.origin = hand.global_transform.origin.lerp(target_hand_pos, delta * hand_move_speed)

	# Update interaction flag at end
	was_interact_pressed = interact_pressed

	# Animate forward button press
	if forward_pressed_anim_time > 0.0:
		forward_pressed_anim_time -= delta
		var t = forward_pressed_anim_time / pressed_anim_duration  # from 1 down to 0
		var offset = pressed_anim_distance * (1.0 - abs(t * 2.0 - 1.0))  # moves forward then back
		# Move along local -Z axis (forward)
		var offset_vec = forward.transform.basis.z * offset * -1
		forward.global_position = forward_original_pos + offset_vec
	else:
		forward.global_position = forward_original_pos

	# Animate backwards button press
	if backwards_pressed_anim_time > 0.0:
		backwards_pressed_anim_time -= delta
		var t = backwards_pressed_anim_time / pressed_anim_duration
		var offset = pressed_anim_distance * (1.0 - abs(t * 2.0 - 1.0))
		var offset_vec = backwards.transform.basis.z * offset * -1
		backwards.global_position = backwards_original_pos + offset_vec
	else:
		backwards.global_position = backwards_original_pos


func _update_target_hand_position(t: float) -> void:
	var button_pos = current_button.global_transform.origin
	var camera_pos = global_transform.origin
	target_hand_pos = button_pos.lerp(camera_pos, t) - Vector3(0,0.20,0)

func _update_button_colors(pressed: bool = false) -> void:
	_set_button_color(forward, color_normal)
	_set_button_color(backwards, color_normal)
	
	if pressed:
		_set_button_color(current_button, color_pressed)
	else:
		_set_button_color(current_button, color_selected)

func _set_button_color(button: StaticBody3D, color: Color) -> void:
	var mesh_instance: MeshInstance3D = button.get_node_or_null("MeshInstance3D")
	if mesh_instance:
		var material := mesh_instance.material_override
		if not material or not (material is StandardMaterial3D):
			# Duplicate from mesh surface material if no override or not StandardMaterial3D
			var base_material := mesh_instance.mesh.surface_get_material(0)
			if base_material and base_material is StandardMaterial3D:
				material = base_material.duplicate()
				material.resource_local_to_scene = true
				mesh_instance.material_override = material
			else:
				return  # Can't set color if no valid material

		# Now safely modify the override
		material.albedo_color = color

func _on_change_track_sound_finished() -> void:
	if pending_track_index != -1:
		play_music_track(pending_track_index)
		pending_track_index = -1
