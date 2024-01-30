extends State
class_name MoveState

var player

func _ready():
	player = get_parent()
	animation.travel("Walk")


func _physics_process(delta):
	if Input.is_action_pressed("sprint") and player.is_on_floor():
		player.SPEED = player.sprint_speed
		player.isSprinting = true
	elif player.is_on_floor():
		player.SPEED = player.walk_speed
		player.isSprinting = false

	if player.direction:
		player.move_dir.x = player.direction.x
		player.move_dir.z = player.direction.z

		if player.isTPC:
			player.move_dir = player.move_dir.rotated(Vector3.UP, player.pcam.get_third_person_rotation().y).normalized()
		else:
			player.move_dir = player.move_dir.rotated(Vector3.UP, player.pcam.rotation.y).normalized()
		player.velocity.x = player.move_dir.x * player.SPEED
		player.velocity.z = player.move_dir.z * player.SPEED
		
		player.visuals.rotation.y = lerp_angle(player.visuals.rotation.y, atan2(player.move_dir.x, player.move_dir.z), delta * 8)
		if player.isSprinting and player.is_on_floor():
			animation.travel("Sprint")
		elif player.is_on_floor():
			animation.travel("Walk")
	else:
		player.change_state("idle")
	
	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		player.change_state("jump")
	
	if Input.is_action_just_pressed("attack") and player.is_on_floor():
		player.change_state("attack")


func exit():
	print("EXIT MOVE STATE")
