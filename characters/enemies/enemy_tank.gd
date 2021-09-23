extends Character


func load_stats():
	$Sprite.texture = preload("res://assets/enemy_tank.png")
	max_hp  = 50
	atk     = 4
	mag		= 0
	crit    = 0.05
	acc     = 0.9
	p_def   = 0.2
	m_def	= 0.2
	dodge   = 0
	spd     = 0

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
