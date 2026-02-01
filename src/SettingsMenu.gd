extends Window


signal changed

@onready var show_dests := $M/V/ShowDestsCheck as CheckBox
@onready var show_highlights := $M/V/ShowHighlightsCheck as CheckBox
@onready var sounds := $M/V/SoundsCheck as CheckBox
@onready var sound_check := $M/V/M/V/SoundCheckCheck as CheckBox
@onready var sound_music := $M/V/M/V/SoundMusicCheck as CheckBox


func _ready() -> void:
	hide()
	show_dests.button_pressed = Settings.show_dests
	show_highlights.button_pressed = Settings.show_highlights
	sounds.button_pressed = Settings.sounds
	sound_check.button_pressed = Settings.sound_check
	sound_check.disabled = not Settings.sounds
	sound_music.button_pressed = Settings.sound_music
	sound_music.disabled = not Settings.sounds


func _on_ShowDestsCheck_toggled(button_pressed: bool) -> void:
	Settings.show_dests = button_pressed


func _on_ShowHighlightsCheck_toggled(button_pressed: bool) -> void:
	Settings.show_highlights = button_pressed
	changed.emit()


func _on_SoundsCheck_toggled(button_pressed: bool) -> void:
	Settings.sounds = button_pressed
	sound_check.disabled = not Settings.sounds
	sound_music.disabled = not Settings.sounds


func _on_SoundCheckCheck_toggled(button_pressed: bool) -> void:
	Settings.sound_check = button_pressed


func _on_SoundMusicCheck_toggled(button_pressed: bool) -> void:
	Settings.sound_music = button_pressed
	Global.music_toggled.emit(button_pressed)


func _on_option_button_item_selected(index: int) -> void:
	Settings.bot_difficulty = 1 + index
