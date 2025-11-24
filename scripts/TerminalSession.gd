extends RefCounted

class_name TerminalSession

var editor: TextEdit
var socket := StreamPeerTCP.new()
var connected := false
var input_buffer := ""
var last_prompt := ""

func setup(editor_node: TextEdit):
	editor = editor_node
	editor.editable = false
	editor.text = ""
	editor.grab_focus()

func connect_to(host: String, port: int):
	socket.connect_to_host(host, port)

func process(delta):
	socket.poll()

	if not connected and socket.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		connected = true
		socket.set_no_delay(true)
		editor.text += ">>> Connected to SSH bridge\n"
		_scroll()

	if connected:
		var avail = socket.get_available_bytes()
		if avail > 0:
			var raw = socket.get_utf8_string(avail)
			var cleaned = _strip_ansi(raw)
			
			var rx := RegEx.new()
			rx.compile("([a-zA-Z0-9_]+@[a-zA-Z0-9_\\-]+:.*[#\\$]) *$")
			var m = rx.search(cleaned)
			if m:
				last_prompt = m.get_string(0)

			editor.text += "\n" + cleaned
			_scroll()

func handle_key(event: InputEventKey):
	if not connected: return

	# ENTER
	if event.keycode == KEY_ENTER and event.pressed:
		socket.put_utf8_string("\n")
		input_buffer = ""
		await Engine.get_main_loop().process_frame
		_scroll()
		return true

	# BACKSPACE
	if event.keycode == KEY_BACKSPACE and event.pressed:
		if input_buffer.length() > 0:
			input_buffer = input_buffer.substr(0, input_buffer.length() - 1)
			editor.text = editor.text.substr(0, editor.text.length() - 1)

		socket.put_data(PackedByteArray([0x7F]))
		await Engine.get_main_loop().process_frame
		_scroll()
		return true

	# CHARACTERS
	if event.unicode >= 32 and event.unicode < 127 and event.pressed:
		var ch := char(event.unicode)
		input_buffer += ch
		editor.text += ch
		socket.put_utf8_string(ch)

		await Engine.get_main_loop().process_frame
		_scroll()
		return true

	return false

func _scroll():
	editor.scroll_vertical = editor.get_line_count()

func _strip_ansi(t:String) -> String:
	var rx = RegEx.new()
	rx.compile("\\x1B(?:[@-Z\\\\-_]|\\[[0-?]*[ -/]*[@-~])")
	return rx.sub(t, "", true)
