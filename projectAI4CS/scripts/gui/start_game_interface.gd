extends Control

func _ready() -> void:
	# appena entri regoli volume e screen settings che aveva utente salvato
	GameState.load_settings()

func _on_start_button_pressed() -> void:
	
	#recupera dati salvati
	GameState.load_game()
	get_tree().change_scene_to_file("res://scenes/MainWorld.tscn")
	


func _on_new_game_pressed() -> void:
	#recupera dati salvati
	GameState.load_game()
	get_tree().change_scene_to_file("res://scenes/guiStuff/newgame.tscn")


func _on_help_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/guiStuff/helpScene.tscn")


func _on_settings_button_pressed() -> void:
	#signal (guarda script settings)
	var settings = preload("res://scenes/guiStuff/settingsScene.tscn").instantiate()
	add_child(settings)
	settings.connect("closed", Callable(self, "_on_settings_closed"))
