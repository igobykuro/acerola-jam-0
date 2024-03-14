extends Node2D

@onready var UI = $UI_Controller
@onready var highlighter = $PortraitHighlighter
@onready var active_sprite = get_node("SideBar/ActiveSprite")
@onready var active_name = get_node("SideBar/ActiveName")
@onready var description = $SkillDescription
@onready var skill_desc = get_node("SkillDescription/Label")
@onready var skill_type = get_node("SkillDescription/SkillRangeLabel")
@onready var skill_type_box = get_node("SkillDescription/SkillRange")
@onready var level = get_node("SideBar/Level")
@onready var char_hp = get_node("SideBar/HP2")
@onready var char_atk = get_node("SideBar/ATK2")
@onready var char_def = get_node("SideBar/DEF2")
@onready var char_trust = get_node("SideBar/Trust2")
@onready var slash_scene: PackedScene = preload("res://Art/VFX/slash.tscn")
@onready var opponent = $Opponent
@onready var combat_dialogue = $CombatDialogue

@onready var sox_scene: PackedScene = preload("res://sox.tscn")
@onready var feesh_scene: PackedScene = preload("res://feesh.tscn")
@onready var salsa_scene: PackedScene = preload("res://salsa.tscn")
@onready var plasticbag_scene: PackedScene = preload("res://plastic_bag.tscn")
@onready var weixian_scene: PackedScene = preload("res://weixian.tscn")
@onready var rizzler_scene: PackedScene = preload("res://rizzler.tscn")

@export var attack_growth = 1.2
@export var hp_growth = 1.2
@export var def_growth = 1.2
@export var exp_gain = 25
@export var exp_needed_growth = 50

var levelling = false
var insight_times = 0
var counter_times : int = 0
var dialogue_showing = false
var traps_placed = 0
var targeted = null
var target_menu_showing = false
var first_move = true
var can_switch = true
var dialogue_finished = true
var can_action = true
var end_signalled = false
var active_character = "mielle"
enum turn {
	ALLY,
	ENEMY
}
var current_turn = turn.ALLY
var enemy_stance = "close"
var hover_skill_1 = false
var hover_skill_2 = false
var hover_skill_3 = false
var hover_skill_4 = false

var can_attack1 = true
var can_attack2 = true
var can_attack3 = true
var can_attack4 = true

var skills_showing = false

var dead1 = false
var dead2 = false
var dead3 = false
var dead4 = false

var level_queue = []

var skill_target : String

var currentOpponent : String

signal enemy_dead

func _ready():
	$Transitioner.fade_in()
	spawn_enemy()
	$TryAgain.hide()
	Manager.current_stats["mielle"]["temp next trust"] = 0
	Manager.current_stats["mielle"]["temp next atk"] = 0
	Manager.current_stats["leon"]["temp next trust"] = 0
	Manager.current_stats["leon"]["temp next atk"] = 0
	Manager.current_stats["tear"]["temp next trust"] = 0
	Manager.current_stats["tear"]["temp next atk"] = 0
	Manager.current_stats["six"]["temp next trust"] = 0
	Manager.current_stats["six"]["temp next atk"] = 0
	$ColorRect.show()
	$Skills.hide()
	update_life_points()
	enemy_dead.connect(death)
	current_turn = turn.ALLY
	Manager.broadcast.connect(add_dialogue)
	Manager.enemy_attack.connect(enemy_attack)
	Manager.enemy_attack_aoe.connect(enemy_attack_aoe)
	description.hide()
	$SideBar.hide()
	%ChibiHighlighter.hide()
	%HighlighterAnim.play("Squiggle")
	highlighter.hide()
	UI.play("pan")
	await get_tree().create_timer(0.2).timeout
	$PortraitHighlighter.hide()
	$SideBar.show()
	UI.play("SlideIn")
	UI.play("ActiveSprite")
	if $SideBar.position != Vector2(200,270):
		$SideBar.position = Vector2(200,270)
	%CharPortrait1.texture = load(Manager.assets[Manager.current_party[0]]["portrait"])
	%CharPortrait2.texture = load(Manager.assets[Manager.current_party[1]]["portrait"])
	%CharPortrait3.texture = load(Manager.assets[Manager.current_party[2]]["portrait"])
	%CharPortrait4.texture = load(Manager.assets[Manager.current_party[3]]["portrait"])
	update_skill_icons()
	update_stats_on_gui()
	$EnemyHP.value = $EnemyHPSlow.value
	update_enemy_hp()
	update_exp()
	if Manager.current_stats["mielle"]["current_hp"] <= 0:
		dead1 = true
		can_attack1 = false
		$PortraitNormal.texture_normal = load("res://UI/Assets/PortraitGrey.png")
	if Manager.current_stats["leon"]["current_hp"] <= 0:
		dead2 = true
		can_attack2 = false
		$PortraitNormal2.texture_normal = load("res://UI/Assets/PortraitGrey.png")
	if Manager.current_stats["tear"]["current_hp"] <= 0:
		dead3 = true
		can_attack3 = false
		$PortraitNormal3.texture_normal = load("res://UI/Assets/PortraitGrey.png")
	if Manager.current_stats["six"]["current_hp"] <= 0:
		dead4 = true
		can_attack4 = false
		$PortraitNormal4.texture_normal = load("res://UI/Assets/PortraitGrey.png")
	update_hp()
	$HPBar1.value = $HPBarSlow1.value
	$HPBar2.value = $HPBarSlow2.value
	$HPBar3.value = $HPBarSlow3.value
	$HPBar4.value = $HPBarSlow4.value
	$PortraitTargetIcon1.hide()
	$PortraitTargetIcon2.hide()
	$PortraitTargetIcon3.hide()
	$PortraitTargetIcon4.hide()
	update_stat_icons()
	fix()
	$ColorRect.hide()
	add_dialogue("Target spotted!")

func spawn_enemy():
	if Manager.current_stats["day"] == 1:
		var plasticbag = plasticbag_scene.instantiate()
		$Opponent.add_child(plasticbag)
	elif Manager.current_stats["day"] == 2:
		var feesh = feesh_scene.instantiate()
		$Opponent.add_child(feesh)
	elif Manager.current_stats["day"] == 3:
		var salsa = salsa_scene.instantiate()
		$Opponent.add_child(salsa)
	elif Manager.current_stats["day"] == 4:
		var sox = sox_scene.instantiate()
		$Opponent.add_child(sox)
	elif Manager.current_stats["day"] == 5:
		var weixian = weixian_scene.instantiate()
		$Opponent.add_child(weixian)
	elif Manager.current_stats["day"] == 7:
		var rizzler = rizzler_scene.instantiate()
		$Opponent.add_child(rizzler)
	var enemy = $Opponent.get_child(0)
	$EnemyFar.texture = load(enemy.far_sprite)
	$EnemyClose.texture = load(enemy.close_sprite)
	$Name.text = enemy.enemy_name.to_upper()
	$Tagline.text = enemy.tagline
	enemy.def = enemy.def * Manager.current_stats["enemy_def_down"]
	enemy.max_hp = enemy.max_hp * Manager.current_stats["enemy_hp_down"]
	enemy.current_hp = enemy.current_hp * Manager.current_stats["enemy_hp_down"]
	if enemy.starting_stance == "close":
		enemy_stance = "close"
		$EnemyClose.show()
		$EnemyFar.hide()
	else:
		enemy_stance = "far"
		$EnemyClose.hide()
		$EnemyFar.show()
	

func add_dialogue(text):
	combat_dialogue.queue_text(text)

func switch_turn(cur_turn):
	var enemy = $Opponent.get_child(0)
	if cur_turn == turn.ENEMY:
		can_action = false
		Manager.current_stats["mielle"]["temp next trust"] = 0
		Manager.current_stats["mielle"]["temp next atk"] = 0
		Manager.current_stats["leon"]["temp next trust"] = 0
		Manager.current_stats["leon"]["temp next atk"] = 0
		Manager.current_stats["tear"]["temp next trust"] = 0
		Manager.current_stats["tear"]["temp next atk"] = 0
		Manager.current_stats["six"]["temp next trust"] = 0
		Manager.current_stats["six"]["temp next atk"] = 0
		enemy.attack()
		update_stat_icons()
	elif cur_turn == turn.ALLY:
		if insight_times > 0:
			insight_times -= 1
		reveal_targets()
		first_move = true
		can_action = true
		if !dead1:
			can_attack1 = true
			$PortraitNormal.texture_normal = load("res://UI/Assets/PortraitNormal.png")
		else:
			$PortraitNormal.texture_normal = load("res://UI/Assets/PortraitGrey.png")
		if !dead2:
			can_attack2 = true
			$PortraitNormal2.texture_normal = load("res://UI/Assets/PortraitNormal.png")
		else:
			$PortraitNormal2.texture_normal = load("res://UI/Assets/PortraitGrey.png")
		if !dead3:
			can_attack3 = true
			$PortraitNormal3.texture_normal = load("res://UI/Assets/PortraitNormal.png")
		else:
			$PortraitNormal3.texture_normal = load("res://UI/Assets/PortraitGrey.png")
		if !dead4:
			can_attack4 = true
			$PortraitNormal4.texture_normal = load("res://UI/Assets/PortraitNormal.png")
		else:
			$PortraitNormal4.texture_normal = load("res://UI/Assets/PortraitGrey.png")
		
		
		Manager.current_stats["mielle"]["shield"] = false
		Manager.current_stats["mielle"]["counter"] = false
		Manager.current_stats["leon"]["shield"] = false
		Manager.current_stats["tear"]["shield"] = false
		Manager.current_stats["six"]["shield"] = false
		update_stat_icons()
		
	current_turn = cur_turn

func death():
	var enemy = $Opponent.get_child(0)
	await get_tree().create_timer(1).timeout
	while !dialogue_finished:
		await get_tree().create_timer(0.1).timeout
	$EnemyClose.hide()
	$EnemyFar.hide()
	add_dialogue(enemy.name.capitalize() + " was defeated!")
	await get_tree().create_timer(1).timeout
	while !dialogue_finished:
		await get_tree().create_timer(0.1).timeout
	add_dialogue("Everyone gained experience.")
	add_exp("mielle",70)
	add_exp("leon",70)
	add_exp("tear",70)
	add_exp("six",70)
	await get_tree().create_timer(2).timeout
	while !dialogue_finished or skills_showing or levelling:
		await get_tree().create_timer(0.1).timeout
	
	$ColorRect.show()
	%HighlighterAnim.play("fade_out")
	await get_tree().create_timer(1).timeout
	if Manager.current_stats["day"] == 7:
		get_tree().change_scene_to_file("res://end_scene.tscn")
	else:
		get_tree().change_scene_to_file("res://mission_complete.tscn")
	

func reveal_targets():
	var enemy = $Opponent.get_child(0)
	var aoe_intent = enemy.aoe_intent
	var close_aoe = enemy.close_aoe
	var far_aoe = enemy.far_aoe
	var aoe_no = enemy.aoe_no
	if insight_times > 0:
		$PortraitTargetIcon1.hide()
		$PortraitTargetIcon2.hide()
		$PortraitTargetIcon3.hide()
		$PortraitTargetIcon4.hide()
		if (aoe_intent and close_aoe and enemy_stance == "close") or (aoe_intent and far_aoe and enemy_stance == "far"):
			for i in range(aoe_no):
				if enemy.targets[i] == 0:
					$PortraitTargetIcon1.show()
				elif enemy.targets[i] == 1:
					$PortraitTargetIcon2.show()
				elif enemy.targets[i] == 2:
					$PortraitTargetIcon3.show()
				elif enemy.targets[i] == 3:
					$PortraitTargetIcon4.show()
		else:
			if enemy.target == 0:
				$PortraitTargetIcon1.show()
			elif enemy.target == 1:
				$PortraitTargetIcon2.show()
			elif enemy.target == 2:
				$PortraitTargetIcon3.show()
			elif enemy.target == 3:
				$PortraitTargetIcon4.show()
	else:
		$PortraitTargetIcon1.hide()
		$PortraitTargetIcon2.hide()
		$PortraitTargetIcon3.hide()
		$PortraitTargetIcon4.hide()

func switch_stance():
	var enemy = $Opponent.get_child(0)
	if enemy_stance == "close":
		enemy_stance = "far"
		$EnemyClose.hide()
		$EnemyFar.show()
	else:
		enemy_stance = "close"
		$EnemyClose.show()
		$EnemyFar.hide()
	reveal_targets()
	if traps_placed > 0:
		#trap activation
		var crit = 1
		var dmg = 1
		var heal_amt = 1
		if randi() % 100 + 1 <= Manager.current_stats["tear"]["crit"] + Manager.current_stats[enemy_stance + "_crit"]:
			crit = Manager.current_stats["tear"]["crit dmg"] + Manager.current_stats[enemy_stance + "_crit_dmg"]
		if Manager.current_stats["tear"]["skill 3"]["modifier"] == "normal":
			if Manager.current_stats["tear"]["skill 3"]["level"] == 1:
				dmg = 1.2
			elif Manager.current_stats["tear"]["skill 3"]["level"] == 2:
				dmg = 1.6
			elif Manager.current_stats["tear"]["skill 3"]["level"] == 3:
				dmg = 2
		elif Manager.current_stats["tear"]["skill 3"]["modifier"] == "sea":
			if Manager.current_stats["tear"]["skill 3"]["level"] == 1:
				dmg = 1.8
			elif Manager.current_stats["tear"]["skill 3"]["level"] == 2:
				dmg = 2.2
			elif Manager.current_stats["tear"]["skill 3"]["level"] == 3:
				dmg = 2.6
		elif Manager.current_stats["tear"]["skill 3"]["modifier"] == "land":
			if Manager.current_stats["tear"]["skill 3"]["level"] == 1:
				dmg = 1.2
				heal_amt = .15
			elif Manager.current_stats["tear"]["skill 3"]["level"] == 2:
				dmg = 1.6
				heal_amt = .2
			elif Manager.current_stats["tear"]["skill 3"]["level"] == 3:
				dmg = 2
				heal_amt = .3
			for i in range(traps_placed):
				heal("tear", "max_hp", heal_amt)
		await get_tree().create_timer(1).timeout
		while !dialogue_finished:
			await get_tree().create_timer(0.1).timeout
		UI.play("Shake")
		enemy.current_hp -= max(0,float((Manager.current_stats["tear"]["atk"] * (1 + Manager.current_stats["atk_boost"]) * Manager.current_stats[enemy_stance + "_dmg_boost"] * dmg - enemy.def) * crit)*traps_placed)
		update_enemy_hp()
		if traps_placed == 1:
			add_dialogue("The trap detonated!")
		else:
			add_dialogue(str(traps_placed) + " traps detonated!")
		traps_placed = 0

func _on_portrait_normal_mouse_entered():
	if can_attack1:
		highlighter.show()
		highlighter.position = %Portrait1.position
		UI.play("Highlighter")


func _on_portrait_normal_mouse_exited():
	highlighter.hide()


func _on_portrait_normal_2_mouse_entered():
	if can_attack2:
		highlighter.show()
		highlighter.position = %Portrait2.position
		UI.play("Highlighter")


func _on_portrait_normal_2_mouse_exited():
	highlighter.hide()


func _on_portrait_normal_3_mouse_entered():
	if can_attack3:
		highlighter.show()
		highlighter.position = %Portrait3.position
		UI.play("Highlighter")


func _on_portrait_normal_3_mouse_exited():
	highlighter.hide()


func _on_portrait_normal_4_mouse_entered():
	if can_attack4:
		highlighter.show()
		highlighter.position = %Portrait4.position
		UI.play("Highlighter")


func _on_portrait_normal_4_mouse_exited():
	highlighter.hide()


