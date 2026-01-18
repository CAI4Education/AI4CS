extends HSlider

#Deve avere lo stesso nome che il bus nelle opzioni audio sotto (case sensistive)
@export var audioBusName: String
var audioBusId
#valore minimo sicuro
const MIN_LINEAR := 0.001

func _ready():
	audioBusId = AudioServer.get_bus_index(audioBusName)
	# inizializza slider in base al salvataggio
	value = GameState.master_volume
	_apply_volume(value)

func _on_value_changed(value: float) -> void:
	GameState.master_volume = value
	_apply_volume(value)
	GameState.save_settings()


func _apply_volume(value: float):
	if value <= 0.0:
		AudioServer.set_bus_mute(audioBusId, true)
	else:
		AudioServer.set_bus_mute(audioBusId, false)
		#per convertire suono lineare a db (in pratica l'orecchio percepisce l'abbassamento del suono non in maniera lineare)
		AudioServer.set_bus_volume_db(
			audioBusId,
			linear_to_db(max(value, MIN_LINEAR))
		)
