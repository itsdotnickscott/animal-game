extends Node2D

class_name Battle

var Character = preload("res://characters/Character.tscn")


func _ready():
	var player = Character.instance()
	player.init("CatArcher")
	add_child(player)

	player.position = $TileMap.map_to_world(Vector2(3, 2))
	player.connect("attack", self, "_on_Character_attack")
	player.start_battle()

	var enemy = Character.instance()
	enemy.init("SampleEnemy")
	add_child(enemy)

	enemy.position = $TileMap.map_to_world(Vector2(6, 2))
	enemy.connect("attack", self, "_on_Character_attack")
	enemy.start_battle()


func _on_Character_attack(unit):
	choose_target(unit).take_damage(unit.atk)


func choose_target(unit):
	var enemies
	
	if unit.is_player:
		enemies = get_tree().get_nodes_in_group("enemy")
	else:
		enemies = get_tree().get_nodes_in_group("player")

	if enemies.size() > 0:
		var target = enemies[0]

		for targ in enemies:
			if unit.position.distance_squared_to(targ.position) < unit.position.distance_squared_to(target.position):
				target = targ

		return target

	return null
