extends Node2D

class_name Battle


var rng = RandomNumberGenerator.new()

enum GameState {CHOOSE_ABILITY, CHOOSE_TARGET}
const POS_COORDS = [19, 55, 91, 127, 193, 229, 265, 301]

var positioning
var ally_team
var enemy_team

var game_state
var target
var ability
var initiative
var curr_turn

var r_num	# round number
var t_num	# turn number

var disarm	# if current player is disarmed
var queue	# if heroes have queued abilities


func set_team(team):
	ally_team = get_tree().get_nodes_in_group("ally")
	enemy_team = get_tree().get_nodes_in_group("enemy")

	var i = 0
	for hero in ally_team:
		hero.init(team[i])
		i += 1

	for hero in enemy_team:
		hero.init("SampleEnemy")

	# Done for positioning purposes
	ally_team.invert()
	positioning = ally_team + enemy_team

	disarm = false
	queue = []

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
	for hero in positioning:
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
	disarm = false
	curr_turn = initiative[t_num].hero

	if curr_turn == null:
		next_turn()
		return

	start_turn()


func start_turn():
	print("-------------------------")
	set_info(curr_turn.name + "'s Turn")

	# If character cannot act this turn
	if resolve_status_effects():
		next_turn()
		return

	if queue:
		for abil in queue:
			if abil.hero == curr_turn:
				target = abil.target
				execute_move(abil.move)
				queue.erase(abil)
				return

	game_state = GameState.CHOOSE_ABILITY

	# If enemy's turn, attack random target
	if curr_turn.is_in_group("enemy"):
		var move = curr_turn.attack()

		random_target(move)
		execute_damage(move)
		next_turn()


func resolve_status_effects():
	var skip_turn = false
	for effect in curr_turn.status:
		# Expired effect
		if effect.turns == 0:
			curr_turn.clear_status(effect)

			if "status" in effect:
				match effect.status:
					StatusEffect.BURN:
						printBattleMsg(curr_turn.name + " is no longer burned")
		
					StatusEffect.STUN:
						printBattleMsg(curr_turn.name + " is no longer stunned")
		
					StatusEffect.DISARM:
						printBattleMsg(curr_turn.name + " is no longer disarmed")

			continue

		# Execute effect
		if "status" in effect:
			match effect.status:
				StatusEffect.BURN:
					curr_turn.curr_hp -= effect.val
					printBattleMsg(curr_turn.name + " was burned for " + effect.val as String + " damage")

				StatusEffect.STUN:
					printBattleMsg(curr_turn.name + " is stunned, their turn is skipped")
					skip_turn = true

				StatusEffect.DISARM:
					printBattleMsg(curr_turn.name + " is disarmed, they cannot attack")
					disarm = true

		effect.turns -= 1

	return skip_turn


func interrupt_queued_ability(targ):
	for move in queue:
		if move.hero == targ:
			queue.erase(move)


func validate_move():
	var move = get_chosen_ability()

	# No ability pressed, just moving self
	if move.type == MoveType.MOVE:
		swap_pos(curr_turn, move.move_self)
		printBattleMsg(curr_turn.name + " moved " + move.move_self as String + " spaces")

		correct_positioning()
		next_turn()
		return

	if !valid_pos(move) || !valid_target(move):
		return

	# Queued abilities are executed a turn later
	if "queue" in move:
		queue.append({"hero": curr_turn, "move": move, "target": target})
		next_turn()
		return

	execute_move(move)


func get_chosen_ability():
	match ability:
		AbilityType.ATK:
			return curr_turn.attack()
			
		AbilityType.PRI:
			return curr_turn.primary()

		AbilityType.SEC:
			return curr_turn.secondary()

		AbilityType.ULT:
			return curr_turn.ultimate()

		AbilityType.M_L:
			return {
				"type": MoveType.MOVE,
				"move_self": -1,
			}

		AbilityType.M_R:
			return {
				"type": MoveType.MOVE,
				"move_self": 1,
			}
	

func execute_move(move):
	# Handles repeated attacks
	var num = 1 + (0 if !("repeat" in move) else move.repeat)
	while(num > 0):
		# If targeting is random
		if "random" in move:
			random_target(move)
		
		# Call corresponding function based off of the move type
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

		# Handle position-altering effects
		if "move_targ" in move:
			swap_pos(target, move.move_targ)
			printBattleMsg(target.name + " moved " + move.move_targ as String + " spaces")

		# If successive attacks get stronger/weaker
		if "dmg_chg" in move:
			move.val = move.val * move.dmg_chg

		num -= 1

	# Handle self position-altering effects
	if "move_self" in move:
		swap_pos(curr_turn, move.move_self)
		printBattleMsg(curr_turn.name + " moved " + move.move_self as String + " spaces")

	func_check("post_check", move)

	correct_positioning()
	next_turn()


