extends ColorRect

@export var start_black: bool = false

var master_bus_idx: int

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE  # Don't block clicks
	master_bus_idx = AudioServer.get_bus_index("Master")
	
	if start_black:
		color = Color.BLACK
		AudioServer.set_bus_volume_db(master_bus_idx, -80)  # Effectively muted
		await get_tree().create_timer(1.0).timeout
		fade_from_black()
	else:
		color = Color(0, 0, 0, 0)  # Start transparent

func fade_to_black(duration: float = 1.0) -> void:
	var tween = create_tween()
	tween.set_parallel(true)  # Run both tweens simultaneously
	tween.tween_property(self, "color:a", 1.0, duration)
	tween.tween_method(set_audio_volume, 0.0, -80.0, duration)
	await tween.finished

func fade_from_black(duration: float = 1.0) -> void:
	var tween = create_tween()
	tween.set_parallel(true)  # Run both tweens simultaneously
	tween.tween_property(self, "color:a", 0.0, duration)
	tween.tween_method(set_audio_volume, -80.0, 0.0, duration)
	await tween.finished

func set_audio_volume(db: float) -> void:
	AudioServer.set_bus_volume_db(master_bus_idx, db)
