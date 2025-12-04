extends RefCounted
class_name TerminalSession

# ====== CONFIG ======
# Se il tuo bridge Python usa length-prefixed messages (4 byte little-endian),
# imposta use_length_prefix = true. Altrimenti false.
var use_length_prefix: bool = false

# Prompt visivo (puoi cambiarlo a runtime)
var prompt: String = "$ "

# Terminal dimensions (non obbligatorio, ma utile se vuoi inviare al server)
var term_width: int = 80
var term_height: int = 24
var term_type: String = "vt100"
# ====================

# UI
var editor: TextEdit = null

# Socket
var socket: StreamPeerTCP = StreamPeerTCP.new()
var connected: bool = false

# Output (append-only) e rendering
var output_text: String = ""    # tutto l'output già "committato"
var input_buffer: String = ""   # ciò che l'utente sta digitando (ancora non inviato)
var cursor_pos: int = 0         # posizione del cursore dentro input_buffer (0..len)
var history: Array = []         # storicizzazione delle righe inviate
var history_index: int = -1     # -1 = no history selection

# Se using length prefix
var recv_buffer: PackedByteArray = PackedByteArray()

# utile per evitare ricostruzioni inutili
var last_rendered_text: String = ""

# --------------------
func setup(editor_node: TextEdit) -> void:
	"""
	Passa il TextEdit che useremo come schermo del terminale.
	Assicurati che l'editor sia `editable = false` nel Inspector o qui.
	"""
	editor = editor_node
	editor.editable = false
	output_text = ""
	input_buffer = ""
	cursor_pos = 0
	history.clear()
	history_index = -1
	_render()  # inizializza visuale


func connect_to(host: String, port: int) -> void:
	socket = StreamPeerTCP.new()
	connected = false
	socket.connect_to_host(host, port)


func _disconnect():
	# chiudi socket in modo pulito
	if socket:
		socket.close()
	connected = false


func process(delta: float) -> void:
	# deve essere chiamato da _process(delta) del nodo che usa questa sessione
	if socket:
		socket.poll()

		# rileva connessione (solo setta flag e mostra messaggio)
		if not connected and socket.get_status() == StreamPeerTCP.STATUS_CONNECTED:
			connected = true
			_append_output_line("[terminal] Connected to remote\n")
			_render()

		# leggi dati in arrivo
		if connected:
			_read_from_socket_and_append()


# --------------------
# Lettura socket
func _read_from_socket_and_append() -> void:
	# Quick path (no length prefix)
	if not use_length_prefix:
		var avail := socket.get_available_bytes()
		if avail > 0:
			var res = socket.get_data(avail)
			var err = res[0]
			var bytes: PackedByteArray = res[1]
			if err == OK and bytes.size() > 0:
				var text : String = bytes.get_string_from_utf8()
				_append_output(text)
				_render()
		return

	# Length-prefix path (4-byte little-endian)
	# accumulate and parse messages
	var avail2 := socket.get_available_bytes()
	if avail2 <= 0:
		return
	var res2 = socket.get_data(avail2)
	var err2 = res2[0]
	var bytes2: PackedByteArray = res2[1]
	if err2 == OK and bytes2.size() > 0:
		# append to recv_buffer
		recv_buffer.append_array(bytes2)

		# parse loop
		while recv_buffer.size() >= 4:
			# read 4-byte little-endian length
			var b0 = recv_buffer[0]
			var b1 = recv_buffer[1]
			var b2 = recv_buffer[2]
			var b3 = recv_buffer[3]
			var msg_len = int(b0) | (int(b1) << 8) | (int(b2) << 16) | (int(b3) << 24)

			# sanity
			if msg_len < 0 or msg_len > 20000000:
				# corrupted length: flush buffer as text and break
				var dump = recv_buffer.get_string_from_utf8()
				_append_output(dump)
				recv_buffer = PackedByteArray()
				_render()
				break

			if recv_buffer.size() < 4 + msg_len:
				# incompleto, aspetta altri byte
				break

			# extract payload
			var payload: PackedByteArray = recv_buffer.slice(4, 4 + msg_len)
			var payload_text: String = payload.get_string_from_utf8()
			_append_output(payload_text)

			var remaining: PackedByteArray = PackedByteArray()
			if recv_buffer.size() > 4 + msg_len:
				remaining = recv_buffer.slice(4 + msg_len, recv_buffer.size())

			recv_buffer = remaining

		_render()


# --------------------
# Appendi output remoto (testo grezzo, non modifica input buffer)
func _append_output(raw: String) -> void:
	# rimuovi o converti sequenze ANSI se vuoi
	var cleaned := _strip_ansi(raw)
	# ensure newline at end? keep as-is
	output_text += cleaned


func _append_output_line(line: String) -> void:
	output_text += line


