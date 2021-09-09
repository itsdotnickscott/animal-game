extends Node2D

class_name Battle


var rng = RandomNumberGenerator.new()

enum GameState {CHOOSE_ABILITY, CHOOSE_TARGET}
const POS_COORDS = [19, 55, 91, 127, 193, 229, 265, 301]

var player_team
var enemy_team

var game_state
var target
var ability
var initiative

var r_num	# round number
var t_num	# turn number

var disarm


func _ready():
	# Group: "player"
	$Character1.init("MagicTurt")
	$Character2.init("PowBun")
	$Character3.init("CowDog")
	$Character4.init("BardSnek")

	# Group: "enemy"
	$Enemy1.init("SampleEnemy")
	$Enemy2.init("SampleEnemy")
	$Enemy3.init("SampleEnemy")
	$Enemy4.init("SampleEnemy")

	player_team = get_tree().get_nodes_in_group("player")
	enemy_team = get_tree().get_nodes_in_group("enemy")

	# Done for positioning purposes
	player_team.invert()

	disarm = false

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
	for _i in range(initiative.size() - 1):
		for j in range(initiative.size() - 1):
			if(initiative[j].roll < initiative[j + 1].roll):
				var temp = initiative[j]
				initiative[j] = initiative[j + 1]
				initiative[j + 1] = temp

	t_num = -1


func next_turn():
	# Start a new round if all heroes have taken a turn
	if t_num == initiative.size() - 1:
		round_start()
		return

	t_num += 1
	target = null
	ability = null

	if initiative[t_num].hero == null:
		next_turn()
		return

	start_turn()


func start_turn():
	print("-------------------------")

	disarm = false

	var hero = initiative[t_num].hero
	set_info(hero.name + "'s Turn")

	if resolve_status_effects():
		next_turn()
		return

	game_state = GameState.CHOOSE_ABILITY

	# If enemy's turn, attack random target
	if hero in enemy_team:
		var targ = rng.randf_range(0, player_team.size()) as int
		target = player_team[targ]

		execute_damage(hero.attack())
		next_turn()


func resolve_status_effects():
	var hero = initiative[t_num].hero

	var skip_turn = false
	for effect in hero.status:
		if effect.turns == 0:
			hero.clear_status(effect)

			if "status" in effect:
				match effect.status:
					StatusEffect.BURN:
						printBattleMsg(hero.name + " is no longer burned")
		
					StatusEffect.STUN:
						printBattleMsg(hero.name + " is no longer stunned")
		
					StatusEffect.DISARM:
						printBattleMsg(hero.name + " is no longer disarmed")

			continue

		if "status" in effect:
			match effect.status:
				StatusEffect.BURN:
					hero.curr_hp -= effect.val
					printBattleMsg(hero.name + " was burned for " + effect.val as String + " damage")

				StatusEffect.STUN:
					printBattleMsg(hero.name + " is stunned, their turn is skipped")
					skip_turn = true

				StatusEffect.DISARM:
					printBattleMsg(hero.name + " is disarmed, they cannot attack")
					disarm = true

		effect.turns -= 1

	return skip_turn


func execute_move():
	if target == null:
		return

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

	if !valid_pos(move) || !valid_target(move):
		return

	if ability_success(move):
		match move.type:
			MoveType.DAMAGE:
				execute_damage(move)

			MoveType.AOE:
				execute_aoe(move)

			MoveType.STATUS:
				execute_status(move.apply)

			MoveType.SHIELD:
				execute_shield(move)

			MoveType.HEAL:
				execute_heal(move)

			MoveType.AOE_HEAL:
				execute_aoe_heal(move)

			_:
				pass

		# Handle position-altering effects
		if "move_self" in move:
			swap_pos(hero, move.move_self)
			printBattleMsg(hero.name + " moved " + move.move_self as String + " spaces")

		if target in enemy_team && "move_targ" in move:
			swap_pos(target, move.move_targ)
			printBattleMsg(target.name + " moved " + move.move_targ as String + " spaces")

	correct_positioning()
	next_turn()


func execute_damage(move, queue = false):
	target.take_damage(move.val)
	printBattleMsg(initiative[t_num].hero.name + " dealt " + move.val as String + " damage to " + target.name)

	# Handles repeating attacks
	if "repeat" in move:
		for _i in range(move.repeat): 
			if ability_success(move):
				# If targeting is random
				if move.targ == "????":
					var targ = rng.randf_range(0, enemy_team.size()) as int
					target = enemy_team[targ]

				# If successive attacks get stronger/weaker
				if "dmg_chg" in move:
					move.val = move.val * move.dmg_chg

				target.take_damage(move.val)
				printBattleMsg(initiative[t_num].hero.name + " dealt " + move.val as String + " damage to " + target.name)

				# If target loses all HP
				if target.curr_hp <= 0:
						kill_hero(target)

	# If target loses all HP
	if target.curr_hp <= 0:
		# If queue is activated, place target in kill queue, otherwise immediately kill
		if queue:
			return true
		else:
			kill_hero(target)

	# Apply debuff to target
	if "apply" in move:
		if move.apply != null:
			execute_status(move.apply)

	# If queue is activated, target is not dead so do not place in kill queue
	if queue:
		return false


