extends Control


signal ability(type)


func _on_Attack_pressed():
	emit_signal("ability", AbilityType.ATK)
	

func _on_Primary_pressed():
	emit_signal("ability", AbilityType.PRI)


func _on_Secondary_pressed():
	emit_signal("ability", AbilityType.SEC)


func _on_Ultimate_pressed():
	emit_signal("ability", AbilityType.ULT)
