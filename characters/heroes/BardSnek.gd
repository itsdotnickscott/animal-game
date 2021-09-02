extends Character


func load_stats():
	name = "BardSnek"

	$Sprite.texture = preload("res://assets/sample_character.png")
	max_hp  = 15
	atk     = 5
	mag		= 8
	crit    = 0
	acc     = 0.9
	def     = 0
	dodge   = 0
	spd     = 3

	curr_hp = max_hp
	status = []

	update_labels()


func attack():
	# Strike a note at a target for 100% ATK.
	return {
		"type": MoveType.DAMAGE,
		"val": atk * 1.0,
		"targ": "xxxx",
		"pos": "oo..",
	}


func primary():
	# Coil around a target for 150% MAG, stunning them.
	return {
		"type": MoveType.DAMAGE,
		"val": mag * 1.5,
		"targ": "xxxx",
		"pos": "oo..",
		"apply": apply_stun(),
	}


func secondary():
	# Heal the entire team for 40% MAG.
	return {
		"type": MoveType.AOE_HEAL,
		"val": mag * 0.4,
		"targ": "oooo",
		"pos": "oo..",
	}

	
func ultimate():
	# Play a charming song for 75% MAG, disarming every target.
	return {
		"type": MoveType.AOE,
		"val": mag * 0.75,
		"targ": "xxxx",
		"pos": "oo..",
		"apply": apply_disarm(),
	}


func apply_stun():
	# Stuns the target for 1 turn.
	return {
		"status": StatusEffect.STUN,
		"turns": 1,
	}


func apply_disarm():
	# Target cannot use the attack action for 1 turn.STATUS
	return {
		"status": StatusEffect.DISARM,
		"turns": 1,
	}


func update_labels():
	.update_labels()


func take_damage(val):
	.take_damage(val)


func apply_status(effect):
	.apply_status(effect)


func clear_status(effect):
	.clear_status(effect)