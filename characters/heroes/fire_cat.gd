extends Character


var on_fire


func load_stats():
	name = "FireCat"
	
	$Sprite.texture = preload("res://assets/fire_cat.png")
	max_hp  = 20
	atk     = 8
	mag 	= 8
	crit    = 0.05
	acc     = 0.95
	p_def   = 0
	m_def	= 0
	dodge   = 0
	spd     = 6

	on_fire = false

	.load_stats()


func attack():
	# Shoot an arrow at one target for 110% ATK.
	return {
		"type": MoveType.DAMAGE,
		"dmg_type": DamageType.PHY,
		"val": atk * 1.1,
		"targ": Positioning.ENEMY_ALL,
		"pos": Positioning.ALLY_BACK,
		"apply": apply_burn(),
	}


func primary():
	# Shoot a piercing arrow, dealing 75% ATK to the first enemy and losing 25% DMG
	# for every other enemy.
	return {
		"type": MoveType.AOE,
		"dmg_type": DamageType.PHY,
		"val": atk * 0.75,
		"targ": Positioning.ENEMY_ALL,
		"pos": Positioning.ALLY_BACK,
		"dmg_chg": 0.75,
		"apply": apply_burn(),
	}


func secondary():
	# Raise DODGE by 5 and set abilities on fire for 2 turns.
	# While on fire, abilities apply a BURN.
	return {
		"type": MoveType.STATUS,
		"targ": Positioning.SELF,
		"pos": Positioning.ALLY_ALL,
		"apply": apply_on_fire(),
	}

	
func ultimate():
	# All enemies with a BURN debuff gets attacked for 120% MAG.
	return {
		"type": MoveType.AOE,
		"dmg_type": DamageType.MAG,
		"val": mag * 1.2,
		"pre_check": ["check_for_burn"],
		"targ": Positioning.ENEMY_ALL,
		"pos": Positioning.ALLY_BACK,
		"apply": apply_burn(),
	}


func apply_on_fire():
	return {
		"dodge": 0.05,
		"on_fire": true,
		"turns": 2,
	}


func apply_burn():
	if !on_fire:
		return null

	# Deals 75% MAG over 3 turns.
	return ({
		"status": StatusEffect.BURN,
		"val": mag * 0.25,
		"turns": 3,
	}).duplicate() 


func check_for_burn(hero):
	for effect in hero.status:
		if effect.status == StatusEffect.BURN:
			return true

	return false


func apply_status(effect):
	if "on_fire" in effect:
		on_fire = effect.on_fire
		print("[note] CatArcher is on fire!")

	.apply_status(effect)


func clear_status(effect):
	if effect.on_fire:
		on_fire = !effect.on_fire
		print("[note] CatArcher is no longer on fire")

	.clear_status(effect)