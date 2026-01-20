extends Control

func _on_start_button_pressed() -> void:
	
	#recupera dati salvati
	GameState.load_game()
	get_tree().change_scene_to_file("res://scenes/MainWorld.tscn")
	


func _on_new_game_pressed() -> void:
	#recupera dati salvati
	GameState.load_game()
	get_tree().change_scene_to_file("res://scenes/guiStuff/newgame.tscn")
