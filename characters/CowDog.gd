extends Character


func load_stats():
	name = "CowDog"
	
	$Sprite.texture = preload("res://assets/cow_dog_64.png")
	max_hp  = 16
	atk     = 9
	mag 	= 4
	crit    = 0
	acc     = 0.85
	def     = 0
	dodge   = 0
	spd     = 5

	curr_hp = max_hp
	status = []

	update_labels()


func attack():
	# Shoot CowDog's gun at one target for 100% ATK.
	return {
		"type": MoveType.DAMAGE,
		"val": atk * 1.0,
		"targ": "xxxx",
	}


func primary():
	# Throw a stun grenade for 75% MAG.
	return {
		"type": MoveType.DAMAGE,
		"val": mag * 0.75,
		"targ": "xx..",
		"apply": apply_stun(),
	}


func secondary():
	# Shoot a blast dealing 80% ATK to the first target and half that damage to the second.
	return {
		"type": MoveType.AOE, 
		"val": atk * 0.80,
		"targ": "xx..",
		"dmg_loss": 0.5,
	}

	
func ultimate():
	# Fire your weapon randomly six times, dealing 50% ATK per bullet.
	return {
		"type": MoveType.DAMAGE,
		"val": atk * 0.5,
		"targ": "????",
		"repeat": 5,
	}


func apply_stun():
	# Stuns the target for 1 turn.
	return {
		"status": StatusEffect.STUN,
		"turns": 1,
	}


func update_labels():
	.update_labels()


func take_damage(val):
	.take_damage(val)


func apply_status(effect):
	.apply_status(effect)


func clear_status(effect):
	.clear_status(effect)
