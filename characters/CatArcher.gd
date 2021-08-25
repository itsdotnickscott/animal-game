extends Character


# Special buff
var on_fire


func load_stats():
	name = "CatArcher"
	
	$Sprite.texture = preload("res://assets/fire_cat_64.png")
	max_hp  = 450
	atk     = 10
	mag 	= 4
	crit    = 0
	acc     = 0.9
	def     = 0
	dodge   = 0
	spd     = 5

	curr_hp = max_hp
	egy = 0
	status = []
	on_fire = false

	update_labels()


func attack():
	# Shoot an arrow at one target for 110% ATK.
	egy += 10

	return {
		"type": MoveType.DAMAGE,
		"val": atk * 1.1,
		"targ": "XXXX",
		"debuff": apply_burn(),
	}


func primary():
	# Shoot a piercing arrow, dealing 75% ATK to the first enemy and losing 50% DMG
	# for every other enemy.
	egy += 10

	return {
		"type": MoveType.AOE,
		"val": atk * 0.75,
		"targ": "XXXX",
		"dmg_loss": 0.5,
		"debuff": apply_burn(),
	}


func secondary():
	# Raise DODGE by 5 and set abilities on fire for 2 turns.
	# While on fire, abilities apply a BURN.
	egy += 10

	apply_status({
		"type": StatusType.BUFF, 
		"dodge": 5,
		"on_fire": true,
		"turns": 2,
	})

	return {
		"type": MoveType.STATUS,
	}

	
func ultimate():
	# All enemies with a BURN debuff gets attacked for 150% ATK.
	return {
		"type": MoveType.AOE,
		"val": atk * 1.5,
		"check": StatusEffect.BURN,
		"targ": "XXXX",
		"debuff": apply_burn(),
	}


func apply_burn():
	if !on_fire:
		return null

	# Deals 15% MAG over 3 turns.
	return {
		"type": StatusType.DEBUFF,
		"effect": StatusEffect.BURN,
		"val": mag * 0.25,
		"turns": 3,
	}


func update_labels():
	.update_labels()


func take_damage(val):
	.take_damage(val)


func start_turn():
	.start_turn()


func apply_status(effect):
	if effect.on_fire:
		on_fire = effect.on_fire
		print("[status]", " CatArcher is on fire")

	.apply_status(effect)


func clear_status(effect):
	if effect.on_fire:
		on_fire = !effect.on_fire

	.clear_status(effect)
