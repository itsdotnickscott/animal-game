extends Character


func load_stats():
	$Sprite.texture = preload("res://assets/sample_enemy.png")
	max_hp  = 100
	atk     = 10
	crit    = 1
	acc     = 1
	def     = 0
	dodge   = 0
	spd     = 0

	curr_hp = max_hp
	egy = 0
	status = []

	$HPLabel.text = max_hp as String + "HP"


func attack():
	# Attack one target for 100% ATK
	return {
		"dmg": atk,
		"targ": "XXXX",
	}


func primary():
	pass


func secondary():
	pass

	
func ultimate():
	pass