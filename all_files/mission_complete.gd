extends Node2D

var targeted = "none"
var target_menu_showing = false


var land_description = "A soothing shard capable of healing any injury"
var sea_description = "A sharp shard which radiates strength and power"
var sky_description = "Scattered pieces of shards, compelling to the mind"
var corrupted_description = "What... is this?"

var taken1 = false
var taken2 = false
var taken3 = false

var options = []
var items_normal = ["land","sea","sky"]
var items = ["land","sea","sky","corrupted"]
var current_item = 0

var menu_done = false

var descriptions = {
	"land" : {
		"name" : "SHARD OF NATURE",
		"description" : "A soothing shard capable of healing any injury",
		"image" : "res://UI/Assets/land_shard.png"
	},
	"sea" : {
		"name" : "SHARD OF DEPTHS",
		"description" : "A sharp shard which radiates strength and power",
		"image" : "res://UI/Assets/sea_shard.png"
	},
	"sky" : {
		"name" : "SHARD OF HORIZONS",
		"description" : "Scattered pieces of shards, compelling to the mind",
		"image" : "res://UI/Assets/sky_shard.png"
	},
	"corrupted" : {
		"name" : "???",
		"description" : "What is this?",
		"image" : "res://UI/Assets/StrangeMass.png"
	}
}

func _ready():
	randomize()
	$DaysRemaining.text = str(7 - Manager.current_stats["day"]) + " days remaining          |"
	if Manager.current_stats["day"] == 1:
		$AfterBattleLabel.text = '"Finally, revenge is mine! Free all the fish!"'
	elif Manager.current_stats["day"] == 2:
		$AfterBattleLabel.text = '"Looks like the taxers got the \'tax return\' instead."'
	elif Manager.current_stats["day"] == 3:
		$AfterBattleLabel.text = '"Isn\'t it funny how karma always catches up?"'
	elif Manager.current_stats["day"] == 4:
		$AfterBattleLabel.text = '"Good work. That should keep the thief busy for a long while!"'
	elif Manager.current_stats["day"] == 5:
		$AfterBattleLabel.text = '"Just watching you endure that was terrifying.... Good thing you survived."'
	Manager.current_stats["day"] += 1
	$HeartsLeft.text = "x" + str(Manager.current_stats["life_points"])
	show_target()
	if Manager.current_stats["day"] <= 5:
		items = items_normal
	elif !(Manager.current_stats["mielle"]["level"] >= 5 or Manager.current_stats["leon"]["level"] >= 5 or Manager.current_stats["tear"]["level"] >= 5 or Manager.current_stats["six"]["level"] >= 5):
		items = items_normal
	options = generate_items()
	update_items()
	$Skills.hide()
	$TargetThing.hide()
	$ColorRect.show()
	await get_tree().create_timer(0.1).timeout
	%HighlighterAnim.play("fade_in")
	await get_tree().create_timer(0.2).timeout
	$AnimationPlayer.play("start")
	$ColorRect.hide()
	$BoxHighlighter.hide()
	await get_tree().create_timer(1.5).timeout
	menu_done = true
	%HighlighterAnim.play("Squiggle")
	

func generate_items():
	var first_item = items[randi() % items.size()]
	var second_item = items[randi() % items.size()]
	var third_item = items[randi() % items.size()]
	while second_item == third_item:
		third_item = items[randi() % items.size()]
	
	return [first_item,second_item,third_item]


