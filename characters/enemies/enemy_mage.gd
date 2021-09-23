extends Character


func load_stats():
	$Sprite.texture = preload("res://assets/enemy_mage.png")
	max_hp  = 14
	atk     = 5
	mag		= 6
	crit    = 0.05
	acc     = 0.9
	p_def   = 0
	m_def	= 0
	dodge   = 0
	spd     = 2

	.load_stats()


func choose_ability():
	# Attack a target for 100% MAG
	return {
		"type": MoveType.DAMAGE,
		"dmg_type": DamageType.MAG,
		"val": mag * 1.0,
		"targ": Positioning.ALLY_ALL,
		"pos": Positioning.ENEMY_BACK,
	}