extends Character


var on_fire


func load_stats():
	name = "FireCat"
	
	$Sprite.texture = preload("res://assets/fire_cat.png")
	max_hp  = 20
	atk     = 8
	mag 	= 4
	crit    = 0
	acc     = 0.9
	def     = 0
	dodge   = 0
	spd     = 6

	on_fire = false


func attack():
	# Shoot an arrow at one target for 110% ATK.
	return {
		"type": MoveType.DAMAGE,
		"val": atk * 1.1,
		"targ": "xxxx",
		"pos": "oo..",
		"apply": apply_burn(),
	}


func primary():
	# Shoot a piercing arrow, dealing 50% ATK to the first enemy and losing 50% DMG
	# for every other enemy.
	return {
		"type": MoveType.AOE,
		"val": atk * 0.5,
		"targ": "xxxx",
		"pos": "oo..",
		"dmg_chg": 0.5,
		"apply": apply_burn(),
	}


func secondary():
	# Raise DODGE by 5 and set abilities on fire for 2 turns.
	# While on fire, abilities apply a BURN.
	return {
		"type": MoveType.STATUS,
		"targ": "self",
		"pos": "oooo",
		"apply": apply_on_fire(),
	}

	
func ultimate():
	# All enemies with a BURN debuff gets attacked for 150% ATK.
	return {
		"type": MoveType.AOE,
		"val": atk * 1.5,
		"pre_check": "check_for_burn",
		"targ": "xxxx",
		"pos": "oo..",
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
	return {
		"status": StatusEffect.BURN,
		"val": mag * 0.25,
		"turns": 3,
	}


func check_for_burn(hero):
	for effect in hero.status:
		if effect.status == StatusEffect.BURN:
			return true

	return false


func apply_status(effect):
	if on_fire in effect:
		on_fire = effect.on_fire
		print("[note] CatArcher is on fire")

	.apply_status(effect)


func clear_status(effect):
	if effect.on_fire:
		on_fire = !effect.on_fire
		print("[note] CatArcher is no longer on fire")

	.clear_status(effect)
