extends Control

func _ready() -> void:
	# appena entri regoli volume e screen settings che aveva utente salvato
	GameState.load_settings()

func _on_start_button_pressed() -> void:
	
	#recupera dati salvati
	GameState.load_game()
	
	# Controlla se è il primo stato (introduzione)
	if GameState.current_level == "0":
		print("Comic printed")
		await show_intro_bubble()
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


func show_intro_bubble() -> void:
	# Carica la scena del fumetto (può essere un Control o CanvasLayer)
	var intro_scene = preload("res://scenes/guiStuff/introComic.tscn").instantiate() as CanvasLayer 
	add_child(intro_scene)
	
	# Timer per rimuovere dopo 10 secondi
	await get_tree().create_timer(5.0).timeout
	
	intro_scene.queue_free()
