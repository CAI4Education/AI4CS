extends PanelContainer

@onready var search_input: LineEdit = $VBoxContainer/SearchBar/SearchInput
@onready var man_viewer: TextEdit = $VBoxContainer/ManViewer

const MAN_FILE := "res://assets/tools/manCommands.txt"

var man_pages: Dictionary = {}

func _ready():
	man_viewer.editable = false
	search_input.text_submitted.connect(_on_search_submitted)

	_load_man_pages()


# -----------------------
# LOAD + PARSE FILE
# -----------------------
func _load_man_pages() -> void:
	var file := FileAccess.open(MAN_FILE, FileAccess.READ)
	if file == null:
		man_viewer.text = "man command text file not here"
		return

	var content := file.get_as_text()
	file.close()

	_parse_man_file(content)


func _parse_man_file(text: String) -> void:
	man_pages.clear()

	var sections := text.split("###", false)

	for section in sections:
		section = section.strip_edges()
		if section == "":
			continue

		var lines := section.split("\n", false)
		if lines.size() == 0:
			continue

		var command := lines[0].strip_edges().to_lower()
		var body := section.substr(command.length()).strip_edges()

		man_pages[command] = body


# -----------------------
# SEARCH
# -----------------------
func _on_search_submitted(text: String) -> void:
	var cmd := text.strip_edges().to_lower()

	if cmd == "":
		return

	if man_pages.has(cmd):
		man_viewer.text = man_pages[cmd]
	else:
		man_viewer.text = "Command not found"
