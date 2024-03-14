extends Node2D

var selected = false
@onready var rest = get_node("HBoxContainer/Rest")
@onready var combat = get_node("HBoxContainer/Combat")

func _ready():
	$Heart.text = str(Manager.current_stats["life_points"])
	$Day.text = str(Manager.current_stats["day"])
	$Transitioner.fade_in()
	if Manager.current_stats["day"] == 3 or Manager.current_stats["day"] == 6:
		rest.show()
	else:
		rest.hide()
	if Manager.current_stats["day"] == 6:
		combat.hide()


func _on_rest_pressed():
	selected = true
	$Transitioner.fade_out()
	await get_tree().create_timer(0.2).timeout
	get_tree().change_scene_to_file("res://rest_scene.tscn")


func _on_combat_pressed():
	selected = true
	$Transitioner.fade_out()
	await get_tree().create_timer(0.2).timeout
	get_tree().change_scene_to_file("res://battle_scene.tscn")
