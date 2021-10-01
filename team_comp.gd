extends Node


var ally_team
var ally_lvls
var enemy_team


func change_scene(next_scene, team, lvls):
	ally_team = team
	ally_lvls = lvls
	
	generate_enemy_comp()
	var _unused = get_tree().change_scene(next_scene)


func generate_enemy_comp():
	enemy_team = []
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	# first enemy: 60% tank, 40% fighter
	enemy_team.append("enemy_tank" if rng.randf() < 0.6 else "enemy_fighter")

	# second enemy: 100% fighter
	enemy_team.append("enemy_fighter")

	# 75% chance of additional enemy (x2): 50% archer, 50% mage
	for _i in range(2):
		if rng.randf() < 0.75:
			enemy_team.append("enemy_archer" if rng.randf() < 0.5 else "enemy_mage")


func get_ally_team(idx=null):
	if idx == null:
		return ally_team

	return ally_team[idx]


func get_ally_lvl(idx):
	return ally_lvls[idx]


func get_enemy_team(idx=null):
	if idx == null:
		return enemy_team

	return enemy_team[idx]
