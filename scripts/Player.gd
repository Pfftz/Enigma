extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var animatedSprite
var state = "idle"
var walkDir = "Down"

func _ready():
	animatedSprite = $AnimatedSprite3D

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		#velocity.y -= gravity * delta
		pass

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		state = "walk"
		if direction.x > 0:
			walkDir = "Right"
		elif direction.x < 0:
			walkDir = "Left"
		
		if direction.z > 0:
			walkDir = "Down"
		elif direction.z < 0:
			walkDir = "Up"
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		state = "idle"
	animatedSprite.animation = state + walkDir
	animatedSprite.play()
	move_and_slide()
