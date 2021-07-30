extends "res://characters/Character.gd"

func load_stats():
	$Sprite.texture = preload("res://assets/sample_enemy.png")
	hp = 100
	atk = 10
	mag = 10
	def = 0
	wil = 0
	spd = 0.5
	ult = 0
	is_player = false


func start_battle():
	.start_battle()


func take_damage(num):
	.take_damage(num)


func update_labels():
	.update_labels()