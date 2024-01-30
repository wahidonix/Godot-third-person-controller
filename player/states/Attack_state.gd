extends State
class_name AttackState

var player

func _ready():
	player = get_parent()
	attackAnim()
	player.velocity.x = 0
	player.velocity.z = 0

func attackAnim():
	animation.travel("Sidekick")

func _physics_process(delta):
	pass

func exit():
	print("EXIT ATTACK STATE")
