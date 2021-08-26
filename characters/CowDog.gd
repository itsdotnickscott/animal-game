extends Character


func load_stats():
	name = "CowDog"
	
	$Sprite.texture = preload("res://assets/cow_dog_64.png")
	max_hp  = 16
	atk     = 10
	mag 	= 4
	crit    = 0
	acc     = 0.85
	def     = 0
	dodge   = 0
	spd     = 5

	curr_hp = max_hp
	egy = 0
	status = []

	update_labels()


func attack():
	# Shoot your gun at one target for 120% ATK.
	egy += 10

	return {
		"type": MoveType.DAMAGE,
		"val": atk * 1.2,
		"targ": "XXXX",
	}


func primary():
	# Roll forward one space and throw a stun grenade for 75% MAG.
	egy += 10

	return {
		"type": MoveType.DAMAGE,
		"val": mag * 0.75,
		"targ": "XXXX",
		"debuff": apply_stun(),
		"pos": 1,
	}


func secondary():
	# Shoot a blast dealing 80% ATK to the first target and half that damage to the second.
	# The blast sends CowDog backward two spaces.
	egy += 10

	return {
		"type": MoveType.AOE, 
		"val": atk * 0.80,
		"targ": "XX..",
		"dmg_loss": 0.5,
		"pos": -2,
	}

	
func ultimate():
	# Fire your weapon randomly six times, dealing 75% ATK per bullet.
	return {
		"type": MoveType.DAMAGE,
		"val": atk * 0.75,
		"targ": "XXXX",
		"shots": 6,
	}


func apply_stun():
	# Stuns the target for 1 turn.
	return {
		"type": StatusType.DEBUFF,
		"effect": StatusEffect.STUN,
		"turns": 1,
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