func update_items():
	if !taken1:
		if options[0] == "land":
			$Item1.texture_normal = load("res://UI/Assets/LandBackground.png")
		elif options[0] == "sea":
			$Item1.texture_normal = load("res://UI/Assets/SeaBackground.png")
		elif options[0] == "sky":
			$Item1.texture_normal = load("res://UI/Assets/SkyBackground.png")
		elif options[0] == "corrupted":
			$Item1.texture_normal = load("res://UI/Assets/CorruptedBackground.png")
		%Label1.text = descriptions[options[0]]["name"]
		%Description1.text = descriptions[options[0]]["description"]
		%Shard1.texture = load(descriptions[options[0]]["image"])
	else:
		$Item1.texture_normal = load("res://UI/Assets/EmptyBackground.png")
		%Label1.text = "---"
		%Description1.text = ""
		%Shard1.hide()
	
	if !taken2 and !taken3:
		if items[1] == "land":
			$Item2.texture_normal = load("res://UI/Assets/LandBackground.png")
		elif options[1] == "sea":
			$Item2.texture_normal = load("res://UI/Assets/SeaBackground.png")
		elif options[1] == "sky":
			$Item2.texture_normal = load("res://UI/Assets/SkyBackground.png")
		elif options[1] == "corrupted":
			$Item2.texture_normal = load("res://UI/Assets/CorruptedBackground.png")
		if options[2] == "land":
			$Item3.texture_normal = load("res://UI/Assets/LandBackground.png")
		elif options[2] == "sea":
			$Item3.texture_normal = load("res://UI/Assets/SeaBackground.png")
		elif options[2] == "sky":
			$Item3.texture_normal = load("res://UI/Assets/SkyBackground.png")
		elif options[2] == "corrupted":
			$Item3.texture_normal = load("res://UI/Assets/CorruptedBackground.png")
		%Label2.text = descriptions[options[1]]["name"]
		%Description2.text = descriptions[options[1]]["description"]
		%Shard2.texture = load(descriptions[options[1]]["image"])
		%Label3.text = descriptions[options[2]]["name"]
		%Description3.text = descriptions[options[2]]["description"]
		%Shard3.texture = load(descriptions[options[2]]["image"])
	else:
		$Item2.texture_normal = load("res://UI/Assets/EmptyBackground.png")
		$Item3.texture_normal = load("res://UI/Assets/EmptyBackground.png")
		%Label2.text = "---"
		%Description2.text = ""
		%Shard2.hide()
		%Label3.text = "---"
		%Description3.text = ""
		%Shard3.hide()


func _on_x_pressed():
	$TargetThing.hide()
	%HighlighterAnim.play("Squiggle")

func _on_chibi_portrait_1_pressed():
	targeted = "mielle"
	$TargetThing.hide()
	target_menu_showing = false
	update_skills()
	$Skills.show()


func _on_chibi_portrait_2_pressed():
	targeted = "leon"
	$TargetThing.hide()
	target_menu_showing = false
	update_skills()
	$Skills.show()


func _on_chibi_portrait_3_pressed():
	targeted = "tear"
	$TargetThing.hide()
	target_menu_showing = false
	update_skills()
	$Skills.show()


func _on_chibi_portrait_4_pressed():
	targeted = "six"
	$TargetThing.hide()
	target_menu_showing = false
	update_skills()
	$Skills.show()


func show_target():
	$TargetThing.show()
	%HighlighterAnim.play("Squiggle")
	target_menu_showing = true

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


func _on_item_1_pressed():
	if !taken1:
		current_item = 0
		show_target()


func _on_item_2_pressed():
	if !taken2 and !taken3:
		current_item = 1
		show_target()


func _on_item_3_pressed():
	if !taken3 and !taken2:
		current_item = 2
		show_target()


func _on_item_1_mouse_entered():
	if !taken1 and menu_done:
		$BoxHighlighter.show()
		$BoxHighlighter.position = $Item1.position + Vector2(96,120)


func _on_item_1_mouse_exited():
	$BoxHighlighter.hide()


func _on_item_2_mouse_entered():
	if !taken2 and !taken3 and menu_done:
		$BoxHighlighter.show()
		$BoxHighlighter.position = $Item2.position + Vector2(96,120)


func _on_item_2_mouse_exited():
	$BoxHighlighter.hide()


func _on_item_3_mouse_entered():
	if !taken2 and !taken3 and menu_done:
		$BoxHighlighter.show()
		$BoxHighlighter.position = $Item3.position + Vector2(96,120)


