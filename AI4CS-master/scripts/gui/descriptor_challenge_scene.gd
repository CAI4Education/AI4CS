extends Control

@onready var description_label: TextEdit = $NinePatchRect/VBoxContainer/MarginContainer/TextEdit
var challenge_name := ""



func open(challenge: String):
	challenge_name = challenge
	_load_text()
	visible = true
	
	
func _load_text():
	print(challenge_name)
	var path := "res://assets/challengesDescription/%s.txt" % challenge_name
	if not FileAccess.file_exists(path):
		description_label.text = "Description not found."
		return

	var file := FileAccess.open(path, FileAccess.READ)
	description_label.text = file.get_as_text()


func _on_return_button_pressed() -> void:
	visible = false
