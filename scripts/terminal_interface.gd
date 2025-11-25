extends Control

@onready var editor_main = $Grid/TopRightEditor
@onready var terminal_button = $Grid/GridContainer/TerminalButton
@onready var editor_secondary = $Grid/GridContainer/SecondTerminal

var terminal1: TerminalSession
var terminal2: TerminalSession

# Socket per ROOT
var root_socket := StreamPeerTCP.new()
var root_connected := false
var pending_challenge := ""

func _ready():
	# --- TERMINALE 1 ---
	terminal1 = TerminalSession.new()
	terminal1.setup(editor_main)
	terminal1.connect_to("127.0.0.1", 5000)

	# --- TERMINALE 2 ---
	terminal2 = TerminalSession.new()
	terminal2.setup(editor_secondary)
	editor_secondary.visible = false
	terminal2.connect_to("127.0.0.1", 5000)

	# --- CONNESSIONE ROOT ---
	_connect_root_bridge("challenge1")

	set_process(true)


func _process(delta):
	terminal1.process(delta)
	terminal2.process(delta)

	# Gestione della connessione ROOT
	if root_socket.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		if not root_connected:
			root_connected = true
			# Ora è sicuro inviare la challenge
			_send_challenge_start(pending_challenge)

	# Se root manda risposta, leggila (debug)
	if root_connected:
		var avail = root_socket.get_available_bytes()
		if avail > 0:
			var msg = root_socket.get_utf8_string(avail)
			print("[ROOT RESPONSE]: ", msg)


func _input(event):
	if not (event is InputEventKey):
		return

	# Terminale principale
	if editor_main.has_focus():
		var handled = await terminal1.handle_key(event)
		if handled:
			get_viewport().set_input_as_handled()

	# Terminale secondario
	if editor_secondary.visible and editor_secondary.has_focus():
		var handled = await terminal2.handle_key(event)
		if handled:
			get_viewport().set_input_as_handled()


func _on_terminal_button_pressed():
	terminal_button.visible = false
	editor_secondary.visible = true
	editor_secondary.grab_focus()


# --------------------------------------------------
# ROOT CONNECTION
# --------------------------------------------------

func _connect_root_bridge(challenge_name:String):
	pending_challenge = challenge_name
	root_socket = StreamPeerTCP.new()
	root_connected = false
	root_socket.connect_to_host("127.0.0.1", 6000)


func _send_challenge_start(challenge_string:String):
	if not root_connected:
		print("[ROOT] Not connected yet. Waiting…")
		return

	var msg := "START_CHALLENGE %s\n" % challenge_string
	root_socket.put_data(msg.to_utf8_buffer())
	print("[ROOT] Sent: ", msg)
