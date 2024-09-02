extends StaticBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().create_timer(0.9).timeout
	$visibilityTimer.start()

func _on_visibility_timer_timeout():
	visible = false
	await get_tree().create_timer(0.05).timeout
	visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.x -= get_parent().MOVE_SPEED