func change_char(charName):
	if charName != active_character:
		active_name.text = charName.to_upper()
		active_sprite.position = Vector2(-794,0)
		active_character = charName
		if charName == "six" and Manager.current_stats["six"]["shapeshifted"]:
			active_sprite.texture = load(Manager.assets[Manager.current_stats["six"]["shapeshifted_char"]]["sprite"])
		elif charName == "six" and Manager.current_stats["six"]["level"] < 5:
			active_sprite.texture = load("res://Art/Group/Sprites/SixSpriteConstrained.png")
		else:
			active_sprite.texture = load(Manager.assets[charName]["sprite"])
		update_stats_on_gui()
		UI.play("ActiveSprite")
	elif charName == "six" and Manager.current_stats["six"]["shapeshifted"]:
		active_sprite.texture = load(Manager.assets[Manager.current_stats["six"]["shapeshifted_char"]]["sprite"])
		update_stats_on_gui()
		UI.play("ActiveSprite")

func update_stats_on_gui():
	update_life_points()
	level.text = "LVL " + str(Manager.current_stats[active_character]["level"])
	if active_character == "six" and Manager.current_stats["six"]["shapeshifted"]:
		char_hp.text = str(int(Manager.current_stats[active_character]["current_hp"])) + "/" + str(Manager.current_stats[active_character]["max_hp"])
		char_atk.text = str(int(Manager.current_stats["six"]["shapeshifted_atk"] * (1 + Manager.current_stats[active_character]["temp next atk"] + Manager.current_stats[active_character]["next atk"])))
		char_def.text = str(int(Manager.current_stats["six"]["def"]))
		char_trust.text = str(int(Manager.current_stats[active_character]["trust"] + Manager.current_stats[active_character]["next trust"] + Manager.current_stats[active_character]["temp next trust"] - Manager.current_stats["six"]["trust_loss"])) + "%"
	elif active_character == "six":
		char_hp.text = str(int(Manager.current_stats[active_character]["current_hp"])) + "/" + str(Manager.current_stats[active_character]["max_hp"])
		char_atk.text = str(int(Manager.current_stats[active_character]["atk"] * (1 + Manager.current_stats[active_character]["temp next atk"] + Manager.current_stats[active_character]["next atk"])))
		char_def.text = str(int(Manager.current_stats[active_character]["def"]))
		char_trust.text = str(int(Manager.current_stats[active_character]["trust"] + Manager.current_stats[active_character]["next trust"] + Manager.current_stats[active_character]["temp next trust"] - Manager.current_stats["six"]["trust_loss"])) + "%"
	else:
		char_hp.text = str(int(Manager.current_stats[active_character]["current_hp"])) + "/" + str(Manager.current_stats[active_character]["max_hp"])
		char_atk.text = str(int(Manager.current_stats[active_character]["atk"] * (1 + Manager.current_stats[active_character]["temp next atk"] + Manager.current_stats[active_character]["next atk"])))
		char_def.text = str(int(Manager.current_stats[active_character]["def"]))
		char_trust.text = str(int(Manager.current_stats[active_character]["trust"] + Manager.current_stats[active_character]["next trust"] + Manager.current_stats[active_character]["temp next trust"])) + "%"
	if Manager.current_stats["leon"]["vitality"] == 0:
		$Vitality1.texture = load("res://UI/Assets/VitalityEmpty.png")
		$Vitality2.texture = load("res://UI/Assets/VitalityEmpty.png")
		$Vitality3.texture = load("res://UI/Assets/VitalityEmpty.png")
		$Vitality4.texture = load("res://UI/Assets/VitalityEmpty.png")
		$Vitality5.texture = load("res://UI/Assets/VitalityEmpty.png")
	elif Manager.current_stats["leon"]["vitality"] == 1:
		$Vitality1.texture = load("res://UI/Assets/VitalityFull.png")
		$Vitality2.texture = load("res://UI/Assets/VitalityEmpty.png")
		$Vitality3.texture = load("res://UI/Assets/VitalityEmpty.png")
		$Vitality4.texture = load("res://UI/Assets/VitalityEmpty.png")
		$Vitality5.texture = load("res://UI/Assets/VitalityEmpty.png")
	elif Manager.current_stats["leon"]["vitality"] == 2:
		$Vitality1.texture = load("res://UI/Assets/VitalityFull.png")
		$Vitality2.texture = load("res://UI/Assets/VitalityFull.png")
		$Vitality3.texture = load("res://UI/Assets/VitalityEmpty.png")
		$Vitality4.texture = load("res://UI/Assets/VitalityEmpty.png")
		$Vitality5.texture = load("res://UI/Assets/VitalityEmpty.png")
	elif Manager.current_stats["leon"]["vitality"] == 3:
		$Vitality1.texture = load("res://UI/Assets/VitalityFull.png")
		$Vitality2.texture = load("res://UI/Assets/VitalityFull.png")
		$Vitality3.texture = load("res://UI/Assets/VitalityFull.png")
		$Vitality4.texture = load("res://UI/Assets/VitalityEmpty.png")
		$Vitality5.texture = load("res://UI/Assets/VitalityEmpty.png")
	elif Manager.current_stats["leon"]["vitality"] == 4:
		$Vitality1.texture = load("res://UI/Assets/VitalityFull.png")
		$Vitality2.texture = load("res://UI/Assets/VitalityFull.png")
		$Vitality3.texture = load("res://UI/Assets/VitalityFull.png")
		$Vitality4.texture = load("res://UI/Assets/VitalityFull.png")
		$Vitality5.texture = load("res://UI/Assets/VitalityEmpty.png")
	elif Manager.current_stats["leon"]["vitality"] >= 5:
		$Vitality1.texture = load("res://UI/Assets/VitalityFull.png")
		$Vitality2.texture = load("res://UI/Assets/VitalityFull.png")
		$Vitality3.texture = load("res://UI/Assets/VitalityFull.png")
		$Vitality4.texture = load("res://UI/Assets/VitalityFull.png")
		$Vitality5.texture = load("res://UI/Assets/VitalityFull.png")

func fix():
	await get_tree().create_timer(0.1).timeout
	can_switch = true
	if active_sprite.position != Vector2(-50,0) and active_character == Manager.current_party[0]:
		active_sprite.position = Vector2(-50,0)

func _on_portrait_normal_pressed():
	if can_action and can_switch:
		can_switch = false
		%Pointer.position = %Portrait1.position + Vector2(-9,70)
		change_char(Manager.current_party[0])
		update_skill_icons()
		fix()

func _on_portrait_normal_2_pressed():
	if can_action and can_switch:
		can_switch = false
		%Pointer.position = %Portrait2.position + Vector2(-9,70)
		change_char(Manager.current_party[1])
		update_skill_icons()
		fix()

func _on_portrait_normal_3_pressed():
	if can_action and can_switch:
		can_switch = false
		%Pointer.position = %Portrait3.position + Vector2(-9,70)
		change_char(Manager.current_party[2])
		update_skill_icons()
		fix()
	
func _on_portrait_normal_4_pressed():
	if can_action and can_switch:
		can_switch = false
		%Pointer.position = %Portrait4.position + Vector2(-9,70)
		change_char(Manager.current_party[3])
		update_skill_icons()
		fix()


func attack_type(skill):
	var type = null
	for i in Manager.char_descriptions[active_character][skill]["tags"]:
		if i == "any":
			type = "ANY"
			break
		elif i == "close":
			type = "MELEE"
			break
		elif i == "far":
			type = "RANGED"
			break
	return type

func _on_skill_1_mouse_entered():
	if can_action:
		hover_skill_1 = true
		await get_tree().create_timer(1).timeout
		if hover_skill_1 and Manager.current_stats[active_character]["skill 1"]["unlocked"]:
			skill_desc.text = Manager.char_descriptions[active_character]["skill 1"]["description"][Manager.current_stats[active_character]["skill 1"]["modifier"]]["lvl " + str(Manager.current_stats[active_character]["skill 1"]["level"])]
			skill_type.show()
			skill_type_box.show()
			skill_type.text = attack_type("skill 1")
			description.show()
			description.position = get_global_mouse_position() - Vector2(0,%ColorRect.size.y)


func _on_skill_1_mouse_exited():
	hover_skill_1 = false
	description.hide()


func _on_skill_2_mouse_entered():
	if can_action:
		hover_skill_2 = true
		await get_tree().create_timer(1).timeout
		if hover_skill_2 and Manager.current_stats[active_character]["skill 2"]["unlocked"]:
			skill_desc.text = Manager.char_descriptions[active_character]["skill 2"]["description"][Manager.current_stats[active_character]["skill 2"]["modifier"]]["lvl " + str(Manager.current_stats[active_character]["skill 2"]["level"])]
			skill_type.show()
			skill_type_box.show()
			skill_type.text = attack_type("skill 2")
			description.show()
			description.position = get_global_mouse_position() - Vector2(0,%ColorRect.size.y)


func _on_skill_2_mouse_exited():
	hover_skill_2 = false
	description.hide()


func _on_skill_3_mouse_entered():
	if can_action:
		hover_skill_3 = true
		await get_tree().create_timer(1).timeout
		if hover_skill_3 and Manager.current_stats[active_character]["skill 3"]["unlocked"]:
			skill_desc.text = Manager.char_descriptions[active_character]["skill 3"]["description"][Manager.current_stats[active_character]["skill 3"]["modifier"]]["lvl " + str(Manager.current_stats[active_character]["skill 3"]["level"])]
			skill_type.show()
			skill_type_box.show()
			skill_type.text = attack_type("skill 3")
			description.show()
			description.position = get_global_mouse_position() - Vector2(0,%ColorRect.size.y)


func _on_skill_3_mouse_exited():
	hover_skill_3 = false
	description.hide()


func _on_skill_4_mouse_entered():
	if can_action:
		hover_skill_4 = true
		await get_tree().create_timer(1).timeout
		if hover_skill_4 and Manager.current_stats[active_character]["skill 4"]["unlocked"]:
			skill_desc.text = Manager.char_descriptions[active_character]["skill 4"]["description"][Manager.current_stats[active_character]["skill 4"]["modifier"]]["lvl " + str(Manager.current_stats[active_character]["skill 4"]["level"])]
			skill_type.show()
			skill_type_box.show()
			skill_type.text = attack_type("skill 4")
			description.show()
			description.position = get_global_mouse_position() - Vector2(0,%ColorRect.size.y)


func _on_first_mouse_entered():
	if can_action:
		skill_type.hide()
		skill_type_box.hide()
		skill_desc.text = Manager.char_descriptions[active_character]["first move"]
		description.show()
		description.position = get_global_mouse_position() - Vector2(0,%ColorRect.size.y)


func _on_first_mouse_exited():
	description.hide()

func _on_skill_4_mouse_exited():
	hover_skill_4 = false
	description.hide()

func update_stat_icons():
	#mielle
	if Manager.current_stats[Manager.current_party[0]]["next atk"] > 0 || Manager.current_stats[Manager.current_party[0]]["temp next atk"] > 0:
		%AttackIcon1.show()
	else:
		%AttackIcon1.hide()
	if Manager.current_stats["def_boost"] > 0:
		%DefenseIcon1.show()
	else:
		%DefenseIcon1.hide()
	if Manager.current_stats[Manager.current_party[0]]["next trust"] > 0 || Manager.current_stats[Manager.current_party[0]]["temp next trust"] > 0:
		%TrustIcon1.show()
	else:
		%TrustIcon1.hide()
	if Manager.current_stats[Manager.current_party[0]]["shield"]:
		$ShieldIcon1.show()
	else:
		$ShieldIcon1.hide()
	if Manager.current_stats["mielle"]["counter"]:
		$CounterIcon.show()
	else:
		$CounterIcon.hide()
	
	#leon
	if Manager.current_stats[Manager.current_party[1]]["next atk"] > 0 || Manager.current_stats[Manager.current_party[1]]["temp next atk"] > 0:
		%AttackIcon2.show()
	else:
		%AttackIcon2.hide()
	if Manager.current_stats["def_boost"] > 0:
		%DefenseIcon2.show()
	else:
		%DefenseIcon2.hide()
	if Manager.current_stats[Manager.current_party[1]]["next trust"] > 0 || Manager.current_stats[Manager.current_party[1]]["temp next trust"] > 0:
		%TrustIcon2.show()
	else:
		%TrustIcon2.hide()
	if Manager.current_stats[Manager.current_party[1]]["shield"]:
		$ShieldIcon2.show()
	else:
		$ShieldIcon2.hide()

	#tear
	if Manager.current_stats[Manager.current_party[2]]["next atk"] > 0 || Manager.current_stats[Manager.current_party[2]]["temp next atk"] > 0:
		%AttackIcon3.show()
	else:
		%AttackIcon3.hide()
	if Manager.current_stats["def_boost"] > 0:
		%DefenseIcon3.show()
	else:
		%DefenseIcon3.hide()
	if Manager.current_stats[Manager.current_party[2]]["next trust"] > 0 || Manager.current_stats[Manager.current_party[2]]["temp next trust"] > 0:
		%TrustIcon3.show()
	else:
		%TrustIcon3.hide()
	if Manager.current_stats[Manager.current_party[2]]["shield"]:
		$ShieldIcon3.show()
	else:
		$ShieldIcon3.hide()
	if Manager.current_stats["tear"]["recalibration"]:
		$RecalibrationIcon.show()
	else:
		$RecalibrationIcon.hide()
		
	#six
	if Manager.current_stats[Manager.current_party[3]]["next atk"] > 0 || Manager.current_stats[Manager.current_party[3]]["temp next atk"] > 0:
		%AttackIcon4.show()
	else:
		%AttackIcon4.hide()
	if Manager.current_stats["def_boost"] > 0:
		%DefenseIcon4.show()
	else:
		%DefenseIcon4.hide()
	if Manager.current_stats[Manager.current_party[3]]["next trust"] > 0 || Manager.current_stats[Manager.current_party[3]]["temp next trust"] > 0:
		%TrustIcon4.show()
	else:
		%TrustIcon4.hide()
	if Manager.current_stats[Manager.current_party[3]]["shield"]:
		$ShieldIcon4.show()
	else:
		$ShieldIcon4.hide()
	if Manager.current_stats["six"]["shapeshifted"]:
		$ShapeshiftedIcon.show()
	else:
		$ShapeshiftedIcon.hide()