func _on_item_3_mouse_exited():
	$BoxHighlighter.hide()


func _on_x_2_pressed():
	$Skills.hide()
	$TargetThing.show()


func update_skills():
	if Manager.current_stats[targeted]["skill 1"]["unlocked"]:
		%Skill1Name.text = Manager.char_descriptions[targeted]["skill 1"]["name"]
	else:
		%Skill1Name.text = "???"
	if !Manager.current_stats[targeted]["skill 1"]["unlocked"]:
		%Skill1.texture_normal = load("res://UI/Assets/SkillNull.png")
		%Skill1.texture_hover = load("res://UI/Assets/SkillNull.png")
	elif Manager.current_stats[targeted]["skill 1"]["modifier"] == "normal":
		%Skill1.texture_normal = load("res://UI/Assets/SkillBase.png")
		%Skill1.texture_hover = load("res://UI/Assets/SkillBaseHover.png")
	elif Manager.current_stats[targeted]["skill 1"]["modifier"] == "sea":
		%Skill1.texture_normal = load("res://UI/Assets/SkillSea.png")
		%Skill1.texture_hover = load("res://UI/Assets/SkillSeaHover.png")
	elif Manager.current_stats[targeted]["skill 1"]["modifier"] == "land":
		%Skill1.texture_normal = load("res://UI/Assets/SkillLand.png")
		%Skill1.texture_hover = load("res://UI/Assets/SkillLandHover.png")
	elif Manager.current_stats[targeted]["skill 1"]["modifier"] == "sky":
		%Skill1.texture_normal = load("res://UI/Assets/SkillSky.png")
		%Skill1.texture_hover = load("res://UI/Assets/SkillSkyHover.png")
		
	#skill 2
	if Manager.current_stats[targeted]["skill 2"]["unlocked"]:
		%Skill2Name.text = Manager.char_descriptions[targeted]["skill 2"]["name"]
	else:
		%Skill2Name.text = "???"
	
	if !Manager.current_stats[targeted]["skill 2"]["unlocked"]:
		%Skill2.texture_normal = load("res://UI/Assets/SkillNull.png")
		%Skill2.texture_hover = load("res://UI/Assets/SkillNull.png")
	elif Manager.current_stats[targeted]["skill 2"]["modifier"] == "normal":
		%Skill2.texture_normal = load("res://UI/Assets/SkillBase.png")
		%Skill2.texture_hover = load("res://UI/Assets/SkillBaseHover.png")
	elif Manager.current_stats[targeted]["skill 2"]["modifier"] == "sea":
		%Skill2.texture_normal = load("res://UI/Assets/SkillSea.png")
		%Skill2.texture_hover = load("res://UI/Assets/SkillSeaHover.png")
	elif Manager.current_stats[targeted]["skill 2"]["modifier"] == "land":
		%Skill2.texture_normal = load("res://UI/Assets/SkillLand.png")
		%Skill2.texture_hover = load("res://UI/Assets/SkillLandHover.png")
	elif Manager.current_stats[targeted]["skill 2"]["modifier"] == "sky":
		%Skill2.texture_normal = load("res://UI/Assets/SkillSky.png")
		%Skill2.texture_hover = load("res://UI/Assets/SkillSkyHover.png")
	
	#skill 3
	if Manager.current_stats[targeted]["skill 3"]["unlocked"]:
		%Skill3Name.text = Manager.char_descriptions[targeted]["skill 3"]["name"]
	else:
		%Skill3Name.text = "???"
		
	if !Manager.current_stats[targeted]["skill 3"]["unlocked"]:
		%Skill3.texture_normal = load("res://UI/Assets/SkillNull.png")
		%Skill3.texture_hover = load("res://UI/Assets/SkillNull.png")
	elif Manager.current_stats[targeted]["skill 3"]["modifier"] == "normal":
		%Skill3.texture_normal = load("res://UI/Assets/SkillBase.png")
		%Skill3.texture_hover = load("res://UI/Assets/SkillBaseHover.png")
	elif Manager.current_stats[targeted]["skill 3"]["modifier"] == "sea":
		%Skill3.texture_normal = load("res://UI/Assets/SkillSea.png")
		%Skill3.texture_hover = load("res://UI/Assets/SkillSeaHover.png")
	elif Manager.current_stats[targeted]["skill 3"]["modifier"] == "land":
		%Skill3.texture_normal = load("res://UI/Assets/SkillLand.png")
		%Skill3.texture_hover = load("res://UI/Assets/SkillLandHover.png")
	elif Manager.current_stats[targeted]["skill 3"]["modifier"] == "sky":
		%Skill3.texture_normal = load("res://UI/Assets/SkillSky.png")
		%Skill3.texture_hover = load("res://UI/Assets/SkillSkyHover.png")
	
	#skill 4
	if Manager.current_stats[targeted]["skill 4"]["unlocked"]:
		%Skill4Name.text = Manager.char_descriptions[targeted]["skill 4"]["name"]
	else:
		%Skill4Name.text = "???"
	
	if !Manager.current_stats[targeted]["skill 4"]["unlocked"]:
		%Skill4.texture_normal = load("res://UI/Assets/SkillNull.png")
		%Skill4.texture_hover = load("res://UI/Assets/SkillNull.png")
	elif Manager.current_stats[targeted]["skill 4"]["modifier"] == "normal":
		%Skill4.texture_normal = load("res://UI/Assets/SkillBase.png")
		%Skill4.texture_hover = load("res://UI/Assets/SkillBaseHover.png")
	elif Manager.current_stats[targeted]["skill 4"]["modifier"] == "sea":
		%Skill4.texture_normal = load("res://UI/Assets/SkillSea.png")
		%Skill4.texture_hover = load("res://UI/Assets/SkillSeaHover.png")
	elif Manager.current_stats[targeted]["skill 4"]["modifier"] == "land":
		%Skill4.texture_normal = load("res://UI/Assets/SkillLand.png")
		%Skill4.texture_hover = load("res://UI/Assets/SkillLandHover.png")
	elif Manager.current_stats[targeted]["skill 4"]["modifier"] == "sky":
		%Skill4.texture_normal = load("res://UI/Assets/SkillSky.png")
		%Skill4.texture_hover = load("res://UI/Assets/SkillSkyHover.png")
	elif Manager.current_stats[targeted]["skill 4"]["modifier"] == "corrupted":
		%Skill4.texture_normal = load("res://UI/Assets/SkillCorrupted.png")
		%Skill4.texture_hover = load("res://UI/Assets/SkillCorruptedHover.png")


func _on_skill_1_pressed():
	modify(1)


func _on_skill_2_pressed():
	modify(2)


func _on_skill_3_pressed():
	modify(3)


func _on_skill_4_pressed():
	modify(4)

func modify(skill):
	if Manager.current_stats[targeted]["skill " + str(skill)]["unlocked"]:
		if options[current_item] == "corrupted" and skill != 4:
			pass
		else:
			if current_item == 0 and !taken1:
				Manager.current_stats[targeted]["skill " + str(skill)]["modifier"] = options[current_item]
				taken1 = true
				update_skills()
				await get_tree().create_timer(1).timeout
			elif (current_item == 1 or current_item == 2) and (!taken2 or !taken3):
				Manager.current_stats[targeted]["skill " + str(skill)]["modifier"] = options[current_item]
				taken2 = true
				taken3 = true
				update_skills()
				await get_tree().create_timer(1).timeout
			update_items()
			if taken1 and taken2:
				$ColorRect.show()
				%HighlighterAnim.play("fade_out")
				await get_tree().create_timer(1).timeout
				get_tree().change_scene_to_file("res://options.tscn")
			else:
				$Skills.hide()
