extends Character


func load_stats():
	$Sprite.texture = preload("res://assets/sample_enemy.png")
	max_hp  = 10
	atk     = 5
	mag		= 0
	crit    = 0
	acc     = 0.9
	def     = 0
	dodge   = 0
	spd     = 0

	curr_hp = max_hp
	status = []

	update_labels()


func attack():
	# Attack one target for 100% ATK
	return {
		"type": MoveType.DAMAGE,
		"val": atk * 1.0,
		"targ": "xxxx",
	}


func primary():
	# Attack one target for 100% ATK
	return {
		"type": MoveType.DAMAGE,
		"val": atk * 1.0,
		"targ": "xxxx",
	}


func secondary():
	# Attack one target for 100% ATK
	return {
		"type": MoveType.DAMAGE,
		"val": atk * 1.0,
		"targ": "xxxx",
	}

	
func ultimate():
	# Attack one target for 100% ATK
	return {
		"type": MoveType.DAMAGE,
		"val": atk * 1.0,
		"targ": "xxxx",
	}


func update_labels():
	.update_labels()


func take_damage(val):
	.take_damage(val)


func apply_status(effect):
	.apply_status(effect)


func clear_status(effect):
	.clear_status(effect)
