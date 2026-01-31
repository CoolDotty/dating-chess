extends AudioStreamPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var globalSignal = get_node("/root/Global")
	globalSignal.music_toggled.connect(_on_music_toggled)
	if Settings.sound_music:
		play()
		pass # Replace with function body.	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_music_toggled():
	if Settings.sound_music:
		play()
	else:
		stop()
