extends Character


func load_stats(lvl):
	name = "FireCat"
	
	$Sprite.texture = preload("res://assets/fire_cat.png")
	max_hp  = 10	+ (lvl * 2)
	atk     = 4		+ (lvl * 2)
	mag 	= 4		+ (lvl * 2)
	crit    = 0.05	+ (lvl * 0.01)
	acc     = 0.95	+ (lvl * 0.001)
	p_def   = 0		+ (lvl * 0.01)
	m_def	= 0 	+ (lvl * 0.01)
	dodge   = 0 	+ (lvl * 0.01)
	spd     = 3 	+ (lvl * 1)

	.load_stats(lvl)


func attack():
	# Shoot an arrow at one target for 100% ATK.
	return {
		"type": MoveType.DAMAGE,
		"dmg_type": DamageType.PHY,
		"val": atk * 1.0,
		"targ": Positioning.ENEMY_ALL,
		"pos": Positioning.ALLY_BACK,
		"apply": apply_burn(),
	}


func primary():
	# Shoot an arrow at one target for 100% ATK, dealing an additional 75% ATK if they have a BURN
	# debuff.
	return {
		"type": MoveType.DAMAGE,
		"dmg_type": DamageType.PHY,
		"val": atk * 1.0,
		"boost": ["check_for_burn", atk * 0.75],
		"targ": Positioning.ENEMY_ALL,
		"pos": Positioning.ALLY_BACK,
		"apply": apply_burn(),
	}


func secondary():
	# Shoot a piercing arrow, dealing 75% ATK and losing 25% DMG every time it hits an enemy.
	return {
		"type": MoveType.AOE,
		"dmg_type": DamageType.PHY,
		"val": atk * 0.75,
		"targ": Positioning.ENEMY_ALL,
		"pos": Positioning.ALLY_BACK,
		"dmg_chg": 0.75,
		"apply": apply_burn(),
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


func apply_burn():
	# Passive: All of FireCat's damaging abilities applies a burn that deals 75% MAG over 3 turns.
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