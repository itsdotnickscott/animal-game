extends Area2D

class_name Character

signal attack(unit)

var hp   # hit points
var atk  # dmg per attack
var mag  # spell damage
var def  # physical resistance
var wil  # magical resistance
var spd  # cd for attack
var ult  # ultimate cooldown
var is_player


func init(name):
	set_script(load("res://characters/" + name +".gd"))

	load_stats()

	if is_player:
		add_to_group("player")
	else:
		add_to_group("enemy")


func start_battle():
	$AttackTimer.wait_time = spd
	$AttackTimer.start()
	update_labels()


func _on_AttackTimer_timeout():
	emit_signal("attack", self)


func take_damage(num):
	hp = clamp(hp - num, 0, hp)
	update_labels()

	if hp == 0:
		queue_free()


func update_labels():
	$HPLabel.text = hp as String + "HP"


func load_stats():
	return
