extends Node2D

@onready var dialogue = $Dialogue

func _ready():
	$Transitioner.fade_in()
	await get_tree().create_timer(0.2).timeout
	dialogue.queue_text("This morning, we received a very strange request.")
	dialogue.queue_text('That is, to go beat up a bunch of random people. Because apparently they all did something to offend this client.')
	dialogue.queue_text('The letter is very whiny. It was safe to assume that this "offense" might\'ve even been deserved.')
	dialogue.queue_text('Mielle shrugged, and told everyone "Eh, it\'ll be fine. This shouldn\'t be too hard, and the client is rich."')
	dialogue.queue_text("Money can get you anything.")
	dialogue.queue_text("Some of them had doubts, but eventually, we all agreed to take the request.")
	dialogue.queue_text("It's not like those people were entirely innocent, anyway. And someone needed to enforce the law around here.")
	await get_tree().create_timer(1).timeout
	while !$Dialogue.dialogue_finished:
		await get_tree().create_timer(0.2).timeout
	$Transitioner.fade_out()
	await get_tree().create_timer(0.2).timeout
	get_tree().change_scene_to_file("res://options.tscn")
