extends Character


func load_stats():
	$Sprite.texture = preload("res://assets/sample_enemy.png")
	max_hp  = 100
	atk     = 10
	crit    = 1
	acc     = 1
	def     = 0
	dodge   = 0
	spd     = 0

	curr_hp = max_hp
	egy = 0
	status = []

	update_labels()


func attack():
	# Attack one target for 100% ATK
	return {
		"type": MoveType.DAMAGE,
		"val": atk * 1.0,
		"targ": "XXXX",
	}


func primary():
	# Attack one target for 100% ATK
	return {
		"type": MoveType.DAMAGE,
		"val": atk * 1.0,
		"targ": "XXXX",
	}


func secondary():
	# Attack one target for 100% ATK
	return {
		"type": MoveType.DAMAGE,
		"val": atk * 1.0,
		"targ": "XXXX",
	}

	
func ultimate():
	# Attack one target for 100% ATK
	return {
		"type": MoveType.DAMAGE,
		"val": atk * 1.0,
		"targ": "XXXX",
	}


func update_labels():
	.update_labels()


func take_damage(val):
	.take_damage(val)


func start_turn():
	.start_turn()


func apply_status(effect):
	.apply_status(effect)


func clear_status(effect):
	.clear_status(effect)