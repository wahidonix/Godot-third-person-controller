extends CharacterBody3D

var SPEED
var isSprinting = false
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


var min_yaw: float = -89.9
var max_yaw: float = 50

var min_pitch: float = 0
var max_pitch: float = 360


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	animation_player.play("Idle")
	SPEED = walk_speed
	pcam = thirdPersonCamera

func _input(event):
	if event is InputEventMouseMotion and isTPC:
		var pcam_rotation_degrees: Vector3
		pcam_rotation_degrees = pcam.get_third_person_rotation_degrees()
		pcam_rotation_degrees.x -= event.relative.y * sens
		pcam_rotation_degrees.x = clampf(pcam_rotation_degrees.x, min_yaw, max_yaw)
		pcam_rotation_degrees.y -= event.relative.x * sens
		pcam_rotation_degrees.y = wrapf(pcam_rotation_degrees.y, min_pitch, max_pitch)
		pcam.set_third_person_rotation_degrees(pcam_rotation_degrees)
		#rotate_y(deg_to_rad(-event.relative.x * sens))

func _physics_process(delta):
	var input_dir = Input.get_vector("move_left", "move_right", "move_forwards", "move_backwards")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		animation_player.play("Falling-idle")

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_pressed("sprint") and is_on_floor():
		SPEED = sprint_speed
		isSprinting = true
	elif is_on_floor():
		SPEED = walk_speed
		isSprinting = false
	
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if direction:
		var move_dir: Vector3 = Vector3.ZERO
		move_dir.x = direction.x
		move_dir.z = direction.z

		if isTPC:
			move_dir = move_dir.rotated(Vector3.UP, pcam.get_third_person_rotation().y).normalized()
		else:
			move_dir = move_dir.rotated(Vector3.UP, pcam.rotation.y).normalized()
		velocity.x = move_dir.x * SPEED
		velocity.z = move_dir.z * SPEED
		
		visuals.rotation.y = lerp_angle(visuals.rotation.y, atan2(move_dir.x, move_dir.z), delta * 9)
		if isSprinting and is_on_floor():
			animation_player.play("Sprint")
		elif is_on_floor():
			animation_player.play("Walk")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		if is_on_floor():
			animation_player.play("Idle")

	move_and_slide()

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