# --------------------
# RENDER: ricostruisce il testo visualizzato in editor (sempre append-only + prompt+input)
func _render() -> void:
	if not editor:
		return

	var display := output_text + prompt
	# show input with cursor (we render a visible cursor as e.g. underline block)
	# For simplicity we show caret as nothing in the buffer, but we can insert a visual marker
	# Build the input showing cursor position (no coloring)
	if cursor_pos < 0:
		cursor_pos = 0
	if cursor_pos > input_buffer.length():
		cursor_pos = input_buffer.length()

	var left := input_buffer.substr(0, cursor_pos)
	var right := input_buffer.substr(cursor_pos, input_buffer.length() - cursor_pos)
	# you can replace the caret with an underscore or block; keep it invisible and rely on caret position
	# We'll render the input as left + right (no special marker). To help the user, we can show a block:
	var caret := "▮"  # visual caret character
	var rendered_input := left + caret + right

	display += rendered_input

	# Only update editor.text if changed (optim)
	if display != last_rendered_text:
		editor.text = display
		last_rendered_text = display
		# scroll to bottom
		editor.scroll_vertical = editor.get_line_count()


# --------------------
# Handle key events: editing of input_buffer, history, sending
# Returns true if handled
func handle_key(event: InputEventKey) -> bool:
	if not connected:
		return false

	# Only react on pressed events (not release)
	if not event.pressed:
		return false

	# ENTER
	if event.keycode == KEY_ENTER or event.is_action_pressed("ui_accept"):
		_send_line()
		return true

	# BACKSPACE / DEL
	if event.keycode == KEY_BACKSPACE:
		if cursor_pos > 0:
			# remove char before cursor
			var before := input_buffer.substr(0, cursor_pos - 1)
			var after := input_buffer.substr(cursor_pos, input_buffer.length() - cursor_pos)
			input_buffer = before + after
			cursor_pos -= 1
			_render()
		return true

	if event.keycode == KEY_DELETE:
		if cursor_pos < input_buffer.length():
			var before2 := input_buffer.substr(0, cursor_pos)
			var after2 := input_buffer.substr(cursor_pos + 1, input_buffer.length() - (cursor_pos + 1))
			input_buffer = before2 + after2
			_render()
		return true

	# LEFT / RIGHT
	if event.keycode == KEY_LEFT:
		if cursor_pos > 0:
			cursor_pos -= 1
			_render()
		return true
	if event.keycode == KEY_RIGHT:
		if cursor_pos < input_buffer.length():
			cursor_pos += 1
			_render()
		return true

	# UP / DOWN -> history navigation
	if event.keycode == KEY_UP:
		_history_prev()
		return true
	if event.keycode == KEY_DOWN:
		_history_next()
		return true

	## Ctrl-C (SIGINT)
	#if event.control and event.keycode == KEY_C:
	#	_send_ctrl_char(3)  # ^C
	#	return true

	# TAB
	if event.keycode == KEY_TAB:
		# send tab to remote
		_send_raw("\t")
		return true

	# Printable characters (ASCII)
	var uc := event.unicode
	if uc >= 32 and uc < 127:
		# insert at cursor
		var ch := char(uc)
		var before := input_buffer.substr(0, cursor_pos)
		var after := input_buffer.substr(cursor_pos, input_buffer.length() - cursor_pos)
		input_buffer = before + ch + after
		cursor_pos += 1
		_render()
		# send char to remote for interactive echo (optional)
		# We choose to NOT echo locally via server; we show locally and send char to remote
		return true

	return false


# --------------------
func _send_line() -> void:
	# Append line to output_text as user typed and send it
	var line := input_buffer
	output_text += prompt + line + "\n"
	_render()

	# push to history
	if line.strip_edges() != "":
		history.append(line)
	history_index = -1
	input_buffer = ""
	cursor_pos = 0

	# send newline-terminated to server
	_send_raw(line + "\n")
	# give one frame so the UI updates (non-blocking)
	await Engine.get_main_loop().process_frame


# send raw data to socket, honoring length-prefix config
func _send_raw(text: String) -> void:
	if not connected:
		return
	if use_length_prefix:
		# pack 4-byte little endian length + payload
		var payload := text.to_utf8_buffer()
		var L := payload.size()
		var header := PackedByteArray()
		header.resize(4)
		header[0] = L & 0xFF
		header[1] = (L >> 8) & 0xFF
		header[2] = (L >> 16) & 0xFF
		header[3] = (L >> 24) & 0xFF
		var full := PackedByteArray()
		full.append_array(header)
		full.append_array(payload)
		socket.put_data(full)
	else:
		# simple path: let Godot handle encoding and sending
		socket.put_utf8_string(text)
	# Try to flush if available
	if "flush" in socket:
		# StreamPeerTCP doesn't expose flush in GDScript, but keep for completeness
		pass


func _send_ctrl_char(n: int) -> void:
	# send single raw byte with value n
	if not connected:
		return
	var arr := PackedByteArray([n & 0xFF])
	socket.put_data(arr)


# --------------------
# history helpers
func _history_prev() -> void:
	if history.size() == 0:
		return
	if history_index == -1:
		history_index = history.size() - 1
	else:
		history_index = max(0, history_index - 1)
	input_buffer = history[history_index]
	cursor_pos = input_buffer.length()
	_render()

func _history_next() -> void:
	if history.size() == 0:
		return
	if history_index == -1:
		return
	history_index += 1
	if history_index >= history.size():
		history_index = -1
		input_buffer = ""
		cursor_pos = 0
	else:
		input_buffer = history[history_index]
		cursor_pos = input_buffer.length()
	_render()


# --------------------
func _strip_ansi(t: String) -> String:
	var rx = RegEx.new()
	rx.compile("\\x1B(?:[@-Z\\\\-_]|\\[[0-?]*[ -/]*[@-~])")
	return rx.sub(t, "", true)
