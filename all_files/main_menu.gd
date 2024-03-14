extends Node2D

func _ready():
	$Transitioner.fade_in()

func _on_start_button_pressed():
	Manager.reset()
	$Transitioner.fade_out()
	get_tree().change_scene_to_file("res://opening_scene.tscn")


func _on_quit_button_pressed():
	get_tree().quit()
