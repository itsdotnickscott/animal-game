class_name Character

extends Area2D


signal selected(node)


var max_hp  # hit points
var atk     # boosts damage from attacks
var mag		# boosts scaling for spells
var crit    # chance to deal extra dmg
var acc     # chance to land an attack
var def     # resist dmg from attacks
var dodge   # avoid attack
var spd     # determines initiative in battle

var curr_hp # current health
var egy     # energy for ult
var status  # current buffs/debuffs


func init(name):
	set_script(load("res://characters/" + name + ".gd"))
	load_stats()


func load_stats():
	pass


func _on_Character_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			emit_signal("selected", self)


func take_damage(val):
	curr_hp -= val

	update_labels()


func update_labels():
	$HPLabel.text = curr_hp as String + "HP"