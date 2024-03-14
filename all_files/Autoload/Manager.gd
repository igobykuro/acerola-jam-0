extends Node


var save_file_path = "user://"
var save_file_name = "PlayerSave.tres"
var playerData = PlayerData.new()


signal enemy_attack(target,damage,vfx,times)
signal enemy_attack_aoe(targets,damage,vfx,amount_of_targets)
signal enemy_condition(target,condition,times)
signal enemy_heal(amount,times)
signal broadcast(dialogue)

func load_data():
	if (ResourceLoader.exists(save_file_path + save_file_name)):
		playerData = ResourceLoader.load(save_file_path + save_file_name).duplicate(true)
func save_data():
	ResourceSaver.save(playerData,save_file_path + save_file_name)

var current_party = ["mielle","leon","tear","six"]

var current_items = []

#1 - sea, 2 - land, 3 - sky, 4 - corrupted
var all_attack_buffs = [[["1","2","3"],["1","2","3"],["1","2","3"],["1","2","3","4"]],[["1","2","3"],["1","2","3"],["1","2","3"],["1","2","3","4"]],[["1","2","3"],["1","2","3"],["1","2","3"],["1","2","3","4"]],[["1","2","3"],["1","2","3"],["1","2","3"],["1","2","3","4"]]]

#0 - mielle, 1 - leon, 2 - tear, 3 - six

#4 items of [["1","2","3"],["1","2","3"],["1","2","3"],["1","2","3","4"]]
var available_attack_buffs = [[["1","2","3"],["1","2","3"],["1","2","3"],["1","2","3","4"]],[["1","2","3"],["1","2","3"],["1","2","3"],["1","2","3","4"]],[["1","2","3"],["1","2","3"],["1","2","3"],["1","2","3","4"]],[["1","2","3"],["1","2","3"],["1","2","3"],["1","2","3","4"]]]

#is this even needed
var boosts = {
	"support" : 1,
	"offense" : 1,
	"defense" : 1,
	"single" : 1,
	"multi" : 1,
	"switch" : 1
}

var current_boosts = {}

var assets = {
	"mielle" : {
		"sprite" : "res://Art/Group/Sprites/MielleSprite.png",
		"portrait" : "res://Art/Group/Portraits/MiellePortrait.png",
		"chibi" : "res://Art/Group/Chibis/MielleChibi.png"
	},
	"leon" : {
		"sprite" : "res://Art/Group/Sprites/LeonSprite.png",
		"portrait" : "res://Art/Group/Portraits/LeonPortrait.png",
		"chibi" : "res://Art/Group/Chibis/LeonChibi.png"
	},
	"tear" : {
		"sprite" : "res://Art/Group/Sprites/TearSprite.png",
		"portrait" : "res://Art/Group/Portraits/TearPortrait.png",
		"chibi" : "res://Art/Group/Chibis/TearChibi.png"
	},
	"six" : {
		"sprite" : "res://Art/Group/Sprites/SixSprite.png",
		"portrait" : "res://Art/Group/Portraits/SixPortrait.png",
		"chibi" : "res://Art/Group/Chibis/SixChibi.png"
	}
}

