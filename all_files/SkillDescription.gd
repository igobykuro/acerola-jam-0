extends Control


@onready var label = $Label
@onready var background = $ColorRect
@onready var skill_label = $SkillRangeLabel
@onready var skill_background = $SkillRange

var start_x = 134

func _process(_delta):
	background.size.y = label.size.y + 18
	skill_background.size.x = skill_label.size.x + 10
	skill_background.position.x = start_x - 5
