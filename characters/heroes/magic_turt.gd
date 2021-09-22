extends Character


# Passive: Instead of having cooldowns on MagicTurt's abilities, Flame is used to cast spells.
# If MagicTurt's Flame runs out, he is stunned for 1 turn.
# Whenever MagicTurt is stunned, he retracts into his shell, gaining 10 DEF.
var shell_mode
var flame


func load_stats():
	name = "MagicTurt"

	$Sprite.texture = preload("res://assets/magic_turt.png")
	max_hp  = 30
	atk     = 6
	mag 	= 10
	crit    = 0
	acc     = 0.9
	p_def   = 0.05
	m_def	= 0.05
	dodge   = 0
	spd     = 0

	shell_mode = false
	flame = 5


func attack():
	# Headbutt a target for 100% ATK.
	# Using this attack while in MagicTurt's shell will deal an additional 80% MAG, restoring all
	# of MagicTurt's missing Flame. MagicTurt leaves his shell.
	var val = atk * 1.0

	if shell_mode:
		flame = 5
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
	# Shoot a fireball at a target for 120% MAG. Flame Cost: 2
	flame -= 2
	check_flame()

	return {
		"type": MoveType.DAMAGE,
		"dmg_type": DamageType.MAG,
		"val": mag * 1.2,
		"targ": Positioning.ENEMY_BACK_3,
		"pos": Positioning.ALLY_FRONT,
	}


func secondary():
	# Create a fiery shield equal to 100% MAG for 2 turns. Flame Cost: 1
	flame -= 1
	check_flame()

	return {
		"type": MoveType.SHIELD,
		"val": mag * 1.0,
		"targ": Positioning.SELF,
		"pos": Positioning.ALLY_ALL,
	}

	
func ultimate():
	# Engulf the front line with a flame dealing 175% MAG. Flame Cost: 3
	flame -= 3
	check_flame()

	return {
		"type": MoveType.AOE,
		"dmg_type": DamageType.MAG,
		"val": mag * 1.75,
		"targ": Positioning.ENEMY_FRONT,
		"pos": Positioning.ALLY_FRONT,
	}


func shell(enter):
	if shell_mode == enter:
		return
	
	shell_mode = enter
	p_def += 0.1 if enter else -0.1
	print("[note] MagicTurt " + ("entered" if enter else "exited") + " his shell")


func check_flame():
	if flame <= 0:
		apply_status(apply_stun())


func apply_stun():
	# Stuns the target for 1 turn.
	return {
		"status": StatusEffect.STUN,
		"turns": 1,
	}


func apply_status(effect):
	if effect.status == StatusEffect.STUN:
		shell(true)
	
	.apply_status(effect)