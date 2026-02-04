extends AudioStreamPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var globalSignal = get_node("/root/Global")
	globalSignal.music_toggled.connect(_on_music_toggled)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_music_toggled(playing : bool) -> void:
	if playing:
		play()
	else:
		stop()
