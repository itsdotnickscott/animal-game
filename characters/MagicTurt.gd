extends Character


var shell_mode
var rage


func load_stats():
	$Sprite.texture = preload("res://assets/magic_turt_64.png")
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
	rage = 0

	update_labels()


func attack():
	# Headbutt a target for 100% ATK.
	return {
		"type": MoveType.DAMAGE,
		"val": atk * 1.0,
		"targ": "xx..",
	}


func primary():
	# Shoot a fireball at a target for 120% MAG.
	return {
		"type": MoveType.DAMAGE,
		"val": mag * 1.2,
		"targ": ".xxx",
	}


func secondary():
	# Passive: Taking or dealing damage is stored as RAGE equal to 25% DMG. 
	# Enter into shell mode for 2 turns, increasing MagicTurt's DEF by 10. Gain twice as much RAGE
	# when taking or dealing damage. MagicTurt cannot cast its ultimate while in shell mode.
	return {
		"type": MoveType.STATUS,
		"targ": "self",
	}

	
func ultimate():
	# Engulf all targets with a flame for 100% MAG plus all RAGE stored.
	# This ability does not generate RAGE.
	return {
		"type": MoveType.AOE,
		"val": mag * 1.0 + convert_rage(),
		"targ": "xxxx",
	}


func convert_rage():
	var dmg = rage
	rage = 0
	return dmg


func apply_shell():
	return {
		"shell_mode": true,
		"def": 0.1,
		"turns": 2,
	}


func update_labels():
	.update_labels()


func take_damage(val):
	.take_damage(val)


func apply_status(effect):
	.apply_status(effect)


func clear_status(effect):
	.clear_status(effect)
