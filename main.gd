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

var highScores = []

func saveGame(data):
	res = FileAccess.open(SAVE_PATH, FileAccess.READ_WRITE)
	#save_nodes = get_tree().get_nodes_in_group("Persist")
	var textContent = JSON.parse_string(res.get_as_text())
	#for a in textContent:
		#highScores.append(a)
	highScores.append(textContent)
	highScores.append(score)
	var json_string = JSON.stringify(data)
	print(textContent)
	print(highScores)
	print(data)
	print(json_string)
	for item in highScores:
		json_string = JSON.stringify(item)
		res.store_line(json_string + ",")
	#res.store_line(json_string)
	
	#for node in save_nodes:
		# Check the node is an instanced scene so it can be instanced again during load.
		#if node.scene_file_path.is_empty():
			#print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			#continue

		# Check the node has a save function.
		#if !node.has_method("save"):
			#print("persistent node '%s' is missing a save() function, skipped" % node.name)
			#continue

		# Call the node's save function.
		#var node_data = node.call("save")

		# JSON provides a static method to serialized JSON string.
		#var json_string = JSON.stringify(score)

		# Store the save dictionary as a new line in the save file.
		#res.store_line(json_string)
	return res

func loadGame():
	pass

const MOVE_SPEED = 3
const SAVE_PATH = "res://data/highscores.json"

var showTime = false
var res
var save_nodes
var playerName
var active_platforms = 0
var platforms = [platform1, platform2]
var lavaFloor = []
var lastFloorPos
var score = {
	"name": "",
	"score": 0
	}
var save_data: SaveData

func startGame():
	showTime = true
	get_tree().paused = false
	score.score = 0
	active_platforms = 0
	$platform.queue_redraw()
	await get_tree().create_timer(1.5).timeout
	$platform.queue_free()
	await get_tree().create_timer(1.5).timeout
	$spawnTimer.start()

func gameOver():
	score.score = snapped(score.score, 0.1)
	print("GAME OVER")
	saveGame(score)

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


func _on_difficulty_timer_timeout():
	if $spawnTimer.wait_time > 0.3:
		$spawnTimer.wait_time -= 0.1

func _on_spawn_timer_timeout():
	var ball = spikeball.instantiate()
	
	var spawn_loc = $spawnPath/spawner
	spawn_loc.progress_ratio = randf()
	
	var ballDirection = spawn_loc.rotation + PI/2
	
	ball.position = spawn_loc.position
	
	ballDirection += randf_range(-PI/4, PI/4)
	ball.rotation = ballDirection
	
	var ballVelocity = Vector2(randf_range(150.0, 250.0), 0.0)
	#ball.linear_velocity = ballVelocity.rotated(ballDirection)
	
	add_child(ball)

func _on_line_edit_text_submitted(new_text):
	if new_text != "":
		score.name = new_text
		$LineEdit.queue_free()
		startGame()

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused = true
	
	#save_data = SaveData.load_or_create()
	lastFloorPos = $lava.position
	for a in 9:
		lavaFloor.append(lava.duplicate())
		add_child(lavaFloor[a])
		lavaFloor[a].position = Vector2(lastFloorPos.x + lava.texture.get_width(),lastFloorPos.y)
		lastFloorPos = lavaFloor[a].position
	#startGame()
	#await get_tree().create_timer(1.5).timeout
	#$platform.queue_free()
	#await get_tree().create_timer(5.5).timeout
	#$spawnTimer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	moveAndAddLava()
	$TileMap.position.x -= 0.21
	
	if showTime:
		if Input.is_action_just_pressed("click") && $platformer.life > 0:
			makePlatform()
	
		$savesLabel.text = "Saves: " + str($platformer.saves)
	
		if $platformer.life > 0:
			score.score += delta*3
			$scoreLabel.text = "Score: " + str(snapped(score.score, 0.1))
		
		elif $platformer.life == 0:
			$platformer.life -= 1
			gameOver()
		$platformer.position.x -= MOVE_SPEED
