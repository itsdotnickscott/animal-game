extends Node2D

class_name Battle


var rng = RandomNumberGenerator.new()

enum GameState {CHOOSE_ABILITY, CHOOSE_TARGET}

var player_team
var enemy_team

var game_state
var target
var ability
var initiative

var r_num	# round number
var t_num	# turn number


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

	r_num = -1
	rng.randomize()

	round_start()


func round_start():
	r_num += 1
	roll_initiative()
	next_turn()


func roll_initiative():
	initiative = []

	# Roll initiatives for each hero
	for hero in player_team:
		initiative.append({"hero": hero, "roll": hero.spd + rng.randf_range(0, 8)})

	for hero in enemy_team:
		initiative.append({"hero": hero, "roll": hero.spd + rng.randf_range(0, 8)})

	# Sort heroes in initiative order based off of roll
	for _i in range(0, (initiative.size() - 1)):
		for j in range(0, (initiative.size() - 1)):
			if(initiative[j].roll < initiative[j + 1].roll):
				var temp = initiative[j]
				initiative[j] = initiative[j + 1]
				initiative[j + 1] = temp

	t_num = -1


func next_turn():
	if t_num == initiative.size() - 1:
		round_start()
		return

	t_num += 1
	target = null
	ability = null

	set_info(initiative[t_num].hero.name + "'s Turn")
	initiative[t_num].hero.start_turn()

	game_state = GameState.CHOOSE_ABILITY


func execute_move():
	var hero = initiative[t_num].hero
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
	print(getRoundTurnString(), initiative[t_num].hero.name + " dealt " + move.val as String + " damage to " + target.name)

	if "debuff" in move:
		target.apply_status(move.debuff)


func execute_aoe(move):
	for hero in enemy_team:
		target = hero
		execute_damage(move)

		move.val = move.val * move.dmg_loss


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


func getRoundTurnString():
	return "[r" + r_num + 1 as String + "t" + t_num + 1 as String + "] "