extends Control

const CHAR_READ_RATE = 0.5

@onready var label = $Dialogue
@onready var background = $DialoguePanel

enum State {
	READY,
	READING,
	FINISHED
}
var current_state = State.READY
var text_queue = []

var dialogue_showing = false

var dialogue_finished = true

func _ready():
	hide_textbox()

func _process(_delta):
	if text_queue.is_empty() and !dialogue_showing:
		dialogue_finished = true
	else:
		dialogue_finished = false
	match current_state:
		State.READY:
			if !text_queue.is_empty():
				display_text()
		State.READING:
			if Input.is_action_just_pressed("skip"):
				label.visible_characters = -1
				change_state(State.FINISHED)
		State.FINISHED:
			if Input.is_action_just_pressed("skip"):
				change_state(State.READY)
				if text_queue.is_empty():
					hide_textbox()


func queue_text(next_text):
	text_queue.push_back(next_text)

func hide_textbox():
	dialogue_showing = false
	background.hide()
	label.hide()
	$DialogueButton.hide()
	
func show_textbox():
	dialogue_showing = true
	background.show()
	label.show()
	$DialogueButton.show()

func display_text():
	var next_text = text_queue.pop_front()
	label.text = next_text
	change_state(State.READING)
	show_textbox()
	label.visible_characters = 0
	while label.visible_characters <= len(next_text):
		if label.visible_characters == -1:
			break
		label.visible_characters += 1
		await get_tree().create_timer(0.01).timeout
	if label.visible_characters == -1:
		current_state = State.FINISHED

func change_state(next_state):
	current_state = next_state


func _on_texture_button_pressed():
	match current_state:
		State.READY:
			pass
		State.READING:
			label.visible_characters = -1
			change_state(State.FINISHED)
		State.FINISHED:
			change_state(State.READY)
			if text_queue.is_empty():
				hide_textbox()
