extends VBoxContainer
@onready var levelDisplay = $levelDisplay

var level: String = str(0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	updateText()
	
func updateText():
	levelDisplay.text = ("LEVEL: " + level)
