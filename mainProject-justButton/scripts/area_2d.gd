extends Area2D
#Start DOcker ubuntu, to add toher terminal linked to that container:
#docker exec -it my_sandbox bash
#var command = "docker run -it --name my_sandbox ubuntu bash"
#3 righe sopra sostituite da:
var container_name = "my_sandbox"
var check_command = "docker ps -a -q -f name=" + container_name
var player_in_area = false
@onready var terminal_ui = preload("res://scenes/terminal_interface.tscn").instantiate()



func _ready() -> void:
	
	get_tree().get_root().call_deferred("add_child", terminal_ui)

func _on_body_entered(body: Node2D) -> void:
	player_in_area = true
	print("Premi E per startare")

func _on_body_exited(body: Node2D) -> void:
	player_in_area = false
	
	
func _input(event) -> void:
	if player_in_area and Input.is_action_pressed("Interact"):
		print("PREMUTO")
		terminal_ui.open_interface()
		#
		#var result = []
		#OS.execute("cmd.exe", ["/c", check_command], result, true)
		#if result.size() == 0:
		#	OS.execute("cmd.exe", ["/c", "start cmd.exe /k docker run -it --rm --name " + container_name + " ubuntu bash"])
		#else:
		#	OS.execute("cmd.exe", ["/c", "start cmd.exe /k docker exec -it " + container_name + " bash"])
			
#------------------------------------------
#Da chat forse giusto, guarda
# NPC script
#@onready var terminal_interface_scene = preload("res://terminal_interface.tscn")
#var terminal_interface : Control = null
#var player_in_area = false
#
#func _ready():
#    terminal_interface = terminal_interface_scene.instantiate()
#    get_tree().root.add_child(terminal_interface)
#    terminal_interface.visible = false
#
#func _on_body_entered(body):
#    if body.is_in_group("player"):
#        player_in_area = true
#        print("Premi E per aprire terminale")
#
#func _on_body_exited(body):
#    if body.is_in_group("player"):
#        player_in_area = false
#
#func _input(event):
#    if player_in_area and event.is_action_pressed("Interact"):
#        terminal_interface.visible = true
#        # optionally set focus to editor
#        terminal_interface.get_node("Grid/TopRightEditor").grab_focus()
#
			
