extends Control

#Riferimento al Editor Text Nodo
@onready var editor = $Grid/TopRightEditor

# Oggetto principale per la comunicazione di rete TCP.
var socket: StreamPeerTCP
# Flag per tracciare lo stato della connessione al bridge Python.
var connected := false

# Buffer locale per accumulare i caratteri digitati dall'utente (il comando corrente).
# È cruciale perché l'input è inviato carattere per carattere.
var input_buffer := ""

# Stringa che memorizza l'ultimo prompt ricevuto (es. "root@host:~# ").
# Usato per mantenere l'interfaccia coerente dopo l'output.
var last_prompt := ""

# ======= Inizializzazione e Connessione =======

func _ready():
	# Inizializza l'oggetto socket.
	socket = StreamPeerTCP.new()
	
	# **IMPOSTAZIONE CHIAVE:** Disabilita l'editing automatico di TextEdit.
	# Questo è fondamentale per prevenire il 'doppio eco'. Il tuo codice gestirà
	# manualmente la visualizzazione dei caratteri digitati in '_input'.
	editor.editable = false
	
	# Richiede il focus al TextEdit per catturare gli eventi della tastiera.
	editor.grab_focus()
	
	# Avvia il tentativo di connessione.
	connect_to_bridge()
	
	# Abilita la funzione _process per monitorare il socket e il tempo.
	set_process(true)

func connect_to_bridge():
	print("[Godot] Connecting…")
	# Tenta di connettersi al bridge Python in esecuzione in locale.
	socket.connect_to_host("127.0.0.1", 5000)

# ======= Loop Principale (Gestione Rete e Output) =======

func _process(delta):
	# Necessario chiamare poll() regolarmente per aggiornare lo stato del socket 
	# e permettere la ricezione dei dati.
	socket.poll()

	# --- Controllo dello Stato di Connessione ---
	if not connected and socket.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		connected = true
		print("[Godot] Connected!")
		# Disabilita il ritardo di Nagle per un'interazione più reattiva (meno latenza).
		socket.set_no_delay(true)
		editor.text += ">>> Connected to SSH bridge\n"
		scroll_to_bottom()

	# --- Gestione Output SSH ---
	if connected:
		# Controlla se ci sono byte disponibili da leggere nel buffer TCP.
		var avail = socket.get_available_bytes()
		if avail > 0:
			# Legge tutti i byte disponibili e li decodifica in stringa UTF-8.
			var raw = socket.get_utf8_string(avail)
			
			# Rimuove le sequenze di escape ANSI/CSI (codici colore, movimento cursore)
			# che altrimenti apparirebbero come caratteri strani nell'editor.
			var cleaned = strip_ansi(raw)

			# --- Rilevamento e Salvataggio del Prompt ---
			# Compila un'espressione regolare per identificare il prompt tipico della shell 
			# (es. user@host:path# o $).
			var rx := RegEx.new()
			rx.compile("([a-zA-Z0-9_]+@[a-zA-Z0-9_\\-]+:.*[#\\$]) *$")
			var m = rx.search(cleaned)
			if m:
				# Salva il prompt trovato, necessario per le operazioni di storia/refresh.
				last_prompt = m.get_string(0)

			# Aggiunge un a capo prima dell'output se necessario, per assicurare che 
			# l'output inizi su una nuova riga e mantenga separato il prompt precedente.
			editor.text += "\n"+ cleaned
			scroll_to_bottom() # Mantiene l'interfaccia visualizzata in fondo.

# ======= Gestione Input (Tastiera) =======

func _input(event):
	# Controlli di guardia: se non connesso o non focalizzato o non è una pressione di tasto, ignora.
	if not connected: return
	if not editor.has_focus(): return
	if not (event is InputEventKey and event.pressed): return

	# =======================
	#       ENTER
	# =======================
	if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
		# 1. Invia il segnale di "fine riga" (Newline) al TTY remoto.
		# La shell remota, che ha già il comando nel suo buffer (ricevuto carattere per carattere), 
		# eseguirà il contenuto del buffer.
		socket.put_utf8_string("\n")
		
		# 2. Resetta il buffer locale.
		input_buffer = ""
		
		# 3. Aspetta il frame successivo per assicurare che l'input sia gestito 
		# prima di forzare lo scroll.
		await get_tree().process_frame
		scroll_to_bottom()
		
		# 4. Indica a Godot che l'evento è stato gestito e non deve propagarsi altrove.
		get_viewport().set_input_as_handled()
		return


	# =======================
	#      BACKSPACE
	# =======================
	if event.keycode == KEY_BACKSPACE:

		# 1) Cancella l'ultimo carattere dal buffer locale.
		if input_buffer.length() > 0:
			input_buffer = input_buffer.substr(0, input_buffer.length() - 1)

			# 2) Cancella l'ultimo carattere dall'interfaccia TextEdit (Eco locale).
			if editor.text.length() > 0:
				# Rimuove l'ultimo carattere visualizzato (il carattere digitato).
				editor.text = editor.text.substr(0, editor.text.length() - 1)

		# 3) Invia il codice di controllo BACKSPACE/DELETE (0x7F) al TTY remoto.
		# Questo codice dice alla shell remota di cancellare l'ultimo carattere nel suo buffer.
		var bs = PackedByteArray([0x7f])
		socket.put_data(bs)

		await get_tree().process_frame
		scroll_to_bottom()
		get_viewport().set_input_as_handled()
		return


	# =======================
	#   CARATTERI NORMALI
	# =======================
	# Filtra solo i caratteri ASCII stampabili (Codice Unicode da 32 a 126).
	var unicode = event.unicode

	if unicode >= 32 and unicode < 127:
		var ch := char(unicode) # Converte il codice Unicode in Stringa.

		# 1) Aggiorna il buffer interno.
		input_buffer += ch

		# 2) MOSTRA il carattere nell'editor (Eco locale).
		editor.text += ch

		# 3) Invia il carattere singolo al TTY remoto.
		# La shell lo riceve e lo aggiunge al suo buffer in attesa di INVIO.
		socket.put_utf8_string(ch)

		await get_tree().process_frame
		scroll_to_bottom()
		get_viewport().set_input_as_handled()
		return


# ======= Funzioni di Supporto =======

func scroll_to_bottom():
	# Forzare lo scroll verticale all'ultima riga del TextEdit.
	editor.scroll_vertical = editor.get_line_count()

func strip_ansi(t:String) -> String:
	# Funzione per rimuovere le sequenze di controllo ANSI/CSI (codici terminale).
	var rx = RegEx.new()
	# Espressione regolare che cattura la sequenza di escape \x1B seguita dai 
	# codici di controllo tipici del terminale (VT100/XTerm).
	rx.compile("\\x1B(?:[@-Z\\\\-_]|\\[[0-?]*[ -/]*[@-~])")
	# Sostituisce tutte le occorrenze con una stringa vuota.
	return rx.sub(t, "", true)
