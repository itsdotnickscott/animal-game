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
	def     = 0
	dodge   = 0
	spd     = 0

	curr_hp = max_hp
	status = []
	shell_mode = false
	flame = 5

	update_labels()


func attack():
	# Headbutt a target for 100% ATK and gain 1 Flame.
	return {
		"type": MoveType.DAMAGE,
		"val": atk * 1.0,
		"targ": "xx..",
		"pos": "..oo",
	}


func primary():
	# Shoot a fireball at a target for 120% MAG. Flame Cost: 2
	return {
		"type": MoveType.DAMAGE,
		"val": mag * 1.2,
		"targ": ".xxx",
		"pos": "..oo",
	}


func secondary():
	# Create a fiery shield equal to 100% MAG for 2 turns. Flame Cost: 1
	return {
		"type": MoveType.SHIELD,
		"val": mag * 1.0,
		"targ": "self",
		"pos": "oooo",
	}

	
func ultimate():
	# Engulf the front line with a flame dealing 175% MAG. Flame Cost: 4
	return {
		"type": MoveType.AOE,
		"val": mag * 1.75,
		"targ": "xx..",
		"pos": "..oo",
	}


func update_labels():
	.update_labels()


func take_damage(val):
	.take_damage(val)


func apply_status(effect):
	.apply_status(effect)


func clear_status(effect):
	.clear_status(effect)
