extends Node2D

class_name Battle


var rng = RandomNumberGenerator.new()

enum GameState {CHOOSE_ABILITY, CHOOSE_TARGET}
const POS_COORDS = [19, 55, 91, 127, 193, 229, 265, 301]	# x-coords of positions on the field
var Character = preload("res://characters/Character.tscn")

# Pip costs
const ONE_PIP = 1
const ULT_PIP = 3


# Battle game state
var positioning
var ally_team
var enemy_team
var initiative

var curr_turn
var game_state
var target
var ability

var r_num	# round number
var t_num	# turn number
var w_num	# wave number


# Current hero's state
var disarm		# if current player is disarmed
var queue		# if heroes have queued abilities
var is_crit 	# if current move crit
var pip_cost	# pip cost of ability being used
var success		# if ability hits (except dodge)


func _ready():
	ally_team = get_tree().get_nodes_in_group("ally")
	enemy_team = get_tree().get_nodes_in_group("enemy")

	# Initialize characters with team comps
	var i = 0
	for hero in ally_team:
		hero.init(TeamComp.get_ally_team(i), TeamComp.get_ally_lvl(i))
		i += 1

	i = 0
	for hero in enemy_team:
		if TeamComp.get_enemy_team().size() > i:
			hero.init(TeamComp.get_enemy_team(i), 0, true)

		else:
			enemy_team.erase(hero)
			hero.queue_free()

		i += 1

	# Done for positioning purposes
	ally_team.invert()

	correct_positioning()

	disarm = false
	queue = []
	is_crit = false

	r_num = -1
	w_num = 0
	rng.randomize()
	round_start()


func round_start():
	r_num += 1

	# Give every player a pip
	for hero in positioning:
		if hero != null:
			hero.give_pip()

	roll_initiative()
	next_turn()


func roll_initiative():
	initiative = []

	# Roll initiatives for each hero
	for hero in positioning:
		if hero != null:
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
	if curr_turn:
		curr_turn.set_turn_indicator(false)

	# Start a new round if all heroes have taken a turn
	if t_num == initiative.size() - 1:
		round_start()
		return

	t_num += 1
	target = null
	ability = null
	disarm = false
	is_crit = false
	pip_cost = 0
	success = false
	curr_turn = initiative[t_num].hero

	if curr_turn == null:
		next_turn()
		return

	start_turn()


func start_turn():
	print("-------------------------")
	set_info(curr_turn.name + "'s Turn")
	curr_turn.set_turn_indicator(true)

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
		var move = curr_turn.choose_ability()

		random_target(move)
		execute_move(move)


func resolve_status_effects():
	var skip_turn = false
	for effect in curr_turn.status:
		# Expired effect
		if effect.turns == 0:
			curr_turn.clear_status(effect)

			if "status" in effect:
				match effect.status:
					StatusEffect.BURN:
						print_battle_msg(curr_turn.name + " is no longer burned")
		
					StatusEffect.STUN:
						print_battle_msg(curr_turn.name + " is no longer stunned")
		
					StatusEffect.DISARM:
						print_battle_msg(curr_turn.name + " is no longer disarmed")

			continue

		# Execute effect
		if "status" in effect:
			match effect.status:
				StatusEffect.BURN:
					curr_turn.curr_hp -= effect.val
					print_battle_msg(curr_turn.name + " was burned for " + effect.val as String + " damage")

				StatusEffect.STUN:
					print_battle_msg(curr_turn.name + " is stunned, their turn is skipped")
					skip_turn = true

				StatusEffect.DISARM:
					print_battle_msg(curr_turn.name + " is disarmed, they cannot attack")
					disarm = true

		effect.turns -= 1

	return skip_turn


func interrupt_queued_ability(targ):
	for move in queue:
		if move.hero == targ:
			queue.erase(move)


func validate_move():
	var move = get_chosen_ability()

	if move == null:
		return

	# No ability pressed, just moving self
	if move.type == MoveType.MOVE:
		execute_move_pos(curr_turn, move.move_self)
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
	pip_cost = 0

	match ability:
		AbilityType.ATK:
			return curr_turn.attack()
			
		AbilityType.PRI:
			if curr_turn.pips - ONE_PIP >= 0:
				pip_cost = ONE_PIP
				return curr_turn.primary()

		AbilityType.SEC:
			if curr_turn.pips - ONE_PIP >= 0:
				pip_cost = ONE_PIP
				return curr_turn.secondary()

		AbilityType.ULT:
			if curr_turn.pips - ULT_PIP >= 0:
				pip_cost = ULT_PIP
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

	print("[note] You don't have enough pips to use this ability")
	return null
	

func execute_move(move):
	if move == null:
		return

	success = false

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
			execute_move_pos(target, move.move_targ)
			
		# If successive attacks get stronger/weaker
		if "dmg_chg" in move:
			move.val = move.val * move.dmg_chg

		num -= 1

	# Handle self position-altering effects
	if "move_self" in move:
		execute_move_pos(curr_turn, move.move_self)

	func_check("post_check", move)

	if success && pip_cost > 0:
		curr_turn.use_pips(pip_cost)

	if check_for_next_wave():
		round_start()
		return

	check_lose_condition()
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


