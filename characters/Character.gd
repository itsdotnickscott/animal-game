class_name Character

extends Area2D


signal selected(node)


# Health bar resources
var bar_red = preload("res://assets/red_health_bar.png")
var bar_green = preload("res://assets/green_health_bar.png")
var bar_yellow = preload("res://assets/yellow_health_bar.png")


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


func init(name, enemy=false):
	set_script(load("res://characters/" + ("enemies" if enemy else "heroes") + "/" + name + ".gd"))
	load_stats()
	update_labels()


func load_stats():
	curr_hp = max_hp
	status = []
	shield = 0

	$HPBar.max_value = max_hp


func _on_Character_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			emit_signal("selected", self)


func take_damage(val):
	if shield > 0:
		shield -= val

		if shield < 0:
			curr_hp += shield
			shield = 0

	else:
		curr_hp -= val

	update_labels()


func heal(val):
	curr_hp = max_hp if curr_hp + val > max_hp else curr_hp + val

	update_labels()


func gain_shield(val):
	shield += val


func update_labels():
	var hp = curr_hp as int
	$HPLabel.text = hp as String + "HP"
	update_hp_bar()


func update_hp_bar():
	if curr_hp < max_hp * 0.3:
		$HPBar.texture_progress = bar_red

	elif curr_hp < max_hp * 0.7:
		$HPBar.texture_progress = bar_yellow

	else:
		$HPBar.texture_progress = bar_green

	$HPBar.value = curr_hp


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


func _to_string():
	return name
