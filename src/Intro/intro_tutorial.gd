extends Node2D

const GAME = preload("uid://cw1fs4vp0p4tm")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Dialogic.start("IntroTimeline") # Replace with function body.
	Dialogic.timeline_ended.connect(_timeline_ended)


func _timeline_ended():
	await $"Fade out".fade_to_black()
	get_tree().change_scene_to_packed(GAME)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
