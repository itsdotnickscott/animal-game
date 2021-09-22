extends Control


signal ability(type)


func _on_Ability_pressed(type):
	emit_signal("ability", type)