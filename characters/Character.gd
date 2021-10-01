class_name Character

extends Area2D


signal selected(node)


# Health bar resources
var bar_red = preload("res://assets/red_health_bar.png")
var bar_green = preload("res://assets/green_health_bar.png")
var bar_yellow = preload("res://assets/yellow_health_bar.png")

# Pip resources
var pip = preload("res://assets/pip.png")
var empty_pip = preload("res://assets/empty_pip.png")

# Damage number resources
var FloatingText = preload("res://characters/FloatingText.tscn")
export var duration = 1


# Character stats
var level
var xp

var max_hp  # hit points
var atk     # boosts damage from attacks
var mag     # boosts scaling for spells
var crit    # chance to deal extra dmg
var acc     # chance to land an attack
var p_def   # resist dmg from physical damage
var m_def	# resist dmg from magic damage
var dodge   # avoid attack
var spd     # determines initiative in battle

var curr_hp # current health
var status  # current buffs/debuffs
var shield  # current shield value
var pips	# energy used to cast abilities
var pip_cd	# after using a pip-spending ability, one won't generate next round


func init(name, lvl, enemy=false):
	# Hide character's pips if an enemy
	var dir = "enemies" if enemy else "heroes"

	set_script(load("res://characters/" + dir + "/" + name + ".gd"))
	load_stats(lvl)
	update_ui()


func load_stats(lvl):
	level = lvl
	curr_hp = max_hp
	status = []
	shield = 0
	pips = 0
	pip_cd = false

	$HPBar.max_value = max_hp


func give_pip():
	if !pip_cd && pips != 5:
		pips += 1

	pip_cd = false
	update_ui()


func use_pips(num):
	pips -= num
	pip_cd = true
	update_ui()


func take_damage(val, is_crit=false):
	show_value(val, false, is_crit)

	# Shields soak up damage
	if shield - val >= 0:
		shield -= val

	elif shield > 0 && shield - val < 0:
		curr_hp -= val - shield
		shield = 0

	else:
		curr_hp -= val

	update_ui()


func heal(val, is_crit=false):
	show_value(val, true, is_crit)
	curr_hp = max_hp if curr_hp + val > max_hp else curr_hp + val
	update_ui()


func gain_shield(val):
	shield += val
	update_ui()


func update_ui():
	update_hp_bar()
	update_pips()


func update_hp_bar():
	var hp = curr_hp as int
	$HPLabel.text = hp as String + "HP"

	if curr_hp < max_hp * 0.34:
		$HPBar.texture_progress = bar_red

	elif curr_hp < max_hp * 0.67:
		$HPBar.texture_progress = bar_yellow

	else:
		$HPBar.texture_progress = bar_green

	$HPBar.value = curr_hp


func update_pips():
	# ik this is bad code but idk how else to do it rn
	var pip_sprites = [$Pip1, $Pip2, $Pip3, $Pip4, $Pip5]

	# Display empty pip or pip
	for i in range(pip_sprites.size()):
		if i < pips:
			pip_sprites[i].texture = pip
		else:
			pip_sprites[i].texture = empty_pip


func show_value(value, is_heal=false, is_crit=false):
	var floating_text = FloatingText.instance()
	add_child(floating_text)
	floating_text.show_value(value as String, duration, is_heal, is_crit)


func apply_status(effect):
	status.append(effect)

	if "dodge" in effect:
		dodge += effect.dodge
	if "crit" in effect:
		crit += effect.crit


func clear_status(effect):
	status.erase(effect)

	if "dodge" in effect:
		dodge -= effect.dodge
	if "crit" in effect:
		crit -= effect.crit


func check_lvl():
	level = 1
	while(xp >= round((4 * (level ^ 3)) / 5)):
		level += 1


func apply_lvl_stats():
	pass


func set_turn_indicator(vis):
	$TurnIndicator.visible = vis


func _on_Character_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			emit_signal("selected", self)


func _to_string():
	return name
