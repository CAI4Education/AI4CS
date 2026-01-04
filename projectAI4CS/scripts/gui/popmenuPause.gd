extends Control

@onready var popmenu: MarginContainer = $popmenu
@onready var pause_button: Button = $pauseIconButton/VBoxContainer/pauseButton
@onready var levelLabel: Label = $popmenu/baseMenu/VBoxContainer/baseMenuScreen/NinePatchRect/MarginContainer/displayLevel/levelDisplay

func _ready():
	# Il menu NON deve essere visibile all'avvio
	popmenu.visible = false

	if GameState.current_level != null:
		levelLabel.text = GameState.current_level
		

func _on_pause_button_pressed() -> void:
	# Toggle del menu
	popmenu.visible = !popmenu.visible

	levelLabel.text = "level: " + GameState.current_level


	# Metti in pausa il gioco
	#get_tree().paused = popmenu.visible
	
func _on_exit_button_pressed() -> void:
	popmenu.visible = !popmenu.visible
	#get_tree().paused = popmenu.visible


func _on_quit_game_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/guiStuff/StartGameInterface.tscn")
	
	
	
func _on_save_button_pressed() -> void:
	#salva posizoine personaggio
	var player = get_tree().get_first_node_in_group("player")
	if player:
		GameState.player_position = player.global_position
		
	
		
	GameState.save_game()
	print("Gioco salvatoooo")