func update_skill_icons():
	#I hate this I wish you could use for loops for this
	#skill 1
	var charas_skill = active_character
	if active_character == "six" and Manager.current_stats["six"]["shapeshifted"]:
		charas_skill = Manager.current_stats["six"]["shapeshifted_char"]

	if Manager.current_stats[charas_skill]["skill 1"]["unlocked"]:
		$Skill1Name.text = Manager.char_descriptions[charas_skill]["skill 1"]["name"]
	else:
		$Skill1Name.text = "???"
	if !Manager.current_stats[charas_skill]["skill 1"]["unlocked"]:
		$Skill1.texture_normal = load("res://UI/Assets/SkillNull.png")
		$Skill1.texture_hover = load("res://UI/Assets/SkillNull.png")
	elif Manager.current_stats[charas_skill]["skill 1"]["modifier"] == "normal":
		$Skill1.texture_normal = load("res://UI/Assets/SkillBase.png")
		$Skill1.texture_hover = load("res://UI/Assets/SkillBaseHover.png")
	elif Manager.current_stats[charas_skill]["skill 1"]["modifier"] == "sea":
		$Skill1.texture_normal = load("res://UI/Assets/SkillSea.png")
		$Skill1.texture_hover = load("res://UI/Assets/SkillSeaHover.png")
	elif Manager.current_stats[charas_skill]["skill 1"]["modifier"] == "land":
		$Skill1.texture_normal = load("res://UI/Assets/SkillLand.png")
		$Skill1.texture_hover = load("res://UI/Assets/SkillLandHover.png")
	elif Manager.current_stats[charas_skill]["skill 1"]["modifier"] == "sky":
		$Skill1.texture_normal = load("res://UI/Assets/SkillSky.png")
		$Skill1.texture_hover = load("res://UI/Assets/SkillSkyHover.png")
		
	#skill 2
	if Manager.current_stats[charas_skill]["skill 2"]["unlocked"]:
		$Skill2Name.text = Manager.char_descriptions[charas_skill]["skill 2"]["name"]
	else:
		$Skill2Name.text = "???"
	
	if !Manager.current_stats[charas_skill]["skill 2"]["unlocked"]:
		$Skill2.texture_normal = load("res://UI/Assets/SkillNull.png")
		$Skill2.texture_hover = load("res://UI/Assets/SkillNull.png")
	elif Manager.current_stats[charas_skill]["skill 2"]["modifier"] == "normal":
		$Skill2.texture_normal = load("res://UI/Assets/SkillBase.png")
		$Skill2.texture_hover = load("res://UI/Assets/SkillBaseHover.png")
	elif Manager.current_stats[charas_skill]["skill 2"]["modifier"] == "sea":
		$Skill2.texture_normal = load("res://UI/Assets/SkillSea.png")
		$Skill2.texture_hover = load("res://UI/Assets/SkillSeaHover.png")
	elif Manager.current_stats[charas_skill]["skill 2"]["modifier"] == "land":
		$Skill2.texture_normal = load("res://UI/Assets/SkillLand.png")
		$Skill2.texture_hover = load("res://UI/Assets/SkillLandHover.png")
	elif Manager.current_stats[charas_skill]["skill 2"]["modifier"] == "sky":
		$Skill2.texture_normal = load("res://UI/Assets/SkillSky.png")
		$Skill2.texture_hover = load("res://UI/Assets/SkillSkyHover.png")
	
	#skill 3
	if Manager.current_stats[charas_skill]["skill 3"]["unlocked"]:
		$Skill3Name.text = Manager.char_descriptions[charas_skill]["skill 3"]["name"]
	else:
		$Skill3Name.text = "???"
		
	if !Manager.current_stats[charas_skill]["skill 3"]["unlocked"]:
		$Skill3.texture_normal = load("res://UI/Assets/SkillNull.png")
		$Skill3.texture_hover = load("res://UI/Assets/SkillNull.png")
	elif Manager.current_stats[charas_skill]["skill 3"]["modifier"] == "normal":
		$Skill3.texture_normal = load("res://UI/Assets/SkillBase.png")
		$Skill3.texture_hover = load("res://UI/Assets/SkillBaseHover.png")
	elif Manager.current_stats[charas_skill]["skill 3"]["modifier"] == "sea":
		$Skill3.texture_normal = load("res://UI/Assets/SkillSea.png")
		$Skill3.texture_hover = load("res://UI/Assets/SkillSeaHover.png")
	elif Manager.current_stats[charas_skill]["skill 3"]["modifier"] == "land":
		$Skill3.texture_normal = load("res://UI/Assets/SkillLand.png")
		$Skill3.texture_hover = load("res://UI/Assets/SkillLandHover.png")
	elif Manager.current_stats[charas_skill]["skill 3"]["modifier"] == "sky":
		$Skill3.texture_normal = load("res://UI/Assets/SkillSky.png")
		$Skill3.texture_hover = load("res://UI/Assets/SkillSkyHover.png")
	
	#skill 4
	if Manager.current_stats[active_character]["skill 4"]["unlocked"]:
		$Skill4Name.text = Manager.char_descriptions[active_character]["skill 4"]["name"]
	else:
		$Skill4Name.text = "???"
	
	if !Manager.current_stats[active_character]["skill 4"]["unlocked"]:
		$Skill4.texture_normal = load("res://UI/Assets/SkillNull.png")
		$Skill4.texture_hover = load("res://UI/Assets/SkillNull.png")
	elif Manager.current_stats[active_character]["skill 4"]["modifier"] == "normal":
		$Skill4.texture_normal = load("res://UI/Assets/SkillBase.png")
		$Skill4.texture_hover = load("res://UI/Assets/SkillBaseHover.png")
	elif Manager.current_stats[active_character]["skill 4"]["modifier"] == "sea":
		$Skill4.texture_normal = load("res://UI/Assets/SkillSea.png")
		$Skill4.texture_hover = load("res://UI/Assets/SkillSeaHover.png")
	elif Manager.current_stats[active_character]["skill 4"]["modifier"] == "land":
		$Skill4.texture_normal = load("res://UI/Assets/SkillLand.png")
		$Skill4.texture_hover = load("res://UI/Assets/SkillLandHover.png")
	elif Manager.current_stats[active_character]["skill 4"]["modifier"] == "sky":
		$Skill4.texture_normal = load("res://UI/Assets/SkillSky.png")
		$Skill4.texture_hover = load("res://UI/Assets/SkillSkyHover.png")
	elif Manager.current_stats[active_character]["skill 4"]["modifier"] == "corrupted":
		$Skill4.texture_normal = load("res://UI/Assets/SkillCorrupted.png")
		$Skill4.texture_hover = load("res://UI/Assets/SkillCorruptedHover.png")

func enemy_attack_aoe(targets,damage,vfx,amount_of_targets):
	var enemy = $Opponent.get_child(0)
	await get_tree().create_timer(2).timeout
	while !dialogue_finished:
		await get_tree().create_timer(0.1).timeout
	amount_of_targets = min (amount_of_targets,Manager.current_stats["alive"])
	for i in amount_of_targets:
		execute_vfx(vfx,targets[i])
		if Manager.current_party[targets[i]] == "mielle" and Manager.current_stats["mielle"]["counter"]:
			mielle_counter(damage,1)
		elif !Manager.current_stats[Manager.current_party[targets[i]]]["shield"]:
			Manager.current_stats[Manager.current_party[targets[i]]]["current_hp"] -= max(0,damage - Manager.current_stats[Manager.current_party[targets[i]]]["def"] * (1 + Manager.current_stats["def_boost"]))
		Manager.current_stats["def_boost"] = 0
		update_hp()
	enemy.moves -= 1
	if enemy.moves == 0:
		enemy.moves = enemy.max_moves
		await get_tree().create_timer(0.1).timeout
		switch_turn(turn.ALLY)
	else:
		enemy.attack()

func enemy_attack(target,dmg,vfx,times):
	var enemy = $Opponent.get_child(0)
	await get_tree().create_timer(2).timeout
	while !dialogue_finished:
		await get_tree().create_timer(0.1).timeout
	counter_times = times
	for i in times:
		execute_vfx(vfx,target)
		if target == 0 and Manager.current_stats["mielle"]["counter"]:
			mielle_counter(dmg,counter_times)
			counter_times -=1
		else:
			if !Manager.current_stats[Manager.current_party[target]]["shield"]:
				Manager.current_stats[Manager.current_party[target]]["current_hp"] -= max(0,dmg - Manager.current_stats[Manager.current_party[target]]["def"] * (1 + Manager.current_stats["def_boost"]))
			update_hp()
		Manager.current_stats["def_boost"] = 0
		await get_tree().create_timer(1).timeout
	enemy.moves -= 1
	if enemy.moves == 0:
		enemy.moves = enemy.max_moves
		await get_tree().create_timer(0.1 * times).timeout
		switch_turn(turn.ALLY)
	else:
		enemy.attack()

func mielle_counter(dmg,counter_timez):
			#damage taking part
			var enemy = $Opponent.get_child(0)
			if !Manager.current_stats["mielle"]["shield"]:
				if Manager.current_stats["mielle"]["skill 4"]["modifier"] == "land":
					if Manager.current_stats["mielle"]["skill 4"]["level"] == 1:
						heal("mielle","damage",(dmg - Manager.current_stats["mielle"]["def"] * (1 + Manager.current_stats["def_boost"]) * .3))
					elif Manager.current_stats["mielle"]["skill 4"]["level"] == 2:
						heal("mielle","damage",(dmg - Manager.current_stats["mielle"]["def"] * (1 + Manager.current_stats["def_boost"]) * .45))
					elif Manager.current_stats["mielle"]["skill 4"]["level"] == 3:
						heal("mielle","damage",(dmg - Manager.current_stats["mielle"]["def"] * (1 + Manager.current_stats["def_boost"]) * .6))
					update_hp_heal()
				else:
					if Manager.current_stats["mielle"]["skill 4"]["level"] == 1:
						Manager.current_stats["mielle"]["current_hp"] -= max(0,float((dmg - Manager.current_stats["mielle"]["def"] * (1 + Manager.current_stats["def_boost"])) * .2))
					elif Manager.current_stats["mielle"]["skill 4"]["level"] == 2:
						Manager.current_stats["mielle"]["current_hp"] -= max(0,float((dmg - Manager.current_stats["mielle"]["def"] * (1 + Manager.current_stats["def_boost"])) * .15))
					elif Manager.current_stats["mielle"]["skill 4"]["level"] == 3:
						Manager.current_stats["mielle"]["current_hp"] -= max(0,float((dmg - Manager.current_stats["mielle"]["def"] * (1 + Manager.current_stats["def_boost"])) * .1))
					update_hp()
			await get_tree().create_timer(1).timeout
			while !dialogue_finished:
				await get_tree().create_timer(0.1).timeout
			randomize()
			
			#attacking part
			
			if counter_timez == 1:
				var crit = 1
				if randi() % 100 + 1 <= Manager.current_stats[active_character]["crit"]:
					crit = Manager.current_stats[active_character]["crit dmg"]
				var retaliation = 1
				if Manager.current_stats["mielle"]["skill 4"]["modifier"] == "normal":	
					if Manager.current_stats["mielle"]["skill 4"]["level"] == 1:
						retaliation = 2.0
					elif Manager.current_stats["mielle"]["skill 4"]["level"] == 2:
						retaliation = 2.4
					elif Manager.current_stats["mielle"]["skill 4"]["level"] == 3:
						retaliation = 3.0
				elif Manager.current_stats["mielle"]["skill 4"]["modifier"] == "sea":	
					if Manager.current_stats["mielle"]["skill 4"]["level"] == 1:
						retaliation = 3.0
					elif Manager.current_stats["mielle"]["skill 4"]["level"] == 2:
						retaliation = 3.4
					elif Manager.current_stats["mielle"]["skill 4"]["level"] == 3:
						retaliation = 4.0
				elif Manager.current_stats["mielle"]["skill 4"]["modifier"] == "corrupted":	
					if Manager.current_stats["mielle"]["skill 4"]["level"] == 1:
						retaliation = 3.6
					elif Manager.current_stats["mielle"]["skill 4"]["level"] == 2:
						retaliation = 4.2
					elif Manager.current_stats["mielle"]["skill 4"]["level"] == 3:
						retaliation = 5.4
				UI.play("Shake")
				enemy.current_hp -= max(0,float(Manager.current_stats["mielle"]["atk"] * (1 + Manager.current_stats["mielle"]["temp next atk"] + Manager.current_stats["mielle"]["next atk"]) * (1 + Manager.current_stats["atk_boost"]) * Manager.current_stats[enemy_stance + "_dmg_boost"] * retaliation - enemy.def) * crit)
				update_enemy_hp()
				add_dialogue("Mielle attacked " + enemy.enemy_name.capitalize() + " in retaliation!")
				if crit > 1:
					add_dialogue("Critical hit!")

func execute_vfx(type,chara):
	if type == "slash":
		var slash = slash_scene.instantiate()
		if chara == 0:
			slash.position = %Portrait1.position
		elif chara == 1:
			slash.position = %Portrait2.position
		elif chara == 2:
			slash.position = %Portrait3.position
		elif chara == 3:
			slash.position = %Portrait4.position
		add_child(slash)

func update_enemy_hp():
	var enemy = $Opponent.get_child(0)
	$EnemyHPSlow.value = float(float(enemy.current_hp) / float(enemy.max_hp)) * 100
	await get_tree().create_timer(0.5).timeout
	while $EnemyHP.value > $EnemyHPSlow.value:
		$EnemyHP.value -= 1
		if $EnemyHP.value <= $EnemyHPSlow.value:
			$EnemyHP.value = $EnemyHPSlow.value
			break
		await get_tree().create_timer(0.02).timeout
	if enemy.current_hp <= 0 and !end_signalled:
		enemy_dead.emit()
		end_signalled = true

func update_hp():
	$HPBarSlow1.value = float(float(Manager.current_stats[Manager.current_party[0]]["current_hp"]) / float(Manager.current_stats[Manager.current_party[0]]["max_hp"])) * 100
	$HPBarSlow2.value = float(float(Manager.current_stats[Manager.current_party[1]]["current_hp"]) / float(Manager.current_stats[Manager.current_party[1]]["max_hp"])) * 100
	$HPBarSlow3.value = float(float(Manager.current_stats[Manager.current_party[2]]["current_hp"]) / float(Manager.current_stats[Manager.current_party[2]]["max_hp"])) * 100
	$HPBarSlow4.value = float(float(Manager.current_stats[Manager.current_party[3]]["current_hp"]) / float(Manager.current_stats[Manager.current_party[3]]["max_hp"])) * 100
	
	await get_tree().create_timer(0.5).timeout
	while $HPBar1.value > $HPBarSlow1.value or $HPBar2.value > $HPBarSlow2.value or $HPBar3.value > $HPBarSlow3.value or $HPBar4.value > $HPBarSlow4.value:
		if $HPBar1.value > $HPBarSlow1.value:
			$HPBar1.value -= 1
		else:
			$HPBar1.value = $HPBarSlow1.value
		if $HPBar2.value > $HPBarSlow2.value:
			$HPBar2.value -= 1
		else:
			$HPBar2.value = $HPBarSlow2.value
		if $HPBar3.value > $HPBarSlow3.value:
			$HPBar3.value -= 1
		else:
			$HPBar3.value = $HPBarSlow3.value
		if $HPBar4.value > $HPBarSlow4.value:
			$HPBar4.value -= 1
		else:
			$HPBar4.value = $HPBarSlow4.value
		await get_tree().create_timer(0.02).timeout
		
	if Manager.current_stats[Manager.current_party[0]]["current_hp"] <= 0:
		if !dead1:
			Manager.current_stats["alive"] -=1
			dead1 = true
			can_attack1 = false
			$PortraitNormal.texture_normal = load("res://UI/Assets/PortraitGrey.png")
			Manager.current_stats["life_points"] = max(0, Manager.current_stats["life_points"] - 1)
	if Manager.current_stats[Manager.current_party[1]]["current_hp"] <= 0:
		if !dead2:
			Manager.current_stats["alive"] -=1
			dead2 = true
			can_attack2 = false
			$PortraitNormal2.texture_normal = load("res://UI/Assets/PortraitGrey.png")
			Manager.current_stats["life_points"] = max(0, Manager.current_stats["life_points"] - 1)
	if Manager.current_stats[Manager.current_party[2]]["current_hp"] <= 0:
		if !dead3:
			Manager.current_stats["alive"] -=1
			dead3 = true
			can_attack3 = false
			$PortraitNormal3.texture_normal = load("res://UI/Assets/PortraitGrey.png")
			Manager.current_stats["life_points"] = max(0, Manager.current_stats["life_points"] - 1)
	if Manager.current_stats[Manager.current_party[3]]["current_hp"] <= 0:
		if !dead4:
			Manager.current_stats["alive"] -=1
			dead4 = true
			can_attack4 = false
			$PortraitNormal4.texture_normal = load("res://UI/Assets/PortraitGrey.png")
			Manager.current_stats["life_points"] = max(0, Manager.current_stats["life_points"] - 1)
	update_life_points()
	if Manager.current_stats["life_points"] <= 0:
		game_over()

