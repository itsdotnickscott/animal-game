extends Character


func load_stats(lvl):
	$Sprite.texture = preload("res://assets/sample_character.png")
	max_hp  = 0		+ (lvl * 0)
	atk     = 0		+ (lvl * 0)
	mag		= 0		+ (lvl * 0)
	crit    = 0		+ (lvl * 0)
	acc     = 0		+ (lvl * 0)
	p_def   = 0		+ (lvl * 0)
	m_def	= 0		+ (lvl * 0)
	dodge   = 0		+ (lvl * 0)
	spd     = 0		+ (lvl * 0)

	.load_stats(lvl)


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