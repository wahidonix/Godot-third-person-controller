extends Node


var player

func _ready():
	player = get_parent()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion and player.isTPC:
		var pcam_rotation_degrees: Vector3
		pcam_rotation_degrees = player.pcam.get_third_person_rotation_degrees()
		pcam_rotation_degrees.x -= event.relative.y * player.sens
		pcam_rotation_degrees.x = clampf(pcam_rotation_degrees.x, player.min_yaw, player.max_yaw)
		pcam_rotation_degrees.y -= event.relative.x * player.sens
		pcam_rotation_degrees.y = wrapf(pcam_rotation_degrees.y, player.min_pitch, player.max_pitch)
		player.pcam.set_third_person_rotation_degrees(pcam_rotation_degrees)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
