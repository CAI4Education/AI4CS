extends Control

@onready var levelLabel1: Label = $VBoxContainer/IIsave/NinePatchRect/HBoxContainer/levelDisplay1
@onready var levelLabel2: Label = $VBoxContainer/IIIsave/NinePatchRect/HBoxContainer/levelDisplay2
@onready var levelLabel3: Label = $VBoxContainer/IVsave/NinePatchRect2/HBoxContainer/levelDisplay3

var current_save_slot: int = 1

	
func _ready():
	updateLabels()

func updateLabels():
	# Slot 1
	var lvl1 = GameState.get_level_from_save(1)
	if lvl1 != null:
		levelLabel1.text = "Level: " + str(lvl1)
	else:
		levelLabel1.text = "Start a new world"
		
	# Slot 2
	var lvl2 = GameState.get_level_from_save(2)
	if lvl2 != null:
		levelLabel2.text = "Level: " + str(lvl2)
	else:
		levelLabel2.text = "Start a new world"
		
	# Slot 3
	var lvl3 = GameState.get_level_from_save(3)
	if lvl3 != null:
		levelLabel3.text = "Level: " + str(lvl3)
	else:
		levelLabel3.text = "Start a new world"
	
func _on_return_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/guiStuff/StartGameInterface.tscn")


#LOAD WORLD
func _on_loadgame_1_pressed() -> void:
	GameState.current_save_slot = 1
	#recupera dati salvati
	GameState.load_game()
	# Controlla se è il primo stato (introduzione)
	if GameState.current_level == "0":
		print("Comic printed")
		await show_intro_bubble()
	get_tree().change_scene_to_file("res://scenes/MainWorld.tscn")

func _on_loadgame_2_pressed() -> void:
	GameState.current_save_slot = 2
	#recupera dati salvati
	GameState.load_game()
	# Controlla se è il primo stato (introduzione)
	if GameState.current_level == "0":
		print("Comic printed")
		await show_intro_bubble()
	get_tree().change_scene_to_file("res://scenes/MainWorld.tscn")

func _on_loadgame_3_pressed() -> void:
	GameState.current_save_slot = 3
	#recupera dati salvati
	GameState.load_game()
	# Controlla se è il primo stato (introduzione)
	if GameState.current_level == "0":
		print("Comic printed")
		await show_intro_bubble()
	get_tree().change_scene_to_file("res://scenes/MainWorld.tscn")

#DELETE WORLD
func _on_cancel_ggame_1_pressed() -> void:
	GameState.delete_save_slot(1)
	updateLabels()


func _on_cancel_ggame_2_pressed() -> void:
	GameState.delete_save_slot(2)
	updateLabels()


func _on_cancel_ggame_3_pressed() -> void:
	GameState.delete_save_slot(3)
	updateLabels()

func show_intro_bubble() -> void:
	# Carica la scena del fumetto (può essere un Control o CanvasLayer)
	var intro_scene = preload("res://scenes/guiStuff/introComic.tscn").instantiate() as CanvasLayer 
	add_child(intro_scene)
	
	# Timer per rimuovere dopo 10 secondi
	await get_tree().create_timer(5.0).timeout
	
	
	intro_scene.queue_free()
