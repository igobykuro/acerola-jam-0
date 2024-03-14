extends AnimationPlayer

func _ready():
	$ColorRect.show()

func fade_in():
	self.play("fade_in")
	await get_tree().create_timer(0.2).timeout
	$ColorRect.hide()

func fade_out():
	self.play("fade_out")
	$ColorRect.show()
