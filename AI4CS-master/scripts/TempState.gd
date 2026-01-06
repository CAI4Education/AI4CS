extends Node
#script per salvare temporaneamente dati da passare per una scena all'altra senza usare: 	var challenge = preload("res://scenes/guiStuff/terminal_interface.tscn").instantiate()--challenge.scene_id = scene_id


var challenge_active := false
var pending_scene_id: String = ""
var pending_enemy_uid: String = ""
#la challenge che ha il nome del nemico
var pending_challenge: String = ""
# per tornare alla scena corretta
var return_scene_path: String = ""
