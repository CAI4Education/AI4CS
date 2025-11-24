extends Control

@onready var editor_main = $Grid/TopRightEditor
@onready var terminal_button = $Grid/GridContainer/TerminalButton
@onready var editor_secondary = $Grid/GridContainer/SecondTerminal

var terminal1: TerminalSession
var terminal2: TerminalSession

func _ready():
	terminal1 = TerminalSession.new()
	terminal1.setup(editor_main)
	terminal1.connect_to("127.0.0.1", 5000)

	terminal2 = TerminalSession.new()
	terminal2.setup(editor_secondary)
	editor_secondary.visible = false
	terminal2.connect_to("127.0.0.1", 5000)

	set_process(true)

func _process(delta):
	terminal1.process(delta)
	terminal2.process(delta)

func _input(event):
	# Ignora subito tutto ciò che NON è un key event
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
