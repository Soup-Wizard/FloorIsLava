extends Node2D

@export var platformScene: PackedScene
@export var spikeball: PackedScene

@onready var lava = $lava

var platform1 = {
	"active": false,
	"scene": platformScene
}
var platform2 = {
	"active": false,
	"scene": platformScene
}

var active_platforms = 0
const MOVE_SPEED = 3

var platforms = [platform1, platform2]
var lavaFloor = []
var lastFloorPos
var score = 0

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

# Called when the node enters the scene tree for the first time.
func _ready():
	lastFloorPos = $lava.position
	for a in 9:
		lavaFloor.append(lava.duplicate())
		add_child(lavaFloor[a])
		lavaFloor[a].position = Vector2(lastFloorPos.x + lava.texture.get_width(),lastFloorPos.y)
		lastFloorPos = lavaFloor[a].position
	await get_tree().create_timer(1.5).timeout
	$platform.queue_free()
	await get_tree().create_timer(5.5).timeout
	$spawnTimer.start()

func _on_spawn_timer_timeout():
	var ball = spikeball.instantiate()
	
	var spawn_loc = $spawnPath/spawner
	spawn_loc.progress_ratio = randf()
	
	var ballDirection = spawn_loc.rotation + PI/2
	
	ball.position = spawn_loc.position
	
	ballDirection += randf_range(-PI/4, PI/4)
	ball.rotation = ballDirection
	
	var ballVelocity = Vector2(randf_range(150.0, 250.0), 0.0)
	ball.linear_velocity = ballVelocity.rotated(ballDirection)
	
	add_child(ball)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("click"):
		makePlatform()
	
	moveAndAddLava()
	
	$savesLabel.text = "Saves: " + str($platformer.saves)
	
	if $platformer.life > 0:
		score += delta*3
		$scoreLabel.text = "Score: " + str(snapped(score, 0.1))
	else:
		score = snapped(score, 0.1)
	
	$platformer.position.x -= MOVE_SPEED