func update_life_points():
	$LifePoints.text = "x" + str(Manager.current_stats["life_points"])

func update_hp_heal():
	$HPBar1.value = float(float(Manager.current_stats[Manager.current_party[0]]["current_hp"]) / float(Manager.current_stats[Manager.current_party[0]]["max_hp"])) * 100
	$HPBar2.value = float(float(Manager.current_stats[Manager.current_party[1]]["current_hp"]) / float(Manager.current_stats[Manager.current_party[1]]["max_hp"])) * 100
	$HPBar3.value = float(float(Manager.current_stats[Manager.current_party[2]]["current_hp"]) / float(Manager.current_stats[Manager.current_party[2]]["max_hp"])) * 100
	$HPBar4.value = float(float(Manager.current_stats[Manager.current_party[3]]["current_hp"]) / float(Manager.current_stats[Manager.current_party[3]]["max_hp"])) * 100
	
	await get_tree().create_timer(0.5).timeout
	while $HPBarSlow1.value < $HPBar1.value or $HPBarSlow2.value < $HPBar2.value or $HPBarSlow3.value < $HPBar3.value or $HPBarSlow4.value < $HPBar4.value:
		if $HPBarSlow1.value < $HPBarSlow1.value:
			$HPBarSlow1.value += 1
		else:
			$HPBarSlow1.value = $HPBar1.value
		if $HPBarSlow2.value < $HPBarSlow2.value:
			$HPBarSlow2.value += 1
		else:
			$HPBarSlow2.value = $HPBar2.value
		if $HPBarSlow3.value < $HPBarSlow3.value:
			$HPBarSlow3.value += 1
		else:
			$HPBarSlow3.value = $HPBar3.value
		if $HPBarSlow4.value < $HPBarSlow4.value:
			$HPBarSlow4.value += 1
		else:
			$HPBarSlow4.value = $HPBar4.value
		await get_tree().create_timer(0.02).timeout
	update_stats_on_gui()

func update_exp():
	$ExpBar1.value = float(float(Manager.current_stats[Manager.current_party[0]]["exp"]) / float(Manager.current_stats[Manager.current_party[0]]["exp_needed"])) * 100
	$ExpBar2.value = float(float(Manager.current_stats[Manager.current_party[1]]["exp"]) / float(Manager.current_stats[Manager.current_party[1]]["exp_needed"])) * 100
	$ExpBar3.value = float(float(Manager.current_stats[Manager.current_party[2]]["exp"]) / float(Manager.current_stats[Manager.current_party[2]]["exp_needed"])) * 100
	$ExpBar4.value = float(float(Manager.current_stats[Manager.current_party[3]]["exp"]) / float(Manager.current_stats[Manager.current_party[3]]["exp_needed"])) * 100

func add_exp(chara,amount):
	if chara != "all":
		Manager.current_stats[chara]["exp"] += amount * Manager.current_stats["exp_gain"]
		
		if Manager.current_stats[chara]["exp"] >= Manager.current_stats[chara]["exp_needed"]:
			level_up(chara)
	else:
		for i in Manager.current_party:
			Manager.current_stats[i]["exp"] += amount
			if Manager.current_stats[i]["exp"] >= Manager.current_stats[i]["exp_needed"]:
				level_up(i)
	update_exp()

func level_up(chara):
	if Manager.current_stats[chara]["level"] <= 9:
		level_queue.append(chara)
	levelling = true
	await get_tree().create_timer(0.5).timeout
	while skills_showing:
		await get_tree().create_timer(0.02).timeout
	Manager.current_stats[chara]["level"] +=1
	add_dialogue(chara.capitalize() + " is now level " + str(Manager.current_stats[chara]["level"]) +"!")
	wait_for_dialogue(1)
	Manager.current_stats[chara]["atk"] = int(Manager.current_stats[chara]["atk"] * attack_growth) #hp_growth
	Manager.current_stats[chara]["def"] = int(Manager.current_stats[chara]["def"] * def_growth)
	Manager.current_stats[chara]["current_hp"] = int(Manager.current_stats[chara]["current_hp"] * hp_growth)
	Manager.current_stats[chara]["max_hp"] = int(Manager.current_stats[chara]["max_hp"] * hp_growth)
	update_stats_on_gui()
	if Manager.current_stats[chara]["level"] == 3:
		Manager.current_stats[chara]["skill 3"]["unlocked"] = true
		add_dialogue("Unlocked skill: " + Manager.char_descriptions[chara]["skill 3"]["name"])
	elif Manager.current_stats[chara]["level"] == 5:
		Manager.current_stats[chara]["skill 4"]["unlocked"] = true
		add_dialogue("Unlocked skill: " + Manager.char_descriptions[chara]["skill 4"]["name"])
	wait_for_dialogue(1)
	update_skill_icons()
	Manager.current_stats[chara]["exp"] -= Manager.current_stats[chara]["exp_needed"]
	Manager.current_stats[chara]["exp_needed"] += exp_needed_growth
	update_exp()
	await get_tree().create_timer(0.5).timeout
	while !dialogue_finished:
		await get_tree().create_timer(0.02).timeout
	if Manager.current_stats[chara]["level"] <= 9:
		skills_showing = true
		$Skills.show()
		skill_target = chara
		update_skills()
		levelling = false
	

func wait_for_dialogue(pre_time):
	await get_tree().create_timer(pre_time).timeout
	while !dialogue_finished:
		await get_tree().create_timer(0.02).timeout	

func _on_combat_dialogue_dialogue_ended():
	dialogue_showing = false


func active_char_attackable():
	if active_character == Manager.current_party[0]:
		if can_attack1:
			return true
		else:
			return false
	elif active_character == Manager.current_party[1]:
		if can_attack2:
			return true
		else:
			return false
	elif active_character == Manager.current_party[2]:
		if can_attack3:
			return true
		else:
			return false
	elif active_character == Manager.current_party[3]:
		if can_attack4:
			return true
		else:
			return false

func _on_skill_1_pressed():
	if can_action and active_char_attackable():
		attack(active_character,"skill 1")


func _on_skill_2_pressed():
	if can_action and active_char_attackable():
		attack(active_character,"skill 2")


func _on_skill_3_pressed():
	if can_action and active_char_attackable():
		if Manager.current_stats[active_character]["skill 3"]["unlocked"]:
			attack(active_character,"skill 3")
		else:
			add_dialogue("You haven't unlocked this skill yet.")


func _on_skill_4_pressed():
	if can_action and active_char_attackable():
		if Manager.current_stats[active_character]["skill 4"]["unlocked"]:
			attack(active_character,"skill 4")
		else:
			add_dialogue("You haven't unlocked this skill yet.")



func _on_chibi_portrait_1_mouse_entered():
	%ChibiHighlighter.show()
	%ChibiHighlighter.position = %ChibiPortrait1.position + Vector2(37,34)


func _on_chibi_portrait_1_mouse_exited():
	%ChibiHighlighter.hide()


func _on_chibi_portrait_2_mouse_entered():
	%ChibiHighlighter.show()
	%ChibiHighlighter.position = %ChibiPortrait2.position + Vector2(37,34)


func _on_chibi_portrait_2_mouse_exited():
	%ChibiHighlighter.hide()


func _on_chibi_portrait_3_mouse_entered():
	%ChibiHighlighter.show()
	%ChibiHighlighter.position = %ChibiPortrait3.position + Vector2(37,34)


func _on_chibi_portrait_3_mouse_exited():
	%ChibiHighlighter.hide()


func _on_chibi_portrait_4_mouse_entered():
	%ChibiHighlighter.show()
	%ChibiHighlighter.position = %ChibiPortrait4.position + Vector2(37,34)


func _on_chibi_portrait_4_mouse_exited():
	%ChibiHighlighter.hide()


func _on_chibi_portrait_1_pressed():
	targeted = "mielle"
	$TargetThing.hide()
	target_menu_showing = false


func _on_chibi_portrait_2_pressed():
	targeted = "leon"
	$TargetThing.hide()
	target_menu_showing = false


func _on_chibi_portrait_3_pressed():
	targeted = "tear"
	$TargetThing.hide()
	target_menu_showing = false


func _on_chibi_portrait_4_pressed():
	targeted = "six"
	$TargetThing.hide()
	target_menu_showing = false


func _on_x_pressed():
	$TargetThing.hide()
	target_menu_showing = false


func _process(_delta):
	if combat_dialogue.text_queue.is_empty() and !dialogue_showing:
		dialogue_finished = true
	else:
		dialogue_finished = false

func give_buff(chara, buff_type, amount):
	if chara == "next":
		Manager.current_stats[buff_type] += amount
	else:
		Manager.current_stats[chara][buff_type] += amount

func heal(chara, type, amount):
	if chara!= "all":
		if type == "max_hp":
			Manager.current_stats[chara]["current_hp"] = min(Manager.current_stats[chara]["max_hp"],Manager.current_stats[chara]["current_hp"] + Manager.current_stats[chara]["max_hp"]* (amount * Manager.current_stats["healing_boost"]))
		elif type == "damage":
			Manager.current_stats[chara]["current_hp"] = min(Manager.current_stats[chara]["max_hp"],Manager.current_stats[chara]["current_hp"] + amount * Manager.current_stats["healing_boost"])
	else:
		for i in range(4):
			if type == "max_hp":
				Manager.current_stats[Manager.current_party[i]]["current_hp"] = min(Manager.current_stats[Manager.current_party[i]]["max_hp"],Manager.current_stats[Manager.current_party[i]]["current_hp"] + Manager.current_stats[Manager.current_party[i]]["max_hp"]* (amount * Manager.current_stats["healing_boost"]))
			elif type == "damage":
				Manager.current_stats[Manager.current_party[i]]["current_hp"] = min(Manager.current_stats[Manager.current_party[i]]["max_hp"],Manager.current_stats[Manager.current_party[i]]["current_hp"] + amount * Manager.current_stats["healing_boost"])
	update_hp_heal()
	
func lowest_hp_character():
	#help there's probably a sort function
	var lowest = null
	var lowest_hp = 9999999
	if Manager.current_stats[Manager.current_party[0]]["current_hp"] < lowest_hp and !dead1:
		lowest_hp = Manager.current_stats[Manager.current_party[0]]["current_hp"]
		lowest = Manager.current_party[0]
	if Manager.current_stats[Manager.current_party[1]]["current_hp"] < lowest_hp and !dead2:
		lowest_hp = Manager.current_stats[Manager.current_party[1]]["current_hp"]
		lowest = Manager.current_party[1]
	if Manager.current_stats[Manager.current_party[2]]["current_hp"] < lowest_hp and !dead3:
		lowest_hp = Manager.current_stats[Manager.current_party[2]]["current_hp"]
		lowest = Manager.current_party[2]
	if Manager.current_stats[Manager.current_party[3]]["current_hp"] < lowest_hp and !dead4:
		lowest_hp = Manager.current_stats[Manager.current_party[3]]["current_hp"]
		lowest = Manager.current_party[3]
	return lowest

func num_of_ally(ally):
	if ally == "mielle":
		return 0
	elif ally == "leon":
		return 1
	elif ally == "tear":
		return 2
	elif ally == "six":
		return 3

func ally_of_num(num):
	#I just realized how useless this function is
	if num == 0:
		return "mielle"
	elif num == 1:
		return "leon"
	elif num == 2:
		return "tear"
	elif num == 3:
		return "six"

