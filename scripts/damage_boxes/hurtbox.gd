class_name Hurtbox extends Area2D

signal hurt(hitbox: Hitbox)

func _read() -> void:
	area_entered.connect(_on_area_entered)
	
func _on_area_entered(area_2d: Area2D) -> void:
	if area_2d is not Hitbox: return
	print("funziona")
	hurt.emit(area_2d)
