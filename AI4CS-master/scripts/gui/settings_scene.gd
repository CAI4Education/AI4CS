extends Control

#il menu viene aperto da 2 bottoni diversi, utilizzando i signal puoi tornare alla scena precedente senza usare get_tree.change_scene_to_file()
signal closed

func _on_return_button_pressed() -> void:
	emit_signal("closed")
	queue_free()
