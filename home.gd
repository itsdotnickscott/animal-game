extends Control


const HERO = ["bard_snek", "cow_dog", "fire_cat", "magic_turt", "pow_bun"]

export(Array) var team_comp
var options


func _ready():
	options = get_tree().get_nodes_in_group("option")

	for button in options:
		for hero in HERO:
			button.add_item(hero)
			
	update_pictures()


func update_pictures():
	var i = 0
	for button in options:
		button.get_node("Sprite").texture = load("res://assets/" + team_comp[i] + ".png")
		button.select(HERO.find(team_comp[i]))

		i += 1


func _on_StartBattle_pressed():
	TeamComp.change_scene("res://Battle.tscn", team_comp)


func _on_OptionButton_item_selected(select, idx):
	team_comp[idx] = HERO[select]

	update_pictures()
