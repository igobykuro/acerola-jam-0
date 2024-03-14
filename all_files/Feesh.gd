extends Node2D

var enemy_name = "feesh"
var far_sprite = "res://Art/Enemies/FarSprites/FeeshFar.png"
var close_sprite = "res://Art/Enemies/NearSprites/FeeshClose.png"
var max_hp = 7450
var def = 69
var current_hp
var target = 0
var starting_stance = "close"
var exp_rate = 1.0
var max_moves = 1
var moves = 1
var targets = [0,1,2,3]
var tagline = """Tax evasion, improper record keeping.
Don't forget those illegal artifacts!
Target locked: Go get him!"""
var aoe_no = 4
var aoe_intent = false
var close_aoe = true
var far_aoe = true

func _ready():
	current_hp = max_hp
	moves = max_moves
	pick_target()
	attack()

#Fast attacker, attacks between 2-3 times each turn when close.
#far stance has a 50/50 of moving to close stance or disabling a character for a turn, then attacking one character

func pick_target():
	randomize()
	var available_targets = [0,1,2,3]
	for i in range(available_targets.size() - 1, -1, -1):
		if Manager.current_stats[Manager.current_party[available_targets[i]]]["current_hp"] <= 0:
			available_targets.remove(i)
	
	#print(available_targets)
	
	if randi() % 2 == 0:
		aoe_intent = true
	else:
		aoe_intent = false
	targets = [0,1,2,3]
	target = available_targets[randi() % available_targets.size()]
	if available_targets.size() < 4:
		targets = available_targets
	targets.shuffle()

#signal enemy_attack(target,damage,vfx)
#signal enemy_condition(target,condition)
#signal enemy_heal(amount)

func attack():
	if get_tree().root.get_child(1).enemy_stance == "close":
		if !aoe_intent:
			Manager.enemy_attack.emit(target,990,"slash",1)
			Manager.broadcast.emit("Feesh attacked " + Manager.current_party[target].capitalize() + "!")
		else:
			Manager.enemy_attack_aoe.emit(targets,756,"slash",2)
			Manager.broadcast.emit("Feesh jabbed twice!")
	else:
		if !aoe_intent:
			Manager.enemy_attack.emit(target,812,"slash",1)
			Manager.broadcast.emit("Feesh attacked " + Manager.current_party[target].capitalize() + "!")
		else:
			Manager.enemy_attack_aoe.emit(targets,698,"slash",4)
			Manager.broadcast.emit("Feesh splashed water!")
	pick_target()
