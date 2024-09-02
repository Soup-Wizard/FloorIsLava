extends Area2D

var direction: Vector2

func _on_body_entered(body):
	direction = body.last_pos - body.current_pos
	if body.saves > 0:
		body.saves -= 1
		#if direction < Vector2(0,0):
			#body.velocity = Vector2(-1250.0, -1250.0)
		#elif direction > Vector2(0,0):
			#body.velocity = Vector2(1250.0, 750.0)
		#elif direction.x > 0 && direction.y == 0:
			#body.velocity.x = 1250.0
		#elif direction.x < 0 && direction.y == 0:
			#body.velocity.x = -1250
		#elif direction.y > 0 && direction.x == 0:
			#body.velocity.y = 750.0
		#elif direction.y < 0 && direction.x == 0:
			#body.velocity.y = -1250
			
		if direction.y < 0:
			body.velocity.y = -1250.0
		else:
			body.velocity.y = 750.0
	else:
		body.life -= 1
