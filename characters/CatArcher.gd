extends "res://characters/Character.gd"

func load_stats():
	$Sprite.texture = preload("res://assets/sample_character.png")
	hp = 400
	atk = 20
	mag = 0
	def = 0
	wil = 0
	spd = 1.0
	ult = 0
	is_player = true


func start_battle():
	.start_battle()


func take_damage(num):
	.take_damage(num)


func update_labels():
	.update_labels()
