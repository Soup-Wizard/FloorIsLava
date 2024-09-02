extends CharacterBody2D

const SPEED = 500.0
const JUMP_VELOCITY = -750.0

@onready var current_pos = position

var last_pos: Vector2

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var saves
var life

func _ready():
	saves = 3
	life = 1

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * (delta*1.5)
	
	if velocity:
		last_pos = current_pos
		current_pos = position
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if get_parent().showTime:
		move_and_slide()
