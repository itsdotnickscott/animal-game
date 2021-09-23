extends Character


func load_stats():
	$Sprite.texture = preload("res://assets/sample_character.png")
	max_hp  = 10
	atk     = 5
	mag		= 0
	crit    = 0
	acc     = 0.9
	p_def   = 0
	m_def	= 0
	dodge   = 0
	spd     = 0

	.load_stats()


func attack():
	# Attack one target for 100% ATK
	return {
		"type": MoveType.DAMAGE,
		"dmg_type": DamageType.PHY,
		"val": atk * 1.0,
		"targ": Positioning.ALLY_ALL,
		"pos": Positioning.ENEMY_ALL,
	}


func primary():
	# Attack one target for 100% ATK
	return {
		"type": MoveType.DAMAGE,
		"dmg_type": DamageType.PHY,
		"val": atk * 1.0,
		"targ": Positioning.ALLY_ALL,
		"pos": Positioning.ENEMY_ALL,
	}


func secondary():
	# Attack one target for 100% ATK
	return {
		"type": MoveType.DAMAGE,
		"dmg_type": DamageType.PHY,
		"val": atk * 1.0,
		"targ": Positioning.ALLY_ALL,
		"pos": Positioning.ENEMY_ALL,
	}

	
func ultimate():
	# Attack one target for 100% ATK
	return {
		"type": MoveType.DAMAGE,
		"dmg_type": DamageType.PHY,
		"val": atk * 1.0,
		"targ": Positioning.ALLY_ALL,
		"pos": Positioning.ENEMY_ALL,
	}