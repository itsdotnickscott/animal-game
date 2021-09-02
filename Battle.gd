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
	$Character1.init("MagicTurt")
	$Character2.init("PowBun")
	$Character3.init("CowDog")
	$Character4.init("FireCat")

	# Group: "enemy"
	$Enemy1.init("SampleEnemy")
	$Enemy2.init("SampleEnemy")
	$Enemy3.init("SampleEnemy")
	$Enemy4.init("SampleEnemy")

	player_team = get_tree().get_nodes_in_group("player")
	enemy_team = get_tree().get_nodes_in_group("enemy")

	# Done for positioning purposes
	player_team.invert()

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
	var hero = initiative[t_num].hero
	set_info(hero.name + "'s Turn")

	# Resolve any status effects
	for effect in hero.status:
		if "status" in effect:
			match effect.status:
				StatusEffect.BURN:
					hero.curr_hp -= effect.val
					print("[status] ", hero.name + " was burned for " + effect.val as String + " damage")

				StatusEffect.STUN:
					print("[status] ", hero.name + " is stunned")
					next_turn()
					return

		effect.turns -= 1

		if effect.turns == 0:
			hero.clear_status(effect)

	# If enemy's turn, attack random target
	if hero in enemy_team:
		var targ = rng.randf_range(0, player_team.size()) as int
		target = player_team[targ]

		execute_damage(hero.attack())
		next_turn()
		return

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

	if !valid_pos(move) || !valid_target(move):
		return

	match move.type:
		MoveType.DAMAGE:
			execute_damage(move)

		MoveType.AOE:
			execute_aoe(move)

		MoveType.STATUS:
			target.apply_status(move.apply)

		_:
			pass

	next_turn()


func execute_damage(move, queue = false):
	if target == null:
		pass

	if ability_success(move):
		target.take_damage(move.val)
		print(getRoundTurnString(), initiative[t_num].hero.name + " dealt " + move.val as String + " damage to " + target.name)

		# Handles repeating attacks
		if "repeat" in move:
			for _i in range(move.repeat): 
				# If targeting is random
				if move.targ == "????":
					var targ = rng.randf_range(0, enemy_team.size()) as int
					target = enemy_team[targ]

				# If successive attacks get stronger/weaker
				if "dmg_chg" in move:
					move.val = move.val * move.dmg_chg

				target.take_damage(move.val)
				print(getRoundTurnString(), initiative[t_num].hero.name + " dealt " + move.val as String + " damage to " + target.name)

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
				target.apply_status(move.apply)

	# If queue is activated, target is not dead so do not place in kill queue
	if queue:
		return false


func execute_aoe(move):
	var kill_queue = []
	var pos = -1

	for hero in enemy_team:
		pos += 1

		if move.targ[pos] == ".":
			continue

		target = hero

		if execute_damage(move, true):
			kill_queue.append(target)

		# If successive attacks get stronger/weaker
		if "dmg_chg" in move:
			move.val = move.val * move.dmg_chg

	for dead in kill_queue:
		kill_hero(dead)


func ability_success(move):
	if "check" in move:
		var hit = false

		# Check if ability requires a check on status effects to hit
		for effect in target.status:
			if effect.status == move.check:
				hit = true

		if !hit:
			return false

	# Roll for accuracy
	var roll = rng.randf()
	if roll > initiative[t_num].hero.acc:
		print(getRoundTurnString(), initiative[t_num].hero.name + " missed")
		return false

	return true


func valid_target(move):
	# Self-targeted ability
	if move.targ == "self":
		if target != initiative[t_num].hero:
			print("Must use this ability on self")
			return false

		return true

	var targ_team = player_team if "o" in move.targ else enemy_team
	var pos = targ_team.find(target)

	if target in targ_team:
		if move.targ[pos] != ".":
			return true

	print("Invalid target")
	return false


func valid_pos(move):
	var hero = initiative[t_num].hero
	var targ_team = player_team if hero in player_team else enemy_team
	var idx = targ_team.find(target)

	if move.pos[idx] == "o":
		return true

	print("Invalid positioning")
	return false


func kill_hero(hero):
	for roll in initiative:
		if roll.hero == hero:
			roll.hero = null

	if player_team.has(hero):
		player_team.erase(hero)
	else:
		enemy_team.erase(hero)

	hero.queue_free()
	print(getRoundTurnString(), hero.name + " died")


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
	return "[r" + (r_num + 1) as String + "t" + (t_num + 1) as String + "] "
