extends Character


func load_stats():
	name = "PowBun"

	$Sprite.texture = preload("res://assets/pow_bun.png")
	max_hp  = 22
	atk     = 10
	mag		= 3
	crit    = 0
	acc     = 0.9
	def     = 0
	dodge   = 0
	spd     = 8

	curr_hp = max_hp
	status = []

	update_labels()


func attack():
	# Punch a target twice, the first dealing 60% ATK, and the second dealing 90% ATK.
	return {
		"type": MoveType.DAMAGE,
		"val": atk * 0.6,
		"targ": "xx..",
		"pos": "..oo",
		"dmg_chg": 1.5,
		"repeat": 1,
	}


func primary():
	# Sucker punch a target for 150% ATK, pushing them back 2 spaces, and stunning them.
	return {
		"type": MoveType.DAMAGE,
		"val": atk * 1.5,
		"targ": "xx..",
		"pos": "..oo",
		"move_targ": -2
	}


func secondary():
	# Take a defensive stance, increasing PowBun's DEF by 10 and CRIT by 10 for 3 turns.
	return {
		"type": MoveType.STATUS,
		"targ": "self",
		"pos": "oooo",
		"apply": apply_defense(),

	}

	
func ultimate():
	# Power punch a target for 200% ATK. If the target dies, their body flies through the rest
	# of the team, dealing 50% less damage per target.
	return {
		"type": MoveType.AOE,
		"val": atk * 2.0,
		"targ": "xx..",
		"pos": "..oo",
		"dmg_chg": 0.5,
	}


func apply_defense():
	return {
		"def": 0.1,
		"crit": 0.1,
		"turns": 3,
	}


func update_labels():
	.update_labels()


func take_damage(val):
	.take_damage(val)


func apply_status(effect):
	.apply_status(effect)


func clear_status(effect):
	.clear_status(effect)