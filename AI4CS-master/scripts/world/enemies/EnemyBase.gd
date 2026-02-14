extends CharacterBody2D
class_name EnemyBase

@export var stats: Stats
@export var scene_id: String = ""

@onready var hurtbox: Hurtbox = $Hurtbox

var challenge_id := name


func _ready() -> void:

	# assegna scena se non presente
	if scene_id == "":
		scene_id = get_tree().current_scene.name
		
	var enemyUid := name

	if GameState.is_enemy_defeated(scene_id, enemyUid):
		queue_free()
		return

	GameState.load_game()

	stats = stats.duplicate()
	hurtbox.hurt.connect(take_hit.call_deferred)
	stats.no_health.connect(queue_free)


func take_hit(other_hitbox: Hitbox) -> void:
	stats.health -= other_hitbox.damage
	openHackGuiAndPause()


func openHackGuiAndPause():

	var player = get_tree().get_first_node_in_group("player")
	if player:
		GameState.player_position = player.global_position
		GameState.save_game()

	TempState.challenge_active = true
	TempState.pending_scene_id = scene_id
	TempState.pending_enemy_uid = name
	TempState.pending_challenge = name
	TempState.return_scene_path = get_tree().current_scene.scene_file_path

	queue_free()
	get_tree().change_scene_to_file("res://scenes/guiStuff/terminal_interface.tscn")
