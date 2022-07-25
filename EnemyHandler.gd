extends Area3D

@onready var Enemy = self.get_parent()
@onready var player = Enemy.get_parent().get_parent().get_node("FPS")
var move = Vector3.ZERO
var speed = .2 # >0.2 is faster than player

func _physics_process(delta):
	move = Vector3.ZERO
	
	if player != null:
		#print(player.position)
		move = Enemy.position.direction_to(player.position)
	else:
		move = Vector3.ZERO
	move = move.normalized() # vienetinis apskritimas
	Enemy.move_and_collide(move * speed)

func _on_area_3d_body_entered(body):
	if "bullet" in body.name:
		var Health = Enemy.get_meta("Health", 100)
		
		Enemy.get_node("AudioStreamPlayer3D").play()
		if Health <= 0:
			print("removing")
			Enemy.queue_free()
		else:
			Health -= 1
			Enemy.set_meta("Health", Health)
		print(Health)
	elif "FPS" in body.name:
		player.get_node("Head/Death").play()
		await get_tree().create_timer(1).timeout
		print("Game over")
		get_tree().quit()