func attack(chara,skill):
	can_action = false
	var enemy = $Opponent.get_child(0)
	var attacked = false
	var enemy_turn = false
	var first_action_char = "none"
	var six_supported_self = false
	if chara == "six" and Manager.current_stats["six"]["shapeshifted"] and skill != "skill 4":
		chara = Manager.current_stats["six"]["shapeshifted_char"]
		Manager.current_stats["six"]["trust_loss"] += 10
		if Manager.current_stats["six"]["skill 4"]["modifier"] == "land":
			heal("six","max_hp",Manager.current_stats["six"]["shapeshifted_heal"])
	for i in Manager.char_descriptions[chara][skill]["tags"]:
		if i == "any" or i == enemy_stance:
			attacked = true
			break
	
	if attacked:
		randomize()
		@warning_ignore("unused_variable")
		var is_target = false
		var crit = 1
		var attack_dmg = Manager.current_stats[active_character]["atk"]
		if active_character == "six" and Manager.current_stats["six"]["shapeshifted"]:
			Manager.current_stats["six"]["continuous_atk_boost"] += 1
			attack_dmg = Manager.current_stats["six"]["shapeshifted_atk"] * pow(Manager.current_stats["six"]["shapeshifted_atk_boost"],Manager.current_stats["six"]["continuous_atk_boost"])
			
		if chara == "mielle":
			if skill == "skill 1":
				var dmg = 1
				if randi() % 100 + 1 <= Manager.current_stats[active_character]["crit"] + Manager.current_stats[enemy_stance + "_crit"]:
					crit = Manager.current_stats[active_character]["crit dmg"] + Manager.current_stats[enemy_stance + "_crit_dmg"]
				if Manager.current_stats["mielle"]["skill 1"]["modifier"] == "normal":
					if Manager.current_stats["mielle"]["skill 1"]["level"] == 1:
						dmg = 0.4
					elif Manager.current_stats["mielle"]["skill 1"]["level"] == 2:
						dmg = 0.55
					elif Manager.current_stats["mielle"]["skill 1"]["level"] == 3:
						dmg = 0.7
					UI.play("Shake")
					enemy.current_hp -= max(0,float(attack_dmg * (1 + Manager.current_stats[active_character]["temp next atk"] + Manager.current_stats[active_character]["next atk"]) * (1 + Manager.current_stats["atk_boost"]) * Manager.current_stats[enemy_stance + "_dmg_boost"] * dmg - enemy.def) * crit)
					update_enemy_hp()
					add_dialogue(active_character.capitalize() + " stabbed " + enemy.enemy_name.capitalize() + "!")
					attacked = true
				elif Manager.current_stats["mielle"]["skill 1"]["modifier"] == "sea":
					var ally = randi() % 3 + 1
					var buff = 0.1
					if Manager.current_stats["mielle"]["skill 1"]["level"] == 1:
						dmg = 0.5
					elif Manager.current_stats["mielle"]["skill 1"]["level"] == 2:
						dmg = 0.75
						buff = 0.2
					elif Manager.current_stats["mielle"]["skill 1"]["level"] == 3:
						dmg = 1
						buff = 0.3
					UI.play("Shake")
					enemy.current_hp -= max(0,float(attack_dmg * (1 + Manager.current_stats[active_character]["temp next atk"] + Manager.current_stats[active_character]["next atk"]) * (1 + Manager.current_stats["atk_boost"]) * Manager.current_stats[enemy_stance + "_dmg_boost"] * dmg - enemy.def) * crit)
					update_enemy_hp()
					add_dialogue(active_character.capitalize() + " stabbed " + enemy.enemy_name.capitalize() + "!")
					give_buff(Manager.current_party[ally],"next atk",buff)
					attacked = true
				elif Manager.current_stats["mielle"]["skill 1"]["modifier"] == "land":
					var heal_amt = 1
					if Manager.current_stats["mielle"]["skill 1"]["level"] == 1:
						dmg = 0.4
						heal_amt = .6
					elif Manager.current_stats["mielle"]["skill 1"]["level"] == 2:
						dmg = 0.55
						heal_amt = .8
					elif Manager.current_stats["mielle"]["skill 1"]["level"] == 3:
						dmg = 0.7
						heal_amt = 1
					enemy.current_hp -= max(0,float(attack_dmg * (1 + Manager.current_stats[active_character]["temp next atk"] + Manager.current_stats[active_character]["next atk"]) * (1 + Manager.current_stats["atk_boost"]) * Manager.current_stats[enemy_stance + "_dmg_boost"] * dmg - enemy.def) * crit)
					update_enemy_hp()
					UI.play("Shake")
					heal(lowest_hp_character(), "damage", (attack_dmg * (1 + Manager.current_stats[active_character]["temp next atk"] + Manager.current_stats[active_character]["next atk"]) * (1 + Manager.current_stats["atk_boost"]) * Manager.current_stats[enemy_stance + "_dmg_boost"] * dmg - enemy.def) * crit * heal_amt)
					add_dialogue(active_character.capitalize() + " stabbed " + enemy.enemy_name.capitalize() + "!")
					attacked = true
				elif Manager.current_stats["mielle"]["skill 1"]["modifier"] == "sky":
					var pass_rate = 40
					if Manager.current_stats["mielle"]["skill 1"]["level"] == 1:
						dmg = 0.4
					elif Manager.current_stats["mielle"]["skill 1"]["level"] == 2:
						dmg = 0.55
						pass_rate = 50
					elif Manager.current_stats["mielle"]["skill 1"]["level"] == 3:
						dmg = 0.7
						pass_rate = 60
					UI.play("Shake")
					enemy.current_hp -= max(0,float(attack_dmg * (1 + Manager.current_stats[active_character]["temp next atk"] + Manager.current_stats[active_character]["next atk"]) * (1 + Manager.current_stats["atk_boost"]) * Manager.current_stats[enemy_stance + "_dmg_boost"] * dmg - enemy.def) * crit)
					update_enemy_hp()
					Manager.current_stats[active_character]["next trust"] += pass_rate
					add_dialogue(active_character.capitalize() + " stabbed " + enemy.enemy_name.capitalize() + "!")
					attacked = true
				
			if skill == "skill 2":
				is_target = true
				$TargetThing.show()
				target_menu_showing = true
				while target_menu_showing and targeted == null:
					await get_tree().create_timer(0.2).timeout
				var isnt_dead = true
				if targeted == "mielle" and dead1:
					isnt_dead = false
				if targeted == "leon" and dead2:
					isnt_dead = false
				if targeted == "tear" and dead3:
					isnt_dead = false
				if targeted == "six" and dead4:
					isnt_dead = false
				if targeted != null and isnt_dead:
					attacked = true
					if targeted == "mielle":
						if active_character == "mielle":
							add_dialogue("Mielle protected herself!")
						elif active_character == "six":
							add_dialogue("Six protected himself!")
					else:
						if active_character == "mielle":
							add_dialogue("Mielle protected " + targeted.capitalize() + "!")
						elif active_character == "six":
							add_dialogue("Six protected " + targeted.capitalize() + "!")
					Manager.current_stats[targeted]["shield"] = true
					update_stat_icons()
					var pass_rate = 0
					if Manager.current_stats["mielle"]["skill 2"]["level"] == 1:
						pass_rate = 0
					elif Manager.current_stats["mielle"]["skill 2"]["level"] == 2:
						pass_rate = 20
					elif Manager.current_stats["mielle"]["skill 2"]["level"] == 3:
						pass_rate = 40
					Manager.current_stats[active_character]["next trust"] += pass_rate
					if Manager.current_stats["mielle"]["skill 2"]["modifier"] == "sea":
						var buff = 1
						if Manager.current_stats["mielle"]["skill 2"]["level"] == 1:
							buff = 0.4
						elif Manager.current_stats["mielle"]["skill 2"]["level"] == 2:
							buff = 0.55
						elif Manager.current_stats["mielle"]["skill 2"]["level"] == 3:
							buff = 0.7
						give_buff(targeted,"next atk",buff)
					elif Manager.current_stats["mielle"]["skill 2"]["modifier"] == "land":
						var heal_amt = 1
						if Manager.current_stats["mielle"]["skill 2"]["level"] == 1:
							heal_amt = 0.2
						elif Manager.current_stats["mielle"]["skill 2"]["level"] == 2:
							heal_amt = 0.3
						elif Manager.current_stats["mielle"]["skill 2"]["level"] == 3:
							heal_amt = 0.4
						heal(targeted, "max_hp", heal_amt)
					elif Manager.current_stats["mielle"]["skill 2"]["modifier"] == "sky":
						if Manager.current_stats["mielle"]["skill 2"]["level"] < 3:
							enemy.target = num_of_ally(targeted)
							if enemy.aoe_no <=2 and enemy.targets[0] != num_of_ally(targeted) and enemy.targets[1] != num_of_ally(targeted):
								enemy.targets[0] = num_of_ally(targeted)
							elif enemy.aoe_no == 3 and enemy.targets[0] != num_of_ally(targeted) and enemy.targets[1] != num_of_ally(targeted) and enemy.targets[2] !=num_of_ally(targeted):
								enemy.targets[0] = num_of_ally(targeted)
						else:
							enemy.target = num_of_ally(targeted)
							enemy.targets = [num_of_ally(targeted),num_of_ally(targeted),num_of_ally(targeted),num_of_ally(targeted)]
				else:
					attacked = false
					
			if skill == "skill 3":
				if randi() % 100 + 1 <= Manager.current_stats[active_character]["crit"] + Manager.current_stats[enemy_stance + "_crit"]:
					crit = Manager.current_stats[active_character]["crit dmg"] + Manager.current_stats[enemy_stance + "_crit_dmg"]
				if Manager.current_stats["mielle"]["skill 3"]["modifier"] == "normal":
					var dmg = 1
					if Manager.current_stats["mielle"]["skill 3"]["level"] == 1:
						dmg = 0.2
					elif Manager.current_stats["mielle"]["skill 3"]["level"] == 2:
						dmg = 0.3
					elif Manager.current_stats["mielle"]["skill 3"]["level"] == 3:
						dmg = 0.4
					UI.play("Shake")
					enemy.current_hp -= max(0,float(attack_dmg * (1 + Manager.current_stats[active_character]["temp next atk"] + Manager.current_stats[active_character]["next atk"]) * (1 + Manager.current_stats["atk_boost"]) * Manager.current_stats[enemy_stance + "_dmg_boost"] * dmg - enemy.def) * crit)
					update_enemy_hp()
					if active_character == "mielle":
						add_dialogue("Mielle threw her knife at " + enemy.enemy_name.capitalize() + "!")
					elif active_character == "six":
						add_dialogue("Six threw a knife at " + enemy.enemy_name.capitalize() + "!")
					attacked = true
				elif Manager.current_stats["mielle"]["skill 3"]["modifier"] == "sea":
					var dmg = 1
					var ally = [1,2,3]
					var buff = 0.1
					if Manager.current_stats["mielle"]["skill 3"]["level"] == 1:
						dmg = 0.4
					elif Manager.current_stats["mielle"]["skill 3"]["level"] == 2:
						dmg = 0.5
						buff = 0.2
					elif Manager.current_stats["mielle"]["skill 3"]["level"] == 3:
						dmg = 0.6
						buff = 0.3
					UI.play("Shake")
					enemy.current_hp -= max(0,float(attack_dmg * (1 + Manager.current_stats[active_character]["temp next atk"] + Manager.current_stats[active_character]["next atk"]) * (1 + Manager.current_stats["atk_boost"]) * Manager.current_stats[enemy_stance + "_dmg_boost"] * dmg - enemy.def) * crit)
					update_enemy_hp()
					if active_character == "mielle":
						add_dialogue("Mielle threw her knife at " + enemy.enemy_name.capitalize() + "!")
					elif active_character == "six":
						add_dialogue("Six threw a knife at " + enemy.enemy_name.capitalize() + "!")
					for _ally in ally:
						give_buff(Manager.current_party[_ally],"next atk",buff)
					attacked = true
				elif Manager.current_stats["mielle"]["skill 3"]["modifier"] == "land":
					var dmg = 1
					var heal_amt = 1
					if Manager.current_stats["mielle"]["skill 3"]["level"] == 1:
						dmg = 0.4
						heal_amt = 0.1
					elif Manager.current_stats["mielle"]["skill 3"]["level"] == 2:
						dmg = 0.55
						heal_amt = 0.15
					elif Manager.current_stats["mielle"]["skill 3"]["level"] == 3:
						dmg = 0.7
						heal_amt = 0.2
					enemy.current_hp -= max(0,float(attack_dmg * (1 + Manager.current_stats[active_character]["temp next atk"] + Manager.current_stats[active_character]["next atk"]) * (1 + Manager.current_stats["atk_boost"]) * Manager.current_stats[enemy_stance + "_dmg_boost"] * dmg - enemy.def) * crit)
					update_enemy_hp()
					UI.play("Shake")
					heal("all", "max_hp", heal_amt)
					if active_character == "mielle":
						add_dialogue("Mielle threw her knife at " + enemy.enemy_name.capitalize() + "!")
					elif active_character == "six":
						add_dialogue("Six threw a knife at " + enemy.enemy_name.capitalize() + "!")
					attacked = true
				elif Manager.current_stats["mielle"]["skill 3"]["modifier"] == "sky":
					var dmg = 1
					var pass_rate = 40
					if Manager.current_stats["mielle"]["skill 3"]["level"] == 1:
						dmg = 0.4
					elif Manager.current_stats["mielle"]["skill 3"]["level"] == 2:
						dmg = 0.55
						pass_rate = 50
					elif Manager.current_stats["mielle"]["skill 3"]["level"] == 3:
						dmg = 0.7
						pass_rate = 60
					UI.play("Shake")
					enemy.current_hp -= max(0,float(attack_dmg * (1 + Manager.current_stats[active_character]["temp next atk"] + Manager.current_stats[active_character]["next atk"]) * (1 + Manager.current_stats["atk_boost"]) * Manager.current_stats[enemy_stance + "_dmg_boost"] * dmg - enemy.def) * crit)
					update_enemy_hp()
					Manager.current_stats[active_character]["next trust"] += pass_rate
					if active_character == "mielle":
						add_dialogue("Mielle threw her knife at " + enemy.enemy_name.capitalize() + "!")
					elif active_character == "six":
						add_dialogue("Six threw a knife at " + enemy.enemy_name.capitalize() + "!")
					attacked = true
				add_dialogue("The target switched stances.")
				await get_tree().create_timer(1).timeout
				while !dialogue_finished:
					await get_tree().create_timer(0.02).timeout
				switch_stance()
			if skill == "skill 4":
				Manager.current_stats["mielle"]["counter"] = true
				add_dialogue("Mielle prepared to counter!")
				if Manager.current_stats["mielle"]["skill 4"]["modifier"] == "sky":
					var pass_rate = 40
					if Manager.current_stats["mielle"]["skill 4"]["level"] == 1:
						pass_rate = 20
					elif Manager.current_stats["mielle"]["skill 4"]["level"] == 2:
						pass_rate = 35
					elif Manager.current_stats["mielle"]["skill 4"]["level"] == 3:
						pass_rate = 60
					Manager.current_stats[active_character]["next trust"] += pass_rate
					enemy.target = num_of_ally("mielle")
					if enemy.aoe_no <=2 and enemy.targets[0] != num_of_ally("mielle") and enemy.targets[1] != num_of_ally("mielle"):
						enemy.targets[0] = num_of_ally("mielle")
					elif enemy.aoe_no == 3 and enemy.targets[0] != num_of_ally("mielle") and enemy.targets[1] != num_of_ally("mielle") and enemy.targets[2] !=num_of_ally("mielle"):
						enemy.targets[0] = num_of_ally("mielle")
				elif Manager.current_stats["mielle"]["skill 4"]["modifier"] == "corrupted":
					Manager.current_stats["mielle"]["current_hp"] -= Manager.current_stats["mielle"]["current_hp"] * 0.5
					update_hp()
				attacked = true
		
		
		elif chara == "leon":
			if skill == "skill 1":
				var attack_times = 3
				var dmg = 1
				var pass_rate = 40
				var heal_amt = 1
				if active_character != "six":
					Manager.current_stats["leon"]["vitality"] += 3
				if Manager.current_stats["leon"]["skill 1"]["level"] == 3:
					if active_character != "six":
						Manager.current_stats["leon"]["vitality"] += 1
					attack_times +=1
				if randi() % 100 + 1 <= Manager.current_stats[active_character]["crit"] + Manager.current_stats[enemy_stance + "_crit"]:
					crit = Manager.current_stats[active_character]["crit dmg"] + Manager.current_stats[enemy_stance + "_crit_dmg"]
				if Manager.current_stats["leon"]["skill 1"]["modifier"] == "normal":
					if Manager.current_stats["leon"]["skill 1"]["level"] == 1:
						dmg = 0.3
					elif Manager.current_stats["leon"]["skill 1"]["level"] == 2:
						dmg = 0.4
					elif Manager.current_stats["leon"]["skill 1"]["level"] == 3:
						dmg = 0.5
				elif Manager.current_stats["leon"]["skill 1"]["modifier"] == "sea":
					if Manager.current_stats["leon"]["skill 1"]["level"] == 1:
						dmg = 0.45
					elif Manager.current_stats["leon"]["skill 1"]["level"] == 2:
						dmg = 0.55
					elif Manager.current_stats["leon"]["skill 1"]["level"] == 3:
						dmg = 0.7
					#give_buff(Manager.current_party[ally],"next atk",buff)
				elif Manager.current_stats["leon"]["skill 1"]["modifier"] == "land":
					if Manager.current_stats["leon"]["skill 1"]["level"] == 1:
						dmg = 0.3
						heal_amt = .1
					elif Manager.current_stats["leon"]["skill 1"]["level"] == 2:
						dmg = 0.4
						heal_amt = .2
					elif Manager.current_stats["leon"]["skill 1"]["level"] == 3:
						dmg = 0.5
						heal_amt = .3
					for i in range(attack_times):
						heal(lowest_hp_character(), "damage", (attack_dmg * (1 + Manager.current_stats[active_character]["temp next atk"] + Manager.current_stats[active_character]["next atk"]) * (1 + Manager.current_stats["atk_boost"]) * Manager.current_stats[enemy_stance + "_dmg_boost"] * dmg - enemy.def) * crit * heal_amt)
				elif Manager.current_stats["leon"]["skill 1"]["modifier"] == "sky":
					if Manager.current_stats["leon"]["skill 1"]["level"] == 1:
						dmg = 0.3
						pass_rate = 30
					elif Manager.current_stats["leon"]["skill 1"]["level"] == 2:
						dmg = 0.4
						pass_rate = 40
					elif Manager.current_stats["leon"]["skill 1"]["level"] == 3:
						dmg = 0.5
						pass_rate = 50
						if active_character != "six":
							Manager.current_stats["leon"]["vitality"] += 1
					Manager.current_stats[active_character]["next trust"] += pass_rate
				update_stats_on_gui()
				for i in range (attack_times):
					UI.play("Shake")
					enemy.current_hp -= max(0,float(attack_dmg * (1 + Manager.current_stats[active_character]["temp next atk"] + Manager.current_stats[active_character]["next atk"]) * (1 + Manager.current_stats["atk_boost"]) * Manager.current_stats[enemy_stance + "_dmg_boost"] * dmg - enemy.def) * crit)
					update_enemy_hp()
					await get_tree().create_timer(1).timeout
				add_dialogue(active_character.capitalize() + " struck " + enemy.enemy_name.capitalize() + " " + str(attack_times) + " times!")
				attacked = true
			if skill == "skill 2":
				var attack_times = 2
				var dmg = 1
				var pass_rate = 40
				var heal_amt = 1
				if active_character != "six":
					Manager.current_stats["leon"]["vitality"] += 2
				if Manager.current_stats["leon"]["skill 2"]["level"] == 3:
					if active_character != "six":
						Manager.current_stats["leon"]["vitality"] += 1
					attack_times +=1
				if randi() % 100 + 1 <= Manager.current_stats[active_character]["crit"] + Manager.current_stats[enemy_stance + "_crit"]:
					crit = Manager.current_stats[active_character]["crit dmg"] + Manager.current_stats[enemy_stance + "_crit_dmg"]
				if Manager.current_stats["leon"]["skill 2"]["modifier"] == "normal":
					if Manager.current_stats["leon"]["skill 2"]["level"] == 1:
						dmg = 0.35
					elif Manager.current_stats["leon"]["skill 2"]["level"] == 2:
						dmg = 0.45
					elif Manager.current_stats["leon"]["skill 2"]["level"] == 3:
						dmg = 0.55
				elif Manager.current_stats["leon"]["skill 2"]["modifier"] == "sea":
					if Manager.current_stats["leon"]["skill 2"]["level"] == 1:
						dmg = 0.45
					elif Manager.current_stats["leon"]["skill 2"]["level"] == 2:
						dmg = 0.55
					elif Manager.current_stats["leon"]["skill 2"]["level"] == 3:
						dmg = 0.7
					#give_buff(Manager.current_party[ally],"next atk",buff)
				elif Manager.current_stats["leon"]["skill 2"]["modifier"] == "land":
					if Manager.current_stats["leon"]["skill 2"]["level"] == 1:
						dmg = 0.35
						heal_amt = .2
					elif Manager.current_stats["leon"]["skill 2"]["level"] == 2:
						dmg = 0.45
						heal_amt = .3
					elif Manager.current_stats["leon"]["skill 2"]["level"] == 3:
						dmg = 0.55
						heal_amt = .4
					for i in range(attack_times):
						heal(lowest_hp_character(), "damage", (attack_dmg * (1 + Manager.current_stats[active_character]["temp next atk"] + Manager.current_stats[active_character]["next atk"]) * (1 + Manager.current_stats["atk_boost"]) * Manager.current_stats[enemy_stance + "_dmg_boost"] * dmg - enemy.def) * crit * heal_amt)
				elif Manager.current_stats["leon"]["skill 2"]["modifier"] == "sky":
					if Manager.current_stats["leon"]["skill 2"]["level"] == 1:
						dmg = 0.35
						pass_rate = 30
						if active_character != "six":
							Manager.current_stats["leon"]["vitality"] += 1
					elif Manager.current_stats["leon"]["skill 2"]["level"] == 2:
						dmg = 0.45
						pass_rate = 40
						if active_character != "six":
							Manager.current_stats["leon"]["vitality"] += 1
					elif Manager.current_stats["leon"]["skill 2"]["level"] == 3:
						dmg = 0.55
						pass_rate = 50
						if active_character != "six":
							Manager.current_stats["leon"]["vitality"] += 2
					Manager.current_stats[active_character]["next trust"] += pass_rate
				update_stats_on_gui()
				for i in range (attack_times):
					UI.play("Shake")
					enemy.current_hp -= max(0,float(attack_dmg * (1 + Manager.current_stats[active_character]["temp next atk"] + Manager.current_stats[active_character]["next atk"]) * (1 + Manager.current_stats["atk_boost"]) * Manager.current_stats[enemy_stance + "_dmg_boost"] * dmg - enemy.def) * crit)
					update_enemy_hp()
					await get_tree().create_timer(1).timeout
				add_dialogue(active_character.capitalize() + " shot " + enemy.enemy_name.capitalize() + " " + str(attack_times) + " times!")
				attacked = true
			if skill == "skill 3":
				var dmg = 1
				var pass_rate = 40
				var buff = 0.1
				var heal_amt = 1
				if active_character != "six":
					Manager.current_stats["leon"]["vitality"] += 2
				if Manager.current_stats["leon"]["skill 3"]["level"] == 2:
					if active_character != "six":
						Manager.current_stats["leon"]["vitality"] += 1
				elif Manager.current_stats["leon"]["skill 3"]["level"] == 3:
					if active_character != "six":
						Manager.current_stats["leon"]["vitality"] += 1
				if randi() % 100 + 1 <= Manager.current_stats[active_character]["crit"] + Manager.current_stats[enemy_stance + "_crit"]:
					crit = Manager.current_stats[active_character]["crit dmg"] + Manager.current_stats[enemy_stance + "_crit_dmg"]
				if Manager.current_stats["leon"]["skill 3"]["modifier"] == "sea":
					if Manager.current_stats["leon"]["skill 3"]["level"] == 1:
						dmg = 0.5
					elif Manager.current_stats["leon"]["skill 3"]["level"] == 2:
						dmg = 0.65
					elif Manager.current_stats["leon"]["skill 3"]["level"] == 3:
						dmg = 0.8
					#give_buff(Manager.current_party[ally],"next atk",buff)
					UI.play("Shake")
					enemy.current_hp -= max(0,float(attack_dmg * (1 + Manager.current_stats[active_character]["temp next atk"] + Manager.current_stats[active_character]["next atk"]) * (1 + Manager.current_stats["atk_boost"]) * Manager.current_stats[enemy_stance + "_dmg_boost"] * dmg - enemy.def) * crit)
					update_enemy_hp()
					add_dialogue(active_character.capitalize() + " struck " + enemy.enemy_name.capitalize() + "!")
					await get_tree().create_timer(1).timeout
					while !dialogue_finished:
						await get_tree().create_timer(0.02).timeout
				elif Manager.current_stats["leon"]["skill 3"]["modifier"] == "land":
					if Manager.current_stats["leon"]["skill 3"]["level"] == 1:
						heal_amt = .1
						buff = .2
					elif Manager.current_stats["leon"]["skill 3"]["level"] == 2:
						heal_amt = .2
						buff = .3
					elif Manager.current_stats["leon"]["skill 3"]["level"] == 3:
						heal_amt = .3
						buff = .4
					give_buff(lowest_hp_character(),"next atk",buff)
					heal(lowest_hp_character(), "max_hp", heal_amt)
				elif Manager.current_stats["leon"]["skill 3"]["modifier"] == "sky":
					if Manager.current_stats["leon"]["skill 3"]["level"] == 1:
						pass_rate = 30
						if active_character != "six":
							Manager.current_stats["leon"]["vitality"] += 1
					elif Manager.current_stats["leon"]["skill 3"]["level"] == 2:
						pass_rate = 40
						if active_character != "six":
							Manager.current_stats["leon"]["vitality"] += 2
					elif Manager.current_stats["leon"]["skill 3"]["level"] == 3:
						pass_rate = 50
						if active_character != "six":
							Manager.current_stats["leon"]["vitality"] += 2
					Manager.current_stats[active_character]["next trust"] += pass_rate
				update_stats_on_gui()
				switch_stance()
				add_dialogue("The target switched stances.")
				await get_tree().create_timer(1).timeout
				while !dialogue_finished:
					await get_tree().create_timer(0.02).timeout
				attacked = true
			if skill == "skill 4":
				var vitality_to_consume: int
				if Manager.current_stats["leon"]["skill 4"]["modifier"] != "sky":
					vitality_to_consume = 3
				else:
					vitality_to_consume = 2
				if Manager.current_stats["leon"]["vitality"] < vitality_to_consume:
					add_dialogue("Not enough vitality!")
					attacked = false
				else:
					Manager.current_stats["leon"]["vitality"] -= vitality_to_consume
					var dmg : float = 1
					var pass_rate = 40
					var heal_amt = 1
					if randi() % 100 + 1 <= Manager.current_stats[active_character]["crit"] + Manager.current_stats[enemy_stance + "_crit"]:
						crit = Manager.current_stats[active_character]["crit dmg"] + Manager.current_stats[enemy_stance + "_crit_dmg"]
					if Manager.current_stats["leon"]["skill 4"]["modifier"] == "normal":
						if Manager.current_stats["leon"]["skill 4"]["level"] == 1:
							dmg = 3
						elif Manager.current_stats["leon"]["skill 4"]["level"] == 2:
							dmg = 3.5
						elif Manager.current_stats["leon"]["skill 4"]["level"] == 3:
							dmg = 4
					elif Manager.current_stats["leon"]["skill 4"]["modifier"] == "sea":
						if Manager.current_stats["leon"]["skill 4"]["level"] == 1:
							dmg = 4
						elif Manager.current_stats["leon"]["skill 4"]["level"] == 2:
							dmg = 4.5
						elif Manager.current_stats["leon"]["skill 4"]["level"] == 3:
							dmg = 5
						#give_buff(Manager.current_party[ally],"next atk",buff)
					elif Manager.current_stats["leon"]["skill 4"]["modifier"] == "land":
						if Manager.current_stats["leon"]["skill 4"]["level"] == 1:
							dmg = 3
							heal_amt = .3
						elif Manager.current_stats["leon"]["skill 4"]["level"] == 2:
							dmg = 3.5
							heal_amt = .5
						elif Manager.current_stats["leon"]["skill 4"]["level"] == 3:
							dmg = 4
							heal_amt = .7
						heal(active_character, "max_hp", heal_amt)
					elif Manager.current_stats["leon"]["skill 4"]["modifier"] == "sky":
						if Manager.current_stats["leon"]["skill 4"]["level"] == 1:
							dmg = 3
							pass_rate = 50
							if active_character != "six":
								Manager.current_stats["leon"]["vitality"] += 1
						elif Manager.current_stats["leon"]["skill 4"]["level"] == 2:
							dmg = 3.5
							pass_rate = 60
							if active_character != "six":
								Manager.current_stats["leon"]["vitality"] += 2
						elif Manager.current_stats["leon"]["skill 4"]["level"] == 3:
							dmg = 4
							pass_rate = 70
							if active_character != "six":
								Manager.current_stats["leon"]["vitality"] += 2
						Manager.current_stats[active_character]["next trust"] += pass_rate
					elif Manager.current_stats["leon"]["skill 4"]["modifier"] == "corrupted":
						if Manager.current_stats["leon"]["skill 4"]["level"] == 1:
							dmg = 6
						elif Manager.current_stats["leon"]["skill 4"]["level"] == 2:
							dmg = 7
						elif Manager.current_stats["leon"]["skill 4"]["level"] == 3:
							dmg = 8
						Manager.current_stats["leon"]["current_hp"] -= Manager.current_stats["leon"]["current_hp"] * 0.5
						update_hp()
					update_stats_on_gui()
					UI.play("Shake")
					enemy.current_hp -= max(0,float(attack_dmg * (1 + Manager.current_stats[active_character]["temp next atk"] + Manager.current_stats[active_character]["next atk"]) * (1 + Manager.current_stats["atk_boost"]) * Manager.current_stats[enemy_stance + "_dmg_boost"] * dmg - enemy.def) * crit)
					update_enemy_hp()
					add_dialogue(active_character.capitalize() + " pummelled " + enemy.enemy_name.capitalize() + "!")
					await get_tree().create_timer(1).timeout
					while !dialogue_finished:
						await get_tree().create_timer(0.02).timeout
					attacked = true

		
		elif chara == "tear":
			var recali = 1
			if Manager.current_stats["tear"]["recalibration"]:
				recali = Manager.current_stats["tear"]["recalibration_dmg"]
				Manager.current_stats["tear"]["recalibration"] = false
			var multiplier = 1
			if first_move:
				if active_character != "six":
					first_action_char = "tear"
					multiplier = 2
				else:
					first_action_char = "six"
			if skill == "skill 1":
				var dmg : float = 1
				var pass_rate = 40
				var heal_amt = 1
				var extra_crit = 60
				var crit_dmg_increase : float = 0
				if Manager.current_stats["tear"]["skill 1"]["level"] == 1:
					extra_crit = 30
				elif Manager.current_stats["tear"]["skill 1"]["level"] == 2:
					extra_crit = 40
				elif Manager.current_stats["tear"]["skill 1"]["level"] == 3:
					extra_crit = 50
				if Manager.current_stats["tear"]["skill 1"]["modifier"] == "normal":
					if Manager.current_stats["tear"]["skill 1"]["level"] == 1:
						dmg = 0.8
						crit_dmg_increase = 1
					elif Manager.current_stats["tear"]["skill 1"]["level"] == 2:
						dmg = 1.2
						crit_dmg_increase = 1.7
					elif Manager.current_stats["tear"]["skill 1"]["level"] == 3:
						dmg = 1.5
						crit_dmg_increase = 2.4
				if Manager.current_stats["tear"]["skill 1"]["modifier"] == "sea":
					if Manager.current_stats["tear"]["skill 1"]["level"] == 1:
						dmg = 1
					elif Manager.current_stats["tear"]["skill 1"]["level"] == 2:
						dmg = 1.3
					elif Manager.current_stats["tear"]["skill 1"]["level"] == 3:
						dmg = 1.6
				elif Manager.current_stats["tear"]["skill 1"]["modifier"] == "land":
					if Manager.current_stats["tear"]["skill 1"]["level"] == 1:
						dmg = 0.8
						heal_amt = .3
					elif Manager.current_stats["tear"]["skill 1"]["level"] == 2:
						dmg = 1.2
						heal_amt = .45
					elif Manager.current_stats["tear"]["skill 1"]["level"] == 3:
						dmg = 1.5
						heal_amt = .5
				elif Manager.current_stats["tear"]["skill 1"]["modifier"] == "sky":
					if Manager.current_stats["tear"]["skill 1"]["level"] == 1:
						dmg = 0.8
						pass_rate = 50
					elif Manager.current_stats["tear"]["skill 1"]["level"] == 2:
						dmg = 1.2
						pass_rate = 60
					elif Manager.current_stats["tear"]["skill 1"]["level"] == 3:
						dmg = 1.5
						pass_rate = 70
					Manager.current_stats[active_character]["next trust"] += pass_rate
				if randi() % 100 + 1 <= Manager.current_stats[active_character]["crit"] + Manager.current_stats[enemy_stance + "_crit"] + extra_crit:
					crit = (Manager.current_stats[active_character]["crit dmg"] + Manager.current_stats[enemy_stance + "_crit_dmg"]) + crit_dmg_increase
				UI.play("Shake")
				enemy.current_hp -= max(0,float((attack_dmg * (1 + Manager.current_stats[active_character]["temp next atk"] + Manager.current_stats[active_character]["next atk"]) * (1 + Manager.current_stats["atk_boost"]) * Manager.current_stats[enemy_stance + "_dmg_boost"] * dmg - enemy.def) * crit)*multiplier * recali)
				update_enemy_hp()
				await get_tree().create_timer(1).timeout
				add_dialogue(active_character.capitalize() + " shot " + enemy.enemy_name.capitalize() + "!")
				if crit > 1 and Manager.current_stats["tear"]["skill 1"]["modifier"] == "land":
					heal(lowest_hp_character(), "damage", (attack_dmg * (1 + Manager.current_stats[active_character]["temp next atk"] + Manager.current_stats[active_character]["next atk"]) * (1 + Manager.current_stats["atk_boost"]) * Manager.current_stats[enemy_stance + "_dmg_boost"] * dmg - enemy.def) * crit * heal_amt * multiplier * recali)
				attacked = true
			if skill == "skill 2":
				var attack_times = 3
				var dmg = 1
				var pass_rate = 40
				var heal_amt = 1
				if randi() % 100 + 1 <= Manager.current_stats[active_character]["crit"] + Manager.current_stats[enemy_stance + "_crit"]:
					crit = Manager.current_stats[active_character]["crit dmg"] + Manager.current_stats[enemy_stance + "_crit_dmg"]
				if Manager.current_stats["tear"]["skill 2"]["modifier"] == "normal":
					if Manager.current_stats["tear"]["skill 2"]["level"] == 1:
						dmg = 0.35
					elif Manager.current_stats["tear"]["skill 2"]["level"] == 2:
						dmg = 0.5
					elif Manager.current_stats["tear"]["skill 2"]["level"] == 3:
						dmg = 0.65
				elif Manager.current_stats["tear"]["skill 2"]["modifier"] == "sea":
					if Manager.current_stats["tear"]["skill 2"]["level"] == 1:
						dmg = 0.6
					elif Manager.current_stats["tear"]["skill 2"]["level"] == 2:
						dmg = 0.75
					elif Manager.current_stats["tear"]["skill 2"]["level"] == 3:
						dmg = 0.9
					#give_buff(Manager.current_party[ally],"next atk",buff)
				elif Manager.current_stats["tear"]["skill 2"]["modifier"] == "land":
					if Manager.current_stats["tear"]["skill 2"]["level"] == 1:
						dmg = 0.35
						heal_amt = .15
					elif Manager.current_stats["tear"]["skill 2"]["level"] == 2:
						dmg = 0.5
						heal_amt = .2
					elif Manager.current_stats["tear"]["skill 2"]["level"] == 3:
						dmg = 0.65
						heal_amt = .3
					for i in range(attack_times):
						heal(lowest_hp_character(), "damage", (attack_dmg * (1 + Manager.current_stats[active_character]["temp next atk"] + Manager.current_stats[active_character]["next atk"]) * (1 + Manager.current_stats["atk_boost"]) * Manager.current_stats[enemy_stance + "_dmg_boost"] * dmg - enemy.def) * crit * heal_amt * multiplier * recali)
				elif Manager.current_stats["tear"]["skill 2"]["modifier"] == "sky":
					if Manager.current_stats["tear"]["skill 2"]["level"] == 1:
						dmg = 0.35
						pass_rate = 50
					elif Manager.current_stats["tear"]["skill 2"]["level"] == 2:
						dmg = 0.5
						pass_rate = 60
					elif Manager.current_stats["tear"]["skill 2"]["level"] == 3:
						dmg = 0.60
						pass_rate = 70
					Manager.current_stats[active_character]["next trust"] += pass_rate
				
				for i in range (attack_times):
					UI.play("Shake")
					enemy.current_hp -= max(0,float((attack_dmg * (1 + Manager.current_stats[active_character]["temp next atk"] + Manager.current_stats[active_character]["next atk"]) * (1 + Manager.current_stats["atk_boost"]) * Manager.current_stats[enemy_stance + "_dmg_boost"] * dmg - enemy.def) * crit)*multiplier * recali)
					update_enemy_hp()
					await get_tree().create_timer(1).timeout
				add_dialogue(active_character.capitalize() + " shot " + enemy.enemy_name.capitalize() + " " + str(attack_times) + " times!")
				attacked = true
			if skill == "skill 3":
				var pass_rate = 0
				add_dialogue(active_character.capitalize() + " planted a trap!")
				traps_placed +=1
				attacked = true
				if Manager.current_stats["tear"]["skill 3"]["modifier"] == "sky":
					if Manager.current_stats["tear"]["skill 3"]["level"] == 1:
						pass_rate = 50
					elif Manager.current_stats["tear"]["skill 2"]["level"] == 2:
						pass_rate = 60
					elif Manager.current_stats["tear"]["skill 2"]["level"] == 3:
						pass_rate = 70
					Manager.current_stats[active_character]["next trust"] += pass_rate
			if skill == "skill 4":
				Manager.current_stats["tear"]["recalibration"] = true
				var dmg = 1
				var pass_rate = 40
				var heal_amt = 1
				if Manager.current_stats["tear"]["skill 4"]["modifier"] == "normal":
					if Manager.current_stats["tear"]["skill 4"]["level"] == 1:
						dmg = 2.2
					elif Manager.current_stats["tear"]["skill 4"]["level"] == 2:
						dmg = 3.2
					elif Manager.current_stats["tear"]["skill 4"]["level"] == 3:
						dmg = 4.2
				elif Manager.current_stats["tear"]["skill 4"]["modifier"] == "sea":
					if Manager.current_stats["tear"]["skill 4"]["level"] == 1:
						dmg = 3.2
					elif Manager.current_stats["tear"]["skill 4"]["level"] == 2:
						dmg = 4.2
					elif Manager.current_stats["tear"]["skill 4"]["level"] == 3:
						dmg = 5.2
					#give_buff(Manager.current_party[ally],"next atk",buff)
				elif Manager.current_stats["tear"]["skill 4"]["modifier"] == "land":
					if Manager.current_stats["tear"]["skill 4"]["level"] == 1:
						dmg = 2.2
						heal_amt = .4
					elif Manager.current_stats["tear"]["skill 4"]["level"] == 2:
						dmg = 3.2
						heal_amt = .5
					elif Manager.current_stats["tear"]["skill 4"]["level"] == 3:
						dmg = 4.2
						heal_amt = .6
					heal(active_character, "max_hp", heal_amt)
				elif Manager.current_stats["tear"]["skill 4"]["modifier"] == "sky":
					Manager.current_stats[active_character]["shield"] = true
					if Manager.current_stats["tear"]["skill 4"]["level"] == 1:
						dmg = 2.2
						pass_rate = 30
					elif Manager.current_stats["tear"]["skill 4"]["level"] == 2:
						dmg = 3.2
						pass_rate = 40
					elif Manager.current_stats["tear"]["skill 4"]["level"] == 3:
						dmg = 4.2
						pass_rate = 50
					Manager.current_stats[active_character]["next trust"] += pass_rate
				elif Manager.current_stats["tear"]["skill 4"]["modifier"] == "corrupted":
					if Manager.current_stats["tear"]["skill 4"]["level"] == 1:
						dmg = 4
					elif Manager.current_stats["tear"]["skill 4"]["level"] == 2:
						dmg = 5
					elif Manager.current_stats["tear"]["skill 4"]["level"] == 3:
						dmg = 6
					Manager.current_stats["tear"]["current_hp"] -= Manager.current_stats["tear"]["current_hp"] * 0.5
					update_hp()
				add_dialogue("Tear adjusted his aim...")
				Manager.current_stats["tear"]["recalibration_dmg"] = dmg
				update_stats_on_gui()
				update_stat_icons()
				attacked = true
		
		elif chara == "six":
			if skill == "skill 1":
				var buff : float= 1
				var heal_amt : float = 1
				is_target = true
				$TargetThing.show()
				target_menu_showing = true
				while target_menu_showing and targeted == null:
					await get_tree().create_timer(0.2).timeout
				var isnt_dead = true
				if targeted == "mielle" and dead1:
					isnt_dead = false
				if targeted == "leon" and dead2:
					isnt_dead = false
				if targeted == "tear" and dead3:
					isnt_dead = false
				if targeted == "six" and dead4:
					isnt_dead = false
				if targeted != null and isnt_dead:
					attacked = true
					if targeted == "six":
						add_dialogue("Six supported himself!")
					else:
						add_dialogue("Six supported " + targeted.capitalize() + "!")
					if Manager.current_stats["six"]["skill 1"]["level"] == 1:
						buff = 0.2
						heal_amt = 0.4
					elif Manager.current_stats["six"]["skill 1"]["level"] == 2:
						buff = 0.3
						heal_amt = 0.5
					elif Manager.current_stats["six"]["skill 1"]["level"] == 3:
						buff = 0.4
						heal_amt = 0.6
					if Manager.current_stats["six"]["skill 1"]["modifier"] == "sea":	
						buff += 0.2
					elif Manager.current_stats["six"]["skill 1"]["modifier"] == "land":
						heal_amt += 0.4
					elif Manager.current_stats["six"]["skill 1"]["modifier"] == "sky":
						var pass_boost = 40
						if Manager.current_stats["six"]["skill 1"]["level"] == 1:
							pass_boost = 40
						elif Manager.current_stats["six"]["skill 1"]["level"] == 2:
							pass_boost = 50
						elif Manager.current_stats["six"]["skill 1"]["level"] == 3:
							pass_boost = 60
						Manager.current_stats["pass_boost"] += pass_boost
					heal(targeted, "damage", Manager.current_stats["six"]["atk"] * heal_amt)
					give_buff(targeted,"next atk",buff)
					Manager.current_stats[targeted]["next atk"] += buff
					update_stat_icons()
					if targeted == "six":
						six_supported_self = true
					attacked = true
				else:
					attacked = false
			if skill == "skill 2":
				var dmg : float = 1
				var pass_rate = 40
				var heal_amt = 1
				if randi() % 100 + 1 <= Manager.current_stats[active_character]["crit"] + Manager.current_stats[enemy_stance + "_crit"]:
					crit = Manager.current_stats[active_character]["crit dmg"] + Manager.current_stats[enemy_stance + "_crit_dmg"]
				if Manager.current_stats["six"]["skill 2"]["level"] == 1:
					dmg = 0.6
				elif Manager.current_stats["six"]["skill 2"]["level"] == 2:
					dmg = 0.5
				elif Manager.current_stats["six"]["skill 2"]["level"] == 3:
					dmg = 0.4
				if Manager.current_stats["six"]["skill 2"]["modifier"] == "sea":
					if Manager.current_stats["six"]["skill 2"]["level"] == 1:
						dmg = 0.6
					elif Manager.current_stats["six"]["skill 2"]["level"] == 2:
						dmg = 0.8
					elif Manager.current_stats["six"]["skill 2"]["level"] == 3:
						dmg = 1
				elif Manager.current_stats["six"]["skill 2"]["modifier"] == "land":
					if Manager.current_stats["six"]["skill 2"]["level"] == 1:
						heal_amt = .6
					elif Manager.current_stats["six"]["skill 2"]["level"] == 2:
						heal_amt = .7
					elif Manager.current_stats["six"]["skill 2"]["level"] == 3:
						heal_amt = .8
					heal(active_character,"damage",max(0,float(attack_dmg * (1 + Manager.current_stats[active_character]["temp next atk"] + Manager.current_stats[active_character]["next atk"]) * (1 + Manager.current_stats["atk_boost"]) * Manager.current_stats[enemy_stance + "_dmg_boost"] * dmg - enemy.def) * crit)*heal_amt)
				elif Manager.current_stats["six"]["skill 2"]["modifier"] == "sky":
					if Manager.current_stats["six"]["skill 2"]["level"] == 1:
						pass_rate = 60
					elif Manager.current_stats["six"]["skill 2"]["level"] == 2:
						pass_rate = 80
					elif Manager.current_stats["six"]["skill 2"]["level"] == 3:
						pass_rate = 100
					Manager.current_stats["pass boost"] += pass_rate
				UI.play("Shake")
				enemy.current_hp -= max(0,float(attack_dmg * (1 + Manager.current_stats[active_character]["temp next atk"] + Manager.current_stats[active_character]["next atk"]) * (1 + Manager.current_stats["atk_boost"]) * Manager.current_stats[enemy_stance + "_dmg_boost"] * dmg - enemy.def) * crit)
				update_enemy_hp()
				await get_tree().create_timer(1).timeout
				add_dialogue(active_character.capitalize() + " slashed " + enemy.enemy_name.capitalize() + "!")
				attacked = true
			if skill == "skill 3":
				insight_times = 0
				if Manager.current_stats["six"]["skill 3"]["level"] == 1:
					insight_times += 1
				elif Manager.current_stats["six"]["skill 3"]["level"] == 2:
					insight_times += 2
				elif Manager.current_stats["six"]["skill 3"]["level"] == 3:
					insight_times += 3
				if Manager.current_stats["six"]["skill 3"]["modifier"] == "sea":	
					var dmg = 1
					if Manager.current_stats["six"]["skill 3"]["level"] == 1:
						dmg = 0.4
					elif Manager.current_stats["six"]["skill 3"]["level"] == 2:
						dmg = 0.5
					elif Manager.current_stats["six"]["skill 3"]["level"] == 3:
						dmg = 0.6
					UI.play("Shake")
					enemy.current_hp -= max(0,float(attack_dmg * (1 + Manager.current_stats[active_character]["temp next atk"] + Manager.current_stats[active_character]["next atk"]) * (1 + Manager.current_stats["atk_boost"]) * Manager.current_stats[enemy_stance + "_dmg_boost"] * dmg - enemy.def) * crit)
					update_enemy_hp()
					await get_tree().create_timer(1).timeout
					add_dialogue(active_character.capitalize() + " attacked " + enemy.enemy_name.capitalize() + "!")
				elif Manager.current_stats["six"]["skill 3"]["modifier"] == "land":
					var heal_amt = 0.4
					if Manager.current_stats["six"]["skill 3"]["level"] == 1:
						heal_amt = 0.1
					elif Manager.current_stats["six"]["skill 3"]["level"] == 2:
						heal_amt = 0.2
					elif Manager.current_stats["six"]["skill 3"]["level"] == 3:
						heal_amt = 0.3
					heal(lowest_hp_character(), "max_hp", heal_amt)
				elif Manager.current_stats["six"]["skill 3"]["modifier"] == "sky":
					var pass_boost = 40
					if Manager.current_stats["six"]["skill 3"]["level"] == 1:
						pass_boost = 60
					elif Manager.current_stats["six"]["skill 3"]["level"] == 2:
						pass_boost = 80
					elif Manager.current_stats["six"]["skill 3"]["level"] == 3:
						pass_boost = 100
					Manager.current_stats["pass_boost"] += pass_boost
				add_dialogue("Six gained insight.")
				reveal_targets()
				attacked = true
			if skill == "skill 4":
				is_target = true
				$TargetThing.show()
				target_menu_showing = true
				targeted = null
				while target_menu_showing and targeted == null:
					await get_tree().create_timer(0.2).timeout
				
				if targeted != null and targeted != "six":
					if Manager.current_stats["six"]["shapeshifted"]:
						add_dialogue("Are you trying to die?")
						attacked = false
					else:
						Manager.current_stats["six"]["shapeshifted"] = true
						Manager.current_stats["six"]["shapeshifted_char"] = targeted
						Manager.current_stats["six"]["shapeshifted_atk"] = Manager.current_stats["six"]["atk"] + Manager.current_stats[targeted]["atk"]
						#Manager.current_stats["six"]["shapeshifted_def"] = Manager.current_stats["six"]["def"] + Manager.current_stats[targeted]["def"]
						if Manager.current_stats["six"]["skill 4"]["level"] == 1:
							Manager.current_stats["six"]["shapeshifted_atk_boost"] = 1.2
							Manager.current_stats["six"]["trust_loss"] += 70
						elif Manager.current_stats["six"]["skill 4"]["level"] == 2:
							Manager.current_stats["six"]["shapeshifted_atk_boost"] = 1.4
							Manager.current_stats["six"]["trust_loss"] += 60
						elif Manager.current_stats["six"]["skill 4"]["level"] == 3:
							Manager.current_stats["six"]["shapeshifted_atk_boost"] = 1.6
							Manager.current_stats["six"]["trust_loss"] += 50
						if Manager.current_stats["six"]["skill 4"]["modifier"] == "sea":
							if Manager.current_stats["six"]["skill 4"]["level"] == 1:
								Manager.current_stats["six"]["shapeshifted_atk"] *= 1.4
							elif Manager.current_stats["six"]["skill 4"]["level"] == 2:
								Manager.current_stats["six"]["shapeshifted_atk"] *= 1.6
							elif Manager.current_stats["six"]["skill 4"]["level"] == 3:
								Manager.current_stats["six"]["shapeshifted_atk"] *= 2
							#Manager.current_stats["six"]["shapeshifted_def"] *= 2
						elif Manager.current_stats["six"]["skill 4"]["modifier"] == "land":
							if Manager.current_stats["six"]["skill 4"]["level"] == 1:
								Manager.current_stats["six"]["shapeshifted_heal"] = 0.1
							elif Manager.current_stats["six"]["skill 4"]["level"] == 2:
								Manager.current_stats["six"]["shapeshifted_heal"] = 0.2
							elif Manager.current_stats["six"]["skill 4"]["level"] == 3:
								Manager.current_stats["six"]["shapeshifted_heal"] = 0.3
						elif Manager.current_stats["six"]["skill 4"]["modifier"] == "sky":
							Manager.current_stats["six"]["trust_loss"] -= 50
						elif Manager.current_stats["six"]["skill 4"]["modifier"] == "corrupted":
							Manager.current_stats["six"]["shapeshifted_atk"] = Manager.current_stats["six"]["atk"] + Manager.current_stats["mielle"]["atk"] + Manager.current_stats["leon"]["atk"] + Manager.current_stats["tear"]["atk"]
							#Manager.current_stats["six"]["shapeshifted_def"] = Manager.current_stats["six"]["def"] + Manager.current_stats["mielle"]["def"] + Manager.current_stats["leon"]["def"] + Manager.current_stats["tear"]["def"]
							Manager.current_stats["six"]["current_hp"] -= Manager.current_stats["six"]["current_hp"] * 0.6
							update_hp()
						#heal(targeted, "max_hp", heal_amt)
						update_stat_icons()
						update_stats_on_gui()
						update_skill_icons()
						change_char(active_character)
						attacked = true
				elif targeted != null and targeted == "six" and Manager.current_stats["six"]["shapeshifted"]:
					Manager.current_stats["six"]["shapeshifted"] = false
					active_sprite.texture = load(Manager.assets["six"]["sprite"])
					Manager.current_stats["six"]["shapeshifted_atk_boost"] = 1
					update_stats_on_gui()
					UI.play("ActiveSprite")
					attacked = true
					update_skill_icons()
					Manager.current_stats["six"]["continuous_atk_boost"] = 0
				elif targeted != null and targeted == "six":
					Manager.current_stats["six"]["shapeshifted"] = false
					attacked = false
				else:
					attacked = false
		
		if attacked and !end_signalled:
			update_stats_on_gui()
			if first_move:
				first_action_char = active_character
				first_move = false
			else:
				first_action_char = "none"
			Manager.current_stats["atk_boost"] = 0
			add_exp(chara,exp_gain)
			if crit > 1:
				add_dialogue("Critical hit!")
			if enemy_stance == "close":
				if active_character != "six":
					if randi_range(1, 100) <= Manager.current_stats[active_character]["trust"] + Manager.current_stats["pass_boost"] + Manager.current_stats[active_character]["next trust"] + Manager.current_stats["trust_boost"] + Manager.current_stats["close_pass_boost"]:
						add_dialogue("Pass!")
						can_action = true
					else:
						enemy_turn = true
				else:
					if randi_range(1, 100) <= Manager.current_stats[active_character]["trust"] + Manager.current_stats["pass_boost"] + Manager.current_stats[active_character]["next trust"] + Manager.current_stats["trust_boost"] + Manager.current_stats["close_pass_boost"] - Manager.current_stats["six"]["trust_loss"]:
						add_dialogue("Pass!")
						can_action = true
					else:
						enemy_turn = true
			else:
				if active_character != "six":
					if randi_range(1, 100) <= Manager.current_stats[active_character]["trust"] + Manager.current_stats["pass_boost"] + Manager.current_stats[active_character]["next trust"] + Manager.current_stats["trust_boost"] + Manager.current_stats["far_pass_boost"]:
						add_dialogue("Pass!")
						can_action = true
					else:
						enemy_turn = true
				else:
					if randi_range(1, 100) <= Manager.current_stats[active_character]["trust"] + Manager.current_stats["pass_boost"] + Manager.current_stats[active_character]["next trust"] + Manager.current_stats["trust_boost"] + Manager.current_stats["far_pass_boost"] - Manager.current_stats["six"]["trust_loss"]:
						add_dialogue("Pass!")
						can_action = true
					else:
						enemy_turn = true
			if !six_supported_self:
				Manager.current_stats[active_character]["next trust"] = 0
				Manager.current_stats[active_character]["next atk"] = 0
				Manager.current_stats[active_character]["temp next trust"] = 0
				Manager.current_stats[active_character]["temp next atk"] = 0
			if active_character != "six":
				Manager.current_stats["pass_boost"] = 0
			update_stat_icons()
			if first_action_char == "leon":
				Manager.current_stats["leon"]["vitality"] += 2
				update_stats_on_gui()
			if active_character == Manager.current_party[0]:
				can_attack1 = false
				$PortraitNormal.texture_normal = load("res://UI/Assets/PortraitGrey.png")
			if active_character == Manager.current_party[1]:
				can_attack2 = false
				$PortraitNormal2.texture_normal = load("res://UI/Assets/PortraitGrey.png")
			if active_character == Manager.current_party[2]:
				can_attack3 = false
				$PortraitNormal3.texture_normal = load("res://UI/Assets/PortraitGrey.png")
			if active_character == Manager.current_party[3]:
				can_attack4 = false
				$PortraitNormal4.texture_normal = load("res://UI/Assets/PortraitGrey.png")
			if !can_attack1 and !can_attack2 and !can_attack3 and !can_attack4:
				enemy_turn = true
			elif !can_attack1 and !can_attack2 and !can_attack4 and Manager.current_stats["tear"]["level"] < 3:
				enemy_turn = true
			
			if first_action_char == "mielle" and !skill == "skill 3" and !end_signalled:
				switch_stance()
				add_dialogue("The target switched stances.")
				#await get_tree().create_timer(1).timeout
				await get_tree().create_timer(1).timeout	
				while !combat_dialogue.text_queue.is_empty():
					await get_tree().create_timer(0.02).timeout	
					
			
			while Manager.current_stats["leon"]["vitality"] >= 5 and !end_signalled:
				await get_tree().create_timer(1).timeout
				while !dialogue_finished:
					await get_tree().create_timer(0.02).timeout
				Manager.current_stats["leon"]["vitality"] -= 5
				UI.play("Shake")
				enemy.current_hp -= max(0,float(attack_dmg) * 0.8)
				update_enemy_hp()
				add_dialogue("Leon swiftly followed with another attack!")
				while !dialogue_finished:
					await get_tree().create_timer(0.02).timeout
				update_stats_on_gui()

			
			if enemy_turn and !end_signalled and enemy.current_hp > 0:
				add_dialogue(enemy.name.capitalize() + " is preparing to attack...")
				switch_turn(turn.ENEMY)
			targeted = null
		else:
			can_action = true
	else:
		if enemy_stance == "close":
			add_dialogue("The target is too close!")
		elif enemy_stance == "far":
			add_dialogue("The target is too far!")
		can_action = true

