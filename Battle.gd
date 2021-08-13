extends Node2D

class_name Battle


enum GameState {CHOOSE_ABILITY, CHOOSE_TARGET}

var player_team
var enemy_team

var curr_turn
var game_state
var target
var ability

var rng = RandomNumberGenerator.new()


func _ready():
	# Group: "player"
	$Character1.init("SampleCharacter")
	$Character2.init("SampleCharacter")
	$Character3.init("SampleCharacter")
	$Character4.init("CatArcher")

	# Group: "enemy"
	$Enemy1.init("SampleEnemy")
	$Enemy2.init("SampleEnemy")
	$Enemy3.init("SampleEnemy")
	$Enemy4.init("SampleEnemy")

	player_team = get_tree().get_nodes_in_group("player")
	enemy_team = get_tree().get_nodes_in_group("enemy")

	rng.randomize()

	game_state = GameState.CHOOSE_ABILITY

	round_start()


func round_start():
	var initiative = roll_initiative()

	var leader = {"roll": 0}
	for hero in initiative:
		if hero.roll > leader.roll:
			leader = hero

		# FORCE LEADER
		if hero.name == "Character4":
			leader = hero
			break
	

	curr_turn = leader
	target = null
	ability = null

	set_info(curr_turn.name + "'s Turn")


func roll_initiative():
	var initiative = []

	for hero in player_team:
		initiative.append({"name": hero.name, "hero": hero, "roll": hero.spd + rng.randf_range(0, 8)})

	for hero in enemy_team:
		initiative.append({"name": hero.name, "hero": hero, "roll": hero.spd + rng.randf_range(0, 8)})

	return initiative


func execute_move():
	var hero = curr_turn.hero
	var move

	match ability:
		AbilityType.ATK:
			move = hero.attack()
		AbilityType.PRI:
			move = hero.primary()
		AbilityType.SEC:
			move = hero.secondary()
		AbilityType.ULT:
			move = hero.ultimate()
		_:
			print("error at ability selection")

	print(move)

	match move.type:
		MoveType.DAMAGE:
			execute_damage(move)


func execute_damage(move):
	if target == null:
		pass
	
	target.take_damage(move.val)

	set_info(target.name + " took " + move.val as String + " damage.")


func set_info(msg):
	$AbilityHUD.get_node("GameInfo").text = msg


func _on_AbilityHUD_ability(abil):
	ability = abil
	game_state = GameState.CHOOSE_TARGET

	set_info("Choose target.")


func _on_Character_selected(node):
	target = node

	if game_state == GameState.CHOOSE_TARGET:
		execute_move()
