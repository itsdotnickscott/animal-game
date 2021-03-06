extends Character


# Passive: Instead of gaining a pip every round, MagicTurt starts with 5 pips.
# If MagicTurt's pips run out, he is stunned for 1 turn.
# Whenever MagicTurt is stunned, he retracts into his shell, gaining 25 DEF.
var shell_mode


func load_stats(lvl):
	name = "MagicTurt"

	$Sprite.texture = preload("res://assets/magic_turt.png")
	max_hp  = 16	+ (lvl * 4)
	atk     = 2		+ (lvl * 1)
	mag 	= 4 	+ (lvl * 2)
	crit    = 0.05	+ (lvl * 0.01)
	acc     = 0.9	+ (lvl * 0.005)
	p_def   = 0.1	+ (lvl * 0.01)
	m_def	= 0.1	+ (lvl * 0.01)
	dodge   = 0		+ (lvl * 0.01)
	spd     = 0		+ (lvl * 1)

	shell_mode = false

	.load_stats(lvl)

	pips = 5


func attack():
	# Headbutt a target for 100% ATK.
	# Using this attack while in MagicTurt's shell will deal an additional 80% MAG, restoring all
	# of MagicTurt's missing Flame. MagicTurt leaves his shell.
	var val = atk * 1.0

	if shell_mode:
		pips = 5
		shell(false)
		val += mag * 0.8

	return {
		"type": MoveType.DAMAGE,
		"dmg_type": DamageType.PHY,
		"val": val,
		"targ": Positioning.ENEMY_FRONT,
		"pos": Positioning.ALLY_FRONT,
	}


func primary():
	# Shoot a fireball at a target for 120% MAG.
	return {
		"type": MoveType.DAMAGE,
		"dmg_type": DamageType.MAG,
		"val": mag * 1.2,
		"targ": Positioning.ENEMY_BACK_3,
		"pos": Positioning.ALLY_FRONT,
	}


func secondary():
	# Create a fiery shield equal to 100% MAG for 2 turns.
	return {
		"type": MoveType.SHIELD,
		"val": mag * 1.0,
		"targ": Positioning.SELF,
		"pos": Positioning.ALLY_ALL,
	}

	
func ultimate():
	# Engulf the front line with a flame dealing 125% MAG.
	return {
		"type": MoveType.AOE,
		"dmg_type": DamageType.MAG,
		"val": mag * 1.25,
		"targ": Positioning.ENEMY_FRONT,
		"pos": Positioning.ALLY_FRONT,
	}


func shell(enter):
	if shell_mode == enter:
		return
	
	shell_mode = enter
	p_def += 0.25 if enter else -0.25
	print("[note] MagicTurt " + ("entered" if enter else "exited") + " his shell")


func apply_stun():
	# Stuns the target for 1 turn.
	return {
		"status": StatusEffect.STUN,
		"turns": 1,
}.duplicate()


func apply_status(effect):
	if effect.status == StatusEffect.STUN:
		shell(true)
	
	.apply_status(effect)


func give_pip():
	pass


func use_pips(num):
	.use_pips(num)

	if pips == 0:
		apply_status(apply_stun())
