extends Area2D

var player_in_area = false
@onready var terminal_ui = preload("res://scenes/terminal_interface.tscn").instantiate()

#@onready var overlay_layer := get_tree().get_root().get_node("MainScene/OverlayLayer")

func _ready():
	terminal_ui.visible = false
	#overlay_layer.call_deferred("add_child", terminal_ui)

func _on_body_entered(body):
	player_in_area = true

func _on_body_exited(body):
	player_in_area = false

func _input(event):
	if player_in_area and Input.is_action_just_pressed("Interact"):
		_open_terminal()

func _open_terminal():
	terminal_ui.visible = true

	# disattiva la scena di gioco (ma NON la nasconde)
	get_tree().current_scene.process_mode = Node.PROCESS_MODE_DISABLED

	# opzionale: blocca input al gioco
	get_tree().set_input_as_handled()

	# focus esclusivo al terminale
	terminal_ui.grab_focus()