func _on_combat_dialogue_dialogue_started():
	dialogue_showing = true

func game_over():
	Manager.add_trust(Manager.current_stats["day"])
	$ColorRect.show()
	$GameOver.show()
	$Tagline2.show()
	UI.play("defeat")
	await get_tree().create_timer(3).timeout
	$TryAgain.show()


func _on_skill_1_lvl_pressed():
	if Manager.current_stats[skill_target]["skill 1"]["level"] < 3:
		Manager.current_stats[skill_target]["skill 1"]["level"] += 1
		check_and_refresh()

func _on_skill_2_lvl_pressed():
	if Manager.current_stats[skill_target]["skill 2"]["level"] < 3:
		Manager.current_stats[skill_target]["skill 2"]["level"] += 1
		check_and_refresh()


func _on_skill_3_lvl_pressed():
	if Manager.current_stats[skill_target]["skill 3"]["unlocked"] and Manager.current_stats[skill_target]["skill 3"]["level"] < 3:
		Manager.current_stats[skill_target]["skill 3"]["level"] += 1
		check_and_refresh()

func _on_skill_4_lvl_pressed():
	if Manager.current_stats[skill_target]["skill 4"]["unlocked"] and Manager.current_stats[skill_target]["skill 4"]["level"] < 3:
		Manager.current_stats[skill_target]["skill 4"]["level"] += 1
		check_and_refresh()


