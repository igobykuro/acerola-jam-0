extends Node2D

@onready var dialogue = $Dialogue

func _ready():
	$Transitioner.fade_in()
	await get_tree().create_timer(0.2).timeout
	Manager.current_stats["day"] += 1
	dialogue.queue_text("The woman scrutinizes the papers on her clipboard.")
	dialogue.queue_text('"Back already? You come awfully often."')
	dialogue.queue_text('Nevertheless, she motions for the group to follow her.')
	dialogue.queue_text('Everyone healed back to full health!')
	Manager.current_stats["mielle"]["current_hp"] = Manager.current_stats["mielle"]["max_hp"]
	Manager.current_stats["leon"]["current_hp"] = Manager.current_stats["leon"]["max_hp"]
	Manager.current_stats["tear"]["current_hp"] = Manager.current_stats["tear"]["max_hp"]
	Manager.current_stats["six"]["current_hp"] = Manager.current_stats["six"]["max_hp"]
	Manager.current_stats["alive"] = 4
	await get_tree().create_timer(1).timeout
	while !$Dialogue.dialogue_finished:
		await get_tree().create_timer(0.2).timeout
	$Transitioner.fade_out()
	await get_tree().create_timer(0.2).timeout
	get_tree().change_scene_to_file("res://options.tscn")