var char_descriptions = {
	"mielle" : {
		"first move" : "Change the stance of the opponent after using a skill",
		"skill 1" : {
			"tags" : ["offensive","single","close"],
			"name" : "Stab",
			"description" : {
				"normal" : {
					"lvl 1" : "Stabs the opponent, dealing 40% of attack as damage",
					"lvl 2" : "Stabs the opponent, dealing 55% of attack as damage",
					"lvl 3" : "Stabs the opponent, dealing 70% of attack as damage"
				},
				"sea" : {
					"lvl 1" : "Stabs the opponent, dealing 50% of attack as damage. A random ally gains +10% attack for their next move",
					"lvl 2" : "Stabs the opponent, dealing 75% of attack as damage. A random ally gains +20% attack for their next move",
					"lvl 3" : "Stabs the opponent, dealing 100% of attack as damage. A random ally gains +30% attack for their next move"
				},
				"land" : {
					"lvl 1" : "Stabs the opponent, dealing 40% of attack as damage. Heals the lowest HP ally for 60% of attack damage",
					"lvl 2" : "Stabs the opponent, dealing 55% of attack as damage. Heals the lowest HP ally for 80% of attack damage",
					"lvl 3" : "Stabs the opponent, dealing 70% of attack as damage. Heals the lowest HP ally for 100% of attack damage"
				},
				"sky" : {
					"lvl 1" : "Stabs the opponent, dealing 40% of attack as damage. Increase pass chance by 40%",
					"lvl 2" : "Stabs the opponent, dealing 55% of attack as damage. Increase pass chance by 50%",
					"lvl 3" : "Stabs the opponent, dealing 70% of attack as damage. Increase pass chance by 60%"
				}
			}
		},
		"skill 2" : {
			"tags" : ["defensive","support","any"],
			"name" : "Protect",
			"description" : {
				"normal" : {
					"lvl 1" : "Shield an ally and prevent them from taking damage for 1 turn",
					"lvl 2" : "Shield an ally and prevent them from taking damage for 1 turn. Pass rate +20%",
					"lvl 3" : "Shield an ally and prevent them from taking damage for 1 turn. Pass rate +40%"
				},
				"sea" : {
					"lvl 1" : "Shield an ally and prevent them from taking damage for 1 turn. That ally is granted +40% attack for their next move",
					"lvl 2" : "Shield an ally and prevent them from taking damage for 1 turn. Pass rate +20%. That ally is granted +55% attack for their next move",
					"lvl 3" : "Shield an ally and prevent them from taking damage for 1 turn. Pass rate +40%. That ally is granted +70% attack for their next move"
				},
				"land" : {
					"lvl 1" : "Shield an ally and prevent them from taking damage for 1 turn. Heals the ally for 20% of their max HP",
					"lvl 2" : "Shield an ally and prevent them from taking damage for 1 turn. Pass rate +20%. Heals the ally for 30% of their max HP",
					"lvl 3" : "Shield an ally and prevent them from taking damage for 1 turn. Pass rate +40%. Heals the ally for 40% of their max HP"
				},
				"sky" : {
					"lvl 1" : "Shield an ally and prevent them from taking damage for 1 turn. Change the target of the opponent’s attack to this ally",
					"lvl 2" : "Shield an ally and prevent them from taking damage for 1 turn. Pass rate +20%. Change the target of the opponent’s attack to this ally",
					"lvl 3" : "Shield an ally and prevent them from taking damage for 1 turn. Pass rate +40%. Change the target of the opponent’s attack to this ally. If the attack targets multiple allies, change it to only one."
				}
			}
		},
		"skill 3" : {
			"tags" : ["switch","far"],
			"name" : "Switch Strike",
			"description" : {
				"normal" : {
					"lvl 1" : "Throws her knife dealing 20% of attack as damage, then retrieves it and changes the opponent’s position",
					"lvl 2" : "Throws her knife dealing 30% of attack as damage, then retrieves it and changes the opponent’s position",
					"lvl 3" : "Throws her knife dealing 40% of attack as damage, then retrieves it and changes the opponent’s position"
				},
				"sea" : {
					"lvl 1" : "Throws her knife dealing 40% of attack as damage, then retrieves it and changes the opponent’s position. Grant +10% attack to all allies for their next move",
					"lvl 2" : "Throws her knife dealing 50% of attack as damage, then retrieves it and changes the opponent’s position. Grant +20% attack to all allies for their next move",
					"lvl 3" : "Throws her knife dealing 60% of attack as damage, then retrieves it and changes the opponent’s position. Grant +30% attack to all allies for their next move"
				},
				"land" : {
					"lvl 1" : "Throws her knife dealing 20% of attack as damage, then retrieves it and changes the opponent’s position. All allies heal 10% of their max HP",
					"lvl 2" : "Throws her knife dealing 30% of attack as damage, then retrieves it and changes the opponent’s position. All allies heal 15% of their max HP",
					"lvl 3" : "Throws her knife dealing 40% of attack as damage, then retrieves it and changes the opponent’s position. All allies heal 20% of their max HP"
				},
				"sky" : {
					"lvl 1" : "Throws her knife dealing 20% of attack as damage, then retrieves it and changes the opponent’s position. Increase pass chance by 40%",
					"lvl 2" : "Throws her knife dealing 30% of attack as damage, then retrieves it and changes the opponent’s position. Increase pass chance by 50%",
					"lvl 3" : "Throws her knife dealing 40% of attack as damage, then retrieves it and changes the opponent’s position. Increase pass chance by 60%"
				}
			}
		},
		"skill 4" : {
			"tags" : ["defensive","single","any"],
			"name" : "Counter",
			"description" : {
				"normal" : {
					"lvl 1" : "Goes into a defensive state. Take 20% of incoming damage. If the opponent attacks her this turn, she deals 200% of attack in retaliation",
					"lvl 2" : "Goes into a defensive state. Take 15% of incoming damage. If the opponent attacks her this turn, she deals 240% of attack in retaliation",
					"lvl 3" : "Goes into a defensive state. Take 10% of incoming damage. If the opponent attacks her this turn, she deals 300% of attack in retaliation"
				},
				"sea" : {
					"lvl 1" : "Goes into a defensive state. Take 20% of incoming damage. If the opponent attacks her this turn, she deals 300% of attack in retaliation",
					"lvl 2" : "Goes into a defensive state. Take 15% of incoming damage. If the opponent attacks her this turn, she deals 340% of attack in retaliation",
					"lvl 3" : "Goes into a defensive state. Take 10% of incoming damage. If the opponent attacks her this turn, she deals 400% of attack in retaliation"
				},
				"land" : {
					"lvl 1" : "Goes into a defensive state. Heal 30% of incoming damage. If the opponent attacks her this turn, she deals 200% of attack in retaliation",
					"lvl 2" : "Goes into a defensive state. Heal 45% of incoming damage. If the opponent attacks her this turn, she deals 240% of attack in retaliation",
					"lvl 3" : "Goes into a defensive state. Heal 60% of incoming damage. If the opponent attacks her this turn, she deals 300% of attack in retaliation"
				},
				"sky" : {
					"lvl 1" : "Goes into a defensive state. Take 20% of incoming damage. If the opponent attacks her this turn, she deals 200% of attack in retaliation. Change the target of the opponent’s attack to Mielle. Pass chance increases by 20%",
					"lvl 2" : "Goes into a defensive state. Take 15% of incoming damage. If the opponent attacks her this turn, she deals 240% of attack in retaliation. Change the target of the opponent’s attack to Mielle. Pass chance increases by 35%",
					"lvl 3" : "Goes into a defensive state. Take 10% of incoming damage. If the opponent attacks her this turn, she deals 300% of attack in retaliation. Change the target of the opponent’s attack to Mielle. Pass chance increases by 60%"
				},
				"corrupted" : {
					"lvl 1" : "Goes into a defensive state. Take 20% of incoming damage. If the opponent attacks her this turn, she deals 360% of attack in retaliation. Immediately take 50% of current HP as damage.",
					"lvl 2" : "Goes into a defensive state. Take 15% of incoming damage. If the opponent attacks her this turn, she deals 420% of attack in retaliation. Immediately take 50% of current HP as damage.",
					"lvl 3" : "Goes into a defensive state. Take 10% of incoming damage. If the opponent attacks her this turn, she deals 540% of attack in retaliation. Immediately take 50% of current HP as damage."
				}
			}
		}
	},
	"leon" : {
		"first move" : """Gain 2 extra vitality
		(When vitality is full: Deal a follow up attack)""",
		"skill 1" : {
			"tags" : ["offensive","multi","close"],
			"name" : "Flurry Strike",
			"description" : {
				"normal" : {
					"lvl 1" : "Hits the opponent 3 times, dealing 30% of attack as damage. Gain 3 vitality",
					"lvl 2" : "Hits the opponent 3 times, dealing 40% of attack as damage. Gain 3 vitality",
					"lvl 3" : "Hits the opponent 4 times, dealing 50% of attack as damage. Gain 4 vitality"
				},
				"sea" : {
					"lvl 1" : "Hits the opponent 3 times, dealing 45% of attack as damage. Gain 3 vitality.",
					"lvl 2" : "Hits the opponent 3 times, dealing 55% of attack as damage. Gain 3 vitality.",
					"lvl 3" : "Hits the opponent 4 times, dealing 70% of attack as damage. Gain 4 vitality."
				},
				"land" : {
					"lvl 1" : "Hits the opponent 3 times, dealing 30% of attack as damage. Gain 3 vitality. Heal the lowest HP ally for 10% of attack damage",
					"lvl 2" : "Hits the opponent 3 times, dealing 40% of attack as damage. Gain 3 vitality. Heal the lowest HP ally for 20% of attack damage",
					"lvl 3" : "Hits the opponent 4 times, dealing 50% of attack as damage. Gain 4 vitality. Heal the lowest HP ally for 30% of attack damage"
				},
				"sky" : {
					
					"lvl 1" : "Hits the opponent 3 times, dealing 30% of attack as damage. Gain 3 vitality. Increase the pass rate by 30%",
					"lvl 2" : "Hits the opponent 3 times, dealing 40% of attack as damage. Gain 4 vitality. Increase the pass rate by 40%",
					"lvl 3" : "Hits the opponent 4 times, dealing 50% of attack as damage. Gain 4 vitality. Increase the pass rate by 50%"
				}
			}
		},
		"skill 2" : {
			"tags" : ["offensive","multi","far"],
			"name" : "Dual Shot",
			"description" : {
				"normal" : {
					"lvl 1" : "Shoots the opponent twice, dealing 35% of attack as damage. Gain 2 vitality",
					"lvl 2" : "Shoots the opponent twice, dealing 45% of attack as damage. Gain 2 vitality",
					"lvl 3" : "Shoots the opponent twice, dealing 55% of attack as damage. Gain 3 vitality"
				},
				"sea" : {
					"lvl 1" : "Shoots the opponent three times, dealing 45% of attack as damage. Gain 2 vitality",
					"lvl 2" : "Shoots the opponent three times, dealing 55% of attack as damage. Gain 2 vitality",
					"lvl 3" : "Shoots the opponent three times, dealing 70% of attack as damage. Gain 3 vitality"
				},
				"land" : {
					"lvl 1" : "Shoots the opponent twice, dealing 35% of attack as damage. Gain 2 vitality. Heal the lowest HP ally for 20% of attack damage",
					"lvl 2" : "Shoots the opponent twice, dealing 45% of attack as damage. Gain 2 vitality. Heal the lowest HP ally for 30% of attack damage",
					"lvl 3" : "Shoots the opponent twice, dealing 55% of attack as damage. Gain 3 vitality. Heal the lowest HP ally for 40% of attack damage"
				},
				"sky" : {
					"lvl 1" : "Shoots the opponent twice, dealing 35% of attack as damage. Gain 3 vitality. Increase the pass rate by 30%",
					"lvl 2" : "Shoots the opponent twice, dealing 45% of attack as damage. Gain 3 vitality. Increase the pass rate by 40%",
					"lvl 3" : "Shoots the opponent twice, dealing 55% of attack as damage. Gain 4 vitality. Increase the pass rate by 50%"
				}
			}
		},
		"skill 3" : {
			"tags" : ["switch","close"],
			"name" : "Reverse Chain",
			"description" : {
				"normal" : {
					"lvl 1" : "Gain 2 vitality and switch the opponent position immediately",
					"lvl 2" : "Gain 3 vitality and switch the opponent position immediately",
					"lvl 3" : "Gain 4 vitality and switch the opponent position immediately"
				},
				"sea" : {
					"lvl 1" : "Gain 2 vitality and switch the opponent position immediately. Deal 50% of attack as damage",
					"lvl 2" : "Gain 3 vitality and switch the opponent position immediately. Deal 65% of attack as damage",
					"lvl 3" : "Gain 4 vitality and switch the opponent position immediately. Deal 80% of attack as damage"
				},
				"land" : {
					"lvl 1" : "Gain 2 vitality and switch the opponent position immediately. Heal the lowest HP ally by 10% of their max HP, then grant them +20% attack for their next turn",
					"lvl 2" : "Gain 3 vitality and switch the opponent position immediately. Heal the lowest HP ally by 20% of their max HP, then grant them +30% attack for their next turn",
					"lvl 3" : "Gain 4 vitality and switch the opponent position immediately. Heal the lowest HP ally by 30% of their max HP, then grant them +40% attack for their next turn"
				},
				"sky" : {
					"lvl 1" : "Gain 3 vitality and switch the opponent position immediately. Increase pass rate by 30%",
					"lvl 2" : "Gain 5 vitality and switch the opponent position immediately. Increase pass rate by 40%",
					"lvl 3" : "Gain 6 vitality and switch the opponent position immediately. Increase pass rate by 50%"
				}
			}
		},
		"skill 4" : {
			"tags" : ["offensive","single","close"],
			"name" : "Finality",
			"description" : {
				"normal" : {
					"lvl 1" : "Consume 3 vitality. Deal 300% of attack as damage",
					"lvl 2" : "Consume 3 vitality. Deal 350% of attack as damage",
					"lvl 3" : "Consume 3 vitality. Deal 400% of attack as damage"
				},
				"sea" : {
					"lvl 1" : "Consume 3 vitality. Deal 400% of attack as damage",
					"lvl 2" : "Consume 3 vitality. Deal 450% of attack as damage",
					"lvl 3" : "Consume 3 vitality. Deal 500% of attack as damage"
				},
				"land" : {
					"lvl 1" : "Consume 3 vitality. Deal 300% of attack as damage. Immediately heal Leon by 30% of his max HP",
					"lvl 2" : "Consume 3 vitality. Deal 350% of attack as damage. Immediately heal Leon by 50% of his max HP",
					"lvl 3" : "Consume 3 vitality. Deal 400% of attack as damage. Immediately heal Leon by 70% of his max HP"
				},
				"sky" : {
					"lvl 1" : "Consume 2 vitality. Deal 300% of attack as damage. Increase the pass rate by 50%",
					"lvl 2" : "Consume 2 vitality. Deal 350% of attack as damage. Increase the pass rate by 60%",
					"lvl 3" : "Consume 2 vitality. Deal 400% of attack as damage. Increase the pass rate by 70%"
				},
				"corrupted" : {
					"lvl 1" : "Consume all vitality (min 3). Lose 30% of current HP and deal 600% of attack as damage",
					"lvl 2" : "Consume all vitality (min 3). Lose 30% of current HP and deal 700% of attack as damage",
					"lvl 3" : "Consume all vitality (min 3). Lose 30% of current HP and deal 800% of attack as damage"
				}
			}
		}
	},
	"tear" : {
		"first move" : "Deals 200% damage on a move",
		"skill 1" : {
			"tags" : ["offensive","single","far"],
			"name" : "Aimed Shot",
			"description" : {
				"normal" : {
					"lvl 1" : "Shoots a single time, dealing 80% of attack with a +30% critical chance",
					"lvl 2" : "Shoots a single time, dealing 120% of attack with a +40% critical chance",
					"lvl 3" : "Shoots a single time, dealing 150% of attack with a +50% critical chance"
				},
				"sea" : {
					"lvl 1" : "Shoots a single time, dealing 100% of attack with a +30% critical chance. Increase crit damage by 100%",
					"lvl 2" : "Shoots a single time, dealing 130% of attack with a +40% critical chance. Increase crit damage by 170%",
					"lvl 3" : "Shoots a single time, dealing 160% of attack with a +50% critical chance. Increase crit damage by 240%"
				},
				"land" : {
					"lvl 1" : "Shoots a single time, dealing 80% of attack with a +30% critical chance. If the move crits, heal the lowest HP ally for 30% of attack damage",
					"lvl 2" : "Shoots a single time, dealing 120% of attack with a +40% critical chance. If the move crits, heal the lowest HP ally for 45% of attack damage",
					"lvl 3" : "Shoots a single time, dealing 150% of attack with a +50% critical chance. If the move crits, heal the lowest HP ally for 60% of attack damage"
				},
				"sky" : {
					"lvl 1" : "Shoots a single time, dealing 80% of attack with a +30% critical chance. Increase the pass rate by 50%",
					"lvl 2" : "Shoots a single time, dealing 120% of attack with a +40% critical chance. Increase the pass rate by 50%",
					"lvl 3" : "Shoots a single time, dealing 150% of attack with a +50% critical chance. Increase the pass rate by 70%"
				}
			}
		},
		"skill 2" : {
			"tags" : ["offensive","multi","far"],
			"name" : "Multishot",
			"description" : {
				"normal" : {
					"lvl 1" : "Shoots, dealing 35% of attack three times.",
					"lvl 2" : "Shoots, dealing 50% of attack three times.",
					"lvl 3" : "Shoots, dealing 65% of attack four times."
				},
				"sea" : {
					"lvl 1" : "Shoots, dealing 60% of attack three times.",
					"lvl 2" : "Shoots, dealing 75% of attack three times.",
					"lvl 3" : "Shoots, dealing 90% of attack four times."
				},
				"land" : {
					"lvl 1" : "Shoots, dealing 35% of attack three times. Heals the lowest HP ally for 15% of attack damage",
					"lvl 2" : "Shoots, dealing 50% of attack three times. Heals the lowest HP ally for 20% of attack damage",
					"lvl 3" : "Shoots, dealing 65% of attack four times. Heals the lowest HP ally for 30% of attack damage"
				},
				"sky" : {
					"lvl 1" : "Shoots, dealing 35% of attack three times. Increase pass rate by 50%",
					"lvl 2" : "Shoots, dealing 50% of attack three times. Increase pass rate by 60%",
					"lvl 3" : "Shoots, dealing 65% of attack four times. Increase pass rate by 70%"
				}
			}
		},
		"skill 3" : {
			"tags" : ["single","any"],
			"name" : "Trap",
			"description" : {
				"normal" : {
					"lvl 1" : "Plants a trap that triggers when the opponent switches positions and deals 120% of attack as damage",
					"lvl 2" : "Plants a trap that triggers when the opponent switches positions and deals 160% of attack as damage",
					"lvl 3" : "Plants a trap that triggers when the opponent switches positions and deals 200% of attack as damage"
				},
				"sea" : {
					"lvl 1" : "Plants a trap that triggers when the opponent switches positions and deals 180% of attack as damage",
					"lvl 2" : "Plants a trap that triggers when the opponent switches positions and deals 220% of attack as damage",
					"lvl 3" : "Plants a trap that triggers when the opponent switches positions and deals 260% of attack as damage"
				},
				"land" : {
					"lvl 1" : "Plants a trap that triggers when the opponent switches positions and deals 120% of attack as damage. Heal Tear by 15% of his max HP",
					"lvl 2" : "Plants a trap that triggers when the opponent switches positions and deals 160% of attack as damage. Heal Tear by 20% of his max HP",
					"lvl 3" : "Plants a trap that triggers when the opponent switches positions and deals 200% of attack as damage. Heal Tear by 30% of his max HP"
				},
				"sky" : {
					"lvl 1" : "Plants a trap that triggers when the opponent switches positions and deals 120% of attack as damage. Increase pass rate by 50%",
					"lvl 2" : "Plants a trap that triggers when the opponent switches positions and deals 160% of attack as damage. Increase pass rate by 60%",
					"lvl 3" : "Plants a trap that triggers when the opponent switches positions and deals 200% of attack as damage. Increase pass rate by 70%"
				}
			}
		},
		"skill 4" : {
			"tags" : ["support","any"],
			"name" : "Recalibration",
			"description" : {
				"normal" : {
					"lvl 1" : "Do nothing this turn. Multiply next turn’s damage by 220%",
					"lvl 2" : "Do nothing this turn. Multiply next turn’s damage by 320%",
					"lvl 3" : "Do nothing this turn. Multiply next turn’s damage by 420%"
				},
				"sea" : {
					"lvl 1" : "Do nothing this turn. Multiply next turn’s damage by 320%",
					"lvl 2" : "Do nothing this turn. Multiply next turn’s damage by 420%",
					"lvl 3" : "Do nothing this turn. Multiply next turn’s damage by 520%"
				},
				"land" : {
					"lvl 1" : "Do nothing this turn. Multiply next turn’s damage by 220%. Immediately heal Tear by 40% of his HP",
					"lvl 2" : "Do nothing this turn. Multiply next turn’s damage by 320%. Immediately heal Tear by 50% of his HP",
					"lvl 3" : "Do nothing this turn. Multiply next turn’s damage by 420%. Immediately heal Tear by 60% of his HP"
				},
				"sky" : {
					"lvl 1" : "Do nothing this turn. Multiply next turn’s damage by 220%. Gain a shield this turn. Increase pass rate by 30%",
					"lvl 2" : "Do nothing this turn. Multiply next turn’s damage by 320%. Gain a shield this turn. Increase pass rate by 40%",
					"lvl 3" : "Do nothing this turn. Multiply next turn’s damage by 420%. Gain a shield this turn. Increase pass rate by 50%"
				},
				"corrupted" : {
					"lvl 1" : "Do nothing this turn. Immediately lose 50% of current HP. Multiply next turn’s damage by 400%",
					"lvl 2" : "Do nothing this turn. Immediately lose 40% of current HP. Multiply next turn’s damage by 500%",
					"lvl 3" : "Do nothing this turn. Immediately lose 30% of current HP. Multiply next turn’s damage by 600%"
				}
			}
		}
	},
	"six" : {
		"first move" : "Boosts the next character’s attack by 30%",
		"skill 1" : {
			"tags" : ["support","any"],
			"name" : "Support",
			"description" : {
				"normal" : {
					"lvl 1" : "Heal an ally’s HP by 40% of Six’s attack, and increase their attack by 20% for their next move",
					"lvl 2" : "Heal an ally’s HP by 50% of Six’s attack, and increase their attack by 30% for their next move",
					"lvl 3" : "Heal an ally’s HP by 60% of Six’s attack, and increase their attack by 40% for their next move"
				},
				"sea" : {
					"lvl 1" : "Heal an ally’s HP by 40% of Six’s attack, and increase their attack by 40% for their next move",
					"lvl 2" : "Heal an ally’s HP by 50% of Six’s attack, and increase their attack by 50% for their next move",
					"lvl 3" : "Heal an ally’s HP by 60% of Six’s attack, and increase their attack by 60% for their next move"
				},
				"land" : {
					"lvl 1" : "Heal an ally’s HP by 80% of Six’s attack, and increase their attack by 20% for their next move",
					"lvl 2" : "Heal an ally’s HP by 90% of Six’s attack, and increase their attack by 30% for their next move",
					"lvl 3" : "Heal an ally’s HP by 100% of Six’s attack, and increase their attack by 40% for their next move"
				},
				"sky" : {
					"lvl 1" : "Heal an ally’s HP by 40% of Six’s attack, and increase their attack by 20% for their next move. Increase the pass rate of the next ally by 40%",
					"lvl 2" : "Heal an ally’s HP by 50% of Six’s attack, and increase their attack by 30% for their next move. Increase the pass rate of the next ally by 50%",
					"lvl 3" : "Heal an ally’s HP by 60% of Six’s attack, and increase their attack by 40% for their next move. Increase the pass rate of the next ally by 60%"
				}
			}
		},
		"skill 2" : {
			"tags" : ["single","offensive","close"],
			"name" : "Slash",
			"description" : {
				"normal" : {
					"lvl 1" : "Deals 40% of attack damage",
					"lvl 2" : "Deals 50% of attack damage",
					"lvl 3" : "Deals 60% of attack damage"
				},
				"sea" : {
					"lvl 1" : "Deals 60% of attack damage",
					"lvl 2" : "Deals 80% of attack damage",
					"lvl 3" : "Deals 100% of attack damage"
				},
				"land" : {
					"lvl 1" : "Deals 40% of attack damage. Heal Six by 60% of damage dealt",
					"lvl 2" : "Deals 50% of attack damage. Heal Six by 70% of damage dealt",
					"lvl 3" : "Deals 60% of attack damage. Heal Six by 80% of damage dealt"
				},
				"sky" : {
					"lvl 1" : "Deals 40% of attack damage. Increase the next ally’s pass rate by 60%",
					"lvl 2" : "Deals 50% of attack damage. Increase the next ally’s pass rate by 80%",
					"lvl 3" : "Deals 60% of attack damage. Increase the next ally’s pass rate by 100%"
				}
			}
		},
		"skill 3" : {
			"tags" : ["support","close"],
			"name" : "Target Intellect",
			"description" : {
				"normal" : {
					"lvl 1" : "Reveals who the opponent is targeting for the next turn",
					"lvl 2" : "Reveals who the opponent is targeting for the next two turns",
					"lvl 3" : "Reveals who the opponent is targeting for the next three turns"
				},
				"sea" : {
					"lvl 1" : "Deals 40% of attack as damage. Reveals who the opponent is targeting for the next turn",
					"lvl 2" : "Deals 50% of attack as damage. Reveals who the opponent is targeting for the next two turns",
					"lvl 3" : "Deals 60% of attack as damage. Reveals who the opponent is targeting for the next three turns"
				},
				"land" : {
					"lvl 1" : "Reveals who the opponent is targeting for the next turn. Heal the lowest HP character by 10% of their max HP",
					"lvl 2" : "Reveals who the opponent is targeting for the next two turns. Heal the lowest HP character by 20% of their max HP",
					"lvl 3" : "Reveals who the opponent is targeting for the next three turns. Heal the lowest HP character by 30% of their max HP"
				},
				"sky" : {
					"lvl 1" : "Reveals who the opponent is targeting for the next turn. Increase the next ally’s pass rate by 60%",
					"lvl 2" : "Reveals who the opponent is targeting for the next two turns. Increase the next ally’s pass rate by 80%",
					"lvl 3" : "Reveals who the opponent is targeting for the next three turns. Increase the next ally’s pass rate by 100%"
				}
			}
		},
		"skill 4" : {
			"tags" : ["support","any"],
			"name" : "Shapeshift",
			"description" : {
				"normal" : {
					"lvl 1" : "Transform into an ally. Six and that ally’s attack and stats will be combined. Trust lowers by 70%. Every consecutive move will decrease trust by 10% permanently for this battle, but attack by 120%",
					"lvl 2" : "Transform into an ally. Six and that ally’s attack and stats will be combined. Trust lowers by 60%. Every consecutive move will decrease trust by 10% permanently for this battle, but attack by 140%",
					"lvl 3" : "Transform into an ally. Six and that ally’s attack and stats will be combined. Trust lowers by 50%. Every consecutive move will decrease trust by 10% permanently for this battle, but attack by 160%"
				},
				"sea" : {
					"lvl 1" : "Transform into an ally. Six and that ally’s attack x140% stats will be combined. Trust lowers by 70%. Every consecutive move will decrease trust by 10% permanently for this battle, but attack by 120%",
					"lvl 2" : "Transform into an ally. Six and that ally’s attack x170% stats will be combined. Trust lowers by 60%. Every consecutive move will decrease trust by 10% permanently for this battle, but attack by 140%",
					"lvl 3" : "Transform into an ally. Six and that ally’s attack x200% stats will be combined. Trust lowers by 50%. Every consecutive move will decrease trust by 10% permanently for this battle, but attack by 160%"
				},
				"land" : {
					"lvl 1" : "Transform into an ally. Six and that ally’s attack and defense stats will be combined. Trust lowers by 70%. Every consecutive move will decrease trust by 10% permanently for this battle, but attack by 120%. Restore 10% of Six's max HP each attack",
					"lvl 2" : "Transform into an ally. Six and that ally’s attack and defense stats will be combined. Trust lowers by 60%. Every consecutive move will decrease trust by 10% permanently for this battle, but attack by 140%. Restore 20% of Six's max HP each attack",
					"lvl 3" : "Transform into an ally. Six and that ally’s attack and defense stats will be combined. Trust lowers by 50%. Every consecutive move will decrease trust by 10% permanently for this battle, but attack by 160%. Restore 30% of Six's max HP each attack"
				},
				"sky" : {
					"lvl 1" : "Transform into an ally. Six and that ally’s attack stats will be combined. Trust lowers by 20%. Every consecutive move will increase attack by 120%",
					"lvl 2" : "Transform into an ally. Six and that ally’s attack stats will be combined. Trust lowers by 10%. Every consecutive move will increase attack by 140%",
					"lvl 3" : "Transform into an ally. Six and that ally’s attack stats will be combined. Every consecutive move will increase attack by 160%"
				},
				"corrupted" : {
					"lvl 1" : "Transform into an ally. Six and all allies' attack stats will be combined. Trust lowers by 70%. Every consecutive move will decrease trust by 10% permanently for this battle, but attack by 120%. Lose 60% of current HP",
					"lvl 2" : "Transform into an ally. Six and all allies' attack stats will be combined. Trust lowers by 60%. Every consecutive move will decrease trust by 10% permanently for this battle, but attack by 140%. Lose 60% of current HP",
					"lvl 3" : "Transform into an ally. Six and all allies' attack stats will be combined. Trust lowers by 50%. Every consecutive move will decrease trust by 10% permanently for this battle, but attack by 160%. Lose 60% of current HP"
				}
			}
		}
	}
}

