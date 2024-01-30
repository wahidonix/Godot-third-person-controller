extends State
class_name JumpState

var player

func _ready():
	player = get_parent()
	player.isJumping = true
	jumpAnim()

func jumpAnim():
	animation.travel("Jump")

func _physics_process(delta):
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
	if player.isJumping:
		player.velocity.y = player.JUMP_VELOCITY
		player.isJumping = false
	await get_tree().create_timer(0.1).timeout
	if player.is_on_floor():
		player.change_state("idle")

func exit():
	print("EXIT JUMP STATE")
