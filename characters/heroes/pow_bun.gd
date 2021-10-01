extends Character


func load_stats(lvl):
	name = "PowBun"

	$Sprite.texture = preload("res://assets/pow_bun.png")
	max_hp  = 11	+ (lvl * 3)
	atk     = 4		+ (lvl * 2)
	mag		= 0		+ (lvl * 0)	
	crit    = 0.05	+ (lvl * 0.01)
	acc     = 0.9	+ (lvl * 0.005)
	p_def   = 0		+ (lvl * 0.01)
	m_def	= 0		+ (lvl * 0.01)
	dodge   = 0.05	+ (lvl * 0.01)
	spd     = 4		+ (lvl * 1)

	.load_stats(lvl)


func attack():
	# Punch a target twice, the first dealing 60% ATK, and the second dealing 90% ATK.
	return {
		"type": MoveType.DAMAGE,
		"dmg_type": DamageType.PHY,
		"val": atk * 0.6,
		"targ": Positioning.ENEMY_FRONT,
		"pos": Positioning.ALLY_FRONT,
		"dmg_chg": 1.5,
		"repeat": 1,
	}


func primary():
	# PowBun winds up for a sucker punch, dealing 150% ATK on the next turn, pushing them back 
	# 2 spaces, stunning them. PowBun moves forward 1 space.
	print("[note] PowBun is winding up for an attack!")

	return {
		"type": MoveType.DAMAGE,
		"dmg_type": DamageType.PHY,
		"val": atk * 1.5,
		"targ": Positioning.ENEMY_1,
		"pos": Positioning.ALLY_FRONT,
		"move_targ": 2,
		"move_self": 1,
		"apply": apply_stun(),
		"queue": true,
	}


func secondary():
	# Focus, increasing PowBun's CRIT by 10 for 3 turns.
	return {
		"type": MoveType.STATUS,
		"targ": Positioning.SELF,
		"pos": Positioning.ALLY_ALL,
		"apply": apply_focus(),
	}

	
func ultimate():
	# Power punch a target for 200% ATK. If the target dies, their body flies through the rest
	# of the team, dealing 50% less damage per target.
	return {
		"type": MoveType.DAMAGE,
		"dmg_type": DamageType.PHY,
		"val": atk * 2.0,
		"targ": Positioning.ENEMY_1,
		"pos": Positioning.ALLY_FRONT,
		"dmg_chg": 0.5,
		"post_check": ["check_for_death", "body_aoe"],
	}


func check_for_death(hero):
	return hero.curr_hp <= 0


func body_aoe():
	return {
		"type": MoveType.AOE,
		"dmg_type": DamageType.PHY,
		"val": atk * 1.0,
		"targ": Positioning.ENEMY_BACK_3,
		"pos": Positioning.ALLY_FRONT,
		"dmg_chg": 0.5,
	}


func apply_focus():
	print("[note] PowBun has increased crit!")
	return {
		"crit": 0.1,
		"turns": 3,
	}


func apply_stun():
	# Stuns the target for 1 turn.
	return {
		"status": StatusEffect.STUN,
		"turns": 1,
	}