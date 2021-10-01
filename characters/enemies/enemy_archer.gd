extends Character


func load_stats(lvl):
	$Sprite.texture = preload("res://assets/enemy_archer.png")
	max_hp  = 8
	atk     = 3
	mag		= 0
	crit    = 0.05
	acc     = 0.9
	p_def   = 0
	m_def	= 0
	dodge   = 0
	spd     = 5

	.load_stats(lvl)


func choose_ability():
	# Attack one target for 100% ATK
	return {
		"type": MoveType.DAMAGE,
		"dmg_type": DamageType.PHY,
		"val": atk * 1,
		"targ": Positioning.ALLY_ALL,
		"pos": Positioning.ENEMY_BACK,
	}