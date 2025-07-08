extends Node3D

@onready var hours_hand: Node3D = $Node3D2
@onready var minutes_hand: Node3D = $Node3D

func _process(delta: float) -> void:
	var t = AutoRun.moment  # elapsed time in seconds

	# seconds hand (minutes_hand) rotates 6° per second (360° per 60s)
	var seconds_angle_deg = fposmod(6 * t, 360)

	# minutes hand (hours_hand) rotates 0.5° per second (360° per 12 min = 720s)
	var minutes_angle_deg = fposmod(t, 360)

	minutes_hand.rotation.z = deg_to_rad(seconds_angle_deg)
	hours_hand.rotation.z = deg_to_rad(minutes_angle_deg)
