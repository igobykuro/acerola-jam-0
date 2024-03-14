extends Node2D

var enemy_name = "sox"
var far_sprite = "res://Art/Enemies/FarSprites/SoxFar.png"
var close_sprite = "res://Art/Enemies/NearSprites/SoxClose.png"
var max_hp = 17450
var def = 197
var current_hp
var target = 0
var starting_stance = "close"
var exp_rate = 1.0
var max_moves = 1
var moves = 1
var targets = [0,1,2,3]
var tagline = """She stole those artifacts!
I KNOW SHE DID!
GET THEM BACK!!!!!!"""
var aoe_no = 3
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
	for i in range(available_targets.size() - 1, -1, -1):
		if Manager.current_stats[Manager.current_party[available_targets[i]]]["current_hp"] <= 0:
			available_targets.remove(i)
	
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
			Manager.enemy_attack.emit(target,1390,"slash",3)
			Manager.broadcast.emit("Sox swiped at " + Manager.current_party[target].capitalize() + " three times!")
		else:
			Manager.enemy_attack_aoe.emit(targets,988,"slash",3)
			Manager.broadcast.emit("Sox scratched furiously!")
	else:
		Manager.enemy_attack.emit(target,1652,"slash",1)
		Manager.broadcast.emit("Sox swiped at " + Manager.current_party[target].capitalize() + "!")
	pick_target()
