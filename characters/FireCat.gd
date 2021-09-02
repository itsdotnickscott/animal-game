extends Character


var on_fire


func load_stats():
	name = "FireCat"
	
	$Sprite.texture = preload("res://assets/fire_cat_64.png")
	max_hp  = 20
	atk     = 8
	mag 	= 4
	crit    = 0
	acc     = 0.9
	def     = 0
	dodge   = 0
	spd     = 5

	curr_hp = max_hp
	status = []
	on_fire = false

	update_labels()


func attack():
	# Shoot an arrow at one target for 100% ATK.
	return {
		"type": MoveType.DAMAGE,
		"val": atk * 1.0,
		"targ": "xxxx",
		"apply": apply_burn(),
	}


func primary():
	# Shoot a piercing arrow, dealing 50% ATK to the first enemy and losing 50% DMG
	# for every other enemy.
	return {
		"type": MoveType.AOE,
		"val": atk * 0.5,
		"targ": "xxxx",
		"dmg_loss": 0.5,
		"apply": apply_burn(),
	}


func secondary():
	# Raise DODGE by 5 and set abilities on fire for 2 turns.
	# While on fire, abilities apply a BURN.
	return {
		"type": MoveType.STATUS,
		"targ": "self",
		"apply": apply_on_fire(),
	}

	
func ultimate():
	# All enemies with a BURN debuff gets attacked for 150% ATK.
	return {
		"type": MoveType.AOE,
		"val": atk * 1.5,
		"check": StatusEffect.BURN,
		"targ": "xxxx",
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


func update_labels():
	.update_labels()


func take_damage(val):
	.take_damage(val)


func apply_status(effect):
	if effect.on_fire:
		on_fire = effect.on_fire
		print("[status]", " CatArcher is on fire")

	.apply_status(effect)


func clear_status(effect):
	if effect.on_fire:
		on_fire = !effect.on_fire

	.clear_status(effect)
