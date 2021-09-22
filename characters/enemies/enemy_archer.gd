extends Character


func load_stats():
	$Sprite.texture = preload("res://assets/enemy_archer.png")
	max_hp  = 16
	atk     = 6
	mag		= 0
	crit    = 0
	acc     = 0.9
	p_def   = 0
	m_def	= 0
	dodge   = 0
	spd     = 4


func choose_ability():
	# Attack all targets for 80% ATK
	return {
		"type": MoveType.AOE,
		"dmg_type": DamageType.PHY,
		"val": atk * 0.8,
		"targ": Positioning.ALLY_ALL,
		"pos": Positioning.ENEMY_BACK,
	}