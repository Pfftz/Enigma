extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var animatedSprite
var state = "idle"
var walkDir = "Down"
var current_direction: int = 2 # 0=Up, 1=Right, 2=Down, 3=Left

func _ready():
    animatedSprite = $AnimatedSprite3D
    add_to_group("player") # Add to player group for easy finding

func _physics_process(delta):
    if not is_on_floor():
        pass

    if Input.is_action_just_pressed("ui_accept") and is_on_floor():
        velocity.y = JUMP_VELOCITY

    var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    
    if direction:
        velocity.x = direction.x * SPEED
        velocity.z = direction.z * SPEED
        state = "walk"
        
        # Update current direction for warp system
        if abs(direction.x) > abs(direction.z):
            if direction.x > 0:
                walkDir = "Right"
                current_direction = 1
            else:
                walkDir = "Left"
                current_direction = 3
        else:
            if direction.z > 0:
                walkDir = "Down"
                current_direction = 2
            else:
                walkDir = "Up"
                current_direction = 0
    else:
        velocity.x = move_toward(velocity.x, 0, SPEED)
        velocity.z = move_toward(velocity.z, 0, SPEED)
        state = "idle"
    
    animatedSprite.animation = state + walkDir
    animatedSprite.play()
    move_and_slide()

# Methods for warp system
func get_current_direction() -> int:
    return current_direction

func set_direction(new_direction: int) -> void:
    current_direction = new_direction
    var directions = ["Up", "Right", "Down", "Left"]
    if new_direction < directions.size():
        walkDir = directions[new_direction]