func random_target(move):
	while(true):
		var num = rng.randf_range(0, move.targ.size()) as int
		var rand_targ = move.targ[num]

		if positioning[rand_targ] == null:
			continue

		target = positioning[rand_targ]
		break


func execute_damage(move, k_queue = false):
	if ability_success(move):
		target.take_damage(move.val)
		printBattleMsg(curr_turn.name + " dealt " + move.val as String + " damage to " + target.name)

		# If target loses all HP
		if target.curr_hp <= 0:
			# If kill queue is activated, place target in kill queue, otherwise immediately kill
			if k_queue:
				return true
			else:
				kill_hero(target)

		# Apply debuff to target
		if "apply" in move:
			if move.apply != null:
				execute_status(move.apply)

		# If kill queue is activated, target is not dead so do not place in kill queue
		if k_queue:
			return false


func execute_aoe(move):
	var kill_queue = []

	for hero in move.targ:
		if positioning[hero] != null:
			target = positioning[hero]

			if execute_damage(move, true):
				kill_queue.append(target)

			# If successive attacks get stronger/weaker
			if "dmg_chg" in move:
				move.val = move.val * move.dmg_chg

	for dead in kill_queue:
		kill_hero(dead)


func execute_status(effect):
	target.apply_status(effect)

	if "status" in effect:
		match effect.status:
			StatusEffect.BURN:
				printBattleMsg(target.name + " was burned by " + curr_turn.name + " for " + effect.turns as String + " turns")

			StatusEffect.STUN:
				interrupt_queued_ability(target)
				printBattleMsg(target.name + " was stunned by " + curr_turn.name + " for " + effect.turns as String + " turns")

			StatusEffect.DISARM:
				printBattleMsg(target.name + " was disarmed by " + curr_turn.name + " for " + effect.turns as String + " turns")


func execute_shield(move):
	target.gain_shield(move.val)
	printBattleMsg(curr_turn.name + " shielded " + target.name + " for " + move.val as String + "HP")


func execute_heal(move):
	target.heal(move.val)
	printBattleMsg(curr_turn.name + " healed " + target.name + " for " + move.val as String + "HP")


func execute_aoe_heal(move):
	for hero in move.targ:
		if positioning[hero] != null:
			target = positioning[hero]
			execute_heal(move)


func ability_success(move):
	if !func_check("pre_check", move):
		return false

	# Roll for accuracy
	var roll = rng.randf()
	if roll > curr_turn.acc:
		printBattleMsg(curr_turn.name + " missed")
		return false

	return true


func func_check(check, move):
	# Verify there is a valid tag: "pre_check" or "post_check"
	if check in move:
		# Call boolean call to see if another move is performed
		if curr_turn.call(move[check][0], target):
			# If there are extra functions to be called
			if move[check].size() > 1:
				for i in range(1, move[check].size()):
					# Grab move to execute
					var call = curr_turn.call(move[check][i])

					# Verify that this is a move Object, by checking if it has a "type" parameter
					if "type" in call:
						execute_move(call)

			# Original action is performed (pre_check), or extra action was performed (post_check)
			return true

		# Action is not performed
		return false

	# There was never a check needed in the first place
	return true


func valid_target(move):
	# Self-targeted ability
	if move.targ == Positioning.SELF:
		if target != curr_turn:
			print("[note] Must use this ability on self")
			return false

		return true

	var pos = positioning.find(target)
	if move.targ.has(pos):
		return true

	print("[note] Invalid target")
	return false


func valid_pos(move):
	var idx = positioning.find(curr_turn)

	if move.pos.has(idx):
		return true

	print("[note] Invalid positioning")
	return false


func swap_pos(hero, num):
	# No more swaps
	if num == 0:
		return

	var targ_team = ally_team if hero.is_in_group("ally") else enemy_team
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

	if hero.is_in_group("ally"):
		ally_team.erase(hero)
	else:
		enemy_team.erase(hero)

	hero.queue_free()
	printBattleMsg(hero.name + " died")

	
func correct_positioning():
	var size = ally_team.size()
	for hero in ally_team:
		hero.position.x = POS_COORDS[4 - size]
		positioning[4 - size] = hero
		size -= 1

	for hero in enemy_team:
		hero.position.x = POS_COORDS[4 + size]
		positioning[4 + size] = hero
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
		validate_move()


func printBattleMsg(msg):
	print("[r" + (r_num + 1) as String + "t" + (t_num + 1) as String + "] " + msg)
