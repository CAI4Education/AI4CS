extends CheckButton

func _ready():
	button_pressed = GameState.fullscreen_enabled

func _on_toggled(toggled_on: bool) -> void:
	GameState.fullscreen_enabled = toggled_on

	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN
		if toggled_on
		else DisplayServer.WINDOW_MODE_WINDOWED
	)

	GameState.save_settings()
