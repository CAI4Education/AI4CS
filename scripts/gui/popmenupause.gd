extends MarginContainer

@onready var popmenu: MarginContainer = $popmenu
@onready var pause_button: Button = $popmenu/baseMenu/HBoxContainer/VBoxContainer/pauseButton

func _ready():
	# Il menu NON deve essere visibile all'avvio
	popmenu.visible = false

	# Collega il bottone
	pause_button.pressed.connect(_on_pause_pressed)


func _on_pause_pressed() -> void:
	# Toggle del menu
	popmenu.visible = !popmenu.visible

	# (opzionale) Pausa il gioco
	get_tree().paused = popmenu.visible
