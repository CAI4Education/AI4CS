extends Node

var player_position: Vector2
var current_level: String = "0"

# scene_id -> { enemy_uid : true }
var defeated_enemies: Dictionary = {}

var current_save_slot: int = 1

func get_save_path() -> String:
	return "user://savegame_%d.save" % current_save_slot


func save_game():
	var data := {
		"player_position": {
			"x": player_position.x,
			"y": player_position.y
		},
		"current_level": current_level,
		"defeated_enemies": defeated_enemies,
		"current_save_slot": current_save_slot
	}

	var file := FileAccess.open(get_save_path(), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()

func reset_data():
	player_position = Vector2.ZERO
	current_level = "0"
	defeated_enemies = {}
	# Non resettiamo current_save_slot qui perché così so quale file caricare

func load_game():
	#prima resetto
	reset_data()
	
	print("PRESO FILE: " + str(current_save_slot))
	var path := get_save_path()
	if not FileAccess.file_exists(path):
		return

	var file := FileAccess.open(path, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()

	player_position = Vector2(
		data["player_position"]["x"],
		data["player_position"]["y"]
	)

	current_level = data["current_level"]
	defeated_enemies = data["defeated_enemies"]
	current_save_slot = data["current_save_slot"]


# ===============================
# NEMICI
# ===============================

func is_enemy_defeated(scene_id: String, enemy_uid: String) -> bool:
	return defeated_enemies.has(scene_id) \
		and defeated_enemies[scene_id].has(enemy_uid)


func mark_enemy_defeated(scene_id: String, enemy_uid: String):
	if not defeated_enemies.has(scene_id):
		defeated_enemies[scene_id] = {}

	defeated_enemies[scene_id][enemy_uid] = true
	print(defeated_enemies)
	
	
#per newgame.gd (selezione mondi) così visualizzi livello 
func get_level_from_save(slot_number: int):
	var path = "user://savegame_%d.save" % slot_number
	if not FileAccess.file_exists(path):
		return null # Restituisce null se il file non esiste
	
	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	var data = JSON.parse_string(content)
	if data and data.has("current_level"):
		return data["current_level"]
	
	return null

# In GameState.gd

func delete_save_slot(slot_number: int):
	var path = "user://savegame_%d.save" % slot_number
	if FileAccess.file_exists(path):
		var dir = DirAccess.open("user://")
		dir.remove(path)
		print("Salvataggio slot %d eliminato." % slot_number)
	else:
		print("Impossibile eliminare: il file non esiste.")
