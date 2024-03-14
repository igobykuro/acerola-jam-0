extends Node2D

var enemy_name = "salsa"
var far_sprite = "res://Art/Enemies/FarSprites/SalsaFar.png"
var close_sprite = "res://Art/Enemies/NearSprites/SalsaClose.png"
var max_hp = 12671
var def = 120
var current_hp
var target = 0
var starting_stance = "far"
var exp_rate = 1.0
var max_moves = 2
var moves = 2
var targets = [0,1,2,3]
var tagline = """Unethical profiteering and brokerage.
Got and sold priviate info from his highschools address book...
And he got away with it! He's the definition of a cheater!"""
var aoe_no = 2
var aoe_intent = false
var close_aoe = true
var far_aoe = false

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
	for i in available_targets:
		if Manager.current_stats[Manager.current_party[i]]["current_hp"] <= 0:
			available_targets.erase(i)
	
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
			Manager.enemy_attack.emit(target,1290,"slash",1)
			Manager.broadcast.emit("Salsa kicked " + Manager.current_party[target].capitalize() + "!")
		else:
			Manager.enemy_attack_aoe.emit(targets,722,"slash",2)
			Manager.broadcast.emit("Salsa swiped his card!")
	else:
		Manager.enemy_attack.emit(target,1012,"slash",1)
		Manager.broadcast.emit("Salsa sniped at " + Manager.current_party[target].capitalize() + " with a sharp coin!")

	pick_target()
