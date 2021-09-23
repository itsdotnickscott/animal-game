extends Character


func load_stats():
	$Sprite.texture = preload("res://assets/enemy_fighter.png")
	max_hp  = 35
	atk     = 6
	mag		= 0
	crit    = 0.06
	acc     = 0.9
	p_def   = 0
	m_def	= 0
	dodge   = 0.05
	spd     = 4

	.load_stats()


func choose_ability():
	# Attack one target for 100% ATK
	return {
		"type": MoveType.DAMAGE,
		"dmg_type": DamageType.PHY,
		"val": atk * 1.0,
		"targ": Positioning.ALLY_FRONT,
		"pos": Positioning.ENEMY_FRONT,
	}
