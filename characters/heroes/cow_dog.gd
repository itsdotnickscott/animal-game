extends Character


func load_stats(lvl):
	name = "CowDog"
	
	$Sprite.texture = preload("res://assets/cow_dog.png")
	max_hp  = 11	+ (lvl * 3)
	atk     = 5		+ (lvl * 2)
	mag 	= 0		+ (lvl * 1)
	crit    = 0.05	+ (lvl * 0.01)
	acc     = 0.85	+ (lvl * 0.005)
	p_def   = 0		+ (lvl * 0.01)
	m_def	= 0		+ (lvl * 0.01)
	dodge   = 0		+ (lvl * 0.01)
	spd     = 3		+ (lvl * 1)

	.load_stats(lvl)


func attack():
	# Shoot CowDog's gun at one target for 120% ATK.
	return {
		"type": MoveType.DAMAGE,
		"dmg_type": DamageType.PHY,
		"val": atk * 1.2,
		"targ": Positioning.ENEMY_ALL,
		"pos": Positioning.ALLY_BACK_3,
	}


func primary():
	# Roll forward 1 space and throw a stun grenade for 75% MAG.
	return {
		"type": MoveType.DAMAGE,
		"dmg_type": DamageType.MAG,
		"val": mag * 0.75,
		"targ": Positioning.ENEMY_FRONT,
		"pos": Positioning.ALLY_BACK_3,
		"move_self": 1,
		"apply": apply_stun(),
	}


func secondary():
	# Shoot a blast dealing 80% ATK to the first target and half that damage to the second, pushing
	# CowDog back 2 spaces.
	return {
		"type": MoveType.AOE, 
		"dmg_type": DamageType.PHY,
		"val": atk * 0.80,
		"targ": Positioning.ENEMY_FRONT,
		"pos": Positioning.ALLY_FRONT,
		"move_self": -2,
		"dmg_chg": 0.5,
	}

	
func ultimate():
	# Fire your weapon randomly six times, dealing 50% ATK per bullet.
	return {
		"type": MoveType.DAMAGE,
		"dmg_type": DamageType.PHY,
		"val": atk * 0.5,
		"targ": Positioning.ENEMY_ALL,
		"pos": Positioning.ALLY_BACK_3,
		"random": true,
		"repeat": 5,
	}


func apply_stun():
	# Stuns the target for 1 turn.
	return {
		"status": StatusEffect.STUN,
		"turns": 1,
	}.duplicate()