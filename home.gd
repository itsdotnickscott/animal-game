extends Control


const HERO = ["bard_snek", "cow_dog", "fire_cat", "magic_turt", "pow_bun"]

export(Array) var team_comp
export(Array) var lvls
var heroes


func _ready():
	heroes = get_tree().get_nodes_in_group("hero")

	for hero in heroes:
		for name in HERO:
			hero.get_node("OptionButton").add_item(name)
			
	update_pictures()


func update_pictures():
	var i = 0
	for hero in heroes:
		hero.texture = load("res://assets/" + team_comp[i] + ".png")
		hero.get_node("OptionButton").select(HERO.find(team_comp[i]))

		i += 1


func _on_StartBattle_pressed():
	TeamComp.change_scene("res://Battle.tscn", team_comp, lvls)


func _on_OptionButton_item_selected(select, idx):
	team_comp[idx] = HERO[select]

	update_pictures()


func _on_SpinBox_value_changed(lvl, idx):
	lvls[idx] = lvl - 1