func execute_aoe(move):
	var kill_queue = []
	var pos = -1

	var targ_team = enemy_team if initiative[t_num].hero in player_team else player_team

	for enemy in targ_team:
		pos += 1

		if move.targ[pos] == ".":
			continue

		target = enemy

		if execute_damage(move, true):
			kill_queue.append(target)

		# If successive attacks get stronger/weaker
		if "dmg_chg" in move:
			move.val = move.val * move.dmg_chg

	for dead in kill_queue:
		kill_hero(dead)


func execute_status(effect):
	target.apply_status(effect)

	var hero = initiative[t_num].hero
	if "status" in effect:
		match effect.status:
			StatusEffect.BURN:
				printBattleMsg(target.name + " was burned by " + hero.name + " for " + effect.turns as String + " turns")

			StatusEffect.STUN:
				printBattleMsg(target.name + " was stunned by " + hero.name + " for " + effect.turns as String + " turns")

			StatusEffect.DISARM:
				printBattleMsg(target.name + " was disarmed by " + hero.name + " for " + effect.turns as String + " turns")


func execute_shield(move):
	target.gain_shield(move.val)
	printBattleMsg(initiative[t_num].hero.name + " shielded " + target.name + " for " + move.val as String + "HP")


func execute_heal(move):
	target.heal(move.val)
	printBattleMsg(initiative[t_num].hero.name + " healed " + target.name + " for " + move.val as String + "HP")


func execute_aoe_heal(move):
	var pos = -1
	var targ_team = player_team if initiative[t_num].hero in player_team else enemy_team

	for ally in targ_team:
		pos += 1

		if move.targ[pos] == ".":
			continue

		target = ally

		execute_heal(move)


func ability_success(move):
	var hero = initiative[t_num].hero

	if "pre_check" in move:
		if !hero.call(move.pre_check, target):
			return false

	# Roll for accuracy
	var roll = rng.randf()
	if roll > hero.acc:
		printBattleMsg(initiative[t_num].hero.name + " missed")
		return false

	return true


func valid_target(move):
	# Self-targeted ability
	if move.targ == "self":
		if target != initiative[t_num].hero:
			print("[note] Must use this ability on self")
			return false

		return true

	var targ_team = player_team if "o" in move.targ else enemy_team
	var pos = targ_team.find(target)

	if target in targ_team:
		if move.targ[pos] != ".":
			return true

	print("[note] Invalid target")
	return false


func valid_pos(move):
	var hero = initiative[t_num].hero
	var targ_team = player_team if hero in player_team else enemy_team
	var idx = targ_team.find(hero)

	if move.pos[idx] == "o":
		return true

	print("[note] Invalid positioning")
	return false


func swap_pos(hero, num):
	# No more swaps
	if num == 0:
		return

	var targ_team = player_team if hero in player_team else enemy_team
	var idx = targ_team.find(hero)
	var move_num = check_pos_boundaries(idx, num, targ_team)
		
	# Swap positions
	targ_team[idx] = targ_team[idx + move_num]
	targ_team[idx + move_num] = hero

	# Run recursively
	swap_pos(hero, num - move_num)


func check_pos_boundaries(idx, num, targ_team):
	# Check boundaries
	if num > 0:
		if idx + 1 >= targ_team.size():
			return 0

		return 1

	else:
		if idx - 1 < 0:
			return 0

		return -1


func kill_hero(hero):
	for roll in initiative:
		if roll.hero == hero:
			roll.hero = null

	if hero in player_team:
		player_team.erase(hero)
	else:
		enemy_team.erase(hero)

	hero.queue_free()
	printBattleMsg(hero.name + " died")

	
func correct_positioning():
	var size = player_team.size()
	for hero in player_team:
		hero.position.x = POS_COORDS[4 - size]
		size -= 1

	for hero in enemy_team:
		hero.position.x = POS_COORDS[4 + size]
		size += 1


func set_info(msg):
	$AbilityHUD.get_node("GameInfo").text = msg


func _on_AbilityHUD_ability(abil):
	if disarm && abil == AbilityType.ATK:
		print("[note] Hero is disarmed, cannot attack")

	ability = abil
	game_state = GameState.CHOOSE_TARGET

	set_info("Choose target.")


func _on_Character_selected(node):
	target = node

	if game_state == GameState.CHOOSE_TARGET:
		execute_move()


func printBattleMsg(msg):
	print("[r" + (r_num + 1) as String + "t" + (t_num + 1) as String + "] " + msg)
