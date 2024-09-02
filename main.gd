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

func saveGame(data):
	res = FileAccess.open(SAVE_PATH, FileAccess.READ_WRITE)
	
	var textContent = JSON.parse_string(res.get_as_text())
	var json_string = JSON.stringify(data)
	
	
	if textContent == null || textContent == { } || data.score > textContent.score:
		res.store_line(json_string)
		$highScoreLabel.text = "High Score: " + data.name + " - " + str(data.score)
	
	$highScoreLabel.visible = true

	return res
	res.close()

func loadGame():
	res = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var textContent = JSON.parse_string(res.get_as_text())
	print(textContent)
	if textContent != { } && textContent != null:
		$highScoreLabel.text = "High Score: " + textContent.name + " - " + str(textContent.score)
	else:
		$highScoreLabel.text = "No High Score Yet"
	
	if !$highScoreLabel.visible:
		$highScoreLabel.visible = true
	
	res.close()

const MOVE_SPEED = 3
const SAVE_PATH = "res://data/highscores.json"

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

func startGame():
	$gameOverLabel.visible = false
	$highScoreLabel.visible = false
	$howToPlay.visible = false
	get_tree().paused = false
	score.score = 0
	active_platforms = 0
	await get_tree().create_timer(1.5).timeout
	$platform.queue_free()
	await get_tree().create_timer(1.5).timeout
	$spawnTimer.start()

func gameOver():
	score.score = snapped(score.score, 0.1)
	saveGame(score)
	$gameOverLabel.visible = true

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
	
	add_child(ball)

func _on_line_edit_text_submitted(new_text):
	if new_text != "":
		score.name = new_text
		$LineEdit.queue_free()
		startGame()

# Called when the node enters the scene tree for the first time.
func _ready():
	loadGame()
	get_tree().paused = true
	
	lastFloorPos = $lava.position
	for a in 9:
		lavaFloor.append(lava.duplicate())
		add_child(lavaFloor[a])
		lavaFloor[a].position = Vector2(lastFloorPos.x + lava.texture.get_width(),lastFloorPos.y)
		lastFloorPos = lavaFloor[a].position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	moveAndAddLava()
	$TileMap.position.x -= 0.21
	
	if Input.is_action_just_pressed("esc"):
		saveGame(score)
		get_tree().reload_current_scene()
		loadGame()
	
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