func execute_damage(move, k_queue=false):
	if ability_success(move):
		var dmg = calculate_damage(move)
		target.take_damage(dmg, is_crit)
		print_battle_msg(curr_turn.name + " dealt " + dmg as String + " damage to " + target.name)

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


func calculate_damage(move):
	var dmg = move.val

	# If an attack gets a boost
	if "boost" in move:
		if curr_turn.call(move.boost[0], target):
			dmg += move.boost[1]

	# Damage value is variable, dealing 85-100% orig dmg value
	dmg *= rng.randf_range(0.85, 1)

	# Damage value doubled if critical
	if rng.randf() <= curr_turn.crit:
		dmg *= 2
		is_crit = true
		print_battle_msg("CRITICAL!")

	# Damage value reduced by target's defense
	dmg -= dmg * (target.p_def if move.dmg_type == DamageType.PHY else target.m_def)

	return round(dmg)


func execute_aoe(move):
	var kill_queue = []

	var i = 0
	for pos in move.targ:
		if i < (enemy_team.size() if target.is_in_group("enemy") else ally_team.size()):
			if positioning[pos] != null:
				target = positioning[pos]

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
				print_battle_msg(target.name + " was burned by " + curr_turn.name + " for " + effect.turns as String + " turns")

			StatusEffect.STUN:
				interrupt_queued_ability(target)
				print_battle_msg(target.name + " was stunned by " + curr_turn.name + " for " + effect.turns as String + " turns")

			StatusEffect.DISARM:
				print_battle_msg(target.name + " was disarmed by " + curr_turn.name + " for " + effect.turns as String + " turns")


func execute_shield(move):
	success = true
	target.gain_shield(move.val)
	print_battle_msg(curr_turn.name + " shielded " + target.name + " for " + move.val as String + "HP")


func execute_heal(move):
	success = true
	target.heal(move.val)
	print_battle_msg(curr_turn.name + " healed " + target.name + " for " + move.val as String + "HP")


func execute_aoe_heal(move):
	var i = 0
	for hero in move.targ:
		if i < (enemy_team.size() if target.is_in_group("enemy") else ally_team.size()):
			if positioning[hero] != null:
				target = positioning[hero]
				execute_heal(move)

		i += 1


func execute_move_pos(targ, num):
	for _i in range(abs(num)):
		swap_pos(targ, num > 0)

	print_battle_msg(targ.name + " moved " + num as String + " spaces")
	correct_positioning()


func ability_success(move):
	is_crit = false

	if !func_check("pre_check", move):
		return false

	# Roll for accuracy
	if rng.randf() > curr_turn.acc:
		print_battle_msg(curr_turn.name + " missed")
		target.show_value("MISS")
		return false

	# An ability succeeds even if target dodges
	success = true

	# If target dodges attack
	if rng.randf() <= target.dodge:
		print_battle_msg(target.name + " dodged")
		target.show_value("DDOGE")
		return false

	return true


func func_check(check, move):
	# Verify there is a valid tag: "pre_check" or "post_check"
	if check in move:
		# Call boolean call to see if move is performed
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


func swap_pos(hero, forward=true):
	var targ_team = ally_team if hero.is_in_group("ally") else enemy_team
	var idx = targ_team.find(hero)
	var move_num = check_pos_boundaries(idx, forward, targ_team)
		
	# Swap positions
	targ_team[idx] = targ_team[idx + move_num]
	targ_team[idx + move_num] = hero


func check_pos_boundaries(idx, forward, targ_team):
	# Check boundaries
	if forward:
		return 0 if idx + 1 >= targ_team.size() else 1

	else:
		return 0 if idx - 1 < 0 else -1


func kill_hero(hero):
	for roll in initiative:
		if roll.hero == hero:
			roll.hero = null

	if hero.is_in_group("ally"):
		ally_team.erase(hero)
	else:
		enemy_team.erase(hero)

	hero.queue_free()
	print_battle_msg(hero.name + " died")

	
func correct_positioning():
	positioning = [null, null, null, null, null, null, null, null]

	var size = ally_team.size()
	# Fill ally spots in order from right -> left
	for hero in ally_team:
		hero.position.x = POS_COORDS[4 - size]
		positioning[4 - size] = hero
		size -= 1

	# Fill enemy spots in order from left -> right
	for hero in enemy_team:
		hero.position.x = POS_COORDS[4 + size]
		positioning[4 + size] = hero
		size += 1


func check_lose_condition():
	if ally_team.size() == 0:
		$AbilityHUD/LosePopup.popup()


func check_for_next_wave():
	if enemy_team.size() == 0:
		TeamComp.generate_enemy_comp()
		var team_comp = TeamComp.enemy_team
		w_num += 1

		for i in range(team_comp.size()):
			var character = Character.instance()
			character.position = Vector2(POS_COORDS[4 + i], 97)
			add_child(character)

			character.init(team_comp[i], 0, true)
			character.add_to_group("enemy")
			enemy_team.append(character)

			character.connect("selected", self, "_on_Character_selected")

		correct_positioning()


func set_info(msg):
	$AbilityHUD/GameInfo.text = msg
	$AbilityHUD/WaveLabel.text = "Wave " + (w_num + 1) as String


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


func print_battle_msg(msg):
	print("[r" + (r_num + 1) as String + "t" + (t_num + 1) as String + "] " + msg)
