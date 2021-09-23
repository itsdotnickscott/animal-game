extends Character


func load_stats():
	name = "BardSnek"

	$Sprite.texture = preload("res://assets/sample_character.png")
	max_hp  = 15
	atk     = 5
	mag		= 8
	crit    = 0.05
	acc     = 0.9
	p_def   = 0
	m_def	= 0
	dodge   = 0
	spd     = 3

	.load_stats()


func attack():
	# Strike a note at a target for 100% ATK.
	return {
		"type": MoveType.DAMAGE,
		"dmg_type": DamageType.PHY,
		"val": atk * 1.0,
		"targ": Positioning.ENEMY_ALL,
		"pos": Positioning.ALLY_BACK,
	}


func primary():
	# Coil around a target for 150% MAG, stunning them.
	return {
		"type": MoveType.DAMAGE,
		"dmg_type": DamageType.MAG,
		"val": mag * 1.5,
		"targ": Positioning.ENEMY_ALL,
		"pos": Positioning.ALLY_BACK,
		"apply": apply_stun(),
	}


func secondary():
	# Heal the entire team for 50% MAG.
	return {
		"type": MoveType.AOE_HEAL,
		"val": mag * 0.5,
		"targ": Positioning.ALLY_ALL,
		"pos": Positioning.ALLY_BACK,
	}

	
func ultimate():
	# Play a charming song for 75% MAG, disarming every target.
	return {
		"type": MoveType.AOE,
		"dmg_type": DamageType.MAG,
		"val": mag * 0.75,
		"targ": Positioning.ENEMY_ALL,
		"pos": Positioning.ALLY_BACK,
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
	return ({
		"status": StatusEffect.DISARM,
		"turns": 1,
	}).duplicate()