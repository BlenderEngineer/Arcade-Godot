extends Node3D

var interval = 2
var seed = 0

@onready var Enemy1 = preload("res://Enemy.tscn")
@onready var Enemy2 = preload("res://Enemy2.tscn")

func _ready(): # runs on game start
	#game music
	get_node("Music").play()
	
	while true:
		#seed += 1
		#seed(seed)
		await get_tree().create_timer(interval).timeout #wait interval time
		print("Spawning enemies")
		
		var newEnemy = Enemy1.instantiate()
		get_node("Enemies").add_child(newEnemy)
		
		await get_tree().create_timer(.5).timeout
		newEnemy = Enemy2.instantiate()
		newEnemy.position += Vector3(2,0,-2)
		get_node("Enemies").add_child(newEnemy)
		
		await get_tree().create_timer(.1).timeout
		newEnemy = Enemy2.instantiate()
		newEnemy.position += Vector3(10,5,0)
		get_node("Enemies").add_child(newEnemy)
		
		await get_tree().create_timer(.1).timeout
		newEnemy = Enemy2.instantiate()
		newEnemy.position += Vector3(-5,0,10)
		get_node("Enemies").add_child(newEnemy)
		
		await get_tree().create_timer(.1).timeout
		newEnemy = Enemy2.instantiate()
		newEnemy.position += Vector3(0,10,0)
		get_node("Enemies").add_child(newEnemy)
		
