extends Node2D

func _ready():
	$Transitioner.fade_in()

func _on_menu_button_pressed():
	$Transitioner.fade_out()
	get_tree().change_scene_to_file("res://main_menu.tscn")
