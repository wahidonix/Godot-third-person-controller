extends CharacterBody3D

var SPEED
var isSprinting = false
var isJumping = false
var isTPC = true

@export_category("Movement variables")
@export var walk_speed = 2.5
@export var sprint_speed = 5
@export var JUMP_VELOCITY = 4.5
@export_category("Camera variables")
@export var sens = 0.5
var pcam: PhantomCamera3D
@export var thirdPersonCamera: PhantomCamera3D
@export var arenaCamera: PhantomCamera3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var animation_player = $visuals/AnimationPlayer
@onready var visuals = $visuals
@onready var animation_tree = $AnimationTree
@onready var playback = animation_tree.get("parameters/playback")


var min_yaw: float = -89.9
var max_yaw: float = 50

var min_pitch: float = 0
var max_pitch: float = 360

var move_dir: Vector3 = Vector3.ZERO
var direction
var input_dir

#State variables
var state
var state_factory



func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	state_factory = StateFactory.new()
	change_state("idle")
	SPEED = walk_speed
	pcam = thirdPersonCamera

func _physics_process(delta):
	input_dir = Input.get_vector("move_left", "move_right", "move_forwards", "move_backwards")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

	move_and_slide()


func change_state(new_state_name):
	if state != null:
		state.exit()
		state.queue_free()
	
	#Add new state
	state = state_factory.get_state(new_state_name).new()
	state.setup("change_state", playback, self)
	state.name = new_state_name
	add_child(state)

func changeCamera():
	if pcam == thirdPersonCamera:
		thirdPersonCamera.set_priority(0)
		arenaCamera.set_priority(1)
		isTPC = false
		pcam = arenaCamera
	else:
		thirdPersonCamera.set_priority(1)
		arenaCamera.set_priority(0)
		isTPC = true
		pcam = thirdPersonCamera


func _on_area_3d_body_entered(body):
	if body.name == "Player":
		changeCamera()


func _on_area_3d_body_exited(body):
	if body.name == "Player":
		changeCamera()


func _on_animation_tree_animation_finished(anim_name):
	if anim_name == "Sidekick":
		change_state("idle")
