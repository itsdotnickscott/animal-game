class_name Character

extends Area2D


signal selected(node)


var max_hp  # hit points
var atk     # boosts damage from attacks
var mag     # boosts scaling for spells
var crit    # chance to deal extra dmg
var acc     # chance to land an attack
var def     # resist dmg from attacks
var dodge   # avoid attack
var spd     # determines initiative in battle

var curr_hp # current health
var status  # current buffs/debuffs
var shield  # current shield value


func init(name):
	set_script(load("res://characters/heroes/" + name + ".gd"))
	load_stats()

	curr_hp = max_hp
	status = []
	shield = 0

	update_labels()


func load_stats():
	pass


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


func update_labels():
	var hp = curr_hp as int
	$HPLabel.text = hp as String + "HP"


func apply_status(effect):
	status.append(effect)

	if "dodge" in effect:
		dodge += effect.dodge

	if "status" in effect:
		match effect.status:
			StatusEffect.BURN:
				curr_hp = effect.val
				print("[status] ", name + " is burned")

			StatusEffect.STUN:
				print("[status] ", name + " is stunned")


func clear_status(effect):
	status.erase(effect)

	if "dodge" in effect:
		dodge -= effect.dodge

	print("[status] ", name + "'s status effect has worn out")