#Manager.char_descriptions[active_character]["skill 1"]["description"][Manager.current_stats[active_character]["skill 1"]["modifier"]]["lvl " + str(Manager.current_stats[active_character]["skill 1"]["level"])]
#Manager.current_stats[active_character]["skill 1"]["modifier"]
#"lvl " + str(Manager.current_stats[active_character]["skill 1"]["level"])
#Manager.current_stats[active_character]["skill 1"]["unlocked"]

var char_base_stats = {
	"life_points" : 4,
	"alive" : 4,
	"day" : 1,
	"money" : 0,
	"close_dmg_boost" : 1, #yes
	"close_pass_boost" : 0, #yes
	"far_dmg_boost" : 1, #yes
	"far_pass_boost" : 0, #yes
	"atk_boost" : 0, #yes. General. Etc. Six's next character gets 1.3x attack thing
	"def_boost" : 0, #yes Also general
	"trust_boost" : 0, #yes
	"healing_boost" : 1,
	"enemy_def_down" : 1, #yes
	"enemy_hp_down" : 1, #yes
	"money_gain" : 1,
	"bonus_money" : 0,
	"exp_gain" : 1,
	"pass_boost" : 0, #yes. Works like atk_boost and def_boost (addition)
	"close_crit" : 0,
	"close_crit_dmg" : 0,
	"far_crit" : 0,
	"far_crit_dmg" : 0,
	"mielle" : {
		"max_hp" : 2120,
		"current_hp" : 2120,
		"atk" : 506,
		"def" : 418,
		"trust" : 30,
		"dodge" : 0,
		"crit" : 5,
		"crit dmg" : 1.5,
		"level" : 1,
		"exp" : 0,
		"exp_needed" : 100,
		"shield" : false,
		"counter" : false,
		"skill 1" : {
			"modifier" : "normal",
			"level" : 1,
			"unlocked" : true
		},
		"skill 2" : {
			"modifier" : "normal",
			"level" : 1,
			"unlocked" : true
		},
		"skill 3" : {
			"modifier" : "normal",
			"level" : 1,
			"unlocked" : false
		},
		"skill 4" : {
			"modifier" : "normal",
			"level" : 1,
			"unlocked" : false
		},
		"next trust" : 0,
		"next atk" : 0,
		"temp next trust" : 0,
		"temp next atk" : 0,
	},
	"leon" : {
		"max_hp" : 1892,
		"current_hp" : 1892,
		"atk" : 615,
		"def" : 356,
		"trust" : 20,
		"dodge" : 10,
		"crit" : 5,
		"crit dmg" : 1.5,
		"level" : 1,
		"exp" : 0,
		"exp_needed" : 100,
		"shield" : false,
		"vitality" : 0,
		"skill 1" : {
			"modifier" : "normal",
			"level" : 1,
			"unlocked" : true
		},
		"skill 2" : {
			"modifier" : "normal",
			"level" : 1,
			"unlocked" : true
		},
		"skill 3" : {
			"modifier" : "normal",
			"level" : 1,
			"unlocked" : false
		},
		"skill 4" : {
			"modifier" : "normal",
			"level" : 1,
			"unlocked" : false
		},
		"next trust" : 0,
		"next atk" : 0,
		"temp next trust" : 0,
		"temp next atk" : 0
	},
	"tear" : {
		"max_hp" : 1520,
		"current_hp" : 1520,
		"atk" : 623,
		"def" : 328,
		"trust" : 5,
		"level" : 1,
		"dodge" : 2,
		"crit" : 5,
		"crit dmg" : 1.5,
		"exp" : 0,
		"exp_needed" : 100,
		"shield" : false,
		"recalibration" : false,
		"recalibration_dmg" : 1,
		"once_dodge" : false,
		"skill 1" : {
			"modifier" : "normal",
			"level" : 1,
			"unlocked" : true
		},
		"skill 2" : {
			"modifier" : "normal",
			"level" : 1,
			"unlocked" : true
		},
		"skill 3" : {
			"modifier" : "normal",
			"level" : 1,
			"unlocked" : false
		},
		"skill 4" : {
			"modifier" : "normal",
			"level" : 1,
			"unlocked" : false
		},
		"next trust" : 0,
		"next atk" : 0,
		"temp next trust" : 0,
		"temp next atk" : 0
	},
	"six" : {
		"max_hp" : 1651,
		"current_hp" : 1651,
		"atk" : 488,
		"def" : 427,
		"trust" : 60,
		"trust_loss" : 0,
		"level" : 1,
		"dodge" : 5,
		"crit" : 5,
		"crit dmg" : 1.5,
		"exp" : 0,
		"exp_needed" : 100,
		"shield" : false,
		"shapeshifted" : false,
		"shapeshifted_char" : "mielle",
		"shapeshifted_heal" : 0,
		"shapeshifted_atk" : 0,
		#"shapeshifted_def" : 0,
		"shapeshifted_atk_boost" : 1,
		"continuous_atk_boost" : 0,
		"skill 1" : {
			"modifier" : "normal",
			"level" : 1,
			"unlocked" : true
		},
		"skill 2" : {
			"modifier" : "normal",
			"level" : 1,
			"unlocked" : true
		},
		"skill 3" : {
			"modifier" : "normal",
			"level" : 1,
			"unlocked" : false
		},
		"skill 4" : {
			"modifier" : "normal",
			"level" : 1,
			"unlocked" : false
		},
		"next trust" : 0,
		"next atk" : 0,
		"temp next trust" : 0,
		"temp next atk" : 0,
	}
}

