extends Character


func load_stats():
	$Sprite.texture = preload("res://assets/sample_enemy.png")
	max_hp  = 100
	atk     = 5
	mag		= 0
	crit    = 0
	acc     = 0.9
	def     = 0
	dodge   = 0
	spd     = 0


func attack():
	# Attack one target for 100% ATK
	return {
		"type": MoveType.DAMAGE,
		"val": atk * 1.0,
		"targ": "xxxx",
		"pos": "oooo",
	}


func primary():
	# Attack one target for 100% ATK
	return {
		"type": MoveType.DAMAGE,
		"val": atk * 1.0,
		"targ": "xxxx",
		"pos": "oooo",
	}


func secondary():
	# Attack one target for 100% ATK
	return {
		"type": MoveType.DAMAGE,
		"val": atk * 1.0,
		"targ": "xxxx",
		"pos": "oooo",
	}

	
func ultimate():
	# Attack one target for 100% ATK
	return {
		"type": MoveType.DAMAGE,
		"val": atk * 1.0,
		"targ": "xxxx",
		"pos": "oooo",
	}