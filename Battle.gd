extends Node2D

class_name Battle


enum GameState {CHOOSE_ABILITY, CHOOSE_TARGET}

var player_team
var enemy_team

var game_state
var target
var ability
var initiative
var curr_turn


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

	round_start()


func round_start():
	roll_initiative()
	next_turn()


func roll_initiative():
	initiative = []

	# roll initiatives for each hero
	for hero in player_team:
		initiative.append({"hero": hero, "roll": hero.spd + rng.randf_range(0, 8)})

	for hero in enemy_team:
		initiative.append({"hero": hero, "roll": hero.spd + rng.randf_range(0, 8)})

	# sort heroes in initiative order based off of roll
	for _i in range(0, (initiative.size() - 1)):
		for j in range(0, (initiative.size() - 1)):
			if(initiative[j].roll < initiative[j + 1].roll):
				var temp = initiative[j]
				initiative[j] = initiative[j + 1]
				initiative[j + 1] = temp

	curr_turn = -1


func execute_move():
	var hero = initiative[curr_turn].hero
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

	match move.type:
		MoveType.DAMAGE:
			execute_damage(move)
		MoveType.AOE:
			execute_aoe(move)
		MoveType.STATUS:
			pass

	next_turn()


func execute_damage(move):
	if target == null:
		pass
	
	target.take_damage(move.val)

	print("[BATTLE LOG] ", initiative[curr_turn].hero.name + " dealt " + move.val as String + " damage to " + target.name)


func execute_aoe(move):
	for hero in enemy_team:
		target = hero
		execute_damage(move)

		move.val = move.val * move.dmg_loss


func next_turn():
	if curr_turn == initiative.size() - 1:
		round_start()
		return

	curr_turn += 1
	target = null
	ability = null

	set_info(initiative[curr_turn].hero.name + "'s Turn")
	initiative[curr_turn].hero.start_turn()

	game_state = GameState.CHOOSE_ABILITY


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