func check_and_refresh():
	level_queue.erase(skill_target)
	if level_queue.is_empty():
		$Skills.hide()
		skills_showing = false
	else:
		skill_target = level_queue[0]
		update_skills()

func update_skills():
	if Manager.current_stats[skill_target]["skill 1"]["unlocked"]:
		%Skill1LvlName.text = Manager.char_descriptions[skill_target]["skill 1"]["name"]
		if Manager.current_stats[skill_target]["skill 1"]["level"] >= 3:
			%Skill1LvlName.text = "MAXED"
	else:
		%Skill1LvlName.text = "???"
	if !Manager.current_stats[skill_target]["skill 1"]["unlocked"]:
		%Skill1Lvl.texture_normal = load("res://UI/Assets/SkillNull.png")
		%Skill1Lvl.texture_hover = load("res://UI/Assets/SkillNull.png")
	elif Manager.current_stats[skill_target]["skill 1"]["modifier"] == "normal":
		%Skill1Lvl.texture_normal = load("res://UI/Assets/SkillBase.png")
		%Skill1Lvl.texture_hover = load("res://UI/Assets/SkillBaseHover.png")
	elif Manager.current_stats[skill_target]["skill 1"]["modifier"] == "sea":
		%Skill1Lvl.texture_normal = load("res://UI/Assets/SkillSea.png")
		%Skill1Lvl.texture_hover = load("res://UI/Assets/SkillSeaHover.png")
	elif Manager.current_stats[skill_target]["skill 1"]["modifier"] == "land":
		%Skill1Lvl.texture_normal = load("res://UI/Assets/SkillLand.png")
		%Skill1Lvl.texture_hover = load("res://UI/Assets/SkillLandHover.png")
	elif Manager.current_stats[skill_target]["skill 1"]["modifier"] == "sky":
		%Skill1Lvl.texture_normal = load("res://UI/Assets/SkillSky.png")
		%Skill1Lvl.texture_hover = load("res://UI/Assets/SkillSkyHover.png")
		
	#skill 2
	if Manager.current_stats[skill_target]["skill 2"]["unlocked"]:
		%Skill2LvlName.text = Manager.char_descriptions[skill_target]["skill 2"]["name"]
		if Manager.current_stats[skill_target]["skill 2"]["level"] >= 3:
			%Skill2LvlName.text = "MAXED"
	else:
		%Skill2LvlName.text = "???"
	
	if !Manager.current_stats[skill_target]["skill 2"]["unlocked"]:
		%Skill2Lvl.texture_normal = load("res://UI/Assets/SkillNull.png")
		%Skill2Lvl.texture_hover = load("res://UI/Assets/SkillNull.png")
	elif Manager.current_stats[skill_target]["skill 2"]["modifier"] == "normal":
		%Skill2Lvl.texture_normal = load("res://UI/Assets/SkillBase.png")
		%Skill2Lvl.texture_hover = load("res://UI/Assets/SkillBaseHover.png")
	elif Manager.current_stats[skill_target]["skill 2"]["modifier"] == "sea":
		%Skill2Lvl.texture_normal = load("res://UI/Assets/SkillSea.png")
		%Skill2Lvl.texture_hover = load("res://UI/Assets/SkillSeaHover.png")
	elif Manager.current_stats[skill_target]["skill 2"]["modifier"] == "land":
		%Skill2Lvl.texture_normal = load("res://UI/Assets/SkillLand.png")
		%Skill2Lvl.texture_hover = load("res://UI/Assets/SkillLandHover.png")
	elif Manager.current_stats[skill_target]["skill 2"]["modifier"] == "sky":
		%Skill2Lvl.texture_normal = load("res://UI/Assets/SkillSky.png")
		%Skill2Lvl.texture_hover = load("res://UI/Assets/SkillSkyHover.png")
	
	#skill 3
	if Manager.current_stats[skill_target]["skill 3"]["unlocked"]:
		%Skill3LvlName.text = Manager.char_descriptions[skill_target]["skill 3"]["name"]
		if Manager.current_stats[skill_target]["skill 3"]["level"] >= 3:
			%Skill3LvlName.text = "MAXED"
	else:
		%Skill3LvlName.text = "???"
		
	if !Manager.current_stats[skill_target]["skill 3"]["unlocked"]:
		%Skill3Lvl.texture_normal = load("res://UI/Assets/SkillNull.png")
		%Skill3Lvl.texture_hover = load("res://UI/Assets/SkillNull.png")
	elif Manager.current_stats[skill_target]["skill 3"]["modifier"] == "normal":
		%Skill3Lvl.texture_normal = load("res://UI/Assets/SkillBase.png")
		%Skill3Lvl.texture_hover = load("res://UI/Assets/SkillBaseHover.png")
	elif Manager.current_stats[skill_target]["skill 3"]["modifier"] == "sea":
		%Skill3Lvl.texture_normal = load("res://UI/Assets/SkillSea.png")
		%Skill3Lvl.texture_hover = load("res://UI/Assets/SkillSeaHover.png")
	elif Manager.current_stats[skill_target]["skill 3"]["modifier"] == "land":
		%Skill3Lvl.texture_normal = load("res://UI/Assets/SkillLand.png")
		%Skill3Lvl.texture_hover = load("res://UI/Assets/SkillLandHover.png")
	elif Manager.current_stats[skill_target]["skill 3"]["modifier"] == "sky":
		%Skill3Lvl.texture_normal = load("res://UI/Assets/SkillSky.png")
		%Skill3Lvl.texture_hover = load("res://UI/Assets/SkillSkyHover.png")
	
	#skill 4
	if Manager.current_stats[skill_target]["skill 4"]["unlocked"]:
		%Skill4LvlName.text = Manager.char_descriptions[skill_target]["skill 4"]["name"]
		if Manager.current_stats[skill_target]["skill 4"]["level"] >= 3:
			%Skill4LvlName.text = "MAXED"
	else:
		%Skill4LvlName.text = "???"
	
	if !Manager.current_stats[skill_target]["skill 4"]["unlocked"]:
		%Skill4Lvl.texture_normal = load("res://UI/Assets/SkillNull.png")
		%Skill4Lvl.texture_hover = load("res://UI/Assets/SkillNull.png")
	elif Manager.current_stats[skill_target]["skill 4"]["modifier"] == "normal":
		%Skill4Lvl.texture_normal = load("res://UI/Assets/SkillBase.png")
		%Skill4Lvl.texture_hover = load("res://UI/Assets/SkillBaseHover.png")
	elif Manager.current_stats[skill_target]["skill 4"]["modifier"] == "sea":
		%Skill4Lvl.texture_normal = load("res://UI/Assets/SkillSea.png")
		%Skill4Lvl.texture_hover = load("res://UI/Assets/SkillSeaHover.png")
	elif Manager.current_stats[skill_target]["skill 4"]["modifier"] == "land":
		%Skill4Lvl.texture_normal = load("res://UI/Assets/SkillLand.png")
		%Skill4Lvl.texture_hover = load("res://UI/Assets/SkillLandHover.png")
	elif Manager.current_stats[skill_target]["skill 4"]["modifier"] == "sky":
		%Skill4Lvl.texture_normal = load("res://UI/Assets/SkillSky.png")
		%Skill4Lvl.texture_hover = load("res://UI/Assets/SkillSkyHover.png")
	elif Manager.current_stats[skill_target]["skill 4"]["modifier"] == "corrupted":
		%Skill4Lvl.texture_normal = load("res://UI/Assets/SkillCorrupted.png")
		%Skill4Lvl.texture_hover = load("res://UI/Assets/SkillCorruptedHover.png")


func _on_try_again_pressed():
	$Transitioner.fade_out()
	await get_tree().create_timer(0.2).timeout
	Manager.reset()
	Manager.current_stats["life_points"] = 4
	get_tree().change_scene_to_file("res://main_menu.tscn")
