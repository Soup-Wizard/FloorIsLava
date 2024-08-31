extends Node2D

@export var platformScene: PackedScene

@onready var lava = $lava

var platform1 = {
	"active": false,
	"scene": platformScene
}
var platform2 = {
	"active": false,
	"scene": platformScene
}

# ADD SPIKE BALL OBSTACLE

const MOVE_SPEED = 3

var platforms = [platform1, platform2]
var lavaFloor = []
var lastFloorPos
var saves = 3
var score = 0
var life = 1

func makePlatform():
	for x in platforms:
		if x.active == false:
			x.active = true
			x.scene = platformScene.instantiate()
			x.scene.position = Vector2(get_local_mouse_position())
			add_child(x.scene)
			await get_tree().create_timer(1.5).timeout
			x.active = false
			x.scene.queue_free()
			break

func moveAndAddLava():
	lastFloorPos.x -= MOVE_SPEED
	
	for b in lavaFloor:
		b.position.x -= MOVE_SPEED
	if lastFloorPos.x < 750:
		lavaFloor.pop_front()
		lavaFloor.append(lava.duplicate())
		add_child(lavaFloor.back())
		lavaFloor.back().position = Vector2(lastFloorPos.x + lava.texture.get_width(),lastFloorPos.y)
		lastFloorPos = lavaFloor.back().position

# This could be useful: .get_rect()

# Called when the node enters the scene tree for the first time.
func _ready():
	lastFloorPos = $lava.position
	for a in 9:
		lavaFloor.append(lava.duplicate())
		add_child(lavaFloor[a])
		lavaFloor[a].position = Vector2(lastFloorPos.x + lava.texture.get_width(),lastFloorPos.y)
		lastFloorPos = lavaFloor[a].position
	await get_tree().create_timer(3).timeout
	$platform.queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("click"):
		makePlatform()
		print(platforms)
	
	moveAndAddLava()
	
	if life > 0:
		score += delta*3
	
	$platformer.position.x -= MOVE_SPEED
	
	if $death.get_collider() == $platformer:
		$death.add_exception($platformer)
		if saves > 0:
			saves -= 1
			$platformer.velocity.y = -1250.0
			await get_tree().create_timer(0.05).timeout
			$death.remove_exception($platformer)
		else:
			life = 0