var current_stats = {}

func _ready():
	load_data()
	reset()

func add_trust(value):
	playerData.trust += value
	save_data()

func reset():
	current_stats = {
		"life_points" : 4,
	"alive" : 4,
	"day" : 1,
	"money" : 0,
	"close_dmg_boost" : 1, #yes
	"close_pass_boost" : 0, #yes
	"far_dmg_boost" : 1, #yes
	"far_pass_boost" : 0, #yes
	"atk_boost" : 0, #yes. General. Etc. Six's next character gets 1.3x attack thing
	"def_boost" : 0, #yes Also general
	"trust_boost" : 0, #yes
	"healing_boost" : 1,
	"enemy_def_down" : 1, #yes
	"enemy_hp_down" : 1, #yes
	"money_gain" : 1,
	"bonus_money" : 0,
	"exp_gain" : 1,
	"pass_boost" : 0, #yes. Works like atk_boost and def_boost (addition)
	"close_crit" : 0,
	"close_crit_dmg" : 0,
	"far_crit" : 0,
	"far_crit_dmg" : 0,
	"mielle" : {
		"max_hp" : 2120,
		"current_hp" : 2120,
		"atk" : 506,
		"def" : 418,
		"trust" : 30,
		"dodge" : 0,
		"crit" : 5,
		"crit dmg" : 1.5,
		"level" : 1,
		"exp" : 0,
		"exp_needed" : 100,
		"shield" : false,
		"counter" : false,
		"skill 1" : {
			"modifier" : "normal",
			"level" : 1,
			"unlocked" : true
		},
		"skill 2" : {
			"modifier" : "normal",
			"level" : 1,
			"unlocked" : true
		},
		"skill 3" : {
			"modifier" : "normal",
			"level" : 1,
			"unlocked" : false
		},
		"skill 4" : {
			"modifier" : "normal",
			"level" : 1,
			"unlocked" : false
		},
		"next trust" : 0,
		"next atk" : 0,
		"temp next trust" : 0,
		"temp next atk" : 0,
	},
	"leon" : {
		"max_hp" : 1892,
		"current_hp" : 1892,
		"atk" : 615,
		"def" : 356,
		"trust" : 20,
		"dodge" : 10,
		"crit" : 5,
		"crit dmg" : 1.5,
		"level" : 1,
		"exp" : 0,
		"exp_needed" : 100,
		"shield" : false,
		"vitality" : 0,
		"skill 1" : {
			"modifier" : "normal",
			"level" : 1,
			"unlocked" : true
		},
		"skill 2" : {
			"modifier" : "normal",
			"level" : 1,
			"unlocked" : true
		},
		"skill 3" : {
			"modifier" : "normal",
			"level" : 1,
			"unlocked" : false
		},
		"skill 4" : {
			"modifier" : "normal",
			"level" : 1,
			"unlocked" : false
		},
		"next trust" : 0,
		"next atk" : 0,
		"temp next trust" : 0,
		"temp next atk" : 0
	},
	"tear" : {
		"max_hp" : 1520,
		"current_hp" : 1520,
		"atk" : 623,
		"def" : 328,
		"trust" : 5,
		"level" : 1,
		"dodge" : 2,
		"crit" : 5,
		"crit dmg" : 1.5,
		"exp" : 0,
		"exp_needed" : 100,
		"shield" : false,
		"recalibration" : false,
		"recalibration_dmg" : 1,
		"once_dodge" : false,
		"skill 1" : {
			"modifier" : "normal",
			"level" : 1,
			"unlocked" : true
		},
		"skill 2" : {
			"modifier" : "normal",
			"level" : 1,
			"unlocked" : true
		},
		"skill 3" : {
			"modifier" : "normal",
			"level" : 1,
			"unlocked" : false
		},
		"skill 4" : {
			"modifier" : "normal",
			"level" : 1,
			"unlocked" : false
		},
		"next trust" : 0,
		"next atk" : 0,
		"temp next trust" : 0,
		"temp next atk" : 0
	},
	"six" : {
		"max_hp" : 1651,
		"current_hp" : 1651,
		"atk" : 488,
		"def" : 427,
		"trust" : 60,
		"trust_loss" : 0,
		"level" : 1,
		"dodge" : 5,
		"crit" : 5,
		"crit dmg" : 1.5,
		"exp" : 0,
		"exp_needed" : 100,
		"shield" : false,
		"shapeshifted" : false,
		"shapeshifted_char" : "mielle",
		"shapeshifted_heal" : 0,
		"shapeshifted_atk" : 0,
		#"shapeshifted_def" : 0,
		"shapeshifted_atk_boost" : 1,
		"continuous_atk_boost" : 0,
		"skill 1" : {
			"modifier" : "normal",
			"level" : 1,
			"unlocked" : true
		},
		"skill 2" : {
			"modifier" : "normal",
			"level" : 1,
			"unlocked" : true
		},
		"skill 3" : {
			"modifier" : "normal",
			"level" : 1,
			"unlocked" : false
		},
		"skill 4" : {
			"modifier" : "normal",
			"level" : 1,
			"unlocked" : false
		},
		"next trust" : 0,
		"next atk" : 0,
		"temp next trust" : 0,
		"temp next atk" : 0,
	}
}
	
	current_stats["mielle"]["trust"] += playerData.trust
	current_stats["leon"]["trust"] += playerData.trust
	current_stats["tear"]["trust"] += playerData.trust
	current_stats["six"]["trust"] += playerData.trust
	current_boosts = boosts
	current_items = []
	available_attack_buffs = all_attack_buffs
